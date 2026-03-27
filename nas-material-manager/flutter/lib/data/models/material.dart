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
