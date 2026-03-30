import type { CalendarSource } from '../types/calendar';

interface Props {
  current: CalendarSource | null;
  onChange: (source: CalendarSource | null) => void;
}

export function SourceFilterChips({ current, onChange }: Props) {
  return (
    <div className="flex gap-2 px-4 py-2">
      <Chip label="すべて" active={current === null} onClick={() => onChange(null)} />
      <Chip
        label="Google"
        active={current === 'google'}
        onClick={() => onChange(current === 'google' ? null : 'google')}
      />
      <Chip
        label="Outlook"
        active={current === 'outlook'}
        onClick={() => onChange(current === 'outlook' ? null : 'outlook')}
      />
    </div>
  );
}

function Chip({
  label,
  active,
  onClick,
}: {
  label: string;
  active: boolean;
  onClick: () => void;
}) {
  return (
    <button
      onClick={onClick}
      className={`px-3 py-1.5 rounded-full text-xs font-medium transition-colors ${
        active
          ? 'bg-primary-500 text-white'
          : 'bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-300'
      }`}
    >
      {label}
    </button>
  );
}
