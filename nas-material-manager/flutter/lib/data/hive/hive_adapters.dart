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
