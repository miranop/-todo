import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/calendar_event.dart';
import '../providers/calendar_provider.dart';

class EventTile extends ConsumerWidget {
  final CalendarEvent event;

  const EventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEventDetail(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: event.isDone,
                onChanged: (_) {
                  ref
                      .read(calendarProvider.notifier)
                      .toggleEventDone(event.id);
                },
                shape: const CircleBorder(),
              ),

              // Event info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      event.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        decoration:
                            event.isDone ? TextDecoration.lineThrough : null,
                        color: event.isDone
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Time and calendar info
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.isAllDay
                              ? '終日'
                              : '${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildSourceBadge(context),
                      ],
                    ),

                    // Calendar name
                    const SizedBox(height: 2),
                    Text(
                      event.calendarName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceBadge(BuildContext context) {
    final theme = Theme.of(context);
    final isGoogle = event.source == CalendarSource.google;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: isGoogle
            ? Colors.blue.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isGoogle ? 'Google' : 'Outlook',
        style: theme.textTheme.labelSmall?.copyWith(
          color: isGoogle ? Colors.blue : Colors.orange,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showEventDetail(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('M/d (E)', 'ja');
    final timeFormat = DateFormat('HH:mm');

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _detailRow(
              context,
              Icons.access_time,
              event.isAllDay
                  ? '${dateFormat.format(event.startTime)} 終日'
                  : '${dateFormat.format(event.startTime)} ${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}',
            ),
            if (event.location != null) ...[
              const SizedBox(height: 8),
              _detailRow(context, Icons.location_on, event.location!),
            ],
            const SizedBox(height: 8),
            _detailRow(context, Icons.calendar_today, event.calendarName),
            if (event.description != null && event.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                event.description!,
                style: theme.textTheme.bodyMedium,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
