# iOS 快速启动指南

## 方式一：使用 Xcode 新建项目（推荐）

### 1. 创建新项目

1. 打开 Xcode
2. 选择 **Create a new Xcode project**
3. 选择 **iOS > App**
4. 填写：
   - Product Name: `NASMaterialManager`
   - Team: 选择您的开发团队（或个人团队）
   - Organization Identifier: `com.example`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None**（不要勾选 Core Data）
5. 保存到：`nas-material-manager/ios/NASMaterialManager`

### 2. 添加源文件

1. 在 Xcode 左侧项目导航器中，右键点击 `NASMaterialManager` 文件夹（蓝色）
2. 选择 **Add Files to "NASMaterialManager"...**
3. 导航到 `nas-material-manager/ios/NASMaterialManager/`
4. 选择以下文件夹，确保勾选 **Copy items if needed**：
   - `App/`
   - `Data/`
   - `Domain/`
   - `Presentation/`
5. 点击 **Add**

### 3. 添加 Core Data 模型

1. File > New > File...
2. 选择 **Data Model**
3. 命名为 `NASMaterialManager`
4. 按照 `NASMaterialManager.xcdatamodeld/README.md` 中的说明创建两个实体：
   - **Folder** 实体
   - **Material** 实体

### 4. 删除默认文件

删除 Xcode 自动生成的 `ContentView.swift`

### 5. 编译运行

按 **Cmd + R** 编译运行！

---

## 方式二：使用 Swift Package Manager（高级）

如果您想更简单的方式，可以考虑后续用 Swift Package 来组织项目。

---

## 常见问题

### 编译错误？

- 确保所有文件都已正确添加到项目
- 检查 Target Membership（文件检查器中勾选）
- 确保没有命名冲突

### 如何在真机上安装？

1. 在 Xcode 中选择您的 iPhone 作为运行目标
2. 确保设备已信任开发者证书
3. 按 Cmd + R
