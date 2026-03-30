import 'package:flutter_test/flutter_test.dart';
import 'package:calsync_todo/models/calendar_event.dart';

void main() {
  group('CalendarEvent.groupBySection', () {
    test('groups events into correct sections', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10, 0);
      final tomorrow = today.add(const Duration(days: 1));
      final nextWeek = today.add(const Duration(days: 3));
      final later = today.add(const Duration(days: 10));

      final events = [
        CalendarEvent(
          id: '1',
          title: 'Today event',
          startTime: today,
          endTime: today.add(const Duration(hours: 1)),
          calendarName: 'Test',
          calendarId: 'test',
          source: CalendarSource.google,
        ),
        CalendarEvent(
          id: '2',
          title: 'Tomorrow event',
          startTime: tomorrow,
          endTime: tomorrow.add(const Duration(hours: 1)),
          calendarName: 'Test',
          calendarId: 'test',
          source: CalendarSource.google,
        ),
        CalendarEvent(
          id: '3',
          title: 'Later event',
          startTime: later,
          endTime: later.add(const Duration(hours: 1)),
          calendarName: 'Test',
          calendarId: 'test',
          source: CalendarSource.google,
        ),
      ];

      final grouped = CalendarEvent.groupBySection(events);
      expect(grouped.containsKey('今日'), isTrue);
      expect(grouped['今日']!.length, 1);
      expect(grouped['今日']!.first.title, 'Today event');
      expect(grouped.containsKey('明日'), isTrue);
      expect(grouped['明日']!.length, 1);
    });

    test('returns empty map for no events', () {
      final grouped = CalendarEvent.groupBySection([]);
      expect(grouped.isEmpty, isTrue);
    });
  });
}
