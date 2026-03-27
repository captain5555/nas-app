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
        loadSampleData()
    }

    private func loadInitialData() {
        folders = folderRepo.fetchAllFolders()
    }

    private func loadSampleData() {
        let sampleFolder = Folder(
            id: UUID(),
            path: "/",
            name: "根目录",
            parentFolderID: nil
        )

        let sampleMaterials = [
            Material(
                id: UUID(),
                filename: "海滩日落.jpg",
                path: "/海滩日落.jpg",
                title: "三亚海滩日落",
                description: "美丽的海滩日落风景，适合发朋友圈",
                tags: MaterialTags(usage: .used, viral: .viral),
                fileSize: 2150400,
                fileModifiedAt: Date().addingTimeInterval(-86400 * 7),
                localUpdatedAt: Date().addingTimeInterval(-3600),
                folderID: sampleFolder.id
            ),
            Material(
                id: UUID(),
                filename: "城市夜景.mp4",
                path: "/城市夜景.mp4",
                title: "上海陆家嘴夜景",
                description: "无人机拍摄的城市夜景",
                tags: MaterialTags(usage: .unused, viral: .notViral),
                fileSize: 104857600,
                fileModifiedAt: Date().addingTimeInterval(-86400 * 3),
                localUpdatedAt: Date().addingTimeInterval(-7200),
                folderID: sampleFolder.id
            ),
            Material(
                id: UUID(),
                filename: "美食照片.jpg",
                path: "/美食照片.jpg",
                title: nil,
                description: nil,
                tags: MaterialTags(usage: .unused, viral: .notViral),
                fileSize: 1536000,
                fileModifiedAt: Date().addingTimeInterval(-86400),
                localUpdatedAt: Date().addingTimeInterval(-86400),
                folderID: sampleFolder.id
            )
        ]

        currentFolder = sampleFolder
        materials = sampleMaterials
    }

    func selectFolder(_ folder: Folder) {
        currentFolder = folder
        materials = materialRepo.fetchMaterials(for: folder.id)
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        try? await Task.sleep(nanoseconds: 1_500_000_000)
    }
}
