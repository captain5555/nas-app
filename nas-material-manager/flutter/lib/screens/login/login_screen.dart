import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/login_provider.dart';
import '../../providers/app_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginProvider(context.read<AppProvider>()),
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            child: Consumer<LoginProvider>(
              builder: (context, provider, _) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.folder, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'NAS 素材管理',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'WebDAV 地址',
                            hintText: 'http://...',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => provider.serverURL = v,
                          controller: TextEditingController(text: provider.serverURL),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: '用户名',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => provider.username = v,
                          controller: TextEditingController(text: provider.username),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: '密码',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          onChanged: (v) => provider.password = v,
                          controller: TextEditingController(text: provider.password),
                        ),
                        if (provider.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage!,
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: provider.isLoading
                                ? null
                                : () => provider.login(),
                            child: provider.isLoading
                                ? const CircularProgressIndicator()
                                : const Text('登录'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
