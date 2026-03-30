import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../models/calendar_event.dart';

/// Service for interacting with Google Calendar API v3.
///
/// Prerequisites:
/// 1. Enable Google Calendar API in Google Cloud Console
///    https://console.cloud.google.com/apis/library/calendar-json.googleapis.com
/// 2. Create OAuth 2.0 Client ID (Android type) in Credentials
///    https://console.cloud.google.com/apis/credentials
/// 3. Add SHA-1 fingerprint of your signing key
class GoogleCalendarService {
  static const _baseUrl = 'https://www.googleapis.com/calendar/v3';

  final GoogleSignIn _googleSignIn;

  GoogleCalendarService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: [
                'https://www.googleapis.com/auth/calendar.readonly',
              ],
            );

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<bool> isSignedIn() async {
    return _googleSignIn.isSignedIn();
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    return await _googleSignIn.signInSilently();
  }

  Future<Map<String, String>?> _getAuthHeaders() async {
    final user = _googleSignIn.currentUser;
    if (user == null) return null;
    return await user.authHeaders;
  }

  /// Fetches the list of calendars the user has access to.
  Future<List<CalendarInfo>> fetchCalendars() async {
    final headers = await _getAuthHeaders();
    if (headers == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/users/me/calendarList'),
      headers: headers,
    );

    if (response.statusCode != 200) return [];

    final data = json.decode(response.body);
    final items = data['items'] as List<dynamic>? ?? [];

    return items.map((item) {
      return CalendarInfo(
        id: item['id'] as String,
        name: item['summary'] as String? ?? 'Unnamed',
        source: CalendarSource.google,
      );
    }).toList();
  }

  /// Fetches events from all calendars within the given time range.
  Future<List<CalendarEvent>> fetchEvents({
    DateTime? timeMin,
    DateTime? timeMax,
    List<String>? calendarIds,
  }) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return [];

    final now = DateTime.now();
    final min = timeMin ?? DateTime(now.year, now.month, now.day);
    final max = timeMax ?? min.add(const Duration(days: 14));

    // If no specific calendars requested, fetch from primary
    final ids = calendarIds ?? ['primary'];
    final allEvents = <CalendarEvent>[];

    for (final calendarId in ids) {
      final queryParams = {
        'timeMin': min.toUtc().toIso8601String(),
        'timeMax': max.toUtc().toIso8601String(),
        'singleEvents': 'true',
        'orderBy': 'startTime',
        'maxResults': '100',
      };

      final uri = Uri.parse(
        '$_baseUrl/calendars/${Uri.encodeComponent(calendarId)}/events',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);
      if (response.statusCode != 200) continue;

      final data = json.decode(response.body);
      final calendarName = data['summary'] as String? ?? 'Calendar';
      final items = data['items'] as List<dynamic>? ?? [];

      for (final item in items) {
        final start = item['start'] as Map<String, dynamic>?;
        final end = item['end'] as Map<String, dynamic>?;
        if (start == null || end == null) continue;

        final isAllDay = start.containsKey('date');

        DateTime startTime;
        DateTime endTime;

        if (isAllDay) {
          startTime = DateTime.parse(start['date'] as String);
          endTime = DateTime.parse(end['date'] as String);
        } else {
          startTime = DateTime.parse(start['dateTime'] as String);
          endTime = DateTime.parse(end['dateTime'] as String);
        }

        allEvents.add(CalendarEvent(
          id: item['id'] as String? ?? '',
          title: item['summary'] as String? ?? '(No title)',
          startTime: startTime,
          endTime: endTime,
          isAllDay: isAllDay,
          calendarName: calendarName,
          calendarId: calendarId,
          source: CalendarSource.google,
          location: item['location'] as String?,
          description: item['description'] as String?,
        ));
      }
    }

    allEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
    return allEvents;
  }
}
