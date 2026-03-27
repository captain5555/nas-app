# iOS 项目设置指南

## 第一步：创建 Xcode 项目

1. 打开 Xcode
2. 选择 "Create a new Xcode project"
3. 选择 "iOS" > "App"
4. 填写以下信息：
   - Product Name: `NASMaterialManager`
   - Team: 选择您的开发团队
   - Organization Identifier: `com.yourcompany`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Storage: `None` (不使用 Core Data 复选框，我们手动添加)
5. 保存到: `nas-material-manager/ios/`

## 第二步：添加文件

创建项目后，将以下文件/文件夹拖入 Xcode 项目（确保勾选 "Copy items if needed"）：

```
NASMaterialManager/
├── App/
│   └── AppEnvironment.swift
├── Data/
│   ├── CoreData/
│   │   ├── CoreDataStack.swift
│   │   └── Models/
│   │       ├── Folder+CoreDataClass.swift
│   │       ├── Folder+CoreDataProperties.swift
│   │       ├── Material+CoreDataClass.swift
│   │       └── Material+CoreDataProperties.swift
│   ├── WebDAV/
│   │   ├── WebDAVClient.swift
│   │   ├── WebDAVConfiguration.swift
│   │   └── IndexFile.swift
│   └── Repository/
│       ├── FolderRepository.swift
│       └── MaterialRepository.swift
├── Domain/
│   └── Models/
│       ├── MaterialTags.swift
│       ├── Material.swift
│       ├── Folder.swift
│       └── WebDAVConfig.swift
└── Presentation/
    ├── Common/
    │   └── Theme.swift
    ├── Features/
    │   ├── Browser/
    │   │   ├── BrowserView.swift
    │   │   ├── BrowserViewModel.swift
    │   │   └── Components/
    │   │       ├── MaterialGridItem.swift
    │   │       └── TagBadge.swift
    │   ├── Login/
    │   │   ├── LoginView.swift
    │   │   └── LoginViewModel.swift
    │   └── MaterialDetail/
    │       ├── MaterialDetailView.swift
    │       └── MaterialDetailViewModel.swift
    ├── MainTabView.swift
    └── NASMaterialManagerApp.swift
```

## 第三步：添加 Core Data 模型

1. 在 Xcode 中，File > New > File...
2. 选择 "Data Model"
3. 命名为 `NASMaterialManager.xcdatamodeld`
4. 按照 `NASMaterialManager.xcdatamodeld/README.md` 中的说明创建实体

## 第四步：替换默认文件

删除 Xcode 自动生成的 `ContentView.swift`，使用我们提供的 `NASMaterialManagerApp.swift`。

## 第五步：编译运行

按 Cmd+R 编译运行项目！

## 已实现功能

- 登录页面（WebDAV 配置）
- 素材浏览（网格视图，带标签徽章）
- 素材详情（编辑标题、描述、标签）
- 设置页面
- 本地数据库（Core Data）
