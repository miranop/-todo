import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calendar_event.dart';
import '../providers/auth_provider.dart';
import '../providers/calendar_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final calendarState = ref.watch(calendarProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        children: [
          // Account section
          _buildSectionTitle(context, 'アカウント'),

          if (authState.isGoogleSignedIn)
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text(authState.googleAccount?.displayName ?? 'Google'),
              subtitle: Text(authState.googleAccount?.email ?? ''),
              trailing: TextButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOutGoogle();
                },
                child: const Text('ログアウト'),
              ),
            )
          else
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text('Googleアカウント'),
              subtitle: const Text('未接続'),
              trailing: FilledButton.tonal(
                onPressed: () =>
                    ref.read(authProvider.notifier).signInWithGoogle(),
                child: const Text('接続'),
              ),
            ),

          ListTile(
            leading: const Icon(Icons.business_outlined),
            title: const Text('Microsoftアカウント'),
            subtitle: const Text('準備中'),
            trailing: const FilledButton.tonal(
              onPressed: null,
              child: Text('接続'),
            ),
          ),

          const Divider(),

          // Calendar visibility section
          _buildSectionTitle(context, 'カレンダー表示設定'),

          if (calendarState.calendars.isEmpty)
            const ListTile(
              title: Text('カレンダーがありません'),
              subtitle: Text('アカウントを接続すると表示されます'),
            )
          else
            ...calendarState.calendars.map((calendar) {
              final isHidden = calendarState.hiddenCalendarIds
                  .contains(calendar.id);
              return SwitchListTile(
                title: Text(calendar.name),
                subtitle: Text(
                  calendar.source == CalendarSource.google
                      ? 'Google Calendar'
                      : 'Outlook',
                ),
                value: !isHidden,
                onChanged: (_) {
                  ref
                      .read(calendarProvider.notifier)
                      .toggleCalendarVisibility(calendar.id);
                },
                secondary: Icon(
                  calendar.source == CalendarSource.google
                      ? Icons.event
                      : Icons.business,
                ),
              );
            }),

          const Divider(),

          // About section
          _buildSectionTitle(context, 'アプリについて'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('CalSync Todo'),
            subtitle: Text('Version 1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
