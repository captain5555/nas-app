//
//  main.dart
//  单文件版本 - 可以直接运行
//
//  使用步骤:
//  1. 安装 Flutter SDK: https://flutter.dev/docs/get-started/install
//  2. 启用桌面支持:
//     flutter config --enable-windows-desktop
//     flutter config --enable-macos-desktop
//  3. 创建项目: flutter create --platforms=windows,macos nas_material_manager
//  4. 替换 lib/main.dart 的内容为此文件
//  5. 运行: flutter run -d windows 或 flutter run -d macos
//

import 'package:flutter/material.dart';
import 'dart:convert';

// ==================== 数据模型 ====================

enum UsageTag {
  unused('unused', '未使用'),
  used('used', '使用过');

  final String rawValue;
  final String displayName;
  const UsageTag(this.rawValue, this.displayName);

  Color get color {
    switch (this) {
      case UsageTag.unused:
        return Colors.orange;
      case UsageTag.used:
        return Colors.green;
    }
  }
}

enum ViralTag {
  notViral('not_viral', '未爆'),
  viral('viral', '爆款');

  final String rawValue;
  final String displayName;
  const ViralTag(this.rawValue, this.displayName);

  Color get color {
    switch (this) {
      case ViralTag.notViral:
        return Colors.blue;
      case ViralTag.viral:
        return Colors.red;
    }
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

class Material {
  final String id;
  final String filename;
  String? title;
  String? description;
  MaterialTags tags;
  final int? fileSize;

  Material({
    required this.id,
    required this.filename,
    this.title,
    this.description,
    required this.tags,
    this.fileSize,
  });

  String get displayTitle => title ?? filename;

  bool get isVideo {
    final ext = filename.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv'].contains(ext);
  }

  Material copyWith({
    String? id,
    String? filename,
    String? title,
    String? description,
    MaterialTags? tags,
    int? fileSize,
  }) {
    return Material(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      fileSize: fileSize ?? this.fileSize,
    );
  }
}

// ==================== App State ====================

class AppState extends ChangeNotifier {
  bool isLoggedIn = false;
  String serverURL = '';
  String username = '';
  String password = '';
  List<Material> materials = [];

  AppState() {
    _loadSampleData();
  }

  void _loadSampleData() {
    materials = [
      Material(
        id: '1',
        filename: '海滩日落.jpg',
        title: '三亚海滩日落',
        description: '美丽的海滩日落风景，适合发朋友圈',
        tags: MaterialTags(usage: UsageTag.used, viral: ViralTag.viral),
        fileSize: 2150400,
      ),
      Material(
        id: '2',
        filename: '城市夜景.mp4',
        title: '上海陆家嘴夜景',
        description: '无人机拍摄的城市夜景',
        tags: MaterialTags(usage: UsageTag.unused, viral: ViralTag.notViral),
        fileSize: 104857600,
      ),
      Material(
        id: '3',
        filename: '美食照片.jpg',
        tags: MaterialTags(usage: UsageTag.unused, viral: ViralTag.notViral),
        fileSize: 1536000,
      ),
      Material(
        id: '4',
        filename: '风景照.png',
        title: '雪山风景',
        description: '去年冬天拍的雪山',
        tags: MaterialTags(usage: UsageTag.used, viral: ViralTag.notViral),
        fileSize: 3145728,
      ),
      Material(
        id: '5',
        filename: '产品图.jpg',
        title: '产品展示图',
        description: '电商产品主图',
        tags: MaterialTags(usage: UsageTag.used, viral: ViralTag.viral),
        fileSize: 827392,
      ),
      Material(
        id: '6',
        filename: '宣传片.mp4',
        tags: MaterialTags(usage: UsageTag.unused, viral: ViralTag.notViral),
        fileSize: 256897234,
      ),
    ];
  }

  void login() {
    isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    notifyListeners();
  }

  void updateMaterial(Material material) {
    final index = materials.indexWhere((m) => m.id == material.id);
    if (index != -1) {
      materials[index] = material;
      notifyListeners();
    }
  }
}

// ==================== UI 组件 ====================

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
                    material.displayTitle,
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
                        color: material.tags.usage.color,
                      ),
                      TagBadge(
                        text: material.tags.viral.displayName,
                        color: material.tags.viral.color,
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

// ==================== 登录页面 ====================

class LoginScreen extends StatelessWidget {
  final AppState appState;

  const LoginScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
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
                    onChanged: (v) => appState.serverURL = v,
                    controller: TextEditingController(text: appState.serverURL),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: '用户名',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => appState.username = v,
                    controller: TextEditingController(text: appState.username),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: '密码',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    onChanged: (v) => appState.password = v,
                    controller: TextEditingController(text: appState.password),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () => appState.login(),
                      child: const Text('登录'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== 浏览页面 ====================

class BrowserScreen extends StatelessWidget {
  final AppState appState;

  const BrowserScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('浏览'),
        actions: [
          TextButton(
            onPressed: () => appState.logout(),
            child: const Text('退出'),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: appState.materials.length,
        itemBuilder: (context, index) {
          final material = appState.materials[index];
          return MaterialGridItem(
            material: material,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MaterialDetailScreen(
                    material: material,
                    onSave: (updated) {
                      appState.updateMaterial(updated);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==================== 素材详情页 ====================

class MaterialDetailScreen extends StatefulWidget {
  final Material material;
  final Function(Material) onSave;

  const MaterialDetailScreen({
    super.key,
    required this.material,
    required this.onSave,
  });

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late UsageTag _usageTag;
  late ViralTag _viralTag;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.material.title ?? '');
    _descriptionController = TextEditingController(text: widget.material.description ?? '');
    _usageTag = widget.material.tags.usage;
    _viralTag = widget.material.tags.viral;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('素材详情'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final updated = widget.material.copyWith(
                title: _titleController.text.isEmpty ? null : _titleController.text,
                description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                tags: widget.material.tags.copyWith(
                  usage: _usageTag,
                  viral: _viralTag,
                ),
              );
              widget.onSave(updated);
              Navigator.of(context).pop();
            },
            child: const Text('保存'),
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
                color: colorScheme.surfaceVariant,
                child: Icon(
                  widget.material.isVideo ? Icons.video_library : Icons.photo,
                  size: 96,
                  color: colorScheme.onSurfaceVariant,
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
            controller: _titleController,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: '描述',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            controller: _descriptionController,
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
            selected: {_usageTag},
            onSelectionChanged: (s) => setState(() => _usageTag = s.first),
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
            selected: {_viralTag},
            onSelectionChanged: (s) => setState(() => _viralTag = s.first),
          ),
          const SizedBox(height: 24),
          Text(
            '文件名: ${widget.material.filename}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          if (widget.material.fileSize != null) ...[
            const SizedBox(height: 4),
            Text(
              '大小: ${_formatSize(widget.material.fileSize!)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

// ==================== 设置页面 ====================

class SettingsScreen extends StatelessWidget {
  final AppState appState;

  const SettingsScreen({super.key, required this.appState});

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
            onTap: () {},
          ),
          const SectionHeader(title: '数据'),
          ListTile(
            leading: const Icon(Icons.cleaning_services),
            title: const Text('清除缓存'),
            onTap: () {},
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

// ==================== 主 Tab 页面 ====================

class MainTabScreen extends StatefulWidget {
  final AppState appState;

  const MainTabScreen({super.key, required this.appState});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          BrowserScreen(appState: widget.appState),
          SettingsScreen(appState: widget.appState),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
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

// ==================== 主 App ====================

class NASMaterialManagerApp extends StatelessWidget {
  final AppState appState;

  const NASMaterialManagerApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NAS 素材管理',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          if (appState.isLoggedIn) {
            return MainTabScreen(appState: appState);
          } else {
            return LoginScreen(appState: appState);
          }
        },
      ),
    );
  }
}

// ==================== 入口函数 ====================

void main() {
  runApp(NASMaterialManagerApp(appState: AppState()));
}
