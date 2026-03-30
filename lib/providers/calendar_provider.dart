import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calendar_event.dart';
import '../services/google_calendar_service.dart';
import 'auth_provider.dart';

/// State for calendar data.
class CalendarState {
  final List<CalendarEvent> events;
  final List<CalendarInfo> calendars;
  final Set<String> hiddenCalendarIds;
  final CalendarSource? sourceFilter; // null = show all
  final bool isLoading;
  final String? error;

  const CalendarState({
    this.events = const [],
    this.calendars = const [],
    this.hiddenCalendarIds = const {},
    this.sourceFilter,
    this.isLoading = false,
    this.error,
  });

  /// Returns events after applying filters.
  List<CalendarEvent> get filteredEvents {
    return events.where((event) {
      if (hiddenCalendarIds.contains(event.calendarId)) return false;
      if (sourceFilter != null && event.source != sourceFilter) return false;
      return true;
    }).toList();
  }

  /// Returns filtered events grouped by section.
  Map<String, List<CalendarEvent>> get groupedEvents {
    return CalendarEvent.groupBySection(filteredEvents);
  }

  CalendarState copyWith({
    List<CalendarEvent>? events,
    List<CalendarInfo>? calendars,
    Set<String>? hiddenCalendarIds,
    CalendarSource? sourceFilter,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearSourceFilter = false,
  }) {
    return CalendarState(
      events: events ?? this.events,
      calendars: calendars ?? this.calendars,
      hiddenCalendarIds: hiddenCalendarIds ?? this.hiddenCalendarIds,
      sourceFilter:
          clearSourceFilter ? null : (sourceFilter ?? this.sourceFilter),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Manages calendar events and filtering.
class CalendarNotifier extends StateNotifier<CalendarState> {
  final GoogleCalendarService _googleService;

  CalendarNotifier(this._googleService) : super(const CalendarState());

  /// Fetches calendars and events from all connected sources.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Fetch Google calendars
      final calendars = await _googleService.fetchCalendars();

      // Fetch events from all visible calendars
      final calendarIds = calendars.map((c) => c.id).toList();
      final events = await _googleService.fetchEvents(
        calendarIds: calendarIds.isNotEmpty ? calendarIds : null,
      );

      state = state.copyWith(
        events: events,
        calendars: calendars,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch events: $e',
      );
    }
  }

  /// Toggle visibility of a specific calendar.
  void toggleCalendarVisibility(String calendarId) {
    final hidden = Set<String>.from(state.hiddenCalendarIds);
    if (hidden.contains(calendarId)) {
      hidden.remove(calendarId);
    } else {
      hidden.add(calendarId);
    }
    state = state.copyWith(hiddenCalendarIds: hidden);
  }

  /// Set source filter (Google, Outlook, or null for all).
  void setSourceFilter(CalendarSource? source) {
    if (source == null) {
      state = state.copyWith(clearSourceFilter: true);
    } else {
      state = state.copyWith(sourceFilter: source);
    }
  }

  /// Toggle the done state of an event.
  void toggleEventDone(String eventId) {
    final events = state.events.map((e) {
      if (e.id == eventId) {
        e.isDone = !e.isDone;
      }
      return e;
    }).toList();
    state = state.copyWith(events: events);
  }
}

final calendarProvider =
    StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  final googleService = ref.watch(googleCalendarServiceProvider);
  return CalendarNotifier(googleService);
});
