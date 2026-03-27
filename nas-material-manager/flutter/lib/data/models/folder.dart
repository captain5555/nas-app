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
