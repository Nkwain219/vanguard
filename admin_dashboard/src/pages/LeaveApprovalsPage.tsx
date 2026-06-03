import React, { useEffect, useState } from 'react';
import {
  collection,
  getDocs,
  doc,
  updateDoc,
  query,
  orderBy,
  getDoc,
} from 'firebase/firestore';
import { CheckCircle, XCircle, MessageSquare } from 'lucide-react';
import { db, auth } from '../firebase';
import { COLLECTIONS } from '../lib/collections';
import { LeaveRequest } from '../types';
import PageHeader from '../components/PageHeader';
import DataTable from '../components/DataTable';
import StatusBadge from '../components/StatusBadge';
import Modal from '../components/Modal';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorState from '../components/ErrorState';
import { format } from 'date-fns';

const LeaveApprovalsPage: React.FC = () => {
  const [leaves, setLeaves] = useState<LeaveRequest[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'pending' | 'approved' | 'rejected'>('all');
  const [selected, setSelected] = useState<LeaveRequest | null>(null);
  const [actionLoading, setActionLoading] = useState(false);
  const [notes, setNotes] = useState('');

  const fetchLeaves = async () => {
    setLoading(true);
    setError('');
    try {
      const snap = await getDocs(
        query(collection(db, COLLECTIONS.LEAVE_REQUESTS), orderBy('requestDate', 'desc'))
      );

      const userCache: Record<string, string> = {};
      const list: LeaveRequest[] = await Promise.all(
        snap.docs.map(async (d) => {
          const data = d.data();
          let employeeName = data.employeeFullName;

          if (!employeeName && data.employeeId) {
            if (!userCache[data.employeeId]) {
              try {
                const userDoc = await getDoc(doc(db, COLLECTIONS.USERS, data.employeeId));
                const userData = userDoc.data();
                userCache[data.employeeId] = userData ? `${userData.firstName} ${userData.lastName}` : data.employeeId;
              } catch {
                userCache[data.employeeId] = data.employeeId;
              }
            }
            employeeName = userCache[data.employeeId];
          }

          return { 
            id: d.id,
            employeeId: data.employeeId,
            employeeFullName: employeeName,
            employeeName: employeeName,
            type: data.type,
            startDate: data.startDate,
            endDate: data.endDate,
            days: data.days,
            reason: data.reason,
            status: data.status,
            requestDate: data.requestDate,
            appliedAt: data.requestDate,
            approvedBy: data.approvedBy,
            approvalDate: data.approvalDate,
            notes: data.notes,
          } as LeaveRequest;
        })
      );

      setLeaves(list);
    } catch (err) {
      console.error(err);
      setError('Failed to load leave requests.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchLeaves(); }, []);

  const handleAction = async (leave: LeaveRequest, action: 'approved' | 'rejected') => {
    setActionLoading(true);
    try {
      await updateDoc(doc(db, COLLECTIONS.LEAVE_REQUESTS, leave.id), {
        status: action,
        approvedBy: auth.currentUser?.uid ?? 'admin',
        approvalDate: new Date().toISOString(),
        notes,
      });
      setLeaves((prev) =>
        prev.map((l) =>
          l.id === leave.id
            ? { ...l, status: action, approvalDate: new Date().toISOString(), notes }
            : l
        )
      );
      setSelected(null);
      setNotes('');
    } catch (err) {
      console.error(err);
    } finally {
      setActionLoading(false);
    }
  };

  const filtered = statusFilter === 'all' ? leaves : leaves.filter((l) => l.status === statusFilter);

  const columns = [
    {
      key: 'employeeName',
      title: 'Employee',
      sortable: true,
      render: (val: unknown, row: LeaveRequest) => (
        <div>
          <p className="font-medium text-gray-900 text-sm">{val as string ?? row.userId}</p>
          <p className="text-xs text-gray-500 capitalize">{row.type} leave</p>
        </div>
      ),
    },
    {
      key: 'startDate',
      title: 'Period',
      render: (_: unknown, row: LeaveRequest) => (
        <div className="text-sm">
          <p className="text-gray-800">
            {row.startDate ? (() => { try { return format(new Date(row.startDate), 'MMM d'); } catch { return row.startDate; } })() : '—'}
            {' → '}
            {row.endDate ? (() => { try { return format(new Date(row.endDate), 'MMM d, yyyy'); } catch { return row.endDate; } })() : '—'}
          </p>
          <p className="text-xs text-gray-500">{row.days} day{row.days !== 1 ? 's' : ''}</p>
        </div>
      ),
    },
    {
      key: 'type',
      title: 'Type',
      sortable: true,
      render: (val: unknown) => (
        <span className="capitalize text-sm text-gray-700">{val as string}</span>
      ),
    },
    {
      key: 'status',
      title: 'Status',
      sortable: true,
      render: (val: unknown) => <StatusBadge status={val as string} />,
    },
    {
      key: 'appliedAt',
      title: 'Applied',
      sortable: true,
      render: (val: unknown) => {
        try { return <span className="text-sm text-gray-600">{format(new Date(val as string), 'MMM d, yyyy')}</span>; }
        catch { return val as string; }
      },
    },
    {
      key: 'id',
      title: 'Actions',
      render: (_: unknown, row: LeaveRequest) => row.status === 'pending' ? (
        <div className="flex items-center gap-2">
          <button
            onClick={(e) => { e.stopPropagation(); setSelected(row); }}
            className="btn-primary py-1 px-3 text-xs"
          >
            Review
          </button>
        </div>
      ) : null,
    },
  ];

  if (loading) return <LoadingSpinner message="Loading leave requests..." />;
  if (error) return <ErrorState message={error} onRetry={fetchLeaves} />;

  const pendingCount = leaves.filter((l) => l.status === 'pending').length;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Leave Approvals"
        subtitle={`${pendingCount} pending request${pendingCount !== 1 ? 's' : ''}`}
        breadcrumb={[{ label: 'Home' }, { label: 'Leave Approvals' }]}
      />

      {/* Filter Tabs */}
      <div className="flex items-center gap-2 flex-wrap">
        {(['all', 'pending', 'approved', 'rejected'] as const).map((s) => (
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
              ({s === 'all' ? leaves.length : leaves.filter((l) => l.status === s).length})
            </span>
          </button>
        ))}
      </div>

      <DataTable
        columns={columns as Parameters<typeof DataTable>[0]['columns']}
        data={filtered as unknown as Record<string, unknown>[]}
        searchPlaceholder="Search by employee or type..."
        onRowClick={(row) => setSelected(row as unknown as LeaveRequest)}
        keyExtractor={(row) => row.id as string}
        emptyTitle="No leave requests"
        emptyMessage={statusFilter === 'pending' ? 'No pending leave requests.' : 'No leave requests found.'}
      />

      {/* Review Modal */}
      {selected && (
        <Modal
          isOpen={!!selected}
          onClose={() => { setSelected(null); setNotes(''); }}
          title="Review Leave Request"
          subtitle={selected.employeeName ?? selected.userId}
          footer={
            selected.status === 'pending' ? (
              <>
                <button onClick={() => { setSelected(null); setNotes(''); }} className="btn-secondary">Cancel</button>
                <button
                  onClick={() => handleAction(selected, 'rejected')}
                  disabled={actionLoading}
                  className="btn-danger"
                >
                  <XCircle className="w-4 h-4" />
                  {actionLoading ? 'Processing...' : 'Reject'}
                </button>
                <button
                  onClick={() => handleAction(selected, 'approved')}
                  disabled={actionLoading}
                  className="btn-success"
                >
                  <CheckCircle className="w-4 h-4" />
                  {actionLoading ? 'Processing...' : 'Approve'}
                </button>
              </>
            ) : (
              <button onClick={() => setSelected(null)} className="btn-secondary">Close</button>
            )
          }
        >
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="p-4 bg-surface rounded-xl">
                <p className="text-xs text-gray-500 mb-1">Leave Type</p>
                <p className="font-semibold text-gray-900 capitalize">{selected.type}</p>
              </div>
              <div className="p-4 bg-surface rounded-xl">
                <p className="text-xs text-gray-500 mb-1">Duration</p>
                <p className="font-semibold text-gray-900">{selected.days} day{selected.days !== 1 ? 's' : ''}</p>
              </div>
              <div className="p-4 bg-surface rounded-xl">
                <p className="text-xs text-gray-500 mb-1">Start Date</p>
                <p className="font-semibold text-gray-900">
                  {selected.startDate ? (() => { try { return format(new Date(selected.startDate), 'MMM d, yyyy'); } catch { return selected.startDate; } })() : '—'}
                </p>
              </div>
              <div className="p-4 bg-surface rounded-xl">
                <p className="text-xs text-gray-500 mb-1">End Date</p>
                <p className="font-semibold text-gray-900">
                  {selected.endDate ? (() => { try { return format(new Date(selected.endDate), 'MMM d, yyyy'); } catch { return selected.endDate; } })() : '—'}
                </p>
              </div>
            </div>

            <div className="p-4 bg-surface rounded-xl">
              <p className="text-xs text-gray-500 mb-2">Reason</p>
              <p className="text-sm text-gray-800">{selected.reason || 'No reason provided.'}</p>
            </div>

            <div className="flex items-center gap-2">
              <p className="text-xs text-gray-500">Status:</p>
              <StatusBadge status={selected.status} />
            </div>

            {selected.status === 'pending' && (
              <div>
                <label className="form-label">
                  <MessageSquare className="w-3.5 h-3.5 inline mr-1" />
                  Review Notes (optional)
                </label>
                <textarea
                  className="form-input"
                  rows={3}
                  value={notes}
                  onChange={(e) => setNotes(e.target.value)}
                  placeholder="Add notes for the employee..."
                />
              </div>
            )}

            {selected.notes && selected.status !== 'pending' && (
              <div className="p-4 bg-surface rounded-xl">
                <p className="text-xs text-gray-500 mb-1">Review Notes</p>
                <p className="text-sm text-gray-800">{selected.notes}</p>
              </div>
            )}
          </div>
        </Modal>
      )}
    </div>
  );
};

export default LeaveApprovalsPage;
