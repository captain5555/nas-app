//
//  NASMaterialManager.swift
//  单文件版本 - 可以直接复制到 Xcode 中运行
//
//  创建步骤:
//  1. Xcode -> New Project -> iOS App
//  2. Product Name: NASMaterialManager
//  3. Interface: SwiftUI, Language: Swift
//  4. 删除 ContentView.swift 的内容
//  5. 将此文件内容全部复制粘贴到 ContentView.swift
//  6. 按 Cmd+R 运行
//

import SwiftUI
import CoreData

// MARK: - 数据模型

enum UsageTag: String, CaseIterable {
    case unused = "unused"
    case used = "used"

    var displayName: String {
        switch self {
        case .unused: return "未使用"
        case .used: return "使用过"
        }
    }

    var color: Color {
        switch self {
        case .unused: return .orange
        case .used: return .green
        }
    }
}

enum ViralTag: String, CaseIterable {
    case notViral = "not_viral"
    case viral = "viral"

    var displayName: String {
        switch self {
        case .notViral: return "未爆"
        case .viral: return "爆款"
        }
    }

    var color: Color {
        switch self {
        case .notViral: return .blue
        case .viral: return .red
        }
    }
}

struct User: Identifiable {
    let id: String
    let name: String
}

struct Material: Identifiable {
    let id: UUID
    let userId: String
    let filename: String
    var title: String?
    var description: String?
    var usageTag: UsageTag
    var viralTag: ViralTag
    var fileSize: Int64?
    let folderType: FolderType

    var displayTitle: String {
        title ?? filename
    }

    var isVideo: Bool {
        let ext = (filename as NSString).pathExtension.lowercased()
        return ["mp4", "mov", "avi", "mkv"].contains(ext)
    }
}

enum FolderType {
    case images
    case videos

    var displayName: String {
        switch self {
        case .images: return "图片"
        case .videos: return "视频"
        }
    }
}

