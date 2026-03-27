import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/login/login_screen.dart';
import 'screens/main_tab_screen.dart';
import 'theme/app_theme.dart';

class NASMaterialManagerApp extends StatelessWidget {
  const NASMaterialManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          return MaterialApp(
            title: 'NAS 素材管理',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            home: appProvider.isLoggedIn
                ? const MainTabScreen()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}
