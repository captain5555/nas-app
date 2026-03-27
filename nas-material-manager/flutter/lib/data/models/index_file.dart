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
