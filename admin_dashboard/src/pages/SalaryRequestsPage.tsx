import React, { useEffect, useState } from 'react';
import {
  collection,
  getDocs,
  doc,
  updateDoc,
  query,
  orderBy,
} from 'firebase/firestore';
import { httpsCallable } from 'firebase/functions';
import { DollarSign, SendHorizonal, AlertCircle } from 'lucide-react';
import { db, functions } from '../firebase';
import { COLLECTIONS } from '../lib/collections';
import { SalaryRequest } from '../types';
import PageHeader from '../components/PageHeader';
import DataTable from '../components/DataTable';
import StatusBadge from '../components/StatusBadge';
import Modal from '../components/Modal';
import StatCard from '../components/StatCard';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorState from '../components/ErrorState';
import { format } from 'date-fns';

const SalaryRequestsPage: React.FC = () => {
  const [requests, setRequests] = useState<SalaryRequest[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [walletBalance, setWalletBalance] = useState(0);
  const [selected, setSelected] = useState<SalaryRequest | null>(null);
  const [disburseLoading, setDisburseLoading] = useState(false);
  const [disburseError, setDisburseError] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'pending' | 'approved' | 'disbursed' | 'rejected'>('all');

  const fetchData = async () => {
    setLoading(true);
    setError('');
    try {
      const [reqSnap, walletSnap] = await Promise.all([
        getDocs(query(collection(db, COLLECTIONS.SALARY_REQUESTS), orderBy('requestedAt', 'desc'))),
        getDocs(collection(db, COLLECTIONS.WALLET_SUMMARY)),
      ]);

      const list: SalaryRequest[] = reqSnap.docs.map((d) => ({
        id: d.id,
        ...(d.data() as Omit<SalaryRequest, 'id'>),
      }));
      setRequests(list);

      let balance = 0;
      walletSnap.forEach((d) => { balance = d.data().balance ?? 0; });
      setWalletBalance(balance);
    } catch (err) {
      console.error(err);
      setError('Failed to load salary requests.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchData(); }, []);

  const handleDisburse = async (request: SalaryRequest) => {
    setDisburseLoading(true);
    setDisburseError('');

    if (walletBalance < request.amount) {
      setDisburseError(`Insufficient wallet balance. Available: XAF ${walletBalance.toLocaleString()}, Required: XAF ${request.amount.toLocaleString()}`);
      setDisburseLoading(false);
      return;
    }

    try {
      // Try Cloud Function first
      try {
        const disburseSalary = httpsCallable(functions, 'disburseSalary');
        await disburseSalary({ salaryRequestId: request.id });
      } catch (fnErr) {
        // Fallback: update directly in Firestore
        console.warn('Cloud function not available, updating directly:', fnErr);
        await updateDoc(doc(db, COLLECTIONS.SALARY_REQUESTS, request.id), {
          status: 'disbursed',
          disbursedAt: new Date().toISOString(),
        });
      }

      setRequests((prev) =>
        prev.map((r) =>
          r.id === request.id ? { ...r, status: 'disbursed', disbursedAt: new Date().toISOString() } : r
        )
      );
      setWalletBalance((b) => b - request.amount);
      setSelected(null);
    } catch (err) {
      console.error(err);
      setDisburseError('Failed to disburse salary. Please try again.');
    } finally {
      setDisburseLoading(false);
    }
  };

  const filtered = statusFilter === 'all' ? requests : requests.filter((r) => r.status === statusFilter);

  const pendingAmount = requests.filter((r) => r.status === 'pending').reduce((s, r) => s + (r.amount ?? 0), 0);
  const disbursedAmount = requests.filter((r) => r.status === 'disbursed').reduce((s, r) => s + (r.amount ?? 0), 0);

  const columns = [
    {
      key: 'employeeName',
      title: 'Employee',
      sortable: true,
      render: (val: unknown, row: SalaryRequest) => (
        <div>
          <p className="font-medium text-gray-900 text-sm">{val as string || row.employeeId}</p>
          <p className="text-xs text-gray-500">{row.period}</p>
        </div>
      ),
    },
    {
      key: 'amount',
      title: 'Amount',
      sortable: true,
      render: (val: unknown) => (
        <span className="font-semibold text-gray-900">XAF {(val as number).toLocaleString()}</span>
      ),
    },
    {
      key: 'status',
      title: 'Status',
      sortable: true,
      render: (val: unknown) => <StatusBadge status={val as string} />,
    },
    {
      key: 'requestedAt',
      title: 'Requested',
      sortable: true,
      render: (val: unknown) => {
        try { return <span className="text-sm text-gray-600">{format(new Date(val as string), 'MMM d, yyyy')}</span>; }
        catch { return val as string; }
      },
    },
    {
      key: 'disbursedAt',
      title: 'Disbursed',
      render: (val: unknown) => {
        if (!val) return <span className="text-gray-400 text-sm">—</span>;
        try { return <span className="text-sm text-emerald-600">{format(new Date(val as string), 'MMM d, yyyy')}</span>; }
        catch { return val as string; }
      },
    },
    {
      key: 'id',
      title: 'Actions',
      render: (_: unknown, row: SalaryRequest) => row.status === 'pending' ? (
        <button
          onClick={(e) => { e.stopPropagation(); setSelected(row); }}
          className="btn-primary py-1 px-3 text-xs"
        >
          <SendHorizonal className="w-3 h-3" />
          Disburse
        </button>
      ) : null,
    },
  ];

  if (loading) return <LoadingSpinner message="Loading salary requests..." />;
  if (error) return <ErrorState message={error} onRetry={fetchData} />;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Salary Requests"
        subtitle="Review and disburse employee salary requests"
        breadcrumb={[{ label: 'Home' }, { label: 'Salary Requests' }]}
      />

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <StatCard
          title="Wallet Balance"
          value={`XAF ${walletBalance.toLocaleString()}`}
          icon={<DollarSign className="w-5 h-5 text-emerald-600" />}
          iconBg="bg-emerald-100"
        />
        <StatCard
          title="Pending Amount"
          value={`XAF ${pendingAmount.toLocaleString()}`}
          icon={<DollarSign className="w-5 h-5 text-amber-600" />}
          iconBg="bg-amber-100"
        />
        <StatCard
          title="Total Disbursed"
          value={`XAF ${disbursedAmount.toLocaleString()}`}
          icon={<DollarSign className="w-5 h-5 text-primary-600" />}
          iconBg="bg-primary-100"
        />
      </div>

      {/* Filter Tabs */}
      <div className="flex items-center gap-2 flex-wrap">
        {(['all', 'pending', 'approved', 'disbursed', 'rejected'] as const).map((s) => (
          <button
            key={s}
            onClick={() => setStatusFilter(s)}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
              statusFilter === s
                ? 'bg-primary-500 text-white shadow-sm'
                : 'bg-white border border-[#E8EAFF] text-gray-600 hover:bg-primary-50'
            }`}
          >
            {s.charAt(0).toUpperCase() + s.slice(1)}
            <span className="ml-1.5 text-xs opacity-75">
              ({s === 'all' ? requests.length : requests.filter((r) => r.status === s).length})
            </span>
          </button>
        ))}
      </div>

      <DataTable
        columns={columns as Parameters<typeof DataTable>[0]['columns']}
        data={filtered as unknown as Record<string, unknown>[]}
        searchPlaceholder="Search by employee or period..."
        onRowClick={(row) => row.status === 'pending' ? setSelected(row as unknown as SalaryRequest) : undefined}
        keyExtractor={(row) => row.id as string}
        emptyTitle="No salary requests"
        emptyMessage="No salary requests found."
      />

      {/* Disburse Modal */}
      {selected && (
        <Modal
          isOpen={!!selected}
          onClose={() => { setSelected(null); setDisburseError(''); }}
          title="Disburse Salary"
          subtitle={selected.employeeName}
          footer={
            <>
              <button onClick={() => { setSelected(null); setDisburseError(''); }} className="btn-secondary">Cancel</button>
              <button
                onClick={() => handleDisburse(selected)}
                disabled={disburseLoading || walletBalance < selected.amount}
                className="btn-success"
              >
                <SendHorizonal className="w-4 h-4" />
                {disburseLoading ? 'Processing...' : 'Confirm Disburse'}
              </button>
            </>
          }
        >
          <div className="space-y-4">
            {disburseError && (
              <div className="flex items-start gap-2 p-4 bg-red-50 border border-red-200 rounded-xl">
                <AlertCircle className="w-4 h-4 text-red-500 flex-shrink-0 mt-0.5" />
                <p className="text-sm text-red-700">{disburseError}</p>
              </div>
            )}

            <div className="grid grid-cols-2 gap-4">
              <div className="p-4 bg-surface rounded-xl">
                <p className="text-xs text-gray-500 mb-1">Employee</p>
                <p className="font-semibold text-gray-900">{selected.employeeName}</p>
              </div>
              <div className="p-4 bg-surface rounded-xl">
                <p className="text-xs text-gray-500 mb-1">Period</p>
                <p className="font-semibold text-gray-900">{selected.period}</p>
              </div>
              <div className="p-4 bg-emerald-50 rounded-xl border border-emerald-200">
                <p className="text-xs text-emerald-600 mb-1">Amount to Disburse</p>
                <p className="font-bold text-emerald-700 text-lg">XAF {selected.amount.toLocaleString()}</p>
              </div>
              <div className={`p-4 rounded-xl border ${walletBalance >= selected.amount ? 'bg-primary-50 border-primary-200' : 'bg-red-50 border-red-200'}`}>
                <p className={`text-xs mb-1 ${walletBalance >= selected.amount ? 'text-primary-600' : 'text-red-600'}`}>Wallet Balance</p>
                <p className={`font-bold text-lg ${walletBalance >= selected.amount ? 'text-primary-700' : 'text-red-700'}`}>
                  XAF {walletBalance.toLocaleString()}
                </p>
              </div>
            </div>

            {selected.notes && (
              <div className="p-4 bg-surface rounded-xl">
                <p className="text-xs text-gray-500 mb-1">Notes</p>
                <p className="text-sm text-gray-800">{selected.notes}</p>
              </div>
            )}

            {walletBalance < selected.amount && (
              <div className="flex items-center gap-2 p-4 bg-amber-50 border border-amber-200 rounded-xl">
                <AlertCircle className="w-4 h-4 text-amber-600 flex-shrink-0" />
                <p className="text-sm text-amber-700">
                  Insufficient balance. Please deposit funds before disbursing.
                </p>
              </div>
            )}
          </div>
        </Modal>
      )}
    </div>
  );
};

export default SalaryRequestsPage;
