import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { useCalendarEvents } from '../hooks/useCalendarEvents';

export function SettingsPage() {
  const { isGoogleConnected, signInWithGoogle, signOutFromGoogle, isSignedIn } =
    useAuth();
  const { calendars, hiddenCalendarIds, toggleCalendarVisibility } =
    useCalendarEvents(isSignedIn);

  return (
    <div className="min-h-screen">
      {/* Header */}
      <header className="sticky top-0 z-10 bg-white/80 dark:bg-gray-950/80 backdrop-blur-md border-b border-gray-100 dark:border-gray-800">
        <div className="flex items-center gap-3 px-4 py-3">
          <Link
            to="/"
            className="p-2 -ml-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
            aria-label="Back"
          >
            <svg className="w-5 h-5 text-gray-600 dark:text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
            </svg>
          </Link>
          <h1 className="text-lg font-bold text-gray-900 dark:text-gray-100">
            設定
          </h1>
        </div>
      </header>

      <div className="divide-y divide-gray-100 dark:divide-gray-800">
        {/* Account section */}
        <section className="px-4 py-4">
          <h2 className="text-xs font-bold text-primary-600 dark:text-primary-400 uppercase tracking-wide mb-3">
            アカウント
          </h2>

          {/* Google */}
          <div className="flex items-center justify-between py-3">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded-full bg-blue-50 dark:bg-blue-900/30 flex items-center justify-center">
                <svg className="w-4 h-4 text-blue-500" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.95-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.54c-.26-.81-1-1.39-1.9-1.39h-1v-3c0-.55-.45-1-1-1H8v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.39z" />
                </svg>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-900 dark:text-gray-100">
                  Google
                </p>
                <p className="text-xs text-gray-500 dark:text-gray-400">
                  {isGoogleConnected ? '接続済み' : '未接続'}
                </p>
              </div>
            </div>
            {isGoogleConnected ? (
              <button
                onClick={signOutFromGoogle}
                className="text-xs font-medium text-red-500 hover:text-red-600 px-3 py-1.5 rounded-lg hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors"
              >
                ログアウト
              </button>
            ) : (
              <button
                onClick={signInWithGoogle}
                className="text-xs font-medium text-primary-500 px-3 py-1.5 rounded-lg bg-primary-50 dark:bg-primary-900/30 hover:bg-primary-100 dark:hover:bg-primary-900/50 transition-colors"
              >
                接続
              </button>
            )}
          </div>

          {/* Microsoft */}
          <div className="flex items-center justify-between py-3">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded-full bg-orange-50 dark:bg-orange-900/30 flex items-center justify-center">
                <svg className="w-4 h-4 text-orange-500" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M3 3h8v8H3V3zm10 0h8v8h-8V3zM3 13h8v8H3v-8zm10 0h8v8h-8v-8z" />
                </svg>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-900 dark:text-gray-100">
                  Microsoft
                </p>
                <p className="text-xs text-gray-500 dark:text-gray-400">
                  準備中
                </p>
              </div>
            </div>
            <button
              disabled
              className="text-xs font-medium text-gray-400 px-3 py-1.5 rounded-lg cursor-not-allowed"
            >
              接続
            </button>
          </div>
        </section>

        {/* Calendar visibility section */}
        <section className="px-4 py-4">
          <h2 className="text-xs font-bold text-primary-600 dark:text-primary-400 uppercase tracking-wide mb-3">
            カレンダー表示設定
          </h2>

          {calendars.length === 0 ? (
            <p className="text-sm text-gray-400 dark:text-gray-500 py-2">
              アカウントを接続するとカレンダーが表示されます
            </p>
          ) : (
            calendars.map((cal) => (
              <label
                key={cal.id}
                className="flex items-center justify-between py-3 cursor-pointer"
              >
                <div>
                  <p className="text-sm font-medium text-gray-900 dark:text-gray-100">
                    {cal.name}
                  </p>
                  <p className="text-xs text-gray-500 dark:text-gray-400">
                    {cal.source === 'google' ? 'Google Calendar' : 'Outlook'}
                  </p>
                </div>
                <input
                  type="checkbox"
                  checked={!hiddenCalendarIds.has(cal.id)}
                  onChange={() => toggleCalendarVisibility(cal.id)}
                  className="w-5 h-5 rounded text-primary-500 focus:ring-primary-500 focus:ring-offset-0"
                />
              </label>
            ))
          )}
        </section>

        {/* About */}
        <section className="px-4 py-4">
          <h2 className="text-xs font-bold text-primary-600 dark:text-primary-400 uppercase tracking-wide mb-3">
            アプリについて
          </h2>
          <p className="text-sm text-gray-600 dark:text-gray-400">
            CalSync Todo v1.0.0
          </p>
        </section>
      </div>
    </div>
  );
}
