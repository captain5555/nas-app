# 第三阶段：Flutter 桌面端

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development

**Goal:** 创建 Flutter 桌面端项目，实现与 iOS 端相同的功能：登录、浏览、素材详情编辑，使用 Hive 本地数据库

**Tech Stack:** Flutter 3.19+, Dart 3.3+, Hive, Provider

---

## Task 1: 初始化 Flutter 项目

**Files:**
- Create: `flutter/pubspec.yaml`
- Create: `flutter/lib/main.dart`
- Create: `flutter/lib/app.dart`

- [ ] **Step 1: 创建 pubspec.yaml**

```yaml
name: nas_material_manager
description: NAS Material Manager Desktop App
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  http: ^1.2.0
  path_provider: ^2.1.2
  shared_preferences: ^2.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

- [ ] **Step 2: 创建 main.dart**

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const NASMaterialManagerApp());
}
```

- [ ] **Step 3: 创建 app.dart**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/login/login_screen.dart';
import 'screens/main_tab_screen.dart';
import 'theme/app_theme.dart';

class NASMaterialManagerApp extends StatelessWidget {
  const NASMaterialManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          return MaterialApp(
            title: 'NAS 素材管理',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            home: appProvider.isLoggedIn
                ? const MainTabScreen()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}
```

---

## Task 2: 创建数据模型与 Hive 适配器

**Files:**
- Create: `flutter/lib/data/models/material_tags.dart`
- Create: `flutter/lib/data/models/material.dart`
- Create: `flutter/lib/data/models/folder.dart`
- Create: `flutter/lib/data/models/webdav_config.dart`
- Create: `flutter/lib/data/models/index_file.dart`
- Create: `flutter/lib/data/hive/hive_service.dart`
- Create: `flutter/lib/data/hive/hive_adapters.dart`

- [ ] **Step 1: 创建 material_tags.dart**

```dart
enum UsageTag {
  unused('unused', '未使用'),
  used('used', '使用过');

  final String rawValue;
  final String displayName;
  const UsageTag(this.rawValue, this.displayName);

  static UsageTag fromRawValue(String value) {
    return UsageTag.values.firstWhere(
      (e) => e.rawValue == value,
      orElse: () => UsageTag.unused,
    );
  }
}

enum ViralTag {
  notViral('not_viral', '未爆'),
  viral('viral', '爆款');

  final String rawValue;
  final String displayName;
  const ViralTag(this.rawValue, this.displayName);

  static ViralTag fromRawValue(String value) {
    return ViralTag.values.firstWhere(
      (e) => e.rawValue == value,
      orElse: () => ViralTag.notViral,
    );
  }
}

class MaterialTags {
  final UsageTag usage;
  final ViralTag viral;

  MaterialTags({
    required this.usage,
    required this.viral,
  });

  MaterialTags copyWith({
    UsageTag? usage,
    ViralTag? viral,
  }) {
    return MaterialTags(
      usage: usage ?? this.usage,
      viral: viral ?? this.viral,
    );
  }
}
```

- [ ] **Step 2: 创建 webdav_config.dart**

```dart
class WebDAVConfig {
  final String serverURL;
  final String username;
  final String password;

  WebDAVConfig({
    required this.serverURL,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'server_url': serverURL,
      'username': username,
      'password': password,
    };
  }

  factory WebDAVConfig.fromJson(Map<String, dynamic> json) {
    return WebDAVConfig(
      serverURL: json['server_url'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
    );
  }
}
```

- [ ] **Step 3: 创建 material.dart**

```dart
import 'package:uuid/uuid.dart';
import 'material_tags.dart';

class Material {
  final String id;
  final String filename;
  final String path;
  String? title;
  String? description;
  MaterialTags tags;
  final int? fileSize;
  final DateTime? fileModifiedAt;
  DateTime localUpdatedAt;
  final String? folderId;

  Material({
    String? id,
    required this.filename,
    required this.path,
    this.title,
    this.description,
    required this.tags,
    this.fileSize,
    this.fileModifiedAt,
    DateTime? localUpdatedAt,
    this.folderId,
  })  : id = id ?? const Uuid().v4(),
        localUpdatedAt = localUpdatedAt ?? DateTime.now().toUtc();

  bool get isVideo {
    final ext = filename.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv'].contains(ext);
  }

