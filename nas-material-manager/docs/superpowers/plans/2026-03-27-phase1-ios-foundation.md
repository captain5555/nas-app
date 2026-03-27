# 第一阶段：共享规范 + iOS 端基础框架实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立项目基础结构，编写共享规范文档，并完成 iOS 端的 WebDAV 客户端、Core Data 模型、登录页面

**Architecture:** Monorepo 结构，shared 目录存放规范文档，ios 目录是完整的 Xcode 项目，采用 MVVM 架构

**Tech Stack:** Swift 5.9+, SwiftUI, iOS 16+, Core Data, URLSession

---

## 项目结构总览

```
nas-material-manager/
├── shared/
│   ├── json-format.md
│   ├── webdav-protocol.md
│   └── sync-mechanism.md
├── ios/
│   └── NASMaterialManager/
│       ├── NASMaterialManager.xcodeproj
│       ├── NASMaterialManager/
│       │   ├── App/
│       │   ├── Data/
│       │   │   ├── CoreData/
│       │   │   ├── WebDAV/
│       │   │   └── Repository/
│       │   ├── Domain/
│       │   │   └── Models/
│       │   └── Presentation/
│       │       └── Features/
│       │           └── Login/
│       └── NASMaterialManager.xcdatamodeld/
└── docs/
```

---

### Task 1: 创建共享规范文档

**Files:**
- Create: `shared/json-format.md`
- Create: `shared/webdav-protocol.md`
- Create: `shared/sync-mechanism.md`

- [ ] **Step 1: 创建 JSON 格式规范文档**

```markdown
# JSON 数据格式规范

## .material_index.json 格式

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

## 标签枚举值

- usage: "unused" | "used"
- viral: "not_viral" | "viral"

## 时间格式

所有时间使用 ISO 8601 UTC 格式，后缀 Z
```

- [ ] **Step 2: 创建 WebDAV 协议规范文档**

```markdown
# WebDAV 协议操作规范

## 支持的 WebDAV 方法

- PROPFIND - 列出目录内容
- GET - 下载文件
- PUT - 上传文件
- DELETE - 删除文件
- MKCOL - 创建文件夹
- PROPPATCH - 更新属性（可选）

## 请求头

Authorization: Basic {base64(username:password)}
Content-Type: application/json (for JSON files)
Depth: 1 (for PROPFIND)
```

- [ ] **Step 3: 创建同步机制规范文档**

```markdown
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
```

---

### Task 2: 创建 iOS 项目基础结构

**Files:**
- Create: `ios/NASMaterialManager/NASMaterialManager.xcodeproj/project.pbxproj`
- Create: `ios/NASMaterialManager/NASMaterialManager/NASMaterialManagerApp.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/App/AppEnvironment.swift`

- [ ] **Step 1: 创建 Xcode 项目基础配置**

使用 Xcode 创建一个新的 SwiftUI 项目，命名为 NASMaterialManager，iOS 16+。

- [ ] **Step 2: 创建 AppEnvironment.swift**

```swift
import Foundation

class AppEnvironment: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var webdavConfig: WebDAVConfig?

    static let shared = AppEnvironment()

    private init() {}
}
```

- [ ] **Step 3: 创建 NASMaterialManagerApp.swift**

```swift
import SwiftUI

@main
struct NASMaterialManagerApp: App {
    @StateObject private var env = AppEnvironment.shared

    var body: some Scene {
        WindowGroup {
            if env.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}
```

---

### Task 3: 创建 Domain 层模型

**Files:**
- Create: `ios/NASMaterialManager/NASMaterialManager/Domain/Models/MaterialTags.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/Domain/Models/Material.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/Domain/Models/Folder.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/Domain/Models/WebDAVConfig.swift`

- [ ] **Step 1: 创建 MaterialTags.swift**

```swift
import Foundation

enum UsageTag: String, Codable, CaseIterable {
    case unused = "unused"
    case used = "used"

    var displayName: String {
        switch self {
        case .unused: return "未使用"
        case .used: return "使用过"
        }
    }
}

enum ViralTag: String, Codable, CaseIterable {
    case notViral = "not_viral"
    case viral = "viral"

    var displayName: String {
        switch self {
        case .notViral: return "未爆"
        case .viral: return "爆款"
        }
    }
}

struct MaterialTags: Codable {
    var usage: UsageTag
    var viral: ViralTag
}
```

- [ ] **Step 2: 创建 WebDAVConfig.swift**

```swift
import Foundation

struct WebDAVConfig: Codable {
    let serverURL: String
    let username: String
    let password: String

    enum CodingKeys: String, CodingKey {
        case serverURL = "server_url"
        case username
        case password
    }
}
```

- [ ] **Step 3: 创建 Material.swift（Domain 层）**

