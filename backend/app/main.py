"""
PikPak Vercel 代理 API
所有 PikPak 请求都通过此后端转发，避免 CORS 和密钥泄露
"""

from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Optional

from app.core import pikpak


app = FastAPI(
    title="PikPak Proxy API",
    description="PikPak 代理服务 - 部署在 Vercel 上的中间层",
    version="1.0.0",
)

# CORS 配置 - 允许所有来源（iOS App 没有域名限制）
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============ 请求模型 ============

class LoginRequest(BaseModel):
    username: str
    password: str


class RefreshTokenRequest(BaseModel):
    refresh_token: str


class CreateFolderRequest(BaseModel):
    name: str
    parent_id: str = "root"


class OfflineDownloadRequest(BaseModel):
    url: str
    parent_id: str = "root"
    name: Optional[str] = None


# ============ API 路由 ============

@app.get("/")
def root():
    """健康检查"""
    return {
        "service": "PikPak Proxy API",
        "status": "running",
        "version": "1.0.0"
    }


@app.post("/api/login")
def api_login(req: LoginRequest):
    """
    PikPak 账号登录
    返回 access_token 和 refresh_token
    """
    try:
        result = pikpak.login(req.username, req.password)
        return result
    except pikpak.TokenExpiredError as e:
        raise HTTPException(status_code=401, detail=str(e))
    except pikpak.PikPakError as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/api/refresh")
def api_refresh(req: RefreshTokenRequest):
    """刷新 access_token"""
    try:
        result = pikpak.refresh_token(req.refresh_token)
        return result
    except pikpak.TokenExpiredError as e:
        raise HTTPException(status_code=401, detail=str(e))
    except pikpak.PikPakError as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/api/files")
def api_list_files(
    access_token: str,
    parent_id: str = "root",
    limit: int = 50,
    cursor: Optional[str] = None
):
    """获取文件/文件夹列表"""
    try:
        result = pikpak.list_files(
            access_token=access_token,
            parent_id=parent_id,
            limit=limit,
            cursor=cursor
        )
        return result
    except pikpak.TokenExpiredError as e:
        raise HTTPException(status_code=401, detail=str(e))
    except pikpak.PikPakError as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/api/folder")
def api_create_folder(req: CreateFolderRequest, access_token: str):
    """创建新文件夹"""
    try:
        result = pikpak.create_folder(
            access_token=access_token,
            name=req.name,
            parent_id=req.parent_id
        )
        return result
    except pikpak.TokenExpiredError as e:
        raise HTTPException(status_code=401, detail=str(e))
    except pikpak.PikPakError as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/api/offline-download")
def api_offline_download(req: OfflineDownloadRequest, access_token: str):
    """
    添加离线下载任务
    支持磁力链、HTTP/HTTPS 直链
    """
    try:
        result = pikpak.add_offline_download(
            access_token=access_token,
            url=req.url,
            parent_id=req.parent_id,
            name=req.name
        )
        return result
    except pikpak.TokenExpiredError as e:
        raise HTTPException(status_code=401, detail=str(e))
    except pikpak.PikPakError as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/api/tasks")
def api_list_tasks(access_token: str, limit: int = 20):
    """获取离线下载任务列表"""
    try:
        result = pikpak.list_tasks(access_token=access_token, limit=limit)
        return result
    except pikpak.TokenExpiredError as e:
        raise HTTPException(status_code=401, detail=str(e))
    except pikpak.PikPakError as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/api/file/{file_id}")
def api_file_detail(file_id: str, access_token: str):
    """获取文件详情"""
    try:
        result = pikpak.get_file_detail(access_token=access_token, file_id=file_id)
        return result
    except pikpak.TokenExpiredError as e:
        raise HTTPException(status_code=401, detail=str(e))
    except pikpak.PikPakError as e:
        raise HTTPException(status_code=400, detail=str(e))


# ============ 异常处理 ============

@app.exception_handler(404)
async def not_found_handler(request: Request, exc: HTTPException):
    return JSONResponse(
        status_code=404,
        content={"success": False, "error": "接口不存在"}
    )