  Material copyWith({
    String? id,
    String? filename,
    String? path,
    String? title,
    String? description,
    MaterialTags? tags,
    int? fileSize,
    DateTime? fileModifiedAt,
    DateTime? localUpdatedAt,
    String? folderId,
  }) {
    return Material(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      path: path ?? this.path,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      fileSize: fileSize ?? this.fileSize,
      fileModifiedAt: fileModifiedAt ?? this.fileModifiedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      folderId: folderId ?? this.folderId,
    );
  }
}
```

- [ ] **Step 4: 创建 folder.dart**

```dart
import 'package:uuid/uuid.dart';

class Folder {
  final String id;
  final String path;
  final String name;
  final String? parentFolderId;

  Folder({
    String? id,
    required this.path,
    required this.name,
    this.parentFolderId,
  }) : id = id ?? const Uuid().v4();
}
```

- [ ] **Step 5: 创建 index_file.dart**

```dart
class IndexFile {
  final int version;
  final DateTime updatedAt;
  final Map<String, MaterialIndex> files;

  IndexFile({
    required this.version,
    required this.updatedAt,
    required this.files,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'updated_at': updatedAt.toIso8601String(),
      'files': files.map((k, v) => MapEntry(k, v.toJson())),
    };
  }

  factory IndexFile.fromJson(Map<String, dynamic> json) {
    return IndexFile(
      version: json['version'] as int,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      files: (json['files'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, MaterialIndex.fromJson(v as Map<String, dynamic>)),
      ),
    );
  }
}

class MaterialIndex {
  final String? title;
  final String? description;
  final TagsIndex tags;
  final DateTime updatedAt;
  final int? fileSize;
  final DateTime? fileModifiedAt;

  MaterialIndex({
    this.title,
    this.description,
    required this.tags,
    required this.updatedAt,
    this.fileSize,
    this.fileModifiedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'tags': tags.toJson(),
      'updated_at': updatedAt.toIso8601String(),
      'file_size': fileSize,
      'file_modified_at': fileModifiedAt?.toIso8601String(),
    };
  }

  factory MaterialIndex.fromJson(Map<String, dynamic> json) {
    return MaterialIndex(
      title: json['title'] as String?,
      description: json['description'] as String?,
      tags: TagsIndex.fromJson(json['tags'] as Map<String, dynamic>),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      fileSize: json['file_size'] as int?,
      fileModifiedAt: json['file_modified_at'] != null
          ? DateTime.parse(json['file_modified_at'] as String)
          : null,
    );
  }
}

class TagsIndex {
  final String usage;
  final String viral;

  TagsIndex({
    required this.usage,
    required this.viral,
  });

  Map<String, dynamic> toJson() {
    return {
      'usage': usage,
      'viral': viral,
    };
  }

  factory TagsIndex.fromJson(Map<String, dynamic> json) {
    return TagsIndex(
      usage: json['usage'] as String,
      viral: json['viral'] as String,
    );
  }
}
```

- [ ] **Step 6: 创建 hive_adapters.dart**

```dart
import 'package:hive/hive.dart';
import '../models/material_tags.dart';
import '../models/material.dart';
import '../models/folder.dart';

class MaterialAdapter extends TypeAdapter<Material> {
  @override
  final int typeId = 1;

  @override
  Material read(BinaryReader reader) {
    return Material(
      id: reader.readString(),
      filename: reader.readString(),
      path: reader.readString(),
      title: reader.readString(),
      description: reader.readString(),
      tags: MaterialTags(
        usage: UsageTag.fromRawValue(reader.readString()),
        viral: ViralTag.fromRawValue(reader.readString()),
      ),
      fileSize: reader.readInt(),
      fileModifiedAt: reader.readString() != null
          ? DateTime.parse(reader.readString()!)
          : null,
      localUpdatedAt: DateTime.parse(reader.readString()),
      folderId: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Material obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.filename);
    writer.writeString(obj.path);
    writer.writeString(obj.title ?? '');
    writer.writeString(obj.description ?? '');
    writer.writeString(obj.tags.usage.rawValue);
    writer.writeString(obj.tags.viral.rawValue);
    writer.writeInt(obj.fileSize ?? 0);
    writer.writeString(obj.fileModifiedAt?.toIso8601String() ?? '');
    writer.writeString(obj.localUpdatedAt.toIso8601String());
    writer.writeString(obj.folderId ?? '');
  }
}

class FolderAdapter extends TypeAdapter<Folder> {
  @override
  final int typeId = 2;

