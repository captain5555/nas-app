---
name: NAS 素材管理系统设计文档
description: 双端同步素材管理系统完整设计规格
type: design
---

# NAS 素材管理系统设计文档

## 项目概述

私有 NAS 素材管理工具，支持 iOS 移动端 + PC 桌面端双端同步，数据存储在用户私有 NAS（WebDAV 协议），不上传任何公有云。

### 核心特性
- 素材标题/文案编辑
- 双标签体系：未使用/使用过、未爆/爆款
- 文件夹管理
- 上传、预览、筛选、搜索
- iOS 端 + PC 端完全互通，数据实时同步

## 技术栈

| 端 | 技术栈 |
|---|--------|
| iOS 移动端 | Swift + SwiftUI, iOS 16+, Core Data |
| PC 桌面端 | Flutter (Dart), Windows + macOS, Hive |
| 协议 | WebDAV |
| 架构 | MVVM |

## NAS 文件结构

```
NAS共享目录/
├── .sync_version                    # 同步版本时间戳
├── .material_index.json             # 根目录索引
├── 文件夹A/
│   ├── .material_index.json
│   ├── 图片1.jpg
│   └── 视频1.mp4
└── 文件夹B/
    └── .material_index.json
```

## JSON 文件格式

### .sync_version
简单文本文件，内容为 ISO 8601 时间戳（**一律使用 UTC 时间，后缀 Z**）：
```
2026-03-27T10:30:00Z
```

### 重要约定
- **所有时间戳使用 UTC**，格式：`yyyy-MM-dd'T'HH:mm:ss'Z'`
- **文件名编码**：UTF-8，支持非 ASCII 字符
- **文件夹表示**：每个文件夹有自己的 `.material_index.json`，子文件夹不在索引中列出，通过 WebDAV 单独遍历

### .material_index.json
```json
{
  "version": 1,
  "updated_at": "2026-03-27T10:30:00Z",
  "files": {
    "文件名.jpg": {
      "title": "自定义标题",
      "description": "描述文案",
      "tags": {
        "usage": "used",
        "viral": "viral"
      },
      "updated_at": "2026-03-27T10:25:00Z",
      "file_size": 2150400,
      "file_modified_at": "2026-03-20T15:00:00Z"
    }
  }
}
```

### 标签枚举
- `usage`: `"unused"` (未使用) | `"used"` (使用过)
- `viral`: `"not_viral"` (未爆) | `"viral"` (爆款)

## 同步机制

### 简化流程
1. **一端修改** → 更新 NAS 上的 `.material_index.json` → 触碰 `.sync_version`
2. **另一端** → 每 45 秒检查 `.sync_version` → 发现变化 → 下载索引 → 更新本地

### 冲突解决
最后写入 wins（比较 `updated_at` 时间戳）

## 项目结构

```
nas-material-manager/
├── ios/                    # iOS 项目
├── flutter/                # Flutter 桌面项目
├── docs/                   # 文档
└── shared/                 # 共享规范文档
```

## 功能模块

### 1. NAS 连接登录
- 输入 WebDAV 地址、账号、密码
- 保存配置，自动重连

### 2. 素材浏览
- 图片 + 视频网格/列表
- 文件夹导航
- 显示标签徽章

### 3. 素材管理
- 编辑标题、文案
- 设置使用状态、爆款标签
- 双端自动同步

### 4. 筛选搜索
- 按标签筛选
- 搜索标题、文案

### 5. 文件操作
- 上传、下载
- 预览
- 新建文件夹、重命名、删除

### 6. 设置
- NAS 配置
- 缓存清理
