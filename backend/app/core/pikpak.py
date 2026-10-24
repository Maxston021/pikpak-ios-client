"""
PikPak API 封装模块
支持登录、文件列表、上传、离线下载、任务查询
"""

import hashlib
import requests
import time
import uuid
import json
from typing import Optional, Dict, List, Any


class PikPakError(Exception):
    """PikPak API 基础异常"""
    def __init__(self, message: str, code: int = 0):
        self.message = message
        self.code = code
        super().__init__(self.message)


class TokenExpiredError(PikPakError):
    """access_token 已过期，需要刷新"""
    pass


# PikPak API 端点
LOGIN_URL = "https://user.mypikpak.com/v1/auth/signin"
REFRESH_URL = "https://user.mypikpak.com/v1/auth/token"
FILES_URL = "https://api-drive.mypikpak.com/drive/v1/files"
TASKS_URL = "https://api-drive.mypikpak.com/drive/v1/tasks"
UPLOAD_URL = "https://api-drive.mypikpak.com/drive/v1/files:upload"

# PikPak Android 客户端凭证
CLIENT_ID = "YNxT9w7GMdWvEOKa"
CLIENT_SECRET = "dbw2OtmVEeuUvIptb1Coyg"
CLIENT_VERSION = "1.21.0"
PACKAGE_NAME = "com.pikcloud.pikpak"

# Android 端签名算法 salt 列表
WEB_ALGORITHMS = [
    "",
    "E32cSkYXC2bciKJGxRsE8ZgwmH/YwkvpD6/O9guSOa2irCwciH4xPHaH",
    "QtqgfMgHP2TFl",
    "zOKgHT56L7nIzFzDpUGhpWFrgP53m3G6ML",
    "S",
    "THxpsktzfFXizUv7DK1y/N7NZ1WhayViluBEvAJJ8bA1Wr6",
    "y9PXH3xGUhG/zQI8CaapRw2LhldCaFM9CRlKpZXJvj+pifu",
    "+RaaG7T8FRTI4cP019N5y9ofLyHE9ySFUr",
    "6Pf1l8UTeuzYldGtb/d",
]

# 固定设备 ID
DEFAULT_DEVICE_ID = "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6"


def _get_headers(access_token: Optional[str] = None, device_id: Optional[str] = None) -> Dict[str, str]:
    """生成请求头"""
    headers = {
        "User-Agent": f"PikPak/{CLIENT_VERSION} (Linux; Android 12; {PACKAGE_NAME})",
        "Content-Type": "application/json",
        "x-device-id": device_id or DEFAULT_DEVICE_ID,
        "x-client-version": CLIENT_VERSION,
        "x-platform": "android",
    }
    if access_token:
        headers["Authorization"] = f"Bearer {access_token}"
    return headers


def login(username: str, password: str) -> Dict[str, Any]:
    """
    PikPak 账号登录
    返回 access_token, refresh_token, user_info
    """
    device_id = DEFAULT_DEVICE_ID
    
    payload = {
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "username": username,
        "password": password,
        "grant_type": "password",
        "scope": "offline_access",
    }
    
    try:
        resp = requests.post(
            LOGIN_URL,
            json=payload,
            headers=_get_headers(device_id=device_id),
            timeout=15
        )
        
        if resp.status_code == 200:
            data = resp.json()
            return {
                "success": True,
                "access_token": data.get("access_token"),
                "refresh_token": data.get("refresh_token"),
                "token_type": data.get("token_type", "Bearer"),
                "expires_in": data.get("expires_in", 7200),
                "user": {
                    "sub": data.get("sub"),
                    "name": data.get("name", username),
                    "email": data.get("email", username),
                }
            }
        else:
            error_data = resp.json() if resp.text else {}
            error_msg = error_data.get("error_description", error_data.get("error", f"登录失败: {resp.status_code}"))
            raise PikPakError(error_msg, code=resp.status_code)
            
    except requests.RequestException as e:
        raise PikPakError(f"网络请求失败: {str(e)}")


def refresh_token(refresh_token: str) -> Dict[str, Any]:
    """刷新 access_token"""
    payload = {
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "refresh_token": refresh_token,
        "grant_type": "refresh_token",
    }
    
    try:
        resp = requests.post(
            REFRESH_URL,
            json=payload,
            headers=_get_headers(),
            timeout=15
        )
        
        if resp.status_code == 200:
            data = resp.json()
            return {
                "success": True,
                "access_token": data.get("access_token"),
                "refresh_token": data.get("refresh_token", refresh_token),
                "expires_in": data.get("expires_in", 7200),
            }
        else:
            raise TokenExpiredError("刷新令牌失败，请重新登录")
            
    except requests.RequestException as e:
        raise PikPakError(f"网络请求失败: {str(e)}")


