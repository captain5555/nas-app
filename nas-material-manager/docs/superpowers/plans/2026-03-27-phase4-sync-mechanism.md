# 第四阶段：NAS 数据同步机制

**Goal:** 完成双端的 NAS 数据同步功能，实现索引文件的上传/下载、轮询同步、版本冲突处理

---

## Task 1: iOS 端 - 完善 SyncManager

**Files:**
- Create: `ios/NASMaterialManager/NASMaterialManager/Data/Sync/SyncManager.swift`
- Create: `ios/NASMaterialManager/NASMaterialManager/Data/Sync/SyncState.swift`
- Update: `ios/NASMaterialManager/NASMaterialManager/Data/WebDAV/WebDAVClient.swift`
- Update: `ios/NASMaterialManager/NASMaterialManager/Presentation/Features/Browser/BrowserViewModel.swift`

- [ ] **Step 1: 创建 SyncState.swift**

```swift
import Foundation

enum SyncState {
    case idle
    case checking
    case downloading
    case uploading
    case error(String)
}

struct SyncStatus {
    let state: SyncState
    let lastSyncAt: Date?
    let progress: Double?
}
```

- [ ] **Step 2: 创建 SyncManager.swift**

```swift
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
            if let existing = materialRepo.fetchMaterial(by: path) {
                if fileIndex.updatedAt > existing.localUpdatedAt {
                    var updated = existing
                    updated.title = fileIndex.title
                    updated.description = fileIndex.description
                    updated.tags.usage = UsageTag(rawValue: fileIndex.tags.usage) ?? .unused
                    updated.tags.viral = ViralTag(rawValue: fileIndex.tags.viral) ?? .notViral
                    updated.localUpdatedAt = fileIndex.updatedAt
                    materialRepo.updateMaterial(updated)
                }
            } else {
                let material = Material(
                    filename: filename,
                    path: path,
                    title: fileIndex.title,
                    description: fileIndex.description,
                    tags: MaterialTags(
                        usage: UsageTag(rawValue: fileIndex.tags.usage) ?? .unused,
                        viral: ViralTag(rawValue: fileIndex.tags.viral) ?? .notViral
                    ),
                    fileSize: fileIndex.fileSize,
                    fileModifiedAt: fileIndex.fileModifiedAt,
                    localUpdatedAt: fileIndex.updatedAt,
                    folderID: nil
                )
                materialRepo.saveMaterial(material)
            }
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
```

- [ ] **Step 3: 更新 WebDAVClient.swift，添加缺失的方法**

（补充 IndexFile 相关的类型引用）

- [ ] **Step 4: 更新 BrowserViewModel.swift，集成 SyncManager**

```swift
// 在 BrowserViewModel 中添加 SyncManager 的引用和调用
```

---

## Task 2: iOS 端 - 更新 MaterialDetail 支持上传

**Files:**
- Update: `ios/NASMaterialManager/NASMaterialManager/Presentation/Features/MaterialDetail/MaterialDetailViewModel.swift`

- [ ] **Step 1: 更新 MaterialDetailViewModel，保存后触发上传**

```swift
// 添加 SyncManager 依赖
// 在 save() 方法成功后，调用 syncManager.uploadChanges()
```

---

## Task 3: Flutter 端 - 完善 SyncManager

**Files:**
- Create: `flutter/lib/data/sync/sync_manager.dart`
- Create: `flutter/lib/data/sync/sync_state.dart`
- Update: `flutter/lib/providers/browser_provider.dart`
- Update: `flutter/lib/providers/material_detail_provider.dart`

- [ ] **Step 1: 创建 sync_state.dart**

```dart
enum SyncState { idle, checking, downloading, uploading, error }

class SyncStatus {
  final SyncState state;
  final DateTime? lastSyncAt;
  final double? progress;
  final String? errorMessage;

  SyncStatus({
    required this.state,
    this.lastSyncAt,
    this.progress,
    this.errorMessage,
  });

  SyncStatus copyWith({
    SyncState? state,
    DateTime? lastSyncAt,
    double? progress,
    String? errorMessage,
  }) {
    return SyncStatus(
      state: state ?? this.state,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
```

- [ ] **Step 2: 创建 sync_manager.dart**

```dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../webdav/webdav_client.dart';
import '../models/index_file.dart';
import '../models/material.dart';
import '../hive/hive_service.dart';
import 'sync_state.dart';

class SyncManager extends ChangeNotifier {
  SyncStatus _status = SyncStatus(state: SyncState.idle);
  SyncStatus get status => _status;

  final WebDAVClient client;
  final HiveService hiveService;
  Timer? _timer;
  static const _pollInterval = Duration(seconds: 45);

  DateTime? _localSyncVersion;

  SyncManager({required this.client, required this.hiveService}) {
    _loadLocalSyncVersion();
  }

  void startPolling() {
    stopPolling();
    _timer = Timer.periodic(_pollInterval, (_) => _checkAndSync());
    _checkAndSync();
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkAndSync() async {
    _updateStatus(SyncStatus(state: SyncState.checking, lastSyncAt: _status.lastSyncAt));

    try {
      final remoteVersion = await _fetchRemoteVersion();
      if (_localSyncVersion == null || remoteVersion.isAfter(_localSyncVersion!)) {
        await _downloadAndMergeChanges();
        _localSyncVersion = remoteVersion;
        await _saveLocalSyncVersion();
      }
      _updateStatus(SyncStatus(state: SyncState.idle, lastSyncAt: DateTime.now()));
    } catch (e) {
      _updateStatus(SyncStatus(
        state: SyncState.error,
        lastSyncAt: _status.lastSyncAt,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<DateTime> _fetchRemoteVersion() async {
    try {
      final data = await client.downloadFile('.sync_version');
      final dateString = utf8.decode(data);
      if (dateString.isNotEmpty) {
        return DateTime.parse(dateString);
      }
    } catch (e) {
    }
    return DateTime.fromMicrosecondsSinceEpoch(0);
  }

  Future<void> _downloadAndMergeChanges() async {
    _updateStatus(SyncStatus(
      state: SyncState.downloading,
      lastSyncAt: _status.lastSyncAt,
      progress: 0.0,
    ));

    final indexFile = await client.downloadIndexFile('.material_index.json');
    if (indexFile != null) {
      await _mergeIndexFile(indexFile, '/');
    }

    _updateStatus(SyncStatus(
      state: SyncState.downloading,
      lastSyncAt: _status.lastSyncAt,
      progress: 1.0,
    ));
  }

  Future<void> _mergeIndexFile(IndexFile index, String folderPath) async {
    for (final entry in index.files.entries) {
      final filename = entry.key;
      final fileIndex = entry.value;
      final path = folderPath.isEmpty ? filename : '$folderPath/$filename';

      final existing = hiveService.getMaterial(path);
      if (existing != null) {
        if (fileIndex.updatedAt.isAfter(existing.localUpdatedAt)) {
          final updated = existing.copyWith(
            title: fileIndex.title,
            description: fileIndex.description,
            tags: existing.tags.copyWith(
              usage: UsageTag.fromRawValue(fileIndex.tags.usage),
              viral: ViralTag.fromRawValue(fileIndex.tags.viral),
            ),
            localUpdatedAt: fileIndex.updatedAt,
          );
          await hiveService.updateMaterial(updated);
        }
      } else {
        final material = Material(
          filename: filename,
          path: path,
          title: fileIndex.title,
          description: fileIndex.description,
          tags: MaterialTags(
            usage: UsageTag.fromRawValue(fileIndex.tags.usage),
            viral: ViralTag.fromRawValue(fileIndex.tags.viral),
          ),
          fileSize: fileIndex.fileSize,
          fileModifiedAt: fileIndex.fileModifiedAt,
          localUpdatedAt: fileIndex.updatedAt,
        );
        await hiveService.saveMaterial(material);
      }
    }
    notifyListeners();
  }

  Future<void> uploadChanges(List<Material> materials, String folderPath) async {
    _updateStatus(SyncStatus(
      state: SyncState.uploading,
      lastSyncAt: _status.lastSyncAt,
      progress: 0.0,
    ));

    final filesDict = <String, MaterialIndex>{};
    for (final material in materials) {
      final tagsIndex = TagsIndex(
        usage: material.tags.usage.rawValue,
        viral: material.tags.viral.rawValue,
      );
      final fileIndex = MaterialIndex(
        title: material.title,
        description: material.description,
        tags: tagsIndex,
        updatedAt: material.localUpdatedAt,
        fileSize: material.fileSize,
        fileModifiedAt: material.fileModifiedAt,
      );
      filesDict[material.filename] = fileIndex;
    }

    final indexFile = IndexFile(
      version: 1,
      updatedAt: DateTime.now().toUtc(),
      files: filesDict,
    );

    await client.uploadIndexFile('.material_index.json', indexFile);
    await _touchSyncVersion();

    _localSyncVersion = DateTime.now().toUtc();
    await _saveLocalSyncVersion();

    _updateStatus(SyncStatus(
      state: SyncState.idle,
      lastSyncAt: DateTime.now(),
      progress: 1.0,
    ));
  }

  Future<void> _touchSyncVersion() async {
    final dateString = DateTime.now().toUtc().toIso8601String();
    final data = utf8.encode(dateString);
    await client.uploadFile('.sync_version', data, contentType: 'text/plain');
  }

  Future<void> _loadLocalSyncVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString('last_sync_version');
    if (dateString != null) {
      _localSyncVersion = DateTime.tryParse(dateString);
    }
  }

  Future<void> _saveLocalSyncVersion() async {
    final prefs = await SharedPreferences.getInstance();
    if (_localSyncVersion != null) {
      await prefs.setString('last_sync_version', _localSyncVersion!.toIso8601String());
    }
  }

  void _updateStatus(SyncStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }
}
```

- [ ] **Step 3: 更新 Provider 层，集成 SyncManager**

在 BrowserProvider 和 MaterialDetailProvider 中添加 SyncManager 支持。

---

## Task 4: 最终测试与优化

**Files:**
- Update: README.md
- Create: `docs/COMPLETE_FEATURES.md`

- [ ] **Step 1: 最终功能验证**
  - [ ] iOS 端可以从 NAS 下载索引
  - [ ] iOS 端可以上传修改到 NAS
  - [ ] Flutter 端可以从 NAS 下载索引
  - [ ] Flutter 端可以上传修改到 NAS
  - [ ] 双端数据互通测试

- [ ] **Step 2: 更新最终文档**
