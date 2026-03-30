import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'CalSync Todo',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'カレンダーの予定をTodoリストで管理',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),

                // Google Sign-In Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: authState.isLoading
                        ? null
                        : () => ref
                            .read(authProvider.notifier)
                            .signInWithGoogle(),
                    icon: const Icon(Icons.account_circle),
                    label: const Text('Googleでサインイン'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Microsoft Sign-In Button (coming soon)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: null, // Will be enabled when Outlook is ready
                    icon: const Icon(Icons.business),
                    label: const Text('Microsoftでサインイン（準備中）'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                if (authState.isLoading) ...[
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(),
                ],

                if (authState.error != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    authState.error!,
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
