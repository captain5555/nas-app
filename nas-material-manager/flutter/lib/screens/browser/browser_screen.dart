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
