import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/webdav_config.dart';

class AppProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  WebDAVConfig? _webdavConfig;

  bool get isLoggedIn => _isLoggedIn;
  WebDAVConfig? get webdavConfig => _webdavConfig;

  AppProvider() {
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString('webdav_config');
    if (configJson != null) {
      _webdavConfig = WebDAVConfig.fromJson(
        jsonDecode(configJson) as Map<String, dynamic>,
      );
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<void> login(WebDAVConfig config) async {
    _webdavConfig = config;
    _isLoggedIn = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('webdav_config', jsonEncode(config.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    _webdavConfig = null;
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('webdav_config');
    notifyListeners();
  }
}
