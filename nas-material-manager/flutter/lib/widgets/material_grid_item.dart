import 'package:flutter/material.dart';
import '../data/models/material.dart';
import '../data/models/material_tags.dart';
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
