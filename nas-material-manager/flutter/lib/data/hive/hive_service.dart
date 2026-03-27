import 'package:hive_flutter/hive_flutter.dart';
import '../models/material.dart';
import '../models/folder.dart';
import 'hive_adapters.dart';

class HiveService {
  static const String materialBoxName = 'materials';
  static const String folderBoxName = 'folders';

  static Future<void> init() async {
    Hive.registerAdapter(MaterialAdapter());
    Hive.registerAdapter(FolderAdapter());
    await Hive.openBox<Material>(materialBoxName);
    await Hive.openBox<Folder>(folderBoxName);
  }

  Box<Material> get materialBox => Hive.box<Material>(materialBoxName);
  Box<Folder> get folderBox => Hive.box<Folder>(folderBoxName);

  Future<void> saveMaterial(Material material) async {
    await materialBox.put(material.id, material);
  }

  Future<void> updateMaterial(Material material) async {
    await materialBox.put(material.id, material);
  }

  List<Material> getMaterialsForFolder(String folderId) {
    return materialBox.values.where((m) => m.folderId == folderId).toList();
  }

  Material? getMaterial(String id) {
    return materialBox.get(id);
  }

  Future<void> saveFolder(Folder folder) async {
    await folderBox.put(folder.id, folder);
  }

  List<Folder> getAllFolders() {
    return folderBox.values.toList();
  }

  Folder? getFolder(String id) {
    return folderBox.get(id);
  }
}