def list_files(
    access_token: str,
    parent_id: str = "root",
    limit: int = 50,
    cursor: Optional[str] = None,
    sort_by: str = "created_at",
    sort_order: str = "desc"
) -> Dict[str, Any]:
    """
    获取文件/文件夹列表
    """
    params = {
        "parent_id": parent_id,
        "limit": limit,
        "with_trashed": False,
        "sort_order": sort_order,
        "sort_by": sort_by,
    }
    if cursor:
        params["cursor"] = cursor
    
    try:
        resp = requests.get(
            FILES_URL,
            params=params,
            headers=_get_headers(access_token),
            timeout=15
        )
        
        if resp.status_code == 200:
            data = resp.json()
            files = []
            for item in data.get("files", []):
                files.append({
                    "id": item.get("id"),
                    "name": item.get("name"),
                    "kind": item.get("kind"),  # folder / file
                    "mime_type": item.get("mimeType", ""),
                    "size": item.get("size", 0),
                    "created_at": item.get("created_at"),
                    "modified_at": item.get("modified_at"),
                    "parent_id": item.get("parent_id"),
                    "thumbnail": item.get("thumbnail", ""),
                    "mime_type": item.get("mimeType", ""),
                })
            
            return {
                "success": True,
                "files": files,
                "next_cursor": data.get("next_cursor"),
                "percent_complete": data.get("percent_complete"),
            }
        elif resp.status_code == 401:
            raise TokenExpiredError("访问令牌已过期")
        else:
            raise PikPakError(f"获取文件列表失败: {resp.status_code}")
            
    except requests.RequestException as e:
        raise PikPakError(f"网络请求失败: {str(e)}")


def create_folder(access_token: str, name: str, parent_id: str = "root") -> Dict[str, Any]:
    """创建新文件夹"""
    payload = {
        "kind": "folder",
        "name": name,
        "parent_id": parent_id,
    }
    
    try:
        resp = requests.post(
            FILES_URL,
            json=payload,
            headers=_get_headers(access_token),
            timeout=15
        )
        
        if resp.status_code in (200, 201):
            data = resp.json()
            return {
                "success": True,
                "file": {
                    "id": data.get("id"),
                    "name": data.get("name"),
                    "kind": "folder",
                }
            }
        elif resp.status_code == 401:
            raise TokenExpiredError("访问令牌已过期")
        else:
            raise PikPakError(f"创建文件夹失败: {resp.status_code}")
            
    except requests.RequestException as e:
        raise PikPakError(f"网络请求失败: {str(e)}")


def add_offline_download(
    access_token: str,
    url: str,
    parent_id: str = "root",
    name: Optional[str] = None
) -> Dict[str, Any]:
    """
    添加离线下载任务（磁力链/HTTP链接）
    """
    payload = {
        "kind": "drive#file",
        "upload_type": "resumable",
        "url": url,
        "parent_id": parent_id,
    }
    if name:
        payload["name"] = name
    
    try:
        resp = requests.post(
            f"{FILES_URL}:upload",
            json=payload,
            headers=_get_headers(access_token),
            timeout=15
        )
        
        if resp.status_code in (200, 201):
            data = resp.json()
            return {
                "success": True,
                "task_id": data.get("id"),
                "file_id": data.get("file", {}).get("id"),
                "name": data.get("file", {}).get("name", name),
            }
        elif resp.status_code == 401:
            raise TokenExpiredError("访问令牌已过期")
        else:
            error_data = resp.json() if resp.text else {}
            raise PikPakError(f"添加离线下载失败: {error_data.get('error', resp.status_code)}")
            
    except requests.RequestException as e:
        raise PikPakError(f"网络请求失败: {str(e)}")


def list_tasks(access_token: str, limit: int = 20) -> Dict[str, Any]:
    """获取离线下载任务列表"""
    params = {"limit": limit}
    
    try:
        resp = requests.get(
            TASKS_URL,
            params=params,
            headers=_get_headers(access_token),
            timeout=15
        )
        
        if resp.status_code == 200:
            data = resp.json()
            tasks = []
            for item in data.get("tasks", []):
                tasks.append({
                    "id": item.get("id"),
                    "name": item.get("name"),
                    "status": item.get("status"),  # PENDING / RUNNING / COMPLETED / ERROR
                    "progress": item.get("progress", 0),
                    "type": item.get("type"),
                    "created_at": item.get("created_at"),
                })
            
            return {
                "success": True,
                "tasks": tasks,
            }
        elif resp.status_code == 401:
            raise TokenExpiredError("访问令牌已过期")
        else:
            raise PikPakError(f"获取任务列表失败: {resp.status_code}")
            
    except requests.RequestException as e:
        raise PikPakError(f"网络请求失败: {str(e)}")


def get_file_detail(access_token: str, file_id: str) -> Dict[str, Any]:
    """获取文件详情"""
    try:
        resp = requests.get(
            f"{FILES_URL}/{file_id}",
            headers=_get_headers(access_token),
            timeout=15
        )
        
        if resp.status_code == 200:
            data = resp.json()
            return {
                "success": True,
                "file": {
                    "id": data.get("id"),
                    "name": data.get("name"),
                    "kind": data.get("kind"),
                    "size": data.get("size", 0),
                    "mime_type": data.get("mimeType", ""),
                    "media_type": data.get("media_type", ""),
                    "thumbnail": data.get("thumbnail", ""),
                    "web_content_link": data.get("web_content_link", ""),
                    "created_at": data.get("created_at"),
                }
            }
        elif resp.status_code == 401:
            raise TokenExpiredError("访问令牌已过期")
        else:
            raise PikPakError(f"获取文件详情失败: {resp.status_code}")
            
    except requests.RequestException as e:
        raise PikPakError(f"网络请求失败: {str(e)}")
