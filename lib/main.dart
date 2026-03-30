import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: CalSyncTodoApp(),
    ),
  );
}

class CalSyncTodoApp extends ConsumerWidget {
  const CalSyncTodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'CalSync Todo',
      debugShowCheckedModeBanner: false,

      // Material Design 3 Light Theme
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),

      // Material Design 3 Dark Theme
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),

      // Follow system theme setting
      themeMode: ThemeMode.system,

      // Show login or home based on auth state
      home: authState.isLoading
          ? const _SplashScreen()
          : authState.isSignedIn
              ? const HomeScreen()
              : const LoginScreen(),

      routes: {
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