  @override
  Folder read(BinaryReader reader) {
    return Folder(
      id: reader.readString(),
      path: reader.readString(),
      name: reader.readString(),
      parentFolderId: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Folder obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.path);
    writer.writeString(obj.name);
    writer.writeString(obj.parentFolderId ?? '');
  }
}
```

- [ ] **Step 7: 创建 hive_service.dart**

```dart
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
```

---

## Task 3: 创建 WebDAV 客户端

**Files:**
- Create: `flutter/lib/data/webdav/webdav_client.dart`
- Create: `flutter/lib/data/webdav/webdav_config.dart`

- [ ] **Step 1: 创建 webdav_config.dart**

```dart
class WebDAVConfiguration {
  final Uri serverURL;
  final String username;
  final String password;

  WebDAVConfiguration({
    required this.serverURL,
    required this.username,
    required this.password,
  });

  String get authHeader {
    final credentials = '$username:$password';
    final bytes = utf8.encode(credentials);
    final base64 = base64Encode(bytes);
    return 'Basic $base64';
  }
}
```

- [ ] **Step 2: 创建 webdav_client.dart**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'webdav_config.dart';
import '../models/index_file.dart';

class WebDAVClient {
  final WebDAVConfiguration config;
  final http.Client client;

  WebDAVClient({required this.config, http.Client? client})
      : client = client ?? http.Client();

  Future<bool> testConnection() async {
    final request = _makeRequest(path: '', method: 'PROPFIND');
    final response = await client.send(request);
    return response.statusCode == 207;
  }

  Future<Uint8List> downloadFile(String path) async {
    final request = _makeRequest(path: path, method: 'GET');
    final response = await client.send(request);
    return await response.stream.toBytes();
  }

  Future<void> uploadFile(
    String path,
    Uint8List data, {
    String contentType = 'application/octet-stream',
  }) async {
    final request = _makeRequest(path: path, method: 'PUT');
    request.headers['Content-Type'] = contentType;
    request.bodyBytes = data;
    await client.send(request);
  }

  Future<void> uploadIndexFile(String path, IndexFile index) async {
    final jsonData = jsonEncode(index.toJson());
    await uploadFile(
      path,
      utf8.encode(jsonData),
      contentType: 'application/json',
    );
  }

  Future<IndexFile?> downloadIndexFile(String path) async {
    try {
      final data = await downloadFile(path);
      final json = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
      return IndexFile.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  http.Request _makeRequest({
    required String path,
    required String method,
  }) {
    final url = config.serverURL.resolve(path);
    final request = http.Request(method, url);
    request.headers['Authorization'] = config.authHeader;
    return request;
  }
}
```

---

## Task 4: 创建 Providers / ViewModels

**Files:**
- Create: `flutter/lib/providers/app_provider.dart`
- Create: `flutter/lib/providers/browser_provider.dart`
- Create: `flutter/lib/providers/login_provider.dart`
- Create: `flutter/lib/providers/material_detail_provider.dart`

- [ ] **Step 1: 创建 app_provider.dart**

```dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/webdav_config.dart';

class AppProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  WebDAVConfig? _webdavConfig;

  bool get isLoggedIn => _isLoggedIn;
  WebDAVConfig? get webdavConfig => _webdavConfig;

  AppProvider() {
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString('webdav_config');
    if (configJson != null) {
      _webdavConfig = WebDAVConfig.fromJson(
        jsonDecode(configJson) as Map<String, dynamic>,
      );
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<void> login(WebDAVConfig config) async {
    _webdavConfig = config;
    _isLoggedIn = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('webdav_config', jsonEncode(config.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    _webdavConfig = null;
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('webdav_config');
    notifyListeners();
  }
}
```

- [ ] **Step 2: 创建 login_provider.dart**

```dart
import 'package:flutter/foundation.dart';
import '../data/webdav/webdav_client.dart';
import '../data/webdav/webdav_config.dart' as client_config;
import '../data/models/webdav_config.dart';
import '../providers/app_provider.dart';

class LoginProvider extends ChangeNotifier {
  final AppProvider appProvider;

  String serverURL = '';
  String username = '';
  String password = '';
  bool isLoading = false;
  String? errorMessage;

  LoginProvider(this.appProvider) {
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    if (appProvider.webdavConfig != null) {
      serverURL = appProvider.webdavConfig!.serverURL;
      username = appProvider.webdavConfig!.username;
      password = appProvider.webdavConfig!.password;
      notifyListeners();
    }
  }

  Future<void> login() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final uri = Uri.parse(serverURL);
      final config = client_config.WebDAVConfiguration(
        serverURL: uri,
        username: username,
        password: password,
      );
      final client = WebDAVClient(config: config);
      final success = await client.testConnection();

      if (success) {
        final appConfig = WebDAVConfig(
          serverURL: serverURL,
          username: username,
          password: password,
        );
        await appProvider.login(appConfig);
      } else {
        errorMessage = '连接失败，请检查配置';
      }
    } catch (e) {
      errorMessage = '连接错误: $e';
    }

    isLoading = false;
    notifyListeners();
  }
}
```

- [ ] **Step 3: 创建 browser_provider.dart**

```dart
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
```

- [ ] **Step 4: 创建 material_detail_provider.dart**

```dart
import 'package:flutter/foundation.dart';
import '../data/models/material.dart';
import '../data/models/material_tags.dart';
import '../data/hive/hive_service.dart';

class MaterialDetailProvider extends ChangeNotifier {
  final HiveService hiveService;

  Material material;
  String titleText;
  String descriptionText;
  UsageTag usageTag;
  ViralTag viralTag;
  bool isSaving = false;
  String? errorMessage;

  MaterialDetailProvider(this.hiveService, this.material)
      : titleText = material.title ?? '',
        descriptionText = material.description ?? '',
        usageTag = material.tags.usage,
        viralTag = material.tags.viral;

  Future<void> save() async {
    isSaving = true;
    notifyListeners();

    final updated = material.copyWith(
      title: titleText.isEmpty ? null : titleText,
      description: descriptionText.isEmpty ? null : descriptionText,
      tags: material.tags.copyWith(
        usage: usageTag,
        viral: viralTag,
      ),
      localUpdatedAt: DateTime.now().toUtc(),
    );

    await hiveService.updateMaterial(updated);
    material = updated;

    isSaving = false;
    notifyListeners();
  }
}
```

---

## Task 5: 创建 UI 组件与页面

**Files:**
- Create: `flutter/lib/theme/app_theme.dart`
- Create: `flutter/lib/widgets/tag_badge.dart`
- Create: `flutter/lib/widgets/material_grid_item.dart`
- Create: `flutter/lib/screens/login/login_screen.dart`
- Create: `flutter/lib/screens/browser/browser_screen.dart`
- Create: `flutter/lib/screens/material_detail/material_detail_screen.dart`
- Create: `flutter/lib/screens/main_tab_screen.dart`
- Create: `flutter/lib/screens/settings/settings_screen.dart`

- [ ] **Step 1: 创建 app_theme.dart**

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    );
  }

  static ThemeData get dark {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }
}
```

- [ ] **Step 2: 创建 tag_badge.dart**

```dart
import 'package:flutter/material.dart';

