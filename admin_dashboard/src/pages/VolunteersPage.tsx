import React, { useEffect, useState } from 'react';
import {
  collection,
  getDocs,
  addDoc,
  doc,
  updateDoc,
  serverTimestamp,
  orderBy,
  query,
} from 'firebase/firestore';
import { UserPlus, Mail, Phone, Briefcase, Clock, Calendar, X } from 'lucide-react';
import { db } from '../firebase';
import { COLLECTIONS } from '../lib/collections';
import { Volunteer } from '../types';
import PageHeader from '../components/PageHeader';
import DataTable from '../components/DataTable';
import StatusBadge from '../components/StatusBadge';
import Modal from '../components/Modal';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorState from '../components/ErrorState';
import { format } from 'date-fns';

const AREAS = ['Community Outreach', 'Event Support', 'Administrative', 'IT Support', 'Training', 'Communications', 'Logistics'];
const ROLES = ['Volunteer', 'Senior Volunteer', 'Team Lead', 'Coordinator', 'Mentor'];

const VolunteersPage: React.FC = () => {
  const [volunteers, setVolunteers] = useState<Volunteer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showAdd, setShowAdd] = useState(false);
  const [selected, setSelected] = useState<Volunteer | null>(null);
  const [saving, setSaving] = useState(false);

  const [form, setForm] = useState({
    name: '',
    email: '',
    phone: '',
    role: '',
    department: '',
    joinDate: new Date().toISOString().split('T')[0],
    status: 'active' as 'active' | 'inactive',
    hoursVolunteered: 0,
  });

  const fetchVolunteers = async () => {
    setLoading(true);
    setError('');
    try {
      const snap = await getDocs(
        query(collection(db, COLLECTIONS.VOLUNTEERS), orderBy('name', 'asc'))
      );
      const list: Volunteer[] = snap.docs.map((d) => ({
        id: d.id,
        ...(d.data() as Omit<Volunteer, 'id'>),
      }));
      setVolunteers(list);
    } catch (err) {
      console.error(err);
      setError('Failed to load volunteers.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchVolunteers(); }, []);

  const handleAdd = async () => {
    if (!form.name || !form.email) return;
    setSaving(true);
    try {
      const newDoc = await addDoc(collection(db, COLLECTIONS.VOLUNTEERS), {
        ...form,
        createdAt: serverTimestamp(),
      });
      setVolunteers((prev) => [...prev, { id: newDoc.id, ...form }]);
      setShowAdd(false);
      setForm({ name: '', email: '', phone: '', role: '', department: '', joinDate: new Date().toISOString().split('T')[0], status: 'active', hoursVolunteered: 0 });
    } catch (err) {
      console.error(err);
    } finally {
      setSaving(false);
    }
  };

  const handleStatusToggle = async (vol: Volunteer) => {
    const newStatus = vol.status === 'active' ? 'inactive' : 'active';
    try {
      await updateDoc(doc(db, COLLECTIONS.VOLUNTEERS, vol.id), { status: newStatus });
      setVolunteers((prev) => prev.map((v) => (v.id === vol.id ? { ...v, status: newStatus } : v)));
      if (selected?.id === vol.id) setSelected((s) => s ? { ...s, status: newStatus } : null);
    } catch (err) {
      console.error(err);
    }
  };

  const columns = [
    {
      key: 'name',
      title: 'Name',
      sortable: true,
      render: (_: unknown, row: Volunteer) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-gradient-to-br from-rose-400 to-rose-600 flex items-center justify-center flex-shrink-0">
            <span className="text-white text-xs font-bold">{row.name.charAt(0).toUpperCase()}</span>
          </div>
          <div>
            <p className="font-medium text-gray-900 text-sm">{row.name}</p>
            <p className="text-xs text-gray-500">{row.email}</p>
          </div>
        </div>
      ),
    },
    { key: 'role', title: 'Role', sortable: true },
    { key: 'department', title: 'Area', sortable: true },
    {
      key: 'hoursVolunteered',
      title: 'Hours',
      sortable: true,
      render: (val: unknown) => (
        <span className="font-medium text-primary-600">{val as number ?? 0}h</span>
      ),
    },
    {
      key: 'status',
      title: 'Status',
      sortable: true,
      render: (val: unknown) => <StatusBadge status={val as string} />,
    },
    {
      key: 'joinDate',
      title: 'Join Date',
      sortable: true,
      render: (val: unknown) => {
        try { return format(new Date(val as string), 'MMM d, yyyy'); } catch { return val as string; }
      },
    },
  ];

  if (loading) return <LoadingSpinner message="Loading volunteers..." />;
  if (error) return <ErrorState message={error} onRetry={fetchVolunteers} />;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Volunteers"
        subtitle={`${volunteers.length} total volunteers`}
        breadcrumb={[{ label: 'Home' }, { label: 'Volunteers' }]}
        action={
          <button onClick={() => setShowAdd(true)} className="btn-primary">
            <UserPlus className="w-4 h-4" />
            Add Volunteer
          </button>
        }
      />

      <DataTable
        columns={columns as Parameters<typeof DataTable>[0]['columns']}
        data={volunteers as unknown as Record<string, unknown>[]}
        searchPlaceholder="Search volunteers..."
        onRowClick={(row) => setSelected(row as unknown as Volunteer)}
        keyExtractor={(row) => row.id as string}
        emptyTitle="No volunteers yet"
        emptyMessage="Add your first volunteer to get started."
      />

      {/* Add Modal */}
      <Modal
        isOpen={showAdd}
        onClose={() => setShowAdd(false)}
        title="Add Volunteer"
        subtitle="Create a new volunteer record"
        footer={
          <>
            <button onClick={() => setShowAdd(false)} className="btn-secondary">Cancel</button>
            <button onClick={handleAdd} disabled={saving || !form.name || !form.email} className="btn-primary">
              {saving ? 'Saving...' : 'Add Volunteer'}
            </button>
          </>
        }
      >
        <div className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="col-span-2">
              <label className="form-label">Full Name *</label>
              <input className="form-input" value={form.name} onChange={(e) => setForm((f) => ({ ...f, name: e.target.value }))} placeholder="Jane Doe" />
            </div>
            <div className="col-span-2">
              <label className="form-label">Email *</label>
              <input type="email" className="form-input" value={form.email} onChange={(e) => setForm((f) => ({ ...f, email: e.target.value }))} placeholder="jane@example.com" />
            </div>
            <div>
              <label className="form-label">Phone</label>
              <input className="form-input" value={form.phone} onChange={(e) => setForm((f) => ({ ...f, phone: e.target.value }))} placeholder="+237 6XX XXX XXX" />
            </div>
            <div>
              <label className="form-label">Hours Volunteered</label>
              <input type="number" className="form-input" value={form.hoursVolunteered} onChange={(e) => setForm((f) => ({ ...f, hoursVolunteered: Number(e.target.value) }))} min={0} />
            </div>
            <div>
              <label className="form-label">Role</label>
              <select className="form-input" value={form.role} onChange={(e) => setForm((f) => ({ ...f, role: e.target.value }))}>
                <option value="">Select role</option>
                {ROLES.map((r) => <option key={r} value={r}>{r}</option>)}
              </select>
            </div>
            <div>
              <label className="form-label">Area</label>
              <select className="form-input" value={form.department} onChange={(e) => setForm((f) => ({ ...f, department: e.target.value }))}>
                <option value="">Select area</option>
                {AREAS.map((a) => <option key={a} value={a}>{a}</option>)}
              </select>
            </div>
            <div>
              <label className="form-label">Join Date</label>
              <input type="date" className="form-input" value={form.joinDate} onChange={(e) => setForm((f) => ({ ...f, joinDate: e.target.value }))} />
            </div>
            <div>
              <label className="form-label">Status</label>
              <select className="form-input" value={form.status} onChange={(e) => setForm((f) => ({ ...f, status: e.target.value as 'active' | 'inactive' }))}>
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
              </select>
            </div>
          </div>
        </div>
      </Modal>

      {/* Detail Panel */}
      {selected && (
        <div className="fixed inset-y-0 right-0 w-full sm:w-96 bg-white border-l border-[#E8EAFF] shadow-modal z-40 flex flex-col">
          <div className="flex items-center justify-between p-6 border-b border-[#E8EAFF]">
            <h3 className="font-semibold text-gray-900">Volunteer Details</h3>
            <button onClick={() => setSelected(null)} className="p-1.5 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100 transition-colors">
              <X className="w-5 h-5" />
            </button>
          </div>
          <div className="flex-1 overflow-y-auto scrollbar-thin p-6 space-y-6">
            <div className="flex flex-col items-center text-center">
              <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-rose-400 to-rose-700 flex items-center justify-center shadow-lg mb-4">
                <span className="text-white text-3xl font-bold">{selected.name.charAt(0).toUpperCase()}</span>
              </div>
              <h4 className="font-bold text-gray-900 text-lg">{selected.name}</h4>
              <p className="text-sm text-gray-500">{selected.role} • {selected.department}</p>
              <div className="mt-3"><StatusBadge status={selected.status} /></div>
            </div>
            <div className="space-y-3">
              {[
                { icon: <Mail className="w-4 h-4" />, label: 'Email', value: selected.email },
                { icon: <Phone className="w-4 h-4" />, label: 'Phone', value: selected.phone ?? '—' },
                { icon: <Briefcase className="w-4 h-4" />, label: 'Role', value: selected.role || '—' },
                { icon: <Clock className="w-4 h-4" />, label: 'Hours Volunteered', value: `${selected.hoursVolunteered ?? 0} hours` },
                {
                  icon: <Calendar className="w-4 h-4" />,
                  label: 'Join Date',
                  value: selected.joinDate ? (() => { try { return format(new Date(selected.joinDate), 'MMMM d, yyyy'); } catch { return selected.joinDate; } })() : '—',
                },
              ].map((item) => (
                <div key={item.label} className="flex items-center gap-3 p-3 bg-surface rounded-xl">
                  <div className="p-2 bg-rose-50 rounded-lg text-rose-500">{item.icon}</div>
                  <div>
                    <p className="text-xs text-gray-500">{item.label}</p>
                    <p className="text-sm font-medium text-gray-800">{item.value}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
          <div className="p-6 border-t border-[#E8EAFF] flex gap-3">
            <button
              onClick={() => handleStatusToggle(selected)}
              className={selected.status === 'active' ? 'btn-danger flex-1' : 'btn-success flex-1'}
            >
              {selected.status === 'active' ? 'Deactivate' : 'Activate'}
            </button>
            <button onClick={() => setSelected(null)} className="btn-secondary flex-1">Close</button>
          </div>
        </div>
      )}
    </div>
  );
};

export default VolunteersPage;