```swift
import Foundation

struct Material {
    let id: UUID
    let filename: String
    let path: String
    var title: String?
    var description: String?
    var tags: MaterialTags
    let fileSize: Int64?
    let fileModifiedAt: Date?
    var localUpdatedAt: Date
    let folderID: UUID?
}
```

- [ ] **Step 4: 创建 Folder.swift（Domain 层）**

```swift
import Foundation

struct Folder {
    let id: UUID
    let path: String
    let name: String
    let parentFolderID: UUID?
}
```

---

### Task 4: 创建 Core Data 模型

**Files:**
- Create: `ios/NASMaterialManager/NASMaterialManager.xcdatamodeld/NASMaterialManager.xcdatamodel/contents`
- Create: `ios/NASMaterialManager/NASMaterialManager/Data/CoreData/CoreDataStack.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/Data/CoreData/Models/Folder+CoreDataClass.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/Data/CoreData/Models/Folder+CoreDataProperties.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/Data/CoreData/Models/Material+CoreDataClass.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/Data/CoreData/Models/Material+CoreDataProperties.swift`

- [ ] **Step 1: 创建 CoreDataStack.swift**

```swift
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NASMaterialManager")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data store failed to load: \(error)")
            }
        }
        return container
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}
```

- [ ] **Step 2: 创建 Core Data 模型实体（在 Xcode 中创建）**

定义两个实体：
- **Folder**:
  - id: UUID
  - path: String
  - name: String
  - parentFolderID: UUID? (optional)
  - childrenFolders: to-many relationship to Folder
  - materials: to-many relationship to Material

- **Material**:
  - id: UUID
  - filename: String
  - path: String
  - title: String? (optional)
  - descriptionText: String? (optional, use descriptionText to avoid conflict)
  - usageTag: String (raw value of UsageTag)
  - viralTag: String (raw value of ViralTag)
  - fileSize: Integer 64 (optional)
  - fileModifiedAt: Date (optional)
  - localUpdatedAt: Date
  - folder: to-one relationship to Folder

- [ ] **Step 3: 创建 NSManagedObject 子类**

（Xcode 自动生成，或手动创建）

---

### Task 5: 创建 WebDAV 客户端

**Files:**
- Create: `ios/NASMaterialManager/NASMaterialManager/Data/WebDAV/WebDAVConfiguration.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/Data/WebDAV/WebDAVClient.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/Data/WebDAV/WebDAVRequests.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/Data/WebDAV/IndexFile.swift`

- [ ] **Step 1: 创建 WebDAVConfiguration.swift**

```swift
import Foundation

struct WebDAVConfiguration {
    let serverURL: URL
    let username: String
    let password: String

    var authHeader: String {
        let credentials = "\(username):\(password)".data(using: .utf8)!
        let base64 = credentials.base64EncodedString()
        return "Basic \(base64)"
    }
}
```

- [ ] **Step 2: 创建 IndexFile.swift（JSON 模型）**

```swift
import Foundation

struct IndexFile: Codable {
    let version: Int
    let updatedAt: Date
    let files: [String: MaterialIndex]

    enum CodingKeys: String, CodingKey {
        case version
        case updatedAt = "updated_at"
        case files
    }
}

struct MaterialIndex: Codable {
    let title: String?
    let description: String?
    let tags: TagsIndex
    let updatedAt: Date
    let fileSize: Int64?
    let fileModifiedAt: Date?

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case tags
        case updatedAt = "updated_at"
        case fileSize = "file_size"
        case fileModifiedAt = "file_modified_at"
    }
}

struct TagsIndex: Codable {
    let usage: String
    let viral: String
}
```

- [ ] **Step 3: 创建 WebDAVClient.swift**

```swift
import Foundation

class WebDAVClient {
    private let config: WebDAVConfiguration
    private let session: URLSession

    init(config: WebDAVConfiguration) {
        self.config = config
        let sessionConfig = URLSessionConfiguration.default
        self.session = URLSession(configuration: sessionConfig)
    }

    func testConnection() async throws -> Bool {
        let request = makeRequest(path: "", method: "PROPFIND")
        let (_, response) = try await session.data(for: request)
        return (response as? HTTPURLResponse)?.statusCode == 207
    }

    func listDirectory(path: String) async throws -> [WebDAVItem] {
        var request = makeRequest(path: path, method: "PROPFIND")
        request.setValue("1", forHTTPHeaderField: "Depth")
        let (data, _) = try await session.data(for: request)
        return parsePROPFINDResponse(data)
    }

    func downloadFile(path: String) async throws -> Data {
        let request = makeRequest(path: path, method: "GET")
        let (data, _) = try await session.data(for: request)
        return data
    }

    func uploadFile(path: String, data: Data, contentType: String = "application/octet-stream") async throws {
        var request = makeRequest(path: path, method: "PUT")
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        _ = try await session.upload(for: request, from: data)
    }

    func deleteFile(path: String) async throws {
        let request = makeRequest(path: path, method: "DELETE")
        _ = try await session.data(for: request)
    }

    func createFolder(path: String) async throws {
        let request = makeRequest(path: path, method: "MKCOL")
        _ = try await session.data(for: request)
    }

    private func makeRequest(path: String, method: String) -> URLRequest {
        let url = config.serverURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(config.authHeader, forHTTPHeaderField: "Authorization")
        return request
    }

    private func parsePROPFINDResponse(_ data: Data) -> [WebDAVItem] {
        // 简化实现，实际需要解析 XML
        // 返回示例
        return []
    }
}

struct WebDAVItem {
    let path: String
    let name: String
    let isDirectory: Bool
    let size: Int64?
    let modifiedAt: Date?
}
```

