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
