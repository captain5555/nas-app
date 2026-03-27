import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/material_detail_provider.dart';
import '../../data/models/material.dart';
import '../../data/models/material_tags.dart';
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
