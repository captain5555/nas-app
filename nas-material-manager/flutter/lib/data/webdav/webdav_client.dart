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
