"""
Vercel Serverless 入口
将 FastAPI 应用适配为 Vercel Serverless 函数
"""

from mangum import Mangum
from app.main import app

handler = Mangum(app, lifespan="off")
