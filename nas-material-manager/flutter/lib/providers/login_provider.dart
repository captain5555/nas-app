import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../data/webdav/webdav_client.dart';
import '../data/webdav/webdav_config.dart' as client_config;
import '../data/models/webdav_config.dart';
import 'app_provider.dart';

class LoginProvider extends ChangeNotifier {
  final AppProvider appProvider;

  String serverURL = '';
  String username = '';
  String password = '';
  bool isLoading = false;
  String? errorMessage;

  LoginProvider(this.appProvider) {
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    if (appProvider.webdavConfig != null) {
      serverURL = appProvider.webdavConfig!.serverURL;
      username = appProvider.webdavConfig!.username;
      password = appProvider.webdavConfig!.password;
      notifyListeners();
    }
  }

  Future<void> login() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final uri = Uri.parse(serverURL);
      final config = client_config.WebDAVConfiguration(
        serverURL: uri,
        username: username,
        password: password,
      );
      final client = WebDAVClient(config: config);
      final success = await client.testConnection();

      if (success) {
        final appConfig = WebDAVConfig(
          serverURL: serverURL,
          username: username,
          password: password,
        );
        await appProvider.login(appConfig);
      } else {
        errorMessage = '连接失败，请检查配置';
      }
    } catch (e) {
      errorMessage = '连接错误: $e';
    }

    isLoading = false;
    notifyListeners();
  }
}
