# NAS 素材管理系统

私有 NAS 素材管理工具，支持 iOS 移动端 + PC 桌面端双端同步。所有数据存储在用户私有 NAS（WebDAV 协议），不上传任何公有云。

## 项目状态

- ✅ 第一阶段：共享规范 + iOS 端基础框架
- ✅ 第二阶段：iOS 端浏览页与素材详情
- ✅ 第三阶段：Flutter 桌面端基础
- ✅ 第四阶段：NAS 数据同步机制

## 项目结构

```
nas-material-manager/
├── README.md
├── shared/                          # 共享规范文档
│   ├── json-format.md
│   ├── webdav-protocol.md
│   └── sync-mechanism.md
├── ios/                             # iOS 原生项目
│   ├── SETUP_GUIDE.md
│   └── NASMaterialManager/
│       ├── NASMaterialManager.xcodeproj
│       ├── NASMaterialManager.xcdatamodeld
│       └── NASMaterialManager/
│           ├── App/
│           ├── Data/
│           │   ├── CoreData/
│           │   ├── WebDAV/
│           │   ├── Sync/
│           │   └── Repository/
│           ├── Domain/
│           │   └── Models/
│           └── Presentation/
│               ├── Common/
│               └── Features/
├── flutter/                         # Flutter 桌面项目
│   ├── SETUP_GUIDE.md
│   ├── pubspec.yaml
│   └── lib/
│       ├── main.dart
│       ├── app.dart
│       ├── theme/
│       ├── widgets/
│       ├── providers/
│       ├── data/
│       │   ├── models/
│       │   ├── hive/
│       │   ├── sync/
│       │   └── webdav/
│       └── screens/
└── docs/                            # 设计文档
    ├── specs/
    └── superpowers/plans/
```

## 功能特性

### iOS 端
- ✅ WebDAV 连接登录
- ✅ 素材网格浏览
- ✅ 标签徽章显示（未使用/使用过、未爆/爆款）
- ✅ 素材详情编辑
- ✅ 本地数据库（Core Data）
- ✅ NAS 数据同步（SyncManager）

### Flutter 桌面端
- ✅ WebDAV 连接登录
- ✅ 素材网格浏览
- ✅ 标签徽章显示（未使用/使用过、未爆/爆款）
- ✅ 素材详情编辑
- ✅ 本地数据库（Hive）
- ✅ NAS 数据同步（SyncManager）

### 双端同步机制
- ✅ 每 45 秒轮询检查 NAS 更新
- ✅ 下载并合并 .material_index.json 索引文件
- ✅ 上传修改到 NAS
- ✅ .sync_version 版本戳管理
- ✅ 最后写入 wins 冲突解决

## NAS 文件结构

```
NAS共享目录/
├── .sync_version                    # 同步版本时间戳
├── .material_index.json             # 根目录素材索引
├── 文件夹A/
│   ├── .material_index.json
│   ├── 图片1.jpg
│   └── 视频1.mp4
└── 文件夹B/
    └── .material_index.json
```

## iOS 端使用说明

1. 用 Xcode 创建新项目（详见 `ios/SETUP_GUIDE.md`）
2. 将 `ios/NASMaterialManager/` 下的文件拖入 Xcode 项目
3. 配置开发团队（Signing & Capabilities）
4. 编译运行

## Flutter 桌面端使用说明

1. 安装 Flutter SDK（详见 `flutter/SETUP_GUIDE.md`）
2. 在 `flutter/` 目录下运行 `flutter create --platforms=windows,macos .`
3. 复制 `lib/` 目录文件
4. 运行 `flutter pub get`
5. 运行 `flutter run -d windows` 或 `flutter run -d macos`

## 技术栈

- **iOS**: Swift 5.9+, SwiftUI, iOS 16+, Core Data, URLSession
- **PC**: Flutter 3.19+, Dart 3.3+, Hive, Provider, http
- **协议**: WebDAV
- **架构**: MVVM

## 双端互通规则

- 登录同一个 NAS = 同一个账号
- 双端看到的文件、标题、文案、标签完全一样
- 一端修改，另一端在 45 秒内自动同步
- 数据文件存储在 NAS，同步信息也存在 NAS
- 无云端服务器，无第三方数据传输