---

### Task 6: 创建登录页面

**Files:**
- Create: `ios/NASMaterialManager/NASMaterialManager/Presentation/Features/Login/LoginView.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/Presentation/Features/Login/LoginViewModel.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/Presentation/MainTabView.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/Presentation/Common/Theme.swift`

- [ ] **Step 1: 创建 Theme.swift**

```swift
import SwiftUI

struct Theme {
    static let primaryColor = Color.blue
    static let backgroundColor = Color(uiColor: .systemBackground)
    static let secondaryBackgroundColor = Color(uiColor: .secondarySystemBackground)
}
```

- [ ] **Step 2: 创建 LoginViewModel.swift**

```swift
import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var serverURL: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadSavedConfig()
    }

    private func loadSavedConfig() {
        if let data = UserDefaults.standard.data(forKey: "webdav_config"),
           let config = try? JSONDecoder().decode(WebDAVConfig.self, from: data) {
            serverURL = config.serverURL
            username = config.username
            password = config.password
        }
    }

    private func saveConfig() {
        let config = WebDAVConfig(
            serverURL: serverURL,
            username: username,
            password: password
        )
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: "webdav_config")
        }
    }

    func login() async {
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: serverURL) else {
            errorMessage = "无效的服务器地址"
            isLoading = false
            return
        }

        let config = WebDAVConfiguration(
            serverURL: url,
            username: username,
            password: password
        )
        let client = WebDAVClient(config: config)

        do {
            let success = try await client.testConnection()
            if success {
                saveConfig()
                AppEnvironment.shared.webdavConfig = WebDAVConfig(
                    serverURL: serverURL,
                    username: username,
                    password: password
                )
                AppEnvironment.shared.isLoggedIn = true
            } else {
                errorMessage = "连接失败，请检查配置"
            }
        } catch {
            errorMessage = "连接错误: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
```

- [ ] **Step 3: 创建 LoginView.swift**

```swift
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "folder.fill")
                .font(.system(size: 60))
                .foregroundColor(Theme.primaryColor)

            Text("NAS 素材管理")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 16) {
                TextField("WebDAV 地址 (http://...)", text: $viewModel.serverURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)

                TextField("用户名", text: $viewModel.username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)

                SecureField("密码", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal, 40)

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: {
                Task {
                    await viewModel.login()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("登录")
                        .fontWeight(.semibold)
                }
            }
            .frame(minWidth: 200)
            .padding()
            .background(Theme.primaryColor)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(viewModel.isLoading)

            Spacer()
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
```

- [ ] **Step 4: 创建 MainTabView.swift（占位符）**

```swift
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Text("浏览页")
                .tabItem {
                    Label("浏览", systemImage: "folder")
                }

            Text("设置")
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
        }
    }
}
```

---

### Task 7: 创建 Repository 层基础

**Files:**
- Create: `ios/NASMaterialManager/NASMaterialManager/Data/Repository/MaterialRepository.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/Data/Repository/FolderRepository.swift`

- [ ] **Step 1: 创建 FolderRepository.swift**

```swift
import Foundation
import CoreData

class FolderRepository {
    private let context = CoreDataStack.shared.viewContext

    func fetchAllFolders() -> [Folder] {
        // 实现 fetch 逻辑
        return []
    }
}
```

- [ ] **Step 2: 创建 MaterialRepository.swift**

```swift
import Foundation
import CoreData

class MaterialRepository {
    private let context = CoreDataStack.shared.viewContext

    func fetchMaterials(for folderID: UUID) -> [Material] {
        // 实现 fetch 逻辑
        return []
    }
}
```

---

## 第一阶段完成验证

- [ ] 项目可以编译运行
- [ ] 登录页面显示正常
- [ ] 可以输入 WebDAV 配置并保存
- [ ] 可以测试连接（需要真实 NAS）
- [ ] 登录成功后显示主页面占位符