class TagBadge extends StatelessWidget {
  final String text;
  final Color color;

  const TagBadge({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: 创建 material_grid_item.dart**

```dart
import 'package:flutter/material.dart';
import '../data/models/material.dart';
import 'tag_badge.dart';

class MaterialGridItem extends StatelessWidget {
  final Material material;
  final VoidCallback onTap;

  const MaterialGridItem({
    super.key,
    required this.material,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: colorScheme.surfaceVariant,
                child: Icon(
                  material.isVideo ? Icons.video_library : Icons.photo,
                  size: 48,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.title ?? material.filename,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: [
                      TagBadge(
                        text: material.tags.usage.displayName,
                        color: material.tags.usage == UsageTag.used
                            ? Colors.green
                            : Colors.orange,
                      ),
                      TagBadge(
                        text: material.tags.viral.displayName,
                        color: material.tags.viral == ViralTag.viral
                            ? Colors.red
                            : Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 创建 login_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/login_provider.dart';
import '../../providers/app_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginProvider(context.read<AppProvider>()),
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            child: Consumer<LoginProvider>(
              builder: (context, provider, _) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.folder, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'NAS 素材管理',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'WebDAV 地址',
                            hintText: 'http://...',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => provider.serverURL = v,
                          controller: TextEditingController(text: provider.serverURL),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: '用户名',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => provider.username = v,
                          controller: TextEditingController(text: provider.username),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: '密码',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          onChanged: (v) => provider.password = v,
                          controller: TextEditingController(text: provider.password),
                        ),
                        if (provider.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage!,
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: provider.isLoading
                                ? null
                                : () => provider.login(),
                            child: provider.isLoading
                                ? const CircularProgressIndicator()
                                : const Text('登录'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: 创建 browser_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/browser_provider.dart';
import '../../data/hive/hive_service.dart';
import '../../widgets/material_grid_item.dart';
import '../material_detail/material_detail_screen.dart';

class BrowserScreen extends StatelessWidget {
  const BrowserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BrowserProvider(context.read<HiveService>()),
      child: Consumer<BrowserProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(provider.currentFolder?.name ?? '浏览'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => provider.refresh(),
                ),
              ],
            ),
            body: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.materials.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('暂无素材', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: provider.materials.length,
                        itemBuilder: (context, index) {
                          final material = provider.materials[index];
                          return MaterialGridItem(
                            material: material,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => MaterialDetailScreen(material: material),
                                ),
                              );
                            },
                          );
                        },
                      ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 6: 创建 material_detail_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/material_detail_provider.dart';
import '../../data/models/material.dart';
import '../../data/hive/hive_service.dart';

class MaterialDetailScreen extends StatelessWidget {
  final Material material;

  const MaterialDetailScreen({super.key, required this.material});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MaterialDetailProvider(
        context.read<HiveService>(),
        material,
      ),
      child: Consumer<MaterialDetailProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('素材详情'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                TextButton(
                  onPressed: provider.isSaving
                      ? null
                      : () async {
                          await provider.save();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                  child: provider.isSaving
                      ? const CircularProgressIndicator()
                      : const Text('保存'),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Icon(
                        provider.material.isVideo ? Icons.video_library : Icons.photo,
                        size: 96,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '标题',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: provider.titleText,
                  onChanged: (v) => provider.titleText = v,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '描述',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  initialValue: provider.descriptionText,
                  onChanged: (v) => provider.descriptionText = v,
                ),
                const SizedBox(height: 24),
                const Text('使用状态', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<UsageTag>(
                  segments: UsageTag.values
                      .map((tag) => ButtonSegment(
                            value: tag,
                            label: Text(tag.displayName),
                          ))
                      .toList(),
                  selected: {provider.usageTag},
                  onSelectionChanged: (s) => provider.usageTag = s.first,
                ),
                const SizedBox(height: 24),
                const Text('爆款标签', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<ViralTag>(
                  segments: ViralTag.values
                      .map((tag) => ButtonSegment(
                            value: tag,
                            label: Text(tag.displayName),
                          ))
                      .toList(),
                  selected: {provider.viralTag},
                  onSelectionChanged: (s) => provider.viralTag = s.first,
                ),
                const SizedBox(height: 24),
                Text(
                  '文件名: ${provider.material.filename}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (provider.material.fileSize != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '大小: ${_formatSize(provider.material.fileSize!)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
```

- [ ] **Step 7: 创建 settings_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          const SectionHeader(title: 'NAS 配置'),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('服务器设置'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // 导航到服务器设置页
            },
          ),
          const SectionHeader(title: '数据'),
          ListTile(
            leading: const Icon(Icons.cleaning_services),
            title: const Text('清除缓存'),
            onTap: () {
              // 清除缓存
            },
          ),
          const SectionHeader(title: '关于'),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('版本'),
            trailing: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
```

- [ ] **Step 8: 创建 main_tab_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'browser/browser_screen.dart';
import 'settings/settings_screen.dart';

class MainTabScreen extends StatelessWidget {
  const MainTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: 0,
        children: const [
          BrowserScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: '浏览',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
```

---

## Task 6: 初始化与整合

**Files:**
- Update: `flutter/lib/main.dart`
- Create: `flutter/lib/service_locator.dart` (可选)

- [ ] **Step 1: 更新 main.dart，初始化 Hive**

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/hive/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final hiveService = HiveService();
  await HiveService.init();
  runApp(
    Provider.value(
      value: hiveService,
      child: const NASMaterialManagerApp(),
    ),
  );
}
```

---

## 第三阶段完成验证

- [ ] Flutter 项目可以编译运行
- [ ] 登录页面显示正常
- [ ] 浏览页显示素材网格和标签徽章
- [ ] 可以进入素材详情页
- [ ] 可以编辑并保存到 Hive
