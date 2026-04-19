import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/theme_constants.dart';
import '../login/login_screen.dart';
import '../admin/user_management_screen.dart';
import '../admin/ai_settings_screen.dart';
import '../admin/stats_screen.dart';
import '../admin/logs_screen.dart';
import '../admin/backup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<SettingsProvider>(context, listen: false).loadSettings();
      }
    });
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _showApiUrlDialog() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final controller = TextEditingController(text: settingsProvider.baseUrl);

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('API URL'),
        content: Padding(
          padding: const EdgeInsets.only(top: ThemeConstants.spacingMd),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'http://localhost:3000',
            autofocus: true,
            clearButtonMode: OverlayVisibilityMode.editing,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            child: const Text('Save'),
            onPressed: () async {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                await settingsProvider.updateBaseUrl(url);
              }
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear all cache?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Clear'),
            onPressed: () async {
              Navigator.pop(ctx);
              await _clearCache();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache() async {
    try {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      await settingsProvider.clearCache();

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Cleared Successfully'),
            content: const Text('Cache has been cleared'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Clear Failed'),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(ThemeConstants.spacingMd),
          children: [
            // Theme Setting
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return CupertinoListSection.insetGrouped(
                  header: const Text('Appearance'),
                  children: [
                    CupertinoListTile(
                      title: const Text('Dark Mode'),
                      trailing: CupertinoSwitch(
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.setTheme(value);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),

            // API Setting
            Consumer<SettingsProvider>(
              builder: (context, settingsProvider, child) {
                return CupertinoListSection.insetGrouped(
                  header: const Text('Server'),
                  children: [
                    CupertinoListTile(
                      title: const Text('API URL'),
                      subtitle: Text(settingsProvider.baseUrl),
                      trailing: const CupertinoListTileChevron(),
                      onTap: _showApiUrlDialog,
                    ),
                  ],
                );
              },
            ),

            // Cache Section
            CupertinoListSection.insetGrouped(
              header: const Text('Cache'),
              children: [
                CupertinoListTile(
                  title: const Text('Clear Cache'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: _showClearCacheDialog,
                ),
              ],
            ),

            // Admin Section (only for admin)
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.user?.role != 'admin') {
                  return const SizedBox.shrink();
                }
                return CupertinoListSection.insetGrouped(
                  header: const Text('Admin'),
                  children: [
                    CupertinoListTile(
                      title: const Text('User Management'),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const UserManagementScreen(),
                          ),
                        );
                      },
                    ),
                    CupertinoListTile(
                      title: const Text('System Stats'),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const StatsScreen(),
                          ),
                        );
                      },
                    ),
                    CupertinoListTile(
                      title: const Text('Activity Logs'),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const LogsScreen(),
                          ),
                        );
                      },
                    ),
                    CupertinoListTile(
                      title: const Text('Backup Management'),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const BackupScreen(),
                          ),
                        );
                      },
                    ),
                    CupertinoListTile(
                      title: const Text('AI Settings'),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const AiSettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),

            // Account Section
            CupertinoListSection.insetGrouped(
              header: const Text('Account'),
              children: [
                CupertinoListTile(
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: CupertinoColors.systemRed),
                  ),
                  onTap: _logout,
                ),
              ],
            ),

            // Info Section
            CupertinoListSection.insetGrouped(
              header: const Text('About'),
              children: const [
                CupertinoListTile(
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
