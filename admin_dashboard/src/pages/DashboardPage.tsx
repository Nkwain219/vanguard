import React, { useEffect, useState } from 'react';
import {
  collection,
  query,
  where,
  getDocs,
  orderBy,
  limit,
} from 'firebase/firestore';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from 'recharts';
import { Users, Heart, CalendarX, Wallet, Activity } from 'lucide-react';
import { db } from '../firebase';
import { COLLECTIONS } from '../lib/collections';
import StatCard from '../components/StatCard';
import PageHeader from '../components/PageHeader';
import StatusBadge from '../components/StatusBadge';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorState from '../components/ErrorState';
import { format, subMonths } from 'date-fns';

interface ActivityItem {
  id: string;
  type: 'leave' | 'salary' | 'employee' | 'notification';
  title: string;
  subtitle: string;
  time: string;
  status?: string;
}

interface MonthlyData {
  month: string;
  revenue: number;
  expenses: number;
}

const DashboardPage: React.FC = () => {
  const [stats, setStats] = useState({
    totalEmployees: 0,
    activeVolunteers: 0,
    pendingLeaves: 0,
    walletBalance: 0,
  });
  const [monthlyData, setMonthlyData] = useState<MonthlyData[]>([]);
  const [activity, setActivity] = useState<ActivityItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const fetchData = async () => {
    setLoading(true);
    setError('');
    try {
      // Parallel fetches
      const [
        employeesSnap,
        volunteersSnap,
        leavesSnap,
        walletSnap,
        recentLeavesSnap,
        recentSalarySnap,
      ] = await Promise.all([
        getDocs(collection(db, COLLECTIONS.EMPLOYEES)),
        getDocs(query(collection(db, COLLECTIONS.VOLUNTEERS), where('status', '==', 'active'))),
        getDocs(query(collection(db, COLLECTIONS.LEAVE_REQUESTS), where('status', '==', 'pending'))),
        getDocs(collection(db, COLLECTIONS.WALLET_SUMMARY)),
        getDocs(query(
          collection(db, COLLECTIONS.LEAVE_REQUESTS),
          orderBy('appliedAt', 'desc'),
          limit(5)
        )),
        getDocs(query(
          collection(db, COLLECTIONS.SALARY_REQUESTS),
          orderBy('requestedAt', 'desc'),
          limit(5)
        )),
      ]);

      // Stats
      let balance = 0;
      walletSnap.forEach((d) => {
        const data = d.data();
        balance = data.balance ?? 0;
      });

      setStats({
        totalEmployees: employeesSnap.size,
        activeVolunteers: volunteersSnap.size,
        pendingLeaves: leavesSnap.size,
        walletBalance: balance,
      });

      // Activity feed
      const acts: ActivityItem[] = [];
      recentLeavesSnap.forEach((d) => {
        const data = d.data();
        acts.push({
          id: d.id,
          type: 'leave',
          title: `Leave Request — ${data.type ?? 'Annual'}`,
          subtitle: data.employeeName ?? data.userId ?? 'Employee',
          time: data.appliedAt ?? '',
          status: data.status ?? 'pending',
        });
      });
      recentSalarySnap.forEach((d) => {
        const data = d.data();
        acts.push({
          id: d.id,
          type: 'salary',
          title: `Salary Request — XAF ${(data.amount ?? 0).toLocaleString()}`,
          subtitle: data.employeeName ?? data.employeeId ?? 'Employee',
          time: data.requestedAt ?? '',
          status: data.status ?? 'pending',
        });
      });
      acts.sort((a, b) => (a.time > b.time ? -1 : 1));
      setActivity(acts.slice(0, 8));

      // Monthly chart data (last 6 months)
      const now = new Date();
      const months: MonthlyData[] = [];
      for (let i = 5; i >= 0; i--) {
        const month = subMonths(now, i);
        months.push({
          month: format(month, 'MMM'),
          revenue: 0,
          expenses: 0,
        });
      }

      // Fetch wallet transactions for chart
      const txSnap = await getDocs(
        query(
          collection(db, COLLECTIONS.WALLET_TRANSACTIONS),
          orderBy('createdAt', 'desc'),
          limit(200)
        )
      );

      txSnap.forEach((d) => {
        const data = d.data();
        const date = data.createdAt ? new Date(data.createdAt) : null;
        if (!date) return;
        const monthLabel = format(date, 'MMM');
        const mEntry = months.find((m) => m.month === monthLabel);
        if (!mEntry) return;
        if (data.type === 'credit') {
          mEntry.revenue += data.amount ?? 0;
        } else {
          mEntry.expenses += data.amount ?? 0;
        }
      });

      setMonthlyData(months);
    } catch (err) {
      console.error(err);
      setError('Failed to load dashboard data. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  if (loading) return <LoadingSpinner message="Loading dashboard..." />;
  if (error) return <ErrorState message={error} onRetry={fetchData} />;

  const formatCurrency = (val: number) =>
    val >= 1_000_000
      ? `XAF ${(val / 1_000_000).toFixed(1)}M`
      : val >= 1_000
      ? `XAF ${(val / 1_000).toFixed(0)}K`
      : `XAF ${val.toLocaleString()}`;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Dashboard"
        subtitle="Welcome back. Here's what's happening today."
        breadcrumb={[{ label: 'Home' }, { label: 'Dashboard' }]}
      />

      {/* Stat Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <StatCard
          title="Total Employees"
          value={stats.totalEmployees}
          icon={<Users className="w-5 h-5 text-primary-600" />}
          iconBg="bg-primary-100"
          trend={5}
          trendLabel="vs last month"
        />
        <StatCard
          title="Active Volunteers"
          value={stats.activeVolunteers}
          icon={<Heart className="w-5 h-5 text-rose-500" />}
          iconBg="bg-rose-100"
          trend={2}
          trendLabel="vs last month"
        />
        <StatCard
          title="Pending Leaves"
          value={stats.pendingLeaves}
          icon={<CalendarX className="w-5 h-5 text-amber-600" />}
          iconBg="bg-amber-100"
          trend={-3}
          trendLabel="vs last month"
        />
        <StatCard
          title="Wallet Balance"
          value={formatCurrency(stats.walletBalance)}
          icon={<Wallet className="w-5 h-5 text-emerald-600" />}
          iconBg="bg-emerald-100"
          trend={8}
          trendLabel="vs last month"
        />
      </div>

      {/* Charts & Activity */}
      <div className="grid grid-cols-1 xl:grid-cols-3 gap-6">
        {/* Line Chart */}
        <div className="xl:col-span-2 card">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h3 className="font-semibold text-gray-900 text-sm">Revenue vs Expenses</h3>
              <p className="text-xs text-gray-500 mt-0.5">Last 6 months overview</p>
            </div>
          </div>
          {monthlyData.every((m) => m.revenue === 0 && m.expenses === 0) ? (
            <div className="h-56 flex items-center justify-center text-sm text-gray-400">
              No transaction data available yet
            </div>
          ) : (
            <ResponsiveContainer width="100%" height={220}>
              <LineChart data={monthlyData} margin={{ top: 4, right: 16, left: 0, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E8EAFF" />
                <XAxis
                  dataKey="month"
                  tick={{ fontSize: 11, fill: '#9CA3AF' }}
                  axisLine={false}
                  tickLine={false}
                />
                <YAxis
                  tick={{ fontSize: 11, fill: '#9CA3AF' }}
                  axisLine={false}
                  tickLine={false}
                  tickFormatter={(v) => `${(v / 1000).toFixed(0)}K`}
                />
                <Tooltip
                  contentStyle={{
                    backgroundColor: '#fff',
                    border: '1px solid #E8EAFF',
                    borderRadius: '12px',
                    fontSize: '12px',
                  }}
                  formatter={(val) => [`XAF ${Number(val ?? 0).toLocaleString()}`, '']}
                />
                <Legend iconType="circle" iconSize={8} wrapperStyle={{ fontSize: '12px' }} />
                <Line
                  type="monotone"
                  dataKey="revenue"
                  stroke="#4F46E5"
                  strokeWidth={2.5}
                  dot={{ r: 4, fill: '#4F46E5', strokeWidth: 0 }}
                  activeDot={{ r: 6 }}
                  name="Revenue"
                />
                <Line
                  type="monotone"
                  dataKey="expenses"
                  stroke="#F43F5E"
                  strokeWidth={2.5}
                  dot={{ r: 4, fill: '#F43F5E', strokeWidth: 0 }}
                  activeDot={{ r: 6 }}
                  name="Expenses"
                />
              </LineChart>
            </ResponsiveContainer>
          )}
        </div>

        {/* Activity Feed */}
        <div className="card">
          <div className="flex items-center gap-2 mb-4">
            <Activity className="w-4 h-4 text-primary-500" />
            <h3 className="font-semibold text-gray-900 text-sm">Recent Activity</h3>
          </div>
          {activity.length === 0 ? (
            <p className="text-sm text-gray-400 text-center py-8">No recent activity</p>
          ) : (
            <div className="space-y-3">
              {activity.map((item) => (
                <div key={item.id} className="flex items-start gap-3">
                  <div
                    className={`mt-0.5 w-2 h-2 rounded-full flex-shrink-0 ${
                      item.status === 'approved' ? 'bg-emerald-500' :
                      item.status === 'rejected' ? 'bg-red-500' :
                      item.status === 'disbursed' ? 'bg-primary-500' :
                      'bg-amber-500'
                    }`}
                  />
                  <div className="min-w-0 flex-1">
                    <p className="text-xs font-medium text-gray-800 truncate">{item.title}</p>
                    <p className="text-xs text-gray-500 truncate">{item.subtitle}</p>
                    {item.time && (
                      <p className="text-xs text-gray-400 mt-0.5">
                        {format(new Date(item.time), 'MMM d, h:mm a')}
                      </p>
                    )}
                  </div>
                  {item.status && (
                    <StatusBadge status={item.status} size="sm" />
                  )}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default DashboardPage;
