# NAS 素材管理系统 v3

一个功能完善的素材管理系统，支持多用户、素材上传、分类管理、备份恢复等功能。

## 功能特性

- 用户认证与权限管理
- 素材上传与管理（图片、视频等）
- 缩略图自动生成
- 文件夹分类
- 垃圾箱功能
- 批量操作
- 管理后台
- 操作日志
- 数据备份
- 支持 SQLite/PostgreSQL 数据库
- 支持本地存储/阿里云 OSS

## 快速开始

### Windows 用户

双击运行 `启动.bat`

### Linux/Mac 用户

```bash
chmod +x start.sh
./start.sh
```

### Docker

```bash
docker-compose up -d
```

### 手动启动

```bash
cd backend
cp .env.example .env
npm install
npm start
```

## 默认账号

- 用户名: `admin`
- 密码: `admin123`

**重要：请在首次登录后立即修改密码！**

## 访问地址

- 用户端: http://localhost:3000
- 管理后台: http://localhost:3000/admin.html

## 项目结构

```
nas-material-manager-v3/
├── backend/
│   ├── src/
│   │   ├── config/          # 配置文件
│   │   ├── db/              # 数据库层
│   │   ├── storage/         # 存储层
│   │   ├── middleware/      # 中间件
│   │   ├── routes/          # API 路由
│   │   ├── services/        # 服务
│   │   ├── utils/           # 工具函数
│   │   └── server.js        # 服务器入口
│   ├── package.json
│   └── .env.example
├── frontend/
│   └── public/              # 前端文件
├── data/                    # 数据目录
├── Dockerfile
├── docker-compose.yml
├── start.sh
└── 启动.bat
```

## 配置说明

编辑 `backend/.env` 文件：

```env
PORT=3000
NODE_ENV=development
DATABASE_TYPE=sqlite
STORAGE_TYPE=local
JWT_SECRET=your-secret-key-change-in-production
```

## 技术栈

- 后端: Node.js + Express
- 数据库: SQLite (默认) / PostgreSQL
- 前端: 原生 JavaScript
- 图片处理: Sharp
- 认证: JWT

## 许可证

MIT
