---
name: Flutter App 功能增强设计文档
description: 为 Flutter NAS 素材管理应用添加视频播放、用户管理入口和复制/移动素材功能
type: design
---

# Flutter App 功能增强设计文档

**日期**: 2026-04-18
**项目**: nas-material-manager-v3
**目标**: Flutter App 功能增强，与 Web 版本对齐

---

## 概述

本文档描述了 Flutter NAS 素材管理应用的三个功能增强：
1. 视频播放功能
2. 用户管理入口
3. 复制/移动素材功能

这些功能旨在使 Flutter 版本与 Web 版本功能对齐。

---

## 阶段 1：视频播放功能

### 功能描述
在素材详情页中集成视频播放器，使用户可以直接在应用内观看视频素材。

### 技术方案
- 使用已有的 `video_player` 依赖（pubspec.yaml 中已包含）
- 在 `MaterialDetailScreen` 中添加视频播放器组件
- 仅在 `material.isVideo` 为 true 时显示播放器

### 实现细节

#### 1. 状态管理
在 `_MaterialDetailScreenState` 中添加：
```dart
VideoPlayerController? _videoController;
bool _isVideoInitialized = false;
bool _isVideoError = false;
```

#### 2. 初始化视频播放器
在 `initState` 中：
- 如果是视频素材，获取媒体 URL
- 初始化 `VideoPlayerController`
- 添加监听器监听初始化状态和错误

#### 3. 界面组件
将原视频预览区域的 `Icon` 替换为：
- 加载中：显示 `CupertinoActivityIndicator`
- 初始化完成：显示 `VideoPlayer` 组件（带系统 controls）
- 错误：显示错误提示图标

#### 4. 资源释放
在 `dispose` 中：
- 释放 `_videoController` 资源

### 文件变更
- `lib/screens/material/material_detail_screen.dart`

---

## 阶段 2：用户管理入口

### 功能描述
仅对 admin 用户显示用户管理入口，提供访问用户管理页面的快捷方式。

### 实现细节

#### 1. 设置页面更新
在 `SettingsScreen` 中添加"管理后台"列表项：
- 仅在 `authProvider.user?.role == 'admin'` 时显示
- 位置：在设置列表的顶部或底部

#### 2. 导航流程
- 点击"管理后台" → 使用 `CupertinoPageRoute` 跳转到 `UserManagementScreen`
- `UserManagementScreen` 已有返回按钮，可回到设置页面

### 文件变更
- `lib/screens/settings/settings_screen.dart`

---

## 阶段 3：复制/移动素材功能

### 功能描述
实现首页批量操作中的"复制"和"移动"功能，使用后端已有的 API。

### 后端 API 确认

#### 批量复制
```
POST /api/materials/batch/copy
Body: {
  ids: number[],           // 素材 ID 数组
  sourceUserId: number,    // 源用户 ID（可选，默认为当前用户）
  targetUserId: number     // 目标用户 ID
}
```

#### 批量移动
```
POST /api/materials/batch/move
Body: {
  ids: number[],           // 素材 ID 数组
  sourceUserId: number,    // 源用户 ID（可选）
  targetUserId: number,    // 目标用户 ID
  targetFolder: string     // 目标文件夹 ('images' | 'videos')
}
```

### 实现细节

#### 1. MaterialService 更新
在 `lib/services/material_service.dart` 中添加：
```dart
Future<Map<String, dynamic>> batchCopy(List<int> ids, int targetUserId)
Future<Map<String, dynamic>> batchMove(List<int> ids, int targetUserId, String targetFolder)
```

#### 2. MaterialProvider 更新
在 `lib/providers/material_provider.dart` 中添加：
```dart
Future<void> batchCopy(List<int> ids, int targetUserId)
Future<void> batchMove(List<int> ids, int targetUserId, String targetFolder)
```

#### 3. 首页对话框
在 `_MaterialsTabState` 中实现：
- `_showBatchCopyDialog()` - 显示复制目标选择
- `_showBatchMoveDialog()` - 显示移动目标选择

对话框设计：
```
┌─────────────────┐
│ 复制到          │
├─────────────────┤
│ ○ 图片文件夹   │
│ ○ 视频文件夹   │
├─────────────────┤
│ [取消]  [确定] │
└─────────────────┘
```

#### 4. 操作逻辑
- **复制**：将素材复制到选定的文件夹（同一用户）
- **移动**：将素材移动到选定的文件夹（同一用户）
- 操作完成后：刷新列表，退出选择模式，显示成功提示

### 文件变更
- `lib/services/material_service.dart`
- `lib/providers/material_provider.dart`
- `lib/screens/home/home_screen.dart`

---

## 开发顺序

按照方案 A，按以下顺序开发：
1. **阶段 1**：视频播放功能
2. **阶段 2**：用户管理入口
3. **阶段 3**：复制/移动素材功能

每个阶段完成后进行测试，确认无误后再进入下一阶段。

---

## 备注

- 后端 API 已完整可用，无需额外开发后端功能
- Web 版本的复制/移动功能也显示"开发中"，Flutter 版本将率先实现完整功能
- 所有功能遵循现有代码风格和架构模式
