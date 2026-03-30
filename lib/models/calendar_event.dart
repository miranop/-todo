/// Represents a calendar event from Google Calendar or Outlook.
enum CalendarSource { google, outlook }

class CalendarEvent {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final String calendarName;
  final String calendarId;
  final CalendarSource source;
  final String? location;
  final String? description;
  bool isDone;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    required this.calendarName,
    required this.calendarId,
    required this.source,
    this.location,
    this.description,
    this.isDone = false,
  });

  /// Groups events into sections: Today, Tomorrow, This Week, Later.
  static Map<String, List<CalendarEvent>> groupBySection(
    List<CalendarEvent> events,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final endOfWeek = today.add(Duration(days: 7 - today.weekday % 7));

    final sections = <String, List<CalendarEvent>>{
      '今日': [],
      '明日': [],
      '今週': [],
      'それ以降': [],
    };

    for (final event in events) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );

      if (eventDate.isAtSameMomentAs(today)) {
        sections['今日']!.add(event);
      } else if (eventDate.isAtSameMomentAs(tomorrow)) {
        sections['明日']!.add(event);
      } else if (eventDate.isBefore(endOfWeek)) {
        sections['今週']!.add(event);
      } else {
        sections['それ以降']!.add(event);
      }
    }

    // Sort each section by start time
    for (final section in sections.values) {
      section.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    // Remove empty sections
    sections.removeWhere((_, events) => events.isEmpty);

    return sections;
  }
}

class CalendarInfo {
  final String id;
  final String name;
  final CalendarSource source;
  bool isVisible;

  CalendarInfo({
    required this.id,
    required this.name,
    required this.source,
    this.isVisible = true,
  });
}