// MARK: - App State

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = true
    @Published var serverURL: String = ""
    @Published var username: String = ""
    @Published var password: String = ""

    @Published var users: [User] = [
        User(id: "user1", name: "张三"),
        User(id: "user2", name: "李四"),
        User(id: "user3", name: "王五")
    ]

    @Published var currentUser: User?
    @Published var currentFolder: FolderType = .images
    @Published var materialsByUser: [String: [FolderType: [Material]]] = [:]

    // Selection mode
    @Published var isSelectMode: Bool = false
    @Published var selectedMaterialIds: Set<UUID> = []

    // Batch operation modals
    @Published var showBatchCopyModal: Bool = false
    @Published var showBatchMoveModal: Bool = false

    init() {
        loadSampleData()
        currentUser = users.first
    }

    private func loadSampleData() {
        users.forEach { user in
            materialsByUser[user.id] = [
                .images: generateSampleMaterials(userId: user.id, folderType: .images),
                .videos: generateSampleMaterials(userId: user.id, folderType: .videos)
            ]
        }
    }

    private func generateSampleMaterials(userId: String, folderType: FolderType) -> [Material] {
        let baseMaterials = folderType == .images ? [
            (filename: "海滩日落.jpg", title: "三亚海滩日落", description: "美丽的海滩日落风景，适合发朋友圈", usageTag: UsageTag.used, viralTag: ViralTag.viral, fileSize: 2150400),
            (filename: "城市夜景.png", title: "上海陆家嘴夜景", description: nil, usageTag: .unused, viralTag: .notViral, fileSize: 3145728),
            (filename: "美食照片.jpg", title: nil, description: nil, usageTag: .unused, viralTag: .notViral, fileSize: 1536000),
            (filename: "产品图.jpg", title: "产品展示图", description: "电商产品主图", usageTag: .used, viralTag: .viral, fileSize: 827392)
        ] : [
            (filename: "宣传片.mp4", title: "企业宣传片", description: "公司年度宣传片", usageTag: .used, viralTag: .notViral, fileSize: 256897234),
            (filename: "城市夜景.mp4", title: "上海陆家嘴夜景", description: "无人机拍摄的城市夜景", usageTag: .unused, viralTag: .notViral, fileSize: 104857600)
        ]

        return baseMaterials.map { m in
            Material(
                id: UUID(),
                userId: userId,
                filename: m.filename,
                title: m.title,
                description: m.description,
                usageTag: m.usageTag,
                viralTag: m.viralTag,
                fileSize: m.fileSize,
                folderType: folderType
            )
        }
    }

    func login() {
        isLoggedIn = true
    }

    func logout() {
        isLoggedIn = false
    }

    func updateMaterial(_ material: Material) {
        guard let userMaterials = materialsByUser[material.userId],
              var materials = userMaterials[material.folderType],
              let index = materials.firstIndex(where: { $0.id == material.id }) else {
            return
        }
        materials[index] = material
        materialsByUser[material.userId]?[material.folderType] = materials
    }

    func getCurrentMaterials() -> [Material] {
        guard let user = currentUser,
              let userMaterials = materialsByUser[user.id],
              let materials = userMaterials[currentFolder] else {
            return []
        }
        return materials
    }

    func toggleSelection(for materialId: UUID) {
        if selectedMaterialIds.contains(materialId) {
            selectedMaterialIds.remove(materialId)
        } else {
            selectedMaterialIds.insert(materialId)
        }
    }

    func selectAll() {
        let materials = getCurrentMaterials()
        if selectedMaterialIds.count == materials.count {
            selectedMaterialIds.removeAll()
        } else {
            selectedMaterialIds = Set(materials.map { $0.id })
        }
    }

    func batchDelete() {
        guard let user = currentUser,
              var userMaterials = materialsByUser[user.id],
              var materials = userMaterials[currentFolder] else {
            return
        }

        materials.removeAll { selectedMaterialIds.contains($0.id) }
        userMaterials[currentFolder] = materials
        materialsByUser[user.id] = userMaterials

        selectedMaterialIds.removeAll()
        isSelectMode = false
    }

    func batchCopy(to targetUserId: String) {
        let materials = getCurrentMaterials().filter { selectedMaterialIds.contains($0.id) }
        guard var targetMaterials = materialsByUser[targetUserId] else { return }

        for material in materials {
            let newMaterial = Material(
                id: UUID(),
                userId: targetUserId,
                filename: material.filename,
                title: material.title,
                description: material.description,
                usageTag: .unused,
                viralTag: .notViral,
                fileSize: material.fileSize,
                folderType: material.folderType
            )
            targetMaterials[material.folderType, default: []].insert(newMaterial, at: 0)
        }

        materialsByUser[targetUserId] = targetMaterials
        selectedMaterialIds.removeAll()
        isSelectMode = false
        showBatchCopyModal = false
    }

    func batchMove(to targetUserId: String) {
        guard let currentUser = currentUser,
              var currentUserMaterials = materialsByUser[currentUser.id],
              var targetMaterials = materialsByUser[targetUserId] else {
            return
        }

        let materialsToMove = getCurrentMaterials().filter { selectedMaterialIds.contains($0.id) }

        for material in materialsToMove {
            let movedMaterial = Material(
                id: UUID(),
                userId: targetUserId,
                filename: material.filename,
                title: material.title,
                description: material.description,
                usageTag: .unused,
                viralTag: .notViral,
                fileSize: material.fileSize,
                folderType: material.folderType
            )
            targetMaterials[material.folderType, default: []].insert(movedMaterial, at: 0)
        }

        currentUserMaterials[currentFolder, default: []].removeAll { selectedMaterialIds.contains($0.id) }

        materialsByUser[currentUser.id] = currentUserMaterials
        materialsByUser[targetUserId] = targetMaterials

        selectedMaterialIds.removeAll()
        isSelectMode = false
        showBatchMoveModal = false
    }

    func exitSelectMode() {
        isSelectMode = false
        selectedMaterialIds.removeAll()
    }
}

// MARK: - UI Components

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

