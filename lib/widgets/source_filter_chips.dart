import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calendar_event.dart';
import '../providers/calendar_provider.dart';

class SourceFilterChips extends ConsumerWidget {
  const SourceFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarProvider);
    final currentFilter = calendarState.sourceFilter;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('すべて'),
            selected: currentFilter == null,
            onSelected: (_) {
              ref.read(calendarProvider.notifier).setSourceFilter(null);
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Google'),
            selected: currentFilter == CalendarSource.google,
            onSelected: (_) {
              ref.read(calendarProvider.notifier).setSourceFilter(
                    currentFilter == CalendarSource.google
                        ? null
                        : CalendarSource.google,
                  );
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Outlook'),
            selected: currentFilter == CalendarSource.outlook,
            onSelected: (_) {
              ref.read(calendarProvider.notifier).setSourceFilter(
                    currentFilter == CalendarSource.outlook
                        ? null
                        : CalendarSource.outlook,
                  );
            },
          ),
        ],
      ),
    );
  }
}
