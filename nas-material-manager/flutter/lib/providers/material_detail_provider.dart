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
