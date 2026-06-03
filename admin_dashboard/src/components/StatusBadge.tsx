import React from 'react';

type BadgeVariant =
  | 'active'
  | 'inactive'
  | 'pending'
  | 'approved'
  | 'rejected'
  | 'disbursed'
  | 'present'
  | 'absent'
  | 'late'
  | 'planning'
  | 'completed'
  | 'on-hold'
  | 'info'
  | 'warning'
  | 'success'
  | 'alert'
  | 'credit'
  | 'debit'
  | string;

interface StatusBadgeProps {
  status: BadgeVariant;
  label?: string;
  size?: 'sm' | 'md';
}

const variantStyles: Record<string, string> = {
  active: 'bg-emerald-100 text-emerald-700 border-emerald-200',
  inactive: 'bg-red-100 text-red-700 border-red-200',
  pending: 'bg-amber-100 text-amber-700 border-amber-200',
  approved: 'bg-emerald-100 text-emerald-700 border-emerald-200',
  rejected: 'bg-red-100 text-red-700 border-red-200',
  disbursed: 'bg-primary-100 text-primary-600 border-primary-200',
  present: 'bg-emerald-100 text-emerald-700 border-emerald-200',
  absent: 'bg-red-100 text-red-700 border-red-200',
  late: 'bg-amber-100 text-amber-700 border-amber-200',
  'half-day': 'bg-orange-100 text-orange-700 border-orange-200',
  planning: 'bg-blue-100 text-blue-700 border-blue-200',
  completed: 'bg-emerald-100 text-emerald-700 border-emerald-200',
  'on-hold': 'bg-gray-100 text-gray-600 border-gray-200',
  info: 'bg-blue-100 text-blue-700 border-blue-200',
  warning: 'bg-amber-100 text-amber-700 border-amber-200',
  success: 'bg-emerald-100 text-emerald-700 border-emerald-200',
  alert: 'bg-red-100 text-red-700 border-red-200',
  credit: 'bg-emerald-100 text-emerald-700 border-emerald-200',
  debit: 'bg-red-100 text-red-700 border-red-200',
  'in-progress': 'bg-primary-100 text-primary-600 border-primary-200',
  review: 'bg-purple-100 text-purple-700 border-purple-200',
  todo: 'bg-gray-100 text-gray-600 border-gray-200',
  done: 'bg-emerald-100 text-emerald-700 border-emerald-200',
};

const dotStyles: Record<string, string> = {
  active: 'bg-emerald-500',
  inactive: 'bg-red-500',
  pending: 'bg-amber-500',
  approved: 'bg-emerald-500',
  rejected: 'bg-red-500',
  disbursed: 'bg-primary-500',
  present: 'bg-emerald-500',
  absent: 'bg-red-500',
  late: 'bg-amber-500',
  'half-day': 'bg-orange-500',
  planning: 'bg-blue-500',
  completed: 'bg-emerald-500',
  'on-hold': 'bg-gray-400',
  info: 'bg-blue-500',
  warning: 'bg-amber-500',
  success: 'bg-emerald-500',
  alert: 'bg-red-500',
  credit: 'bg-emerald-500',
  debit: 'bg-red-500',
  'in-progress': 'bg-primary-500',
  review: 'bg-purple-500',
  todo: 'bg-gray-400',
  done: 'bg-emerald-500',
};

const StatusBadge: React.FC<StatusBadgeProps> = ({ status, label, size = 'md' }) => {
  const baseStyle = variantStyles[status] ?? 'bg-gray-100 text-gray-600 border-gray-200';
  const dotStyle = dotStyles[status] ?? 'bg-gray-400';
  const displayLabel = label ?? status.charAt(0).toUpperCase() + status.slice(1).replace(/-/g, ' ');

  const sizeClass = size === 'sm'
    ? 'text-xs px-2 py-0.5 gap-1'
    : 'text-xs px-2.5 py-1 gap-1.5';

  return (
    <span
      className={`inline-flex items-center font-medium rounded-full border ${baseStyle} ${sizeClass}`}
    >
      <span className={`w-1.5 h-1.5 rounded-full ${dotStyle}`} />
      {displayLabel}
    </span>
  );
};

export default StatusBadge;
