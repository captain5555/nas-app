# Flutter 桌面端设置指南

## 第一步：创建 Flutter 项目

1. 安装 Flutter SDK（https://flutter.dev/docs/get-started/install）
2. 启用桌面支持：
   ```bash
   flutter config --enable-windows-desktop
   flutter config --enable-macos-desktop
   ```
3. 在 `flutter/` 目录下创建项目：
   ```bash
   cd flutter
   flutter create --platforms=windows,macos .
   ```

## 第二步：添加文件

将 `lib/` 下的所有文件/文件夹复制到项目中，替换原有的内容。

## 第三步：安装依赖

```bash
flutter pub get
```

## 第四步：运行项目

```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos
```

## 项目结构

```
flutter/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── theme/
│   ├── widgets/
│   ├── providers/
│   ├── data/
│   │   ├── models/
│   │   ├── hive/
│   │   └── webdav/
│   └── screens/
└── pubspec.yaml
```

## 已实现功能

- 登录页面（WebDAV 配置）
- 素材网格浏览（带标签徽章）
- 素材详情编辑
- Hive 本地数据库
- 设置页面
