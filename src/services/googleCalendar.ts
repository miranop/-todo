/**
 * Google Calendar API v3 service.
 *
 * Prerequisites:
 * 1. Enable Google Calendar API in Google Cloud Console
 *    https://console.cloud.google.com/apis/library/calendar-json.googleapis.com
 * 2. Create OAuth 2.0 Client ID (Web application type)
 *    https://console.cloud.google.com/apis/credentials
 * 3. Add authorized JavaScript origins (e.g. http://localhost:5173)
 * 4. Set VITE_GOOGLE_CLIENT_ID in .env
 */

import type { CalendarEvent, CalendarInfo } from '../types/calendar';

const CALENDAR_API = 'https://www.googleapis.com/calendar/v3';
const SCOPES = 'https://www.googleapis.com/auth/calendar.readonly';

let tokenClient: google.accounts.oauth2.TokenClient | null = null;
let accessToken: string | null = null;

export function initGoogleAuth(): Promise<string> {
  return new Promise((resolve, reject) => {
    const clientId = import.meta.env.VITE_GOOGLE_CLIENT_ID;
    if (!clientId || clientId === 'your_google_client_id_here') {
      reject(new Error('VITE_GOOGLE_CLIENT_ID is not configured'));
      return;
    }

    tokenClient = google.accounts.oauth2.initTokenClient({
      client_id: clientId,
      scope: SCOPES,
      callback: (response) => {
        if (response.error) {
          reject(new Error(response.error));
          return;
        }
        if (response.access_token) {
          accessToken = response.access_token;
          resolve(response.access_token);
        }
      },
    });

    tokenClient.requestAccessToken();
  });
}

export function signOutGoogle(): void {
  if (accessToken) {
    google.accounts.oauth2.revoke(accessToken, () => {});
    accessToken = null;
  }
}

export function getAccessToken(): string | null {
  return accessToken;
}

export function isGoogleSignedIn(): boolean {
  return accessToken !== null;
}

async function fetchWithAuth(url: string): Promise<Response> {
  if (!accessToken) throw new Error('Not authenticated');
  return fetch(url, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
}

export async function fetchCalendars(): Promise<CalendarInfo[]> {
  const res = await fetchWithAuth(`${CALENDAR_API}/users/me/calendarList`);
  if (!res.ok) throw new Error(`Failed to fetch calendars: ${res.status}`);

  const data = await res.json();
  const items = (data.items ?? []) as Array<{
    id: string;
    summary?: string;
  }>;

  return items.map((item) => ({
    id: item.id,
    name: item.summary ?? 'Unnamed',
    source: 'google' as const,
    isVisible: true,
  }));
}

export async function fetchEvents(
  calendarIds?: string[]
): Promise<CalendarEvent[]> {
  const now = new Date();
  const timeMin = new Date(
    now.getFullYear(),
    now.getMonth(),
    now.getDate()
  ).toISOString();
  const timeMax = new Date(
    now.getFullYear(),
    now.getMonth(),
    now.getDate() + 14
  ).toISOString();

  const ids = calendarIds?.length ? calendarIds : ['primary'];
  const allEvents: CalendarEvent[] = [];

  for (const calendarId of ids) {
    const params = new URLSearchParams({
      timeMin,
      timeMax,
      singleEvents: 'true',
      orderBy: 'startTime',
      maxResults: '100',
    });

    const url = `${CALENDAR_API}/calendars/${encodeURIComponent(calendarId)}/events?${params}`;
    const res = await fetchWithAuth(url);
    if (!res.ok) continue;

    const data = await res.json();
    const calendarName = (data.summary as string) ?? 'Calendar';
    const items = (data.items ?? []) as Array<{
      id?: string;
      summary?: string;
      start?: { date?: string; dateTime?: string };
      end?: { date?: string; dateTime?: string };
      location?: string;
      description?: string;
    }>;

    for (const item of items) {
      if (!item.start || !item.end) continue;

      const isAllDay = !!item.start.date;
      const startTime = item.start.dateTime ?? item.start.date ?? '';
      const endTime = item.end.dateTime ?? item.end.date ?? '';

      allEvents.push({
        id: item.id ?? crypto.randomUUID(),
        title: item.summary ?? '(No title)',
        startTime,
        endTime,
        isAllDay,
        calendarName,
        calendarId,
        source: 'google',
        location: item.location,
        description: item.description,
      });
    }
  }

  allEvents.sort(
    (a, b) => new Date(a.startTime).getTime() - new Date(b.startTime).getTime()
  );
  return allEvents;
}
