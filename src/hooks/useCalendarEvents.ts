import { useQuery } from '@tanstack/react-query';
import { useState, useMemo } from 'react';
import {
  fetchCalendars,
  fetchEvents,
} from '../services/googleCalendar';
import {
  groupEventsBySection,
  type CalendarEvent,
  type CalendarInfo,
  type CalendarSource,
  type GroupedEvents,
} from '../types/calendar';

export function useCalendarEvents(isSignedIn: boolean) {
  const [hiddenCalendarIds, setHiddenCalendarIds] = useState<Set<string>>(
    new Set()
  );
  const [sourceFilter, setSourceFilter] = useState<CalendarSource | null>(null);
  const [doneIds, setDoneIds] = useState<Set<string>>(new Set());

  const calendarsQuery = useQuery<CalendarInfo[]>({
    queryKey: ['calendars'],
    queryFn: fetchCalendars,
    enabled: isSignedIn,
    staleTime: 5 * 60 * 1000,
  });

  const eventsQuery = useQuery<CalendarEvent[]>({
    queryKey: ['events', calendarsQuery.data?.map((c) => c.id)],
    queryFn: () => {
      const ids = calendarsQuery.data?.map((c) => c.id);
      return fetchEvents(ids);
    },
    enabled: isSignedIn && !!calendarsQuery.data,
    staleTime: 2 * 60 * 1000,
  });

  const filteredEvents = useMemo(() => {
    if (!eventsQuery.data) return [];
    return eventsQuery.data.filter((event) => {
      if (hiddenCalendarIds.has(event.calendarId)) return false;
      if (sourceFilter && event.source !== sourceFilter) return false;
      return true;
    });
  }, [eventsQuery.data, hiddenCalendarIds, sourceFilter]);

  const groupedEvents: GroupedEvents = useMemo(
    () => groupEventsBySection(filteredEvents),
    [filteredEvents]
  );

  const toggleCalendarVisibility = (calendarId: string) => {
    setHiddenCalendarIds((prev) => {
      const next = new Set(prev);
      if (next.has(calendarId)) next.delete(calendarId);
      else next.add(calendarId);
      return next;
    });
  };

  const toggleDone = (eventId: string) => {
    setDoneIds((prev) => {
      const next = new Set(prev);
      if (next.has(eventId)) next.delete(eventId);
      else next.add(eventId);
      return next;
    });
  };

  const refresh = () => {
    calendarsQuery.refetch();
    eventsQuery.refetch();
  };

  return {
    calendars: calendarsQuery.data ?? [],
    events: filteredEvents,
    groupedEvents,
    isLoading: calendarsQuery.isLoading || eventsQuery.isLoading,
    error: calendarsQuery.error ?? eventsQuery.error,
    hiddenCalendarIds,
    sourceFilter,
    doneIds,
    setSourceFilter,
    toggleCalendarVisibility,
    toggleDone,
    refresh,
  };
}
