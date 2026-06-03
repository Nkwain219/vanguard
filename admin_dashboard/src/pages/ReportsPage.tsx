import React, { useEffect, useState } from 'react';
import { collection, getDocs, query, orderBy, limit } from 'firebase/firestore';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Legend,
} from 'recharts';
import { BarChart3, RefreshCw } from 'lucide-react';
import { db } from '../firebase';
import { COLLECTIONS } from '../lib/collections';
import PageHeader from '../components/PageHeader';
import StatCard from '../components/StatCard';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorState from '../components/ErrorState';
import { format, subMonths } from 'date-fns';

const COLORS = ['#4F46E5', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#06B6D4'];

interface AttendanceSummary {
  month: string;
  present: number;
  absent: number;
  late: number;
}

interface LeaveTypeData {
  name: string;
  value: number;
}

interface SalaryMonthly {
  month: string;
  disbursed: number;
  pending: number;
}

const ReportsPage: React.FC = () => {
  const [attendanceData, setAttendanceData] = useState<AttendanceSummary[]>([]);
  const [leaveTypeData, setLeaveTypeData] = useState<LeaveTypeData[]>([]);
  const [salaryData, setSalaryData] = useState<SalaryMonthly[]>([]);
  const [stats, setStats] = useState({
    totalAttendance: 0,
    totalLeaves: 0,
    totalDisbursed: 0,
    attendanceRate: 0,
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const fetchReports = async () => {
    setLoading(true);
    setError('');
    try {
      const [attendanceSnap, leavesSnap, salarySnap] = await Promise.all([
        getDocs(query(collection(db, COLLECTIONS.ATTENDANCE), orderBy('date', 'desc'), limit(500))),
        getDocs(collection(db, COLLECTIONS.LEAVE_REQUESTS)),
        getDocs(query(collection(db, COLLECTIONS.SALARY_REQUESTS), orderBy('requestedAt', 'desc'), limit(200))),
      ]);

      // Attendance by month
      const now = new Date();
      const months: AttendanceSummary[] = [];
      for (let i = 5; i >= 0; i--) {
        months.push({ month: format(subMonths(now, i), 'MMM'), present: 0, absent: 0, late: 0 });
      }

      let totalPresent = 0;
      let totalAll = 0;
      attendanceSnap.forEach((d) => {
        const data = d.data();
        if (!data.date) return;
        const label = (() => { try { return format(new Date(data.date), 'MMM'); } catch { return ''; } })();
        const entry = months.find((m) => m.month === label);
        if (!entry) return;
        totalAll++;
        if (data.status === 'present') { entry.present++; totalPresent++; }
        else if (data.status === 'absent') entry.absent++;
        else if (data.status === 'late') { entry.late++; totalPresent++; }
      });
      setAttendanceData(months);

      // Leave by type
      const leaveTypes: Record<string, number> = {};
      leavesSnap.forEach((d) => {
        const data = d.data();
        const type = data.type ?? 'other';
        leaveTypes[type] = (leaveTypes[type] ?? 0) + 1;
      });
      setLeaveTypeData(
        Object.entries(leaveTypes).map(([name, value]) => ({
          name: name.charAt(0).toUpperCase() + name.slice(1),
          value,
        }))
      );

      // Salary disbursements by month
      const salaryMonths: SalaryMonthly[] = [];
      for (let i = 5; i >= 0; i--) {
        salaryMonths.push({ month: format(subMonths(now, i), 'MMM'), disbursed: 0, pending: 0 });
      }
      let totalDisbursedAmount = 0;
      salarySnap.forEach((d) => {
        const data = d.data();
        const dateStr = data.disbursedAt ?? data.requestedAt;
        if (!dateStr) return;
        const label = (() => { try { return format(new Date(dateStr), 'MMM'); } catch { return ''; } })();
        const entry = salaryMonths.find((m) => m.month === label);
        if (!entry) return;
        if (data.status === 'disbursed') {
          entry.disbursed += data.amount ?? 0;
          totalDisbursedAmount += data.amount ?? 0;
        } else if (data.status === 'pending') {
          entry.pending += data.amount ?? 0;
        }
      });
      setSalaryData(salaryMonths);

      setStats({
        totalAttendance: totalAll,
        totalLeaves: leavesSnap.size,
        totalDisbursed: totalDisbursedAmount,
        attendanceRate: totalAll > 0 ? Math.round((totalPresent / totalAll) * 100) : 0,
      });
    } catch (err) {
      console.error(err);
      setError('Failed to load reports.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchReports(); }, []);

  if (loading) return <LoadingSpinner message="Generating reports..." />;
  if (error) return <ErrorState message={error} onRetry={fetchReports} />;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Reports & Analytics"
        subtitle="Overview of workforce data and trends"
        breadcrumb={[{ label: 'Home' }, { label: 'Reports' }]}
        action={
          <button onClick={fetchReports} className="btn-secondary">
            <RefreshCw className="w-4 h-4" />
            Refresh
          </button>
        }
      />

      {/* Summary Stats */}
      <div className="grid grid-cols-2 xl:grid-cols-4 gap-4">
        <StatCard
          title="Attendance Records"
          value={stats.totalAttendance}
          icon={<BarChart3 className="w-5 h-5 text-primary-600" />}
          iconBg="bg-primary-100"
        />
        <StatCard
          title="Attendance Rate"
          value={`${stats.attendanceRate}%`}
          icon={<BarChart3 className="w-5 h-5 text-emerald-600" />}
          iconBg="bg-emerald-100"
        />
        <StatCard
          title="Leave Requests"
          value={stats.totalLeaves}
          icon={<BarChart3 className="w-5 h-5 text-amber-600" />}
          iconBg="bg-amber-100"
        />
        <StatCard
          title="Total Disbursed"
          value={`XAF ${(stats.totalDisbursed / 1000).toFixed(0)}K`}
          icon={<BarChart3 className="w-5 h-5 text-rose-500" />}
          iconBg="bg-rose-100"
        />
      </div>

      {/* Charts Row 1 */}
      <div className="grid grid-cols-1 xl:grid-cols-2 gap-6">
        {/* Attendance Bar Chart */}
        <div className="card">
          <div className="mb-6">
            <h3 className="font-semibold text-gray-900 text-sm">Attendance Summary</h3>
            <p className="text-xs text-gray-500 mt-0.5">Monthly attendance breakdown — last 6 months</p>
          </div>
          {attendanceData.every((m) => m.present === 0 && m.absent === 0) ? (
            <div className="h-52 flex items-center justify-center text-sm text-gray-400">No attendance data</div>
          ) : (
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={attendanceData} barSize={16} barGap={4} margin={{ top: 4, right: 8, left: 0, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E8EAFF" vertical={false} />
                <XAxis dataKey="month" tick={{ fontSize: 11, fill: '#9CA3AF' }} axisLine={false} tickLine={false} />
                <YAxis tick={{ fontSize: 11, fill: '#9CA3AF' }} axisLine={false} tickLine={false} />
                <Tooltip
                  contentStyle={{ backgroundColor: '#fff', border: '1px solid #E8EAFF', borderRadius: '12px', fontSize: '12px' }}
                />
                <Legend iconType="circle" iconSize={8} wrapperStyle={{ fontSize: '12px' }} />
                <Bar dataKey="present" fill="#10B981" radius={[4, 4, 0, 0]} name="Present" />
                <Bar dataKey="absent" fill="#EF4444" radius={[4, 4, 0, 0]} name="Absent" />
                <Bar dataKey="late" fill="#F59E0B" radius={[4, 4, 0, 0]} name="Late" />
              </BarChart>
            </ResponsiveContainer>
          )}
        </div>

        {/* Leave Pie Chart */}
        <div className="card">
          <div className="mb-6">
            <h3 className="font-semibold text-gray-900 text-sm">Leave by Type</h3>
            <p className="text-xs text-gray-500 mt-0.5">Distribution of leave request types</p>
          </div>
          {leaveTypeData.length === 0 ? (
            <div className="h-52 flex items-center justify-center text-sm text-gray-400">No leave data</div>
          ) : (
            <ResponsiveContainer width="100%" height={220}>
              <PieChart>
                <Pie
                  data={leaveTypeData}
                  cx="50%"
                  cy="50%"
                  innerRadius={55}
                  outerRadius={85}
                  paddingAngle={3}
                  dataKey="value"
                >
                  {leaveTypeData.map((_, index) => (
                    <Cell key={index} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip
                  contentStyle={{ backgroundColor: '#fff', border: '1px solid #E8EAFF', borderRadius: '12px', fontSize: '12px' }}
                />
                <Legend iconType="circle" iconSize={8} wrapperStyle={{ fontSize: '12px' }} />
              </PieChart>
            </ResponsiveContainer>
          )}
        </div>
      </div>

      {/* Salary Disbursements Chart */}
      <div className="card">
        <div className="mb-6">
          <h3 className="font-semibold text-gray-900 text-sm">Salary Disbursements</h3>
          <p className="text-xs text-gray-500 mt-0.5">Monthly disbursed vs pending salary amounts</p>
        </div>
        {salaryData.every((m) => m.disbursed === 0 && m.pending === 0) ? (
          <div className="h-56 flex items-center justify-center text-sm text-gray-400">No salary disbursement data</div>
        ) : (
          <ResponsiveContainer width="100%" height={240}>
            <BarChart data={salaryData} barSize={24} barGap={4} margin={{ top: 4, right: 16, left: 0, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E8EAFF" vertical={false} />
              <XAxis dataKey="month" tick={{ fontSize: 11, fill: '#9CA3AF' }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontSize: 11, fill: '#9CA3AF' }} axisLine={false} tickLine={false} tickFormatter={(v) => `${(v / 1000).toFixed(0)}K`} />
              <Tooltip
                contentStyle={{ backgroundColor: '#fff', border: '1px solid #E8EAFF', borderRadius: '12px', fontSize: '12px' }}
                formatter={(val) => [`XAF ${Number(val ?? 0).toLocaleString()}`, '']}
              />
              <Legend iconType="circle" iconSize={8} wrapperStyle={{ fontSize: '12px' }} />
              <Bar dataKey="disbursed" fill="#4F46E5" radius={[6, 6, 0, 0]} name="Disbursed" />
              <Bar dataKey="pending" fill="#F59E0B" radius={[6, 6, 0, 0]} name="Pending" />
            </BarChart>
          </ResponsiveContainer>
        )}
      </div>
    </div>
  );
};

export default ReportsPage;
