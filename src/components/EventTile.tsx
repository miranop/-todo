import { useState } from 'react';
import type { CalendarEvent } from '../types/calendar';

interface Props {
  event: CalendarEvent;
  isDone: boolean;
  onToggleDone: () => void;
}

function formatTime(iso: string): string {
  const d = new Date(iso);
  return d.toLocaleTimeString('ja-JP', { hour: '2-digit', minute: '2-digit' });
}

function formatDate(iso: string): string {
  const d = new Date(iso);
  return d.toLocaleDateString('ja-JP', {
    month: 'numeric',
    day: 'numeric',
    weekday: 'short',
  });
}

export function EventTile({ event, isDone, onToggleDone }: Props) {
  const [showDetail, setShowDetail] = useState(false);

  return (
    <>
      <div
        className="mx-3 my-1 rounded-xl bg-white dark:bg-gray-900 shadow-sm border border-gray-100 dark:border-gray-800 px-3 py-2.5 flex items-start gap-3 cursor-pointer active:bg-gray-50 dark:active:bg-gray-800 transition-colors"
        onClick={() => setShowDetail(true)}
      >
        {/* Checkbox */}
        <button
          onClick={(e) => {
            e.stopPropagation();
            onToggleDone();
          }}
          className={`mt-0.5 w-5 h-5 rounded-full border-2 flex-shrink-0 flex items-center justify-center transition-colors ${
            isDone
              ? 'bg-primary-500 border-primary-500'
              : 'border-gray-300 dark:border-gray-600'
          }`}
          aria-label={isDone ? 'Mark as not done' : 'Mark as done'}
        >
          {isDone && (
            <svg className="w-3 h-3 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={3}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
            </svg>
          )}
        </button>

        {/* Event info */}
        <div className="flex-1 min-w-0">
          <p
            className={`text-sm font-medium truncate ${
              isDone
                ? 'line-through text-gray-400 dark:text-gray-500'
                : 'text-gray-900 dark:text-gray-100'
            }`}
          >
            {event.title}
          </p>

          <div className="flex items-center gap-2 mt-1">
            <span className="text-xs text-gray-500 dark:text-gray-400">
              {event.isAllDay
                ? '終日'
                : `${formatTime(event.startTime)} - ${formatTime(event.endTime)}`}
            </span>
            <SourceBadge source={event.source} />
          </div>

          <p className="text-xs text-gray-400 dark:text-gray-500 mt-0.5">
            {event.calendarName}
          </p>
        </div>
      </div>

      {/* Detail bottom sheet */}
      {showDetail && (
        <EventDetailSheet event={event} onClose={() => setShowDetail(false)} />
      )}
    </>
  );
}

function SourceBadge({ source }: { source: string }) {
  const isGoogle = source === 'google';
  return (
    <span
      className={`text-[10px] font-medium px-1.5 py-0.5 rounded ${
        isGoogle
          ? 'bg-blue-50 text-blue-600 dark:bg-blue-900/30 dark:text-blue-400'
          : 'bg-orange-50 text-orange-600 dark:bg-orange-900/30 dark:text-orange-400'
      }`}
    >
      {isGoogle ? 'Google' : 'Outlook'}
    </span>
  );
}

function EventDetailSheet({
  event,
  onClose,
}: {
  event: CalendarEvent;
  onClose: () => void;
}) {
  return (
    <div className="fixed inset-0 z-50 flex items-end" onClick={onClose}>
      <div className="absolute inset-0 bg-black/40" />
      <div
        className="relative w-full bg-white dark:bg-gray-900 rounded-t-2xl p-6 pb-8 max-h-[70vh] overflow-y-auto"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Handle bar */}
        <div className="w-10 h-1 bg-gray-300 dark:bg-gray-600 rounded-full mx-auto mb-4" />

        <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100">
          {event.title}
        </h2>

        <div className="mt-4 space-y-2">
          <DetailRow
            icon="🕐"
            text={
              event.isAllDay
                ? `${formatDate(event.startTime)} 終日`
                : `${formatDate(event.startTime)} ${formatTime(event.startTime)} - ${formatTime(event.endTime)}`
            }
          />
          {event.location && <DetailRow icon="📍" text={event.location} />}
          <DetailRow icon="📅" text={event.calendarName} />
        </div>

        {event.description && (
          <p className="mt-4 text-sm text-gray-600 dark:text-gray-400 whitespace-pre-wrap line-clamp-5">
            {event.description}
          </p>
        )}
      </div>
    </div>
  );
}

function DetailRow({ icon, text }: { icon: string; text: string }) {
  return (
    <div className="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
      <span>{icon}</span>
      <span>{text}</span>
    </div>
  );
}
