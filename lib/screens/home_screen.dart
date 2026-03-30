import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/calendar_event.dart';
import '../providers/auth_provider.dart';
import '../providers/calendar_provider.dart';
import '../widgets/event_tile.dart';
import '../widgets/source_filter_chips.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch events on first load
    Future.microtask(() => ref.read(calendarProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final grouped = calendarState.groupedEvents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CalSync Todo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Source filter chips
          const SourceFilterChips(),

          // Event list
          Expanded(
            child: calendarState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : calendarState.error != null
                    ? _buildError(calendarState.error!, theme)
                    : grouped.isEmpty
                        ? _buildEmpty(theme)
                        : RefreshIndicator(
                            onRefresh: () =>
                                ref.read(calendarProvider.notifier).refresh(),
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: _countItems(grouped),
                              itemBuilder: (context, index) =>
                                  _buildItem(context, index, grouped),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.read(calendarProvider.notifier).refresh(),
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '予定はありません',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '直近2週間の予定がここに表示されます',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Counts total items including section headers.
  int _countItems(Map<String, List<CalendarEvent>> grouped) {
    int count = 0;
    for (final entry in grouped.entries) {
      count += 1 + entry.value.length; // header + events
    }
    return count;
  }

  /// Builds either a section header or an event tile.
  Widget _buildItem(
    BuildContext context,
    int index,
    Map<String, List<CalendarEvent>> grouped,
  ) {
    int current = 0;
    for (final entry in grouped.entries) {
      if (index == current) {
        return _buildSectionHeader(context, entry.key, entry.value.length);
      }
      current++;
      if (index < current + entry.value.length) {
        final event = entry.value[index - current];
        return EventTile(event: event);
      }
      current += entry.value.length;
    }
    return const SizedBox.shrink();
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    int count,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
