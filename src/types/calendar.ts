export type CalendarSource = 'google' | 'outlook';

export interface CalendarEvent {
  id: string;
  title: string;
  startTime: string; // ISO 8601
  endTime: string;
  isAllDay: boolean;
  calendarName: string;
  calendarId: string;
  source: CalendarSource;
  location?: string;
  description?: string;
}

export interface CalendarInfo {
  id: string;
  name: string;
  source: CalendarSource;
  isVisible: boolean;
}

export type SectionKey = '今日' | '明日' | '今週' | 'それ以降';

export type GroupedEvents = Partial<Record<SectionKey, CalendarEvent[]>>;

export function groupEventsBySection(events: CalendarEvent[]): GroupedEvents {
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const tomorrow = new Date(today);
  tomorrow.setDate(tomorrow.getDate() + 1);
  const endOfWeek = new Date(today);
  endOfWeek.setDate(endOfWeek.getDate() + (7 - (today.getDay() % 7)));

  const sections: GroupedEvents = {};

  const sorted = [...events].sort(
    (a, b) => new Date(a.startTime).getTime() - new Date(b.startTime).getTime()
  );

  for (const event of sorted) {
    const eventDate = new Date(event.startTime);
    const eventDay = new Date(
      eventDate.getFullYear(),
      eventDate.getMonth(),
      eventDate.getDate()
    );

    let key: SectionKey;
    if (eventDay.getTime() === today.getTime()) {
      key = '今日';
    } else if (eventDay.getTime() === tomorrow.getTime()) {
      key = '明日';
    } else if (eventDay < endOfWeek) {
      key = '今週';
    } else {
      key = 'それ以降';
    }

    if (!sections[key]) sections[key] = [];
    sections[key]!.push(event);
  }

  return sections;
}
