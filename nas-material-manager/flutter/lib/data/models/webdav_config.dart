import 'dart:convert';

class WebDAVConfig {
  final String serverURL;
  final String username;
  final String password;

  WebDAVConfig({
    required this.serverURL,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'server_url': serverURL,
      'username': username,
      'password': password,
    };
  }

  factory WebDAVConfig.fromJson(Map<String, dynamic> json) {
    return WebDAVConfig(
      serverURL: json['server_url'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
    );
  }
}
