# WebDAV 协议操作规范

## 支持的 WebDAV 方法

- PROPFIND - 列出目录内容
- GET - 下载文件
- PUT - 上传文件
- DELETE - 删除文件
- MKCOL - 创建文件夹
- PROPPATCH - 更新属性（可选）

## 请求头

```
Authorization: Basic {base64(username:password)}
Content-Type: application/json (for JSON files)
Depth: 1 (for PROPFIND)
```
