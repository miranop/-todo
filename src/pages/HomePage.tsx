import { useAuth } from '../contexts/AuthContext';
import { useCalendarEvents } from '../hooks/useCalendarEvents';
import { EventTile } from '../components/EventTile';
import { SourceFilterChips } from '../components/SourceFilterChips';
import type { SectionKey } from '../types/calendar';
import { Link } from 'react-router-dom';

export function HomePage() {
  const { isSignedIn } = useAuth();
  const {
    groupedEvents,
    isLoading,
    error,
    sourceFilter,
    doneIds,
    setSourceFilter,
    toggleDone,
    refresh,
  } = useCalendarEvents(isSignedIn);

  const sectionOrder: SectionKey[] = ['今日', '明日', '今週', 'それ以降'];
  const sections = sectionOrder.filter((key) => groupedEvents[key]?.length);

  return (
    <div className="min-h-screen flex flex-col">
      {/* Header */}
      <header className="sticky top-0 z-10 bg-white/80 dark:bg-gray-950/80 backdrop-blur-md border-b border-gray-100 dark:border-gray-800">
        <div className="flex items-center justify-between px-4 py-3">
          <h1 className="text-lg font-bold text-gray-900 dark:text-gray-100">
            CalSync Todo
          </h1>
          <Link
            to="/settings"
            className="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
            aria-label="Settings"
          >
            <svg className="w-5 h-5 text-gray-600 dark:text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.066 2.573c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.573 1.066c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.066-2.573c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
              <path strokeLinecap="round" strokeLinejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
          </Link>
        </div>

        <SourceFilterChips current={sourceFilter} onChange={setSourceFilter} />
      </header>

      {/* Content */}
      <main className="flex-1 pb-8">
        {isLoading ? (
          <div className="flex items-center justify-center py-20">
            <div className="w-8 h-8 border-2 border-primary-500 border-t-transparent rounded-full animate-spin" />
          </div>
        ) : error ? (
          <div className="text-center py-20 px-8">
            <p className="text-red-500 dark:text-red-400 mb-4">
              {error instanceof Error ? error.message : 'Failed to load events'}
            </p>
            <button
              onClick={refresh}
              className="px-4 py-2 rounded-lg bg-primary-500 text-white text-sm font-medium"
            >
              再試行
            </button>
          </div>
        ) : sections.length === 0 ? (
          <div className="text-center py-20 px-8">
            <div className="text-4xl mb-4">📅</div>
            <p className="text-gray-500 dark:text-gray-400 font-medium">
              予定はありません
            </p>
            <p className="text-sm text-gray-400 dark:text-gray-500 mt-1">
              直近2週間の予定がここに表示されます
            </p>
          </div>
        ) : (
          sections.map((sectionKey) => (
            <section key={sectionKey}>
              <SectionHeader
                title={sectionKey}
                count={groupedEvents[sectionKey]!.length}
              />
              {groupedEvents[sectionKey]!.map((event) => (
                <EventTile
                  key={event.id}
                  event={event}
                  isDone={doneIds.has(event.id)}
                  onToggleDone={() => toggleDone(event.id)}
                />
              ))}
            </section>
          ))
        )}
      </main>
    </div>
  );
}

function SectionHeader({ title, count }: { title: string; count: number }) {
  return (
    <div className="flex items-center gap-2 px-4 pt-4 pb-1">
      <h2 className="text-sm font-bold text-primary-600 dark:text-primary-400">
        {title}
      </h2>
      <span className="px-2 py-0.5 rounded-full bg-primary-50 dark:bg-primary-900/30 text-[11px] font-medium text-primary-600 dark:text-primary-400">
        {count}
      </span>
    </div>
  );
}
