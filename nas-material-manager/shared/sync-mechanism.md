# 同步机制规范

## 轮询间隔

45 秒

## 同步流程

1. 检查 .sync_version 修改时间
2. 如果有变化，从根目录开始递归下载 .material_index.json
3. 合并到本地数据库（最后写入 wins）

## 本地修改流程

1. 更新本地数据库
2. 更新文件夹的 .material_index.json
3. 上传到 NAS
4. 触碰 .sync_version（更新修改时间）