struct MaterialGridItem: View {
    let material: Material
    let isSelected: Bool
    let isSelectMode: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                ZStack(alignment: .topLeading) {
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

                    if isSelectMode {
                        Circle()
                            .fill(isSelected ? Color.blue : Color.white)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .opacity(isSelected ? 1 : 0)
                            )
                            .padding(8)
                    }
                }

                Text(material.displayTitle)
                    .font(.caption)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    TagBadge(
                        text: material.usageTag.displayName,
                        color: material.usageTag.color
                    )
                    TagBadge(
                        text: material.viralTag.displayName,
                        color: material.viralTag.color
                    )
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Login Screen

struct LoginView: View {
    @ObservedObject var appState: AppState
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "folder.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("NAS 素材管理")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 16) {
                TextField("WebDAV 地址 (http://...)", text: $appState.serverURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)

                TextField("用户名", text: $appState.username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)

                SecureField("密码", text: $appState.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal, 40)

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: {
                isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    appState.login()
                    isLoading = false
                }
            }) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("登录")
                        .fontWeight(.semibold)
                }
            }
            .frame(minWidth: 200)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(isLoading)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Browser Screen

struct BrowserView: View {
    @ObservedObject var appState: AppState
    @State private var selectedMaterial: Material?

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if appState.isSelectMode {
                    batchActionsBar
                }

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(appState.getCurrentMaterials()) { material in
                            MaterialGridItem(
                                material: material,
                                isSelected: appState.selectedMaterialIds.contains(material.id),
                                isSelectMode: appState.isSelectMode
                            ) {
                                if appState.isSelectMode {
                                    appState.toggleSelection(for: material.id)
                                } else {
                                    selectedMaterial = material
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("\(appState.currentUser?.name ?? "") - \(appState.currentFolder.displayName)")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(appState.users) { user in
                            Button(user.name) {
                                appState.currentUser = user
                                appState.exitSelectMode()
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "person.circle")
                            Text(appState.currentUser?.name ?? "选择用户")
                        }
                    }
                }

                ToolbarItem(placement: .principal) {
                    Picker("文件夹", selection: $appState.currentFolder) {
                        Text("图片").tag(FolderType.images)
                        Text("视频").tag(FolderType.videos)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 200)
                    .onChange(of: appState.currentFolder) { _ in
                        appState.exitSelectMode()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(appState.isSelectMode ? "取消" : "选择") {
                        if appState.isSelectMode {
                            appState.exitSelectMode()
                        } else {
                            appState.isSelectMode = true
                        }
                    }
                }
            }
            .sheet(item: $selectedMaterial) { material in
                MaterialDetailView(
                    material: material,
                    onSave: { updated in
                        appState.updateMaterial(updated)
                    }
                )
            }
            .sheet(isPresented: $appState.showBatchCopyModal) {
                BatchCopyView(appState: appState)
            }
            .sheet(isPresented: $appState.showBatchMoveModal) {
                BatchMoveView(appState: appState)
            }
        }
    }

    private var batchActionsBar: some View {
        HStack {
            Button(action: { appState.selectAll() }) {
                Text(appState.selectedMaterialIds.count == appState.getCurrentMaterials().count ? "取消全选" : "全选")
            }

            Text("已选择 \(appState.selectedMaterialIds.count) 项")
                .foregroundColor(.secondary)

            Spacer()

            Button(role: .destructive, action: {
                if appState.selectedMaterialIds.count > 0 {
                    appState.batchDelete()
                }
            }) {
                Label("删除", systemImage: "trash")
            }
            .disabled(appState.selectedMaterialIds.isEmpty)

            Button(action: {
                appState.showBatchCopyModal = true
            }) {
                Label("复制", systemImage: "doc.on.doc")
            }
            .disabled(appState.selectedMaterialIds.isEmpty)

            Button(action: {
                appState.showBatchMoveModal = true
            }) {
                Label("移动", systemImage: "arrow.right.doc.on.clipboard")
            }
            .disabled(appState.selectedMaterialIds.isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.separator)),
            alignment: .bottom
        )
    }
}

// MARK: - Batch Copy View

