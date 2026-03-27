import 'package:flutter/foundation.dart';
import '../data/models/folder.dart';
import '../data/models/material.dart';
import '../data/models/material_tags.dart';
import '../data/hive/hive_service.dart';

class BrowserProvider extends ChangeNotifier {
  final HiveService hiveService;

  List<Folder> folders = [];
  List<Material> materials = [];
  Folder? currentFolder;
  bool isLoading = false;
  String? errorMessage;

  BrowserProvider(this.hiveService) {
    _loadSampleData();
  }

  void _loadSampleData() {
    final sampleFolder = Folder(
      path: '/',
      name: '根目录',
    );

    final sampleMaterials = [
      Material(
        filename: '海滩日落.jpg',
        path: '/海滩日落.jpg',
        title: '三亚海滩日落',
        description: '美丽的海滩日落风景，适合发朋友圈',
        tags: MaterialTags(usage: UsageTag.used, viral: ViralTag.viral),
        fileSize: 2150400,
        fileModifiedAt: DateTime.now().toUtc().subtract(const Duration(days: 7)),
        folderId: sampleFolder.id,
      ),
      Material(
        filename: '城市夜景.mp4',
        path: '/城市夜景.mp4',
        title: '上海陆家嘴夜景',
        description: '无人机拍摄的城市夜景',
        tags: MaterialTags(usage: UsageTag.unused, viral: ViralTag.notViral),
        fileSize: 104857600,
        fileModifiedAt: DateTime.now().toUtc().subtract(const Duration(days: 3)),
        folderId: sampleFolder.id,
      ),
      Material(
        filename: '美食照片.jpg',
        path: '/美食照片.jpg',
        tags: MaterialTags(usage: UsageTag.unused, viral: ViralTag.notViral),
        fileSize: 1536000,
        fileModifiedAt: DateTime.now().toUtc().subtract(const Duration(days: 1)),
        folderId: sampleFolder.id,
      ),
    ];

    currentFolder = sampleFolder;
    materials = sampleMaterials;
  }

  void selectFolder(Folder folder) {
    currentFolder = folder;
    materials = hiveService.getMaterialsForFolder(folder.id);
    notifyListeners();
  }

  Future<void> refresh() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    isLoading = false;
    notifyListeners();
  }
}
