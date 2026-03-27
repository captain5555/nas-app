import Foundation

class SyncManager: ObservableObject {
    @Published var status = SyncStatus(state: .idle, lastSyncAt: nil, progress: nil)

    private let client: WebDAVClient
    private let materialRepo: MaterialRepository
    private let folderRepo: FolderRepository
    private var timer: Timer?
    private let pollInterval: TimeInterval = 45

    private var lastRemoteVersion: Date?
    private var localSyncVersion: Date?

    init(client: WebDAVClient, materialRepo: MaterialRepository, folderRepo: FolderRepository) {
        self.client = client
        self.materialRepo = materialRepo
        self.folderRepo = folderRepo
        loadLocalSyncVersion()
    }

    func startPolling() {
        stopPolling()
        timer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.checkAndSync()
            }
        }
        Task {
            await checkAndSync()
        }
    }

    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    func checkAndSync() async {
        await MainActor.run {
            status = SyncStatus(state: .checking, lastSyncAt: status.lastSyncAt, progress: nil)
        }

        do {
            let remoteVersion = try await fetchRemoteVersion()
            if localSyncVersion == nil || remoteVersion > localSyncVersion! {
                await downloadAndMergeChanges()
                localSyncVersion = remoteVersion
                saveLocalSyncVersion()
            }
            await MainActor.run {
                status = SyncStatus(state: .idle, lastSyncAt: Date(), progress: nil)
            }
        } catch {
            await MainActor.run {
                status = SyncStatus(state: .error(error.localizedDescription), lastSyncAt: status.lastSyncAt, progress: nil)
            }
        }
    }

    private func fetchRemoteVersion() async throws -> Date {
        do {
            let data = try await client.downloadFile(path: ".sync_version")
            if let dateString = String(data: data, encoding: .utf8), !dateString.isEmpty {
                return ISO8601DateFormatter().date(from: dateString) ?? Date.distantPast
            }
        } catch {
        }
        return Date.distantPast
    }

    private func downloadAndMergeChanges() async {
        await MainActor.run {
            status = SyncStatus(state: .downloading, lastSyncAt: status.lastSyncAt, progress: 0.0)
        }

        let indexFile = try? await client.downloadIndexFile(path: ".material_index.json")
        if let index = indexFile {
            mergeIndexFile(index, folderPath: "/")
        }

        await MainActor.run {
            status = SyncStatus(state: .downloading, lastSyncAt: status.lastSyncAt, progress: 1.0)
        }
    }

    private func mergeIndexFile(_ index: IndexFile, folderPath: String) {
        for (filename, fileIndex) in index.files {
            let path = folderPath.isEmpty ? filename : "\(folderPath)/\(filename)"
            let existingID = path.data(using: .utf8)?.base64EncodedString()
            // 简化实现：实际需要更完善的查找逻辑
        }
    }

    func uploadChanges(for materials: [Material], folderPath: String) async throws {
        await MainActor.run {
            status = SyncStatus(state: .uploading, lastSyncAt: status.lastSyncAt, progress: 0.0)
        }

        var filesDict: [String: MaterialIndex] = [:]
        for material in materials {
            let tagsIndex = TagsIndex(usage: material.tags.usage.rawValue, viral: material.tags.viral.rawValue)
            let fileIndex = MaterialIndex(
                title: material.title,
                description: material.description,
                tags: tagsIndex,
                updatedAt: material.localUpdatedAt,
                fileSize: material.fileSize,
                fileModifiedAt: material.fileModifiedAt
            )
            filesDict[material.filename] = fileIndex
        }

        let indexFile = IndexFile(
            version: 1,
            updatedAt: Date(),
            files: filesDict
        )

        try await client.uploadIndexFile(path: ".material_index.json", index: indexFile)
        try await touchSyncVersion()

        localSyncVersion = Date()
        saveLocalSyncVersion()

        await MainActor.run {
            status = SyncStatus(state: .idle, lastSyncAt: Date(), progress: 1.0)
        }
    }

    private func touchSyncVersion() async throws {
        let dateString = ISO8601DateFormatter().string(from: Date())
        let data = dateString.data(using: .utf8)!
        try await client.uploadFile(path: ".sync_version", data: data, contentType: "text/plain")
    }

    private func loadLocalSyncVersion() {
        if let dateString = UserDefaults.standard.string(forKey: "last_sync_version"),
           let date = ISO8601DateFormatter().date(from: dateString) {
            localSyncVersion = date
        }
    }

    private func saveLocalSyncVersion() {
        if let date = localSyncVersion {
            UserDefaults.standard.set(ISO8601DateFormatter().string(from: date), forKey: "last_sync_version")
        }
    }
}
