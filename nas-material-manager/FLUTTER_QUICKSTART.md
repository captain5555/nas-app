# Flutter 桌面端 - 快速启动指南

## 前置条件

您的电脑（Windows 或 macOS）

---

## 第一步：安装 Flutter SDK

### Windows:
1. 下载 Flutter SDK: https://flutter.dev/docs/get-started/install/windows
2. 解压到 `C:\flutter`
3. 把 `C:\flutter\bin` 添加到系统 PATH 环境变量
4. 打开新的 PowerShell/CMD 窗口，运行:
   ```
   flutter doctor
   ```

### macOS:
1. 下载 Flutter SDK: https://flutter.dev/docs/get-started/install/macos
2. 解压到 `~/flutter`
3. 把 `~/flutter/bin` 添加到 PATH
4. 打开终端，运行:
   ```
   flutter doctor
   ```

---

## 第二步：启用桌面支持

打开终端/PowerShell，运行：

```bash
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
```

验证：
```bash
flutter devices
```
您应该能看到 Windows 或 macOS 设备。

---

## 第三步：创建项目并运行

### 方式一：使用单文件版本（推荐，最简单！）

1. 创建项目文件夹：
   ```bash
   cd D:\Claude_Workspace\nas-material-manager
   mkdir temp_flutter
   cd temp_flutter
   flutter create --platforms=windows,macos .
   ```

2. 打开 `temp_flutter/lib/main.dart`

3. **删除全部内容**

4. **复制 `flutter/SINGLE_FILE_APP.dart` 的全部内容**

5. **粘贴到 `temp_flutter/lib/main.dart`**

6. 运行！
   ```bash
   # Windows
   flutter run -d windows

   # macOS
   flutter run -d macos
   ```

---

## 第四步：使用应用

1. 点击「登录」（测试账号，随意输入）
2. 浏览示例素材
3. 点击任意素材，进入详情页
4. 编辑标题、描述、标签
5. 点击「保存」
6. 回到浏览页，能看到更新！

---

## 功能展示

- ✅ 登录页面
- ✅ 素材网格浏览
- ✅ 标签徽章（未使用/使用过、未爆/爆款）
- ✅ 素材详情编辑
- ✅ 设置页面
- ✅ 亮色/深色主题自动适配

---

## 遇到问题？

### `flutter doctor` 有警告？
没关系，只要能看到 Windows/macOS 设备就行！

### 无法运行？
确认已启用桌面支持：
```bash
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter devices
```

---

## 下一步

应用可以正常运行后，您可以：
- 查看 `flutter/lib/` 下的完整代码
- 查看 `shared/` 下的规范文档
- 继续开发 NAS WebDAV 同步功能
