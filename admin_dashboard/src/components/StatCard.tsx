import React from 'react';
import { TrendingUp, TrendingDown, Minus } from 'lucide-react';

interface StatCardProps {
  title: string;
  value: string | number;
  icon: React.ReactNode;
  iconBg?: string;
  trend?: number;
  trendLabel?: string;
  prefix?: string;
  suffix?: string;
  loading?: boolean;
}

const StatCard: React.FC<StatCardProps> = ({
  title,
  value,
  icon,
  iconBg = 'bg-primary-100',
  trend,
  trendLabel,
  prefix = '',
  suffix = '',
  loading = false,
}) => {
  const trendPositive = trend !== undefined && trend > 0;
  const trendNegative = trend !== undefined && trend < 0;
  const trendNeutral = trend === 0;

  return (
    <div className="card flex flex-col gap-4">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-xs font-semibold text-gray-500 uppercase tracking-wider">{title}</p>
          {loading ? (
            <div className="mt-2 h-8 w-28 bg-gray-100 animate-pulse rounded-lg" />
          ) : (
            <p className="mt-1.5 text-2xl font-bold text-gray-900">
              {prefix}
              {typeof value === 'number' ? value.toLocaleString() : value}
              {suffix}
            </p>
          )}
        </div>
        <div className={`p-3 rounded-xl ${iconBg}`}>{icon}</div>
      </div>

      {trend !== undefined && !loading && (
        <div className="flex items-center gap-1.5">
          {trendPositive && (
            <>
              <TrendingUp className="w-3.5 h-3.5 text-emerald-500" />
              <span className="text-xs font-semibold text-emerald-600">+{trend}%</span>
            </>
          )}
          {trendNegative && (
            <>
              <TrendingDown className="w-3.5 h-3.5 text-red-500" />
              <span className="text-xs font-semibold text-red-600">{trend}%</span>
            </>
          )}
          {trendNeutral && (
            <>
              <Minus className="w-3.5 h-3.5 text-gray-400" />
              <span className="text-xs font-semibold text-gray-500">0%</span>
            </>
          )}
          {trendLabel && (
            <span className="text-xs text-gray-500">{trendLabel}</span>
          )}
        </div>
      )}
    </div>
  );
};

export default StatCard;
