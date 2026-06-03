import React, { useEffect, useState } from 'react';
import {
  collection,
  getDocs,
  addDoc,
  deleteDoc,
  doc,
  query,
  orderBy,
} from 'firebase/firestore';
import { MapPin, Plus, Trash2, Navigation, Building } from 'lucide-react';
import { db } from '../firebase';
import { COLLECTIONS } from '../lib/collections';
import { WorkLocation } from '../types';
import PageHeader from '../components/PageHeader';
import Modal from '../components/Modal';
import StatusBadge from '../components/StatusBadge';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorState from '../components/ErrorState';
import EmptyState from '../components/EmptyState';
import { format } from 'date-fns';

const WorkLocationsPage: React.FC = () => {
  const [locations, setLocations] = useState<WorkLocation[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showAdd, setShowAdd] = useState(false);
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState<string | null>(null);
  const [confirmDelete, setConfirmDelete] = useState<WorkLocation | null>(null);

  const [form, setForm] = useState({
    name: '',
    address: '',
    city: '',
    country: 'Cameroon',
    radius: 100,
    status: 'active' as 'active' | 'inactive',
    latitude: '',
    longitude: '',
  });

  const fetchLocations = async () => {
    setLoading(true);
    setError('');
    try {
      const snap = await getDocs(
        query(collection(db, COLLECTIONS.WORK_LOCATIONS), orderBy('name', 'asc'))
      );
      const list: WorkLocation[] = snap.docs.map((d) => ({
        id: d.id,
        ...(d.data() as Omit<WorkLocation, 'id'>),
      }));
      setLocations(list);
    } catch (err) {
      console.error(err);
      setError('Failed to load work locations.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchLocations(); }, []);

  const handleAdd = async () => {
    if (!form.name || !form.address) return;
    setSaving(true);
    try {
      const newDoc = await addDoc(collection(db, COLLECTIONS.WORK_LOCATIONS), {
        ...form,
        latitude: form.latitude ? parseFloat(form.latitude) : null,
        longitude: form.longitude ? parseFloat(form.longitude) : null,
        radius: Number(form.radius),
        createdAt: new Date().toISOString(),
      });
      setLocations((prev) => [
        ...prev,
        {
          id: newDoc.id,
          name: form.name,
          address: form.address,
          city: form.city,
          country: form.country,
          radius: Number(form.radius),
          status: form.status,
          createdAt: new Date().toISOString(),
        },
      ]);
      setShowAdd(false);
      setForm({ name: '', address: '', city: '', country: 'Cameroon', radius: 100, status: 'active', latitude: '', longitude: '' });
    } catch (err) {
      console.error(err);
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (location: WorkLocation) => {
    setDeleting(location.id);
    try {
      await deleteDoc(doc(db, COLLECTIONS.WORK_LOCATIONS, location.id));
      setLocations((prev) => prev.filter((l) => l.id !== location.id));
      setConfirmDelete(null);
    } catch (err) {
      console.error(err);
    } finally {
      setDeleting(null);
    }
  };

  if (loading) return <LoadingSpinner message="Loading work locations..." />;
  if (error) return <ErrorState message={error} onRetry={fetchLocations} />;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Work Locations"
        subtitle={`${locations.length} registered location${locations.length !== 1 ? 's' : ''}`}
        breadcrumb={[{ label: 'Home' }, { label: 'Work Locations' }]}
        action={
          <button onClick={() => setShowAdd(true)} className="btn-primary">
            <Plus className="w-4 h-4" />
            Add Location
          </button>
        }
      />

      {locations.length === 0 ? (
        <EmptyState
          title="No work locations"
          message="Add your first work location to enable attendance tracking."
          icon={<MapPin className="w-8 h-8 text-primary-400" />}
          action={
            <button onClick={() => setShowAdd(true)} className="btn-primary">
              <Plus className="w-4 h-4" />
              Add Location
            </button>
          }
        />
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {locations.map((loc) => (
            <div key={loc.id} className="card hover:shadow-card transition-shadow">
              <div className="flex items-start justify-between mb-4">
                <div className="p-3 bg-primary-100 rounded-xl">
                  <MapPin className="w-5 h-5 text-primary-600" />
                </div>
                <div className="flex items-center gap-2">
                  <StatusBadge status={loc.status} size="sm" />
                  <button
                    onClick={() => setConfirmDelete(loc)}
                    className="p-1.5 rounded-lg text-gray-400 hover:text-red-500 hover:bg-red-50 transition-colors"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>

              <h3 className="font-semibold text-gray-900 mb-1">{loc.name}</h3>
              <p className="text-sm text-gray-500 mb-3 leading-relaxed">{loc.address}</p>

              <div className="space-y-2 pt-3 border-t border-[#E8EAFF]">
                {(loc.city || loc.country) && (
                  <div className="flex items-center gap-2 text-xs text-gray-500">
                    <Building className="w-3.5 h-3.5" />
                    <span>{[loc.city, loc.country].filter(Boolean).join(', ')}</span>
                  </div>
                )}
                <div className="flex items-center gap-2 text-xs text-gray-500">
                  <Navigation className="w-3.5 h-3.5" />
                  <span>Radius: {loc.radius}m</span>
                </div>
                {loc.createdAt && (
                  <div className="flex items-center gap-2 text-xs text-gray-400">
                    <span>Added {(() => { try { return format(new Date(loc.createdAt), 'MMM d, yyyy'); } catch { return loc.createdAt; } })()}</span>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Add Modal */}
      <Modal
        isOpen={showAdd}
        onClose={() => setShowAdd(false)}
        title="Add Work Location"
        subtitle="Register a new attendance location"
        footer={
          <>
            <button onClick={() => setShowAdd(false)} className="btn-secondary">Cancel</button>
            <button onClick={handleAdd} disabled={saving || !form.name || !form.address} className="btn-primary">
              {saving ? 'Saving...' : 'Add Location'}
            </button>
          </>
        }
      >
        <div className="space-y-4">
          <div>
            <label className="form-label">Location Name *</label>
            <input className="form-input" value={form.name} onChange={(e) => setForm((f) => ({ ...f, name: e.target.value }))} placeholder="Headquarters" />
          </div>
          <div>
            <label className="form-label">Address *</label>
            <input className="form-input" value={form.address} onChange={(e) => setForm((f) => ({ ...f, address: e.target.value }))} placeholder="123 Main Street" />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="form-label">City</label>
              <input className="form-input" value={form.city} onChange={(e) => setForm((f) => ({ ...f, city: e.target.value }))} placeholder="Yaoundé" />
            </div>
            <div>
              <label className="form-label">Country</label>
              <input className="form-input" value={form.country} onChange={(e) => setForm((f) => ({ ...f, country: e.target.value }))} placeholder="Cameroon" />
            </div>
          </div>
          <div>
            <label className="form-label">Check-in Radius (meters)</label>
            <input type="number" className="form-input" value={form.radius} onChange={(e) => setForm((f) => ({ ...f, radius: Number(e.target.value) }))} min={50} max={5000} />
            <p className="text-xs text-gray-500 mt-1">Employees must be within this radius to check in</p>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="form-label">Latitude</label>
              <input className="form-input" value={form.latitude} onChange={(e) => setForm((f) => ({ ...f, latitude: e.target.value }))} placeholder="3.8480" />
            </div>
            <div>
              <label className="form-label">Longitude</label>
              <input className="form-input" value={form.longitude} onChange={(e) => setForm((f) => ({ ...f, longitude: e.target.value }))} placeholder="11.5021" />
            </div>
          </div>
          <div>
            <label className="form-label">Status</label>
            <select className="form-input" value={form.status} onChange={(e) => setForm((f) => ({ ...f, status: e.target.value as 'active' | 'inactive' }))}>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>
        </div>
      </Modal>

      {/* Delete Confirmation */}
      {confirmDelete && (
        <Modal
          isOpen={!!confirmDelete}
          onClose={() => setConfirmDelete(null)}
          title="Delete Location"
          size="sm"
          footer={
            <>
              <button onClick={() => setConfirmDelete(null)} className="btn-secondary">Cancel</button>
              <button
                onClick={() => handleDelete(confirmDelete)}
                disabled={deleting === confirmDelete.id}
                className="btn-danger"
              >
                <Trash2 className="w-4 h-4" />
                {deleting === confirmDelete.id ? 'Deleting...' : 'Delete'}
              </button>
            </>
          }
        >
          <p className="text-sm text-gray-600">
            Are you sure you want to delete <strong>{confirmDelete.name}</strong>? This action cannot be undone.
          </p>
        </Modal>
      )}
    </div>
  );
};

export default WorkLocationsPage;
