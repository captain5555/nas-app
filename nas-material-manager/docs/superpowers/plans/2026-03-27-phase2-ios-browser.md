# 第二阶段：iOS 端浏览页与素材详情

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development

**Goal:** 完善 iOS 端，实现文件夹浏览、素材网格展示、素材详情编辑、完整的 Core Data 实现

**Tech Stack:** Swift 5.9+, SwiftUI, iOS 16+, Core Data

---

## Task 1: 完善 Core Data 实现

**Files:**
- Update: `ios/NASMaterialManager/NASMaterialManager/Data/CoreData/CoreDataStack.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/Data/CoreData/Extensions/NSManagedObjectContext+Save.swift`

- [ ] **Step 1: 完善 CoreDataStack，添加批量操作支持**

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

    func newBackgroundContext() -> NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        saveContext(context)
    }

    func saveContext(_ context: NSManagedObjectContext) {
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

---

## Task 2: 完善 Repository 层

**Files:**
- Update: `ios/NASMaterialManager/NASMaterialManager/Data/Repository/FolderRepository.swift`
- Update: `ios/NASMaterialManager/NASMaterialManager/Data/Repository/MaterialRepository.swift`

- [ ] **Step 1: 完善 FolderRepository.swift**

```swift
import Foundation
import CoreData

class FolderRepository {
    private let context = CoreDataStack.shared.viewContext

    func fetchAllFolders() -> [Folder] {
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        do {
            let cdFolders = try context.fetch(request)
            return cdFolders.map { $0.toDomain() }
        } catch {
            print("Failed to fetch folders: \(error)")
            return []
        }
    }

    func fetchFolder(by id: UUID) -> Folder? {
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        do {
            if let cdFolder = try context.fetch(request).first {
                return cdFolder.toDomain()
            }
        } catch {
            print("Failed to fetch folder: \(error)")
        }
        return nil
    }

    func saveFolder(_ folder: Folder) {
        let cdFolder = Folder(context: context)
        cdFolder.id = folder.id
        cdFolder.path = folder.path
        cdFolder.name = folder.name
        cdFolder.parentFolderID = folder.parentFolderID
        CoreDataStack.shared.saveContext()
    }
}

extension Folder {
    func toDomain() -> Folder {
        return Folder(
            id: id ?? UUID(),
            path: path ?? "",
            name: name ?? "",
            parentFolderID: parentFolderID
        )
    }
}
```

- [ ] **Step 2: 完善 MaterialRepository.swift**

```swift
import Foundation
import CoreData

class MaterialRepository {
    private let context = CoreDataStack.shared.viewContext

    func fetchMaterials(for folderID: UUID) -> [Material] {
        let request: NSFetchRequest<Material> = Material.fetchRequest()
        request.predicate = NSPredicate(format: "folder.id == %@", folderID as CVarArg)
        do {
            let cdMaterials = try context.fetch(request)
            return cdMaterials.map { $0.toDomain() }
        } catch {
            print("Failed to fetch materials: \(error)")
            return []
        }
    }

    func fetchMaterial(by id: UUID) -> Material? {
        let request: NSFetchRequest<Material> = Material.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        do {
            if let cdMaterial = try context.fetch(request).first {
                return cdMaterial.toDomain()
            }
        } catch {
            print("Failed to fetch material: \(error)")
        }
        return nil
    }

    func saveMaterial(_ material: Material) {
        let cdMaterial = Material(context: context)
        cdMaterial.id = material.id
        cdMaterial.filename = material.filename
        cdMaterial.path = material.path
        cdMaterial.title = material.title
        cdMaterial.descriptionText = material.description
        cdMaterial.usageTag = material.tags.usage.rawValue
        cdMaterial.viralTag = material.tags.viral.rawValue
        if let fileSize = material.fileSize {
            cdMaterial.fileSize = fileSize
        }
        cdMaterial.fileModifiedAt = material.fileModifiedAt
        cdMaterial.localUpdatedAt = material.localUpdatedAt
        // folder relation 需要单独设置
        CoreDataStack.shared.saveContext()
    }

    func updateMaterial(_ material: Material) {
        guard let id = material.id else { return }
        let request: NSFetchRequest<Material> = Material.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        do {
            if let cdMaterial = try context.fetch(request).first {
                cdMaterial.title = material.title
                cdMaterial.descriptionText = material.description
                cdMaterial.usageTag = material.tags.usage.rawValue
                cdMaterial.viralTag = material.tags.viral.rawValue
                cdMaterial.localUpdatedAt = Date()
                CoreDataStack.shared.saveContext()
            }
        } catch {
            print("Failed to update material: \(error)")
        }
    }
}

extension Material {
    func toDomain() -> Material {
        let usage = UsageTag(rawValue: usageTag ?? "unused") ?? .unused
        let viral = ViralTag(rawValue: viralTag ?? "not_viral") ?? .notViral
        return Material(
            id: id ?? UUID(),
            filename: filename ?? "",
            path: path ?? "",
            title: title,
            description: descriptionText,
            tags: MaterialTags(usage: usage, viral: viral),
            fileSize: fileSize != 0 ? fileSize : nil,
            fileModifiedAt: fileModifiedAt,
            localUpdatedAt: localUpdatedAt ?? Date(),
            folderID: folder?.id
        )
    }
}
```

---

## Task 3: 创建浏览页

**Files:**
- Create: `ios/NASMaterialManager/NASMaterialManager/Presentation/Features/Browser/BrowserView.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/Presentation/Features/Browser/BrowserViewModel.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/Presentation/Features/Browser/Components/MaterialGridItem.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/Presentation/Features/Browser/Components/TagBadge.swift`

- [ ] **Step 1: 创建 TagBadge.swift**

```swift
import SwiftUI

struct TagBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(4)
    }
}
```

- [ ] **Step 2: 创建 MaterialGridItem.swift**

```swift
import SwiftUI

struct MaterialGridItem: View {
    let material: Material
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(1, contentMode: .fill)
                    .overlay(
                        Image(systemName: material.isVideo ? "video.fill" : "photo.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
                    .clipped()
                    .cornerRadius(8)

                Text(material.title ?? material.filename)
                    .font(.caption)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    TagBadge(
                        text: material.tags.usage.displayName,
                        color: material.tags.usage == .used ? .green : .orange
                    )
                    TagBadge(
                        text: material.tags.viral.displayName,
                        color: material.tags.viral == .viral ? .red : .blue
                    )
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension Material {
    var isVideo: Bool {
        let videoExtensions = ["mp4", "mov", "avi", "mkv"]
        return videoExtensions.contains((filename as NSString).pathExtension.lowercased())
    }
}
```

- [ ] **Step 3: 创建 BrowserViewModel.swift**

```swift
import Foundation
import Combine

@MainActor
class BrowserViewModel: ObservableObject {
    @Published var folders: [Folder] = []
    @Published var materials: [Material] = []
    @Published var currentFolder: Folder?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let folderRepo = FolderRepository()
    private let materialRepo = MaterialRepository()
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadInitialData()
    }

    private func loadInitialData() {
        folders = folderRepo.fetchAllFolders()
    }

    func selectFolder(_ folder: Folder) {
        currentFolder = folder
        materials = materialRepo.fetchMaterials(for: folder.id)
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        // TODO: 从 WebDAV 同步数据
    }
}
```

- [ ] **Step 4: 创建 BrowserView.swift**

```swift
import SwiftUI

struct BrowserView: View {
    @StateObject private var viewModel = BrowserViewModel()

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("加载中...")
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.materials) { material in
                                MaterialGridItem(material: material) {
                                    // 导航到详情页
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(viewModel.currentFolder?.name ?? "浏览")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.refresh()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

struct BrowserView_Previews: PreviewProvider {
    static var previews: some View {
        BrowserView()
    }
}
```

---

## Task 4: 创建素材详情页

**Files:**
- Create: `ios/NASMaterialManager/NASMaterialManager/Presentation/Features/MaterialDetail/MaterialDetailView.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/Presentation/Features/MaterialDetail/MaterialDetailViewModel.swift`

- [ ] **Step 1: 创建 MaterialDetailViewModel.swift**

```swift
import Foundation
import Combine

@MainActor
class MaterialDetailViewModel: ObservableObject {
    @Published var material: Material
    @Published var titleText: String
    @Published var descriptionText: String
    @Published var usageTag: UsageTag
    @Published var viralTag: ViralTag
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    private let materialRepo = MaterialRepository()

    init(material: Material) {
        self.material = material
        self.titleText = material.title ?? ""
        self.descriptionText = material.description ?? ""
        self.usageTag = material.tags.usage
        self.viralTag = material.tags.viral
    }

    func save() async {
        isSaving = true
        defer { isSaving = false }

        var updated = material
        updated.title = titleText.isEmpty ? nil : titleText
        updated.description = descriptionText.isEmpty ? nil : descriptionText
        updated.tags.usage = usageTag
        updated.tags.viral = viralTag
        updated.localUpdatedAt = Date()

        materialRepo.updateMaterial(updated)
        material = updated

        // TODO: 同步到 NAS
    }
}
```

- [ ] **Step 2: 创建 MaterialDetailView.swift**

```swift
import SwiftUI

struct MaterialDetailView: View {
    @StateObject private var viewModel: MaterialDetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(material: Material) {
        _viewModel = StateObject(wrappedValue: MaterialDetailViewModel(material: material))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            Image(systemName: viewModel.material.isVideo ? "video.fill" : "photo.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                        )
                        .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("标题")
                                .font(.headline)
                            TextField("输入标题...", text: $viewModel.titleText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("描述")
                                .font(.headline)
                            TextEditor(text: $viewModel.descriptionText)
                                .frame(minHeight: 100)
                                .border(Color.gray.opacity(0.3), cornerRadius: 8)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("使用状态")
                                .font(.headline)
                            Picker("使用状态", selection: $viewModel.usageTag) {
                                ForEach(UsageTag.allCases, id: \.self) { tag in
                                    Text(tag.displayName).tag(tag)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("爆款标签")
                                .font(.headline)
                            Picker("爆款标签", selection: $viewModel.viralTag) {
                                ForEach(ViralTag.allCases, id: \.self) { tag in
                                    Text(tag.displayName).tag(tag)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("文件名: \(viewModel.material.filename)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if let size = viewModel.material.fileSize {
                                Text("大小: \(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("素材详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.save()
                            dismiss()
                        }
                    }) {
                        if viewModel.isSaving {
                            ProgressView()
                        } else {
                            Text("保存")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
            }
        }
    }
}
```

---

## Task 5: 更新 MainTabView 和 App 导航

**Files:**
- Update: `ios/NASMaterialManager/NASMaterialManager/Presentation/MainTabView.swift`
- Update: `ios/NASMaterialManager/NASMaterialManager/Presentation/Features/Browser/BrowserView.swift` (添加导航到详情页)

- [ ] **Step 1: 更新 MainTabView.swift**

```swift
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            BrowserView()
                .tabItem {
                    Label("浏览", systemImage: "folder")
                }

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("NAS 配置") {
                    NavigationLink("服务器设置") {
                        Text("服务器设置页面")
                    }
                }
                Section("数据") {
                    Button("清除缓存") {
                        // 清除缓存
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}
```

- [ ] **Step 2: 更新 BrowserView 添加导航**

在 BrowserView 的 MaterialGridItem onTap 中添加：
```swift
NavigationLink(value: material) {
    // ...
}
```

并添加：
```swift
.navigationDestination(for: Material.self) { material in
    MaterialDetailView(material: material)
}
```

---

## 第二阶段完成验证

- [ ] 浏览页可以显示素材网格
- [ ] 素材卡片上显示标签徽章
- [ ] 可以进入素材详情页
- [ ] 可以编辑标题、描述、标签
- [ ] 保存后更新本地数据库
