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
  Legend,
} from 'recharts';
import { Wallet, TrendingUp, TrendingDown, ArrowUpRight, ArrowDownRight } from 'lucide-react';
import { db } from '../firebase';
import { COLLECTIONS } from '../lib/collections';
import { WalletTransaction } from '../types';
import PageHeader from '../components/PageHeader';
import StatCard from '../components/StatCard';
import StatusBadge from '../components/StatusBadge';
import DataTable from '../components/DataTable';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorState from '../components/ErrorState';
import { format, subMonths } from 'date-fns';

interface MonthlyData {
  month: string;
  revenue: number;
  expenses: number;
}

const WalletPage: React.FC = () => {
  const [balance, setBalance] = useState(0);
  const [totalRevenue, setTotalRevenue] = useState(0);
  const [totalExpenses, setTotalExpenses] = useState(0);
  const [transactions, setTransactions] = useState<WalletTransaction[]>([]);
  const [monthlyData, setMonthlyData] = useState<MonthlyData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const fetchData = async () => {
    setLoading(true);
    setError('');
    try {
      const [walletSnap, txSnap] = await Promise.all([
        getDocs(collection(db, COLLECTIONS.WALLET_SUMMARY)),
        getDocs(
          query(
            collection(db, COLLECTIONS.WALLET_TRANSACTIONS),
            orderBy('createdAt', 'desc'),
            limit(200)
          )
        ),
      ]);

      // Summary
      walletSnap.forEach((d) => {
        const data = d.data();
        setBalance(data.balance ?? 0);
        setTotalRevenue(data.totalRevenue ?? 0);
        setTotalExpenses(data.totalExpenses ?? 0);
      });

      // Transactions
      const txList: WalletTransaction[] = txSnap.docs.map((d) => ({
        id: d.id,
        ...(d.data() as Omit<WalletTransaction, 'id'>),
      }));
      setTransactions(txList.slice(0, 50));

      // Monthly chart — last 6 months
      const now = new Date();
      const months: MonthlyData[] = [];
      for (let i = 5; i >= 0; i--) {
        months.push({ month: format(subMonths(now, i), 'MMM'), revenue: 0, expenses: 0 });
      }

      txList.forEach((tx) => {
        if (!tx.createdAt) return;
        const label = (() => { try { return format(new Date(tx.createdAt), 'MMM'); } catch { return ''; } })();
        const entry = months.find((m) => m.month === label);
        if (!entry) return;
        if (tx.type === 'credit') entry.revenue += tx.amount ?? 0;
        else entry.expenses += tx.amount ?? 0;
      });

      setMonthlyData(months);

      // Recalculate from transactions if summary missing
      if (totalRevenue === 0 && totalExpenses === 0) {
        let rev = 0, exp = 0;
        txList.forEach((tx) => {
          if (tx.type === 'credit') rev += tx.amount ?? 0;
          else exp += tx.amount ?? 0;
        });
        setTotalRevenue(rev);
        setTotalExpenses(exp);
      }
    } catch (err) {
      console.error(err);
      setError('Failed to load wallet data.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchData(); }, []);

  const columns = [
    {
      key: 'description',
      title: 'Description',
      render: (val: unknown, row: WalletTransaction) => (
        <div className="flex items-center gap-3">
          <div className={`p-2 rounded-lg ${row.type === 'credit' ? 'bg-emerald-100' : 'bg-red-100'}`}>
            {row.type === 'credit'
              ? <ArrowUpRight className="w-4 h-4 text-emerald-600" />
              : <ArrowDownRight className="w-4 h-4 text-red-600" />}
          </div>
          <div>
            <p className="text-sm font-medium text-gray-900">{val as string || 'Transaction'}</p>
            <p className="text-xs text-gray-500 capitalize">{row.category || row.type}</p>
          </div>
        </div>
      ),
    },
    {
      key: 'type',
      title: 'Type',
      render: (val: unknown) => <StatusBadge status={val as string} />,
    },
    {
      key: 'amount',
      title: 'Amount',
      sortable: true,
      render: (val: unknown, row: WalletTransaction) => (
        <span className={`font-semibold ${row.type === 'credit' ? 'text-emerald-600' : 'text-red-600'}`}>
          {row.type === 'credit' ? '+' : '-'} XAF {(val as number).toLocaleString()}
        </span>
      ),
    },
    {
      key: 'balance',
      title: 'Balance After',
      render: (val: unknown) => val
        ? <span className="text-sm text-gray-700">XAF {(val as number).toLocaleString()}</span>
        : <span className="text-gray-400">—</span>,
    },
    {
      key: 'createdAt',
      title: 'Date',
      sortable: true,
      render: (val: unknown) => {
        try { return <span className="text-sm text-gray-600">{format(new Date(val as string), 'MMM d, yyyy h:mm a')}</span>; }
        catch { return val as string; }
      },
    },
  ];

  if (loading) return <LoadingSpinner message="Loading wallet data..." />;
  if (error) return <ErrorState message={error} onRetry={fetchData} />;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Wallet"
        subtitle="Financial overview and transaction history"
        breadcrumb={[{ label: 'Home' }, { label: 'Wallet' }]}
      />

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <StatCard
          title="Current Balance"
          value={`XAF ${balance.toLocaleString()}`}
          icon={<Wallet className="w-5 h-5 text-primary-600" />}
          iconBg="bg-primary-100"
        />
        <StatCard
          title="Total Revenue"
          value={`XAF ${totalRevenue.toLocaleString()}`}
          icon={<TrendingUp className="w-5 h-5 text-emerald-600" />}
          iconBg="bg-emerald-100"
        />
        <StatCard
          title="Total Expenses"
          value={`XAF ${totalExpenses.toLocaleString()}`}
          icon={<TrendingDown className="w-5 h-5 text-red-500" />}
          iconBg="bg-red-100"
        />
      </div>

      {/* Monthly Bar Chart */}
      <div className="card">
        <div className="mb-6">
          <h3 className="font-semibold text-gray-900 text-sm">Monthly Financial Overview</h3>
          <p className="text-xs text-gray-500 mt-0.5">Revenue and expenses for the last 6 months</p>
        </div>
        {monthlyData.every((m) => m.revenue === 0 && m.expenses === 0) ? (
          <div className="h-56 flex items-center justify-center text-sm text-gray-400">
            No transaction data available yet
          </div>
        ) : (
          <ResponsiveContainer width="100%" height={240}>
            <BarChart data={monthlyData} margin={{ top: 4, right: 16, left: 0, bottom: 0 }} barSize={24} barGap={4}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E8EAFF" vertical={false} />
              <XAxis dataKey="month" tick={{ fontSize: 11, fill: '#9CA3AF' }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontSize: 11, fill: '#9CA3AF' }} axisLine={false} tickLine={false} tickFormatter={(v) => `${(v / 1000).toFixed(0)}K`} />
              <Tooltip
                contentStyle={{ backgroundColor: '#fff', border: '1px solid #E8EAFF', borderRadius: '12px', fontSize: '12px' }}
                formatter={(val) => [`XAF ${Number(val ?? 0).toLocaleString()}`, '']}
              />
              <Legend iconType="circle" iconSize={8} wrapperStyle={{ fontSize: '12px' }} />
              <Bar dataKey="revenue" fill="#4F46E5" radius={[6, 6, 0, 0]} name="Revenue" />
              <Bar dataKey="expenses" fill="#F43F5E" radius={[6, 6, 0, 0]} name="Expenses" />
            </BarChart>
          </ResponsiveContainer>
        )}
      </div>

      {/* Transactions */}
      <div>
        <h3 className="font-semibold text-gray-900 text-sm mb-4">Recent Transactions</h3>
        <DataTable
          columns={columns as Parameters<typeof DataTable>[0]['columns']}
          data={transactions as unknown as Record<string, unknown>[]}
          searchPlaceholder="Search transactions..."
          keyExtractor={(row) => row.id as string}
          emptyTitle="No transactions"
          emptyMessage="No wallet transactions found."
        />
      </div>
    </div>
  );
};

export default WalletPage;
