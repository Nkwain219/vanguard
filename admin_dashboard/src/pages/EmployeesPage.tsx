import React, { useEffect, useState } from 'react';
import {
  collection,
  getDocs,
  doc,
  updateDoc,
  orderBy,
  query,
} from 'firebase/firestore';
import { httpsCallable } from 'firebase/functions';
import { UserPlus, Mail, Phone, Briefcase, Building2, Calendar, X } from 'lucide-react';
import { db, functions } from '../firebase';
import { COLLECTIONS } from '../lib/collections';
import { Employee } from '../types';
import PageHeader from '../components/PageHeader';
import DataTable from '../components/DataTable';
import StatusBadge from '../components/StatusBadge';
import Modal from '../components/Modal';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorState from '../components/ErrorState';
import { format } from 'date-fns';

const DEPARTMENTS = ['Engineering', 'Operations', 'Finance', 'HR', 'Marketing', 'Sales', 'Support', 'Management'];
const ROLES = ['Manager', 'Senior Staff', 'Staff', 'Supervisor', 'Coordinator', 'Director', 'Analyst', 'Specialist'];

const EmployeesPage: React.FC = () => {
  const [employees, setEmployees] = useState<Employee[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showAdd, setShowAdd] = useState(false);
  const [selected, setSelected] = useState<Employee | null>(null);
  const [saving, setSaving] = useState(false);

  const [form, setForm] = useState({
    name: '',
    email: '',
    phone: '',
    role: '',
    department: '',
    joinDate: new Date().toISOString().split('T')[0],
    status: 'active' as 'active' | 'inactive',
  });

  const fetchEmployees = async () => {
    setLoading(true);
    setError('');
    try {
      const snap = await getDocs(
        query(collection(db, COLLECTIONS.USERS), orderBy('firstName', 'asc'))
      );
      const list: Employee[] = snap.docs
        .map((d) => {
          const data = d.data();
          const status = data.isActive ? 'active' : 'inactive';
          return {
            id: d.id,
            name: `${data.firstName || ''} ${data.lastName || ''}`.trim(),
            email: data.email || '',
            phone: data.phone || '',
            role: data.position || data.role || '',
            department: data.department || '',
            joinDate: data.joinDate?.toDate?.()?.toISOString() || data.createdAt?.toDate?.()?.toISOString() || new Date().toISOString(),
            status: status as 'active' | 'inactive',
          };
        })
        .filter((emp) => emp.email); // Only include users with email
      setEmployees(list);
    } catch (err) {
      console.error(err);
      setError('Failed to load employees.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchEmployees(); }, []);

  const handleAdd = async () => {
    if (!form.name || !form.email) return;
    setSaving(true);
    setError('');
    
    try {
      // Split name into firstName and lastName
      const nameParts = form.name.trim().split(' ');
      const firstName = nameParts[0];
      const lastName = nameParts.slice(1).join(' ') || firstName;
      
      // Call Cloud Function to create user with Firebase Auth + send email
      const createUserFn = httpsCallable(functions, 'createUser');
      const result = await createUserFn({
        email: form.email,
        firstName: firstName,
        lastName: lastName,
        phone: form.phone || '',
        role: 'employee',
        department: form.department || 'General',
        position: form.role || 'Staff',
      });
      
      const data = result.data as { success: boolean; userId: string; message: string };
      
      if (data.success) {
        // Refresh the employee list
        await fetchEmployees();
        setShowAdd(false);
        setForm({ 
          name: '', 
          email: '', 
          phone: '', 
          role: '', 
          department: '', 
          joinDate: new Date().toISOString().split('T')[0], 
          status: 'active' 
        });
        alert(data.message);
      }
    } catch (err: any) {
      console.error('Error creating employee:', err);
      setError(err.message || 'Failed to create employee. Please try again.');
    } finally {
      setSaving(false);
    }
  };

  const handleStatusToggle = async (emp: Employee) => {
    const newStatus = emp.status === 'active' ? 'inactive' : 'active';
    const newIsActive = newStatus === 'active';
    try {
      await updateDoc(doc(db, COLLECTIONS.USERS, emp.id), { isActive: newIsActive });
      setEmployees((prev) =>
        prev.map((e) => (e.id === emp.id ? { ...e, status: newStatus } : e))
      );
      if (selected?.id === emp.id) {
        setSelected((s) => s ? { ...s, status: newStatus } : null);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const columns = [
    {
      key: 'name',
      title: 'Name',
      sortable: true,
      render: (_: unknown, row: Employee) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center flex-shrink-0">
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
    { key: 'department', title: 'Department', sortable: true },
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

  if (loading) return <LoadingSpinner message="Loading employees..." />;
  if (error) return <ErrorState message={error} onRetry={fetchEmployees} />;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Employees"
        subtitle={`${employees.length} total employees`}
        breadcrumb={[{ label: 'Home' }, { label: 'Employees' }]}
        action={
          <button onClick={() => setShowAdd(true)} className="btn-primary">
            <UserPlus className="w-4 h-4" />
            Add Employee
          </button>
        }
      />

      <DataTable
        columns={columns as Parameters<typeof DataTable>[0]['columns']}
        data={employees as unknown as Record<string, unknown>[]}
        searchPlaceholder="Search employees..."
        onRowClick={(row) => setSelected(row as unknown as Employee)}
        keyExtractor={(row) => row.id as string}
        emptyTitle="No employees yet"
        emptyMessage="Add your first employee to get started."
      />

      {/* Add Employee Modal */}
      <Modal
        isOpen={showAdd}
        onClose={() => setShowAdd(false)}
        title="Add Employee"
        subtitle="Create a new employee record"
        footer={
          <>
            <button onClick={() => setShowAdd(false)} className="btn-secondary">Cancel</button>
            <button
              onClick={handleAdd}
              disabled={saving || !form.name || !form.email}
              className="btn-primary"
            >
              {saving ? 'Saving...' : 'Add Employee'}
            </button>
          </>
        }
      >
        <div className="space-y-4">
          {error && (
            <div className="p-3 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm">
              {error}
            </div>
          )}
          <div className="grid grid-cols-2 gap-4">
            <div className="col-span-2">
              <label className="form-label">Full Name *</label>
              <input
                className="form-input"
                value={form.name}
                onChange={(e) => setForm((f) => ({ ...f, name: e.target.value }))}
                placeholder="John Doe"
              />
            </div>
            <div className="col-span-2">
              <label className="form-label">Email *</label>
              <input
                type="email"
                className="form-input"
                value={form.email}
                onChange={(e) => setForm((f) => ({ ...f, email: e.target.value }))}
                placeholder="john@company.com"
              />
            </div>
            <div>
              <label className="form-label">Phone</label>
              <input
                className="form-input"
                value={form.phone}
                onChange={(e) => setForm((f) => ({ ...f, phone: e.target.value }))}
                placeholder="+237 6XX XXX XXX"
              />
            </div>
            <div>
              <label className="form-label">Join Date</label>
              <input
                type="date"
                className="form-input"
                value={form.joinDate}
                onChange={(e) => setForm((f) => ({ ...f, joinDate: e.target.value }))}
              />
            </div>
            <div>
              <label className="form-label">Role</label>
              <select
                className="form-input"
                value={form.role}
                onChange={(e) => setForm((f) => ({ ...f, role: e.target.value }))}
              >
                <option value="">Select role</option>
                {ROLES.map((r) => <option key={r} value={r}>{r}</option>)}
              </select>
            </div>
            <div>
              <label className="form-label">Department</label>
              <select
                className="form-input"
                value={form.department}
                onChange={(e) => setForm((f) => ({ ...f, department: e.target.value }))}
              >
                <option value="">Select department</option>
                {DEPARTMENTS.map((d) => <option key={d} value={d}>{d}</option>)}
              </select>
            </div>
            <div>
              <label className="form-label">Status</label>
              <select
                className="form-input"
                value={form.status}
                onChange={(e) => setForm((f) => ({ ...f, status: e.target.value as 'active' | 'inactive' }))}
              >
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
              </select>
            </div>
          </div>
        </div>
      </Modal>

      {/* Employee Detail Panel */}
      {selected && (
        <div className="fixed inset-y-0 right-0 w-full sm:w-96 bg-white border-l border-[#E8EAFF] shadow-modal z-40 flex flex-col">
          {/* Header */}
          <div className="flex items-center justify-between p-6 border-b border-[#E8EAFF]">
            <h3 className="font-semibold text-gray-900">Employee Details</h3>
            <button
              onClick={() => setSelected(null)}
              className="p-1.5 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100 transition-colors"
            >
              <X className="w-5 h-5" />
            </button>
          </div>

          {/* Content */}
          <div className="flex-1 overflow-y-auto scrollbar-thin p-6 space-y-6">
            {/* Avatar */}
            <div className="flex flex-col items-center text-center">
              <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-primary-400 to-primary-700 flex items-center justify-center shadow-lg mb-4">
                <span className="text-white text-3xl font-bold">
                  {selected.name.charAt(0).toUpperCase()}
                </span>
              </div>
              <h4 className="font-bold text-gray-900 text-lg">{selected.name}</h4>
              <p className="text-sm text-gray-500">{selected.role} • {selected.department}</p>
              <div className="mt-3">
                <StatusBadge status={selected.status} />
              </div>
            </div>

            {/* Info */}
            <div className="space-y-3">
              {[
                { icon: <Mail className="w-4 h-4" />, label: 'Email', value: selected.email },
                { icon: <Phone className="w-4 h-4" />, label: 'Phone', value: selected.phone ?? '—' },
                { icon: <Briefcase className="w-4 h-4" />, label: 'Role', value: selected.role || '—' },
                { icon: <Building2 className="w-4 h-4" />, label: 'Department', value: selected.department || '—' },
                {
                  icon: <Calendar className="w-4 h-4" />,
                  label: 'Join Date',
                  value: selected.joinDate
                    ? (() => { try { return format(new Date(selected.joinDate), 'MMMM d, yyyy'); } catch { return selected.joinDate; } })()
                    : '—',
                },
              ].map((item) => (
                <div key={item.label} className="flex items-center gap-3 p-3 bg-surface rounded-xl">
                  <div className="p-2 bg-primary-50 rounded-lg text-primary-500">{item.icon}</div>
                  <div>
                    <p className="text-xs text-gray-500">{item.label}</p>
                    <p className="text-sm font-medium text-gray-800">{item.value}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Footer */}
          <div className="p-6 border-t border-[#E8EAFF] flex gap-3">
            <button
              onClick={() => handleStatusToggle(selected)}
              className={selected.status === 'active' ? 'btn-danger flex-1' : 'btn-success flex-1'}
            >
              {selected.status === 'active' ? 'Deactivate' : 'Activate'}
            </button>
            <button onClick={() => setSelected(null)} className="btn-secondary flex-1">
              Close
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default EmployeesPage;
