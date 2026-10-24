# PikPak iOS Client

一个基于 SwiftUI 的 PikPak 第三方 iOS 客户端，后端代理部署在 Vercel 上。

## 项目结构

```
PikPak/
├── backend/                 # Vercel 后端 API
│   ├── api/
│   │   └── index.py        # Vercel Serverless 入口
│   ├── app/
│   │   ├── main.py         # FastAPI 主应用
│   │   └── core/
│   │       └── pikpak.py    # PikPak API 封装
│   ├── requirements.txt     # Python 依赖
│   └── vercel.json          # Vercel 配置
│
├── ios/                     # iOS App 源码
│   └── PikPakClient/
│       ├── PikPakClientApp.swift  # App 入口
│       ├── Models/
│       │   └── Models.swift       # 数据模型
│       ├── Services/
│       │   ├── APIService.swift   # API 请求层
│       │   └── AuthManager.swift # 认证管理
│       └── Views/
│           ├── LoginView.swift      # 登录页
│           ├── FileListView.swift    # 文件列表主界面
│           ├── UploadMenuView.swift # 上传菜单
│           ├── OfflineDownloadView.swift # 离线下载
│           ├── TasksView.swift       # 任务列表
│           └── Components/
│               └── FileRowView.swift # 文件行组件
│
└── README.md               # 本文件
```

---

## 一、部署 Vercel 后端

### 前置要求
- GitHub 账号
- Vercel 账号（可以用 GitHub 登录）

### 部署步骤

1. **上传代码到 GitHub**
   - 新建一个仓库（比如命名为 `pikpak-proxy`）
   - 将 `backend/` 目录下的所有文件上传到仓库根目录

2. **在 Vercel 导入项目**
   - 登录 [Vercel](https://vercel.com)
   - 点击 "Add New Project"
   - 选择你刚创建的 GitHub 仓库
   - 保持默认配置，点击 "Deploy"

3. **等待部署完成**
   - 部署成功后，你会得到一个域名，比如 `https://pikpak-proxy.vercel.app`
   - 访问 `https://你的域名/` 应该能看到健康检查返回的 JSON

4. **测试 API**
   ```bash
   # 测试登录接口
   curl -X POST https://你的域名/api/login \
     -H "Content-Type: application/json" \
     -d '{"username":"你的账号","password":"你的密码"}'
   ```

---

## 二、配置 iOS App

### 修改 API 地址

打开 `ios/PikPakClient/Services/APIService.swift`，修改 `baseURL`：

```swift
let baseURL = "https://你的项目.vercel.app"  // 替换为你的 Vercel 域名
```

### 功能说明

#### 已实现功能
- ✅ PikPak 账号登录（账号密码）
- ✅ 文件/文件夹列表浏览
- ✅ 文件夹导航（进入/返回）
- ✅ 右上角加号上传菜单
- ✅ 从相册选择照片上传
- ✅ 离线下载（磁力链 / HTTP 链接）
- ✅ 下载任务列表（自动刷新）
- ✅ Token 本地持久化存储

#### 待完善功能
- ⏳ 大文件直传（Vercel Serverless 有请求体大小限制）
- ⏳ 视频在线播放
- ⏳ 文件搜索
- ⏳ 多文件选择上传

---

## 三、打包 IPA

### 方式一：Xcode 直接构建（推荐）

1. **在 Mac 上安装 Xcode**
   - 从 App Store 安装 Xcode

2. **创建 Xcode 项目**
   - 新建 iOS App 项目，命名为 `PikPakClient`
   - 界面选择 SwiftUI
   - 语言选择 Swift

3. **导入源码**
   - 将 `ios/PikPakClient/` 目录下的所有 `.swift` 文件拖入 Xcode 项目
   - 确保勾选 "Copy items if needed"

4. **配置签名**
   - 选择你的开发者账号
   - 设置 Bundle Identifier（比如 `com.yourname.pikpak`）

5. **构建运行**
   - 连接 iPhone 或选择模拟器
   - 点击 Run 按钮

### 方式二：使用 TrollStore 侧载

如果没有开发者账号，可以使用 TrollStore 安装 IPA：
1. 在有 Mac 的环境下用 Xcode 构建 IPA
2. 使用 TrollStore 安装到越狱/支持的设备上

### 方式三：使用 AltStore 侧载
1. 用 Xcode 构建 IPA
2. 通过 AltStore 安装到非越狱设备

---

## 四、API 接口文档

| 接口 | 方法 | 说明 |
|------|------|------|
| `/` | GET | 健康检查 |
| `/api/login` | POST | 账号登录 |
| `/api/refresh` | POST | 刷新 Token |
| `/api/files` | GET | 文件列表 |
| `/api/folder` | POST | 创建文件夹 |
| `/api/offline-download` | POST | 添加离线下载 |
| `/api/tasks` | GET | 任务列表 |
| `/api/file/{id}` | GET | 文件详情 |

---

## 五、注意事项

### 安全提示
- 后端部署在 Vercel 上，所有请求都经过你的 Vercel 实例转发
- PikPak 账号密码只在登录时传输一次，之后只保存 token 在本地
- 建议不要在公共设备上勾选"记住登录"

### Vercel 限制
- Serverless 函数执行时间限制：30 秒
- 请求体大小限制：4.5 MB
- 大文件上传建议后续改为客户端直传

### 免责声明
- 本项目仅供学习交流使用
- 请遵守 PikPak 用户协议
- 使用本项目产生的一切后果由使用者自行承担