struct BatchCopyView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(appState.users.filter { $0.id != appState.currentUser?.id }) { user in
                    Button(action: {
                        appState.batchCopy(to: user.id)
                        dismiss()
                    }) {
                        HStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(user.name.prefix(1))
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.name)
                                    .fontWeight(.semibold)
                                Text("复制到「\(appState.currentFolder.displayName)」文件夹")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Label(appState.currentFolder.displayName, systemImage: appState.currentFolder == .images ? "photo" : "video")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(20)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("复制给其他用户")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Batch Move View

struct BatchMoveView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(appState.users.filter { $0.id != appState.currentUser?.id }) { user in
                    Button(action: {
                        appState.batchMove(to: user.id)
                        dismiss()
                    }) {
                        HStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(user.name.prefix(1))
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.name)
                                    .fontWeight(.semibold)
                                Text("移动到「\(appState.currentFolder.displayName)」文件夹")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Label(appState.currentFolder.displayName, systemImage: appState.currentFolder == .images ? "photo" : "video")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(20)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("移动给其他用户")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Material Detail Screen

struct MaterialDetailView: View {
    let material: Material
    let onSave: (Material) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var titleText: String
    @State private var descriptionText: String
    @State private var usageTag: UsageTag
    @State private var viralTag: ViralTag

    init(material: Material, onSave: @escaping (Material) -> Void) {
        self.material = material
        self.onSave = onSave
        _titleText = State(initialValue: material.title ?? "")
        _descriptionText = State(initialValue: material.description ?? "")
        _usageTag = State(initialValue: material.usageTag)
        _viralTag = State(initialValue: material.viralTag)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            Image(systemName: material.isVideo ? "video.fill" : "photo.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                        )
                        .cornerRadius(12)
                        .listRowInsets(EdgeInsets())
                }

                Section("基本信息") {
                    HStack {
                        TextField("标题", text: $titleText)
                        Button(action: {
                            UIPasteboard.general.string = titleText
                        }) {
                            Image(systemName: "doc.on.doc")
                        }
                    }

                    HStack {
                        TextField("描述", text: $descriptionText, axis: .vertical)
                            .lineLimit(3...6)
                        Button(action: {
                            UIPasteboard.general.string = descriptionText
                        }) {
                            Image(systemName: "doc.on.doc")
                        }
                    }
                }

                Section("使用状态") {
                    Picker("使用状态", selection: $usageTag) {
                        ForEach(UsageTag.allCases, id: \.self) { tag in
                            Text(tag.displayName).tag(tag)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section("爆款标签") {
                    Picker("爆款标签", selection: $viralTag) {
                        ForEach(ViralTag.allCases, id: \.self) { tag in
                            Text(tag.displayName).tag(tag)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section("文件信息") {
                    HStack {
                        Text("文件名")
                        Spacer()
                        Text(material.filename)
                            .foregroundColor(.secondary)
                    }
                    if let size = material.fileSize {
                        HStack {
                            Text("大小")
                            Spacer()
                            Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))
                                .foregroundColor(.secondary)
                        }
                    }
                }
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
                    Button("保存") {
                        var updated = material
                        updated.title = titleText.isEmpty ? nil : titleText
                        updated.description = descriptionText.isEmpty ? nil : descriptionText
                        updated.usageTag = usageTag
                        updated.viralTag = viralTag
                        onSave(updated)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Settings Screen

struct SettingsView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                Section("NAS 配置") {
                    NavigationLink("服务器设置") {
                        Form {
                            TextField("服务器地址", text: $appState.serverURL)
                            TextField("用户名", text: $appState.username)
                            SecureField("密码", text: $appState.password)
                        }
                        .navigationTitle("服务器设置")
                    }
                }

                Section("数据") {
                    Button("清除缓存") {
                        // 清除缓存
                    }
                }

                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        TabView {
            BrowserView(appState: appState)
                .tabItem {
                    Label("浏览", systemImage: "folder")
                }

            SettingsView(appState: appState)
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
        }
    }
}

// MARK: - Main App

@main
struct NASMaterialManagerApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                MainTabView(appState: appState)
            } else {
                LoginView(appState: appState)
            }
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NASMaterialManagerApp()
    }
}
