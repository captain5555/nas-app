import 'dart:convert';

class WebDAVConfiguration {
  final Uri serverURL;
  final String username;
  final String password;

  WebDAVConfiguration({
    required this.serverURL,
    required this.username,
    required this.password,
  });

  String get authHeader {
    final credentials = '$username:$password';
    final bytes = utf8.encode(credentials);
    final base64 = base64Encode(bytes);
    return 'Basic $base64';
  }
}
