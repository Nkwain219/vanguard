import React, { useEffect, useState } from 'react';
import {
  collection,
  getDocs,
  addDoc,
  query,
  orderBy,
  limit,
} from 'firebase/firestore';
import { Bell, Send, Users, Heart, Shield, Globe, Clock } from 'lucide-react';
import { db, auth } from '../firebase';
import { COLLECTIONS } from '../lib/collections';
import { Notification } from '../types';
import PageHeader from '../components/PageHeader';
import StatusBadge from '../components/StatusBadge';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorState from '../components/ErrorState';
import EmptyState from '../components/EmptyState';
import { format } from 'date-fns';

const TARGET_OPTIONS = [
  { value: 'all', label: 'All Users', icon: <Globe className="w-4 h-4" />, desc: 'Send to everyone' },
  { value: 'employees', label: 'Employees', icon: <Users className="w-4 h-4" />, desc: 'Send to employees only' },
  { value: 'volunteers', label: 'Volunteers', icon: <Heart className="w-4 h-4" />, desc: 'Send to volunteers only' },
  { value: 'admins', label: 'Admins', icon: <Shield className="w-4 h-4" />, desc: 'Send to admins only' },
];

const TYPE_OPTIONS = [
  { value: 'info', label: 'Info', color: 'text-blue-600 bg-blue-50 border-blue-200' },
  { value: 'success', label: 'Success', color: 'text-emerald-600 bg-emerald-50 border-emerald-200' },
  { value: 'warning', label: 'Warning', color: 'text-amber-600 bg-amber-50 border-amber-200' },
  { value: 'alert', label: 'Alert', color: 'text-red-600 bg-red-50 border-red-200' },
];

const NotificationsPage: React.FC = () => {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [sending, setSending] = useState(false);
  const [sendSuccess, setSendSuccess] = useState(false);

  const [form, setForm] = useState({
    title: '',
    message: '',
    target: 'all' as Notification['target'],
    type: 'info' as Notification['type'],
  });

  const fetchNotifications = async () => {
    setLoading(true);
    setError('');
    try {
      const snap = await getDocs(
        query(collection(db, COLLECTIONS.NOTIFICATIONS), orderBy('sentAt', 'desc'), limit(50))
      );
      const list: Notification[] = snap.docs.map((d) => ({
        id: d.id,
        ...(d.data() as Omit<Notification, 'id'>),
      }));
      setNotifications(list);
    } catch (err) {
      console.error(err);
      setError('Failed to load notifications.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchNotifications(); }, []);

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.title || !form.message) return;
    setSending(true);
    setSendSuccess(false);
    try {
      const newNotif: Omit<Notification, 'id'> = {
        title: form.title,
        message: form.message,
        target: form.target,
        type: form.type,
        sentBy: auth.currentUser?.uid ?? 'admin',
        sentAt: new Date().toISOString(),
        readBy: [],
      };
      const newDoc = await addDoc(collection(db, COLLECTIONS.NOTIFICATIONS), newNotif);
      setNotifications((prev) => [{ id: newDoc.id, ...newNotif }, ...prev]);
      setForm({ title: '', message: '', target: 'all', type: 'info' });
      setSendSuccess(true);
      setTimeout(() => setSendSuccess(false), 3000);
    } catch (err) {
      console.error(err);
    } finally {
      setSending(false);
    }
  };

  const typeIcon = (type: string) => {
    const colors: Record<string, string> = {
      info: 'bg-blue-100 text-blue-600',
      success: 'bg-emerald-100 text-emerald-600',
      warning: 'bg-amber-100 text-amber-600',
      alert: 'bg-red-100 text-red-600',
    };
    return colors[type] ?? colors.info;
  };

  if (loading) return <LoadingSpinner message="Loading notifications..." />;
  if (error) return <ErrorState message={error} onRetry={fetchNotifications} />;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Notifications"
        subtitle="Compose and send notifications to your team"
        breadcrumb={[{ label: 'Home' }, { label: 'Notifications' }]}
      />

      <div className="grid grid-cols-1 xl:grid-cols-3 gap-6">
        {/* Compose */}
        <div className="xl:col-span-1">
          <div className="card">
            <div className="flex items-center gap-2 mb-6">
              <Bell className="w-4 h-4 text-primary-500" />
              <h3 className="font-semibold text-gray-900 text-sm">Compose Notification</h3>
            </div>

            {sendSuccess && (
              <div className="mb-4 p-3 bg-emerald-50 border border-emerald-200 rounded-xl text-sm text-emerald-700">
                Notification sent successfully!
              </div>
            )}

            <form onSubmit={handleSend} className="space-y-4">
              <div>
                <label className="form-label">Title *</label>
                <input
                  className="form-input"
                  value={form.title}
                  onChange={(e) => setForm((f) => ({ ...f, title: e.target.value }))}
                  placeholder="Notification title"
                  maxLength={100}
                />
              </div>

              <div>
                <label className="form-label">Message *</label>
                <textarea
                  className="form-input"
                  rows={4}
                  value={form.message}
                  onChange={(e) => setForm((f) => ({ ...f, message: e.target.value }))}
                  placeholder="Write your message here..."
                  maxLength={500}
                />
                <p className="text-xs text-gray-400 mt-1 text-right">{form.message.length}/500</p>
              </div>

              <div>
                <label className="form-label">Target Audience</label>
                <div className="space-y-2">
                  {TARGET_OPTIONS.map((opt) => (
                    <label
                      key={opt.value}
                      className={`flex items-center gap-3 p-3 rounded-xl border cursor-pointer transition-colors ${
                        form.target === opt.value
                          ? 'border-primary-500 bg-primary-50'
                          : 'border-[#E8EAFF] hover:bg-gray-50'
                      }`}
                    >
                      <input
                        type="radio"
                        name="target"
                        value={opt.value}
                        checked={form.target === opt.value}
                        onChange={(e) => setForm((f) => ({ ...f, target: e.target.value as Notification['target'] }))}
                        className="sr-only"
                      />
                      <span className={`p-1.5 rounded-lg ${form.target === opt.value ? 'bg-primary-500 text-white' : 'bg-gray-100 text-gray-500'}`}>
                        {opt.icon}
                      </span>
                      <div>
                        <p className="text-sm font-medium text-gray-900">{opt.label}</p>
                        <p className="text-xs text-gray-500">{opt.desc}</p>
                      </div>
                    </label>
                  ))}
                </div>
              </div>

              <div>
                <label className="form-label">Notification Type</label>
                <div className="grid grid-cols-2 gap-2">
                  {TYPE_OPTIONS.map((opt) => (
                    <label
                      key={opt.value}
                      className={`flex items-center justify-center gap-2 p-2 rounded-lg border cursor-pointer transition-all ${
                        form.type === opt.value
                          ? opt.color + ' border-current'
                          : 'border-[#E8EAFF] text-gray-500 hover:bg-gray-50'
                      }`}
                    >
                      <input
                        type="radio"
                        name="type"
                        value={opt.value}
                        checked={form.type === opt.value}
                        onChange={(e) => setForm((f) => ({ ...f, type: e.target.value as Notification['type'] }))}
                        className="sr-only"
                      />
                      <span className="text-sm font-medium">{opt.label}</span>
                    </label>
                  ))}
                </div>
              </div>

              <button
                type="submit"
                disabled={sending || !form.title || !form.message}
                className="btn-primary w-full justify-center py-3"
              >
                <Send className="w-4 h-4" />
                {sending ? 'Sending...' : 'Send Notification'}
              </button>
            </form>
          </div>
        </div>

        {/* History */}
        <div className="xl:col-span-2">
          <div className="card p-0 overflow-hidden">
            <div className="flex items-center justify-between px-6 py-4 border-b border-[#E8EAFF]">
              <h3 className="font-semibold text-gray-900 text-sm">Notification History</h3>
              <span className="text-xs text-gray-500">{notifications.length} sent</span>
            </div>

            {notifications.length === 0 ? (
              <EmptyState
                title="No notifications sent"
                message="Compose your first notification to get started."
                icon={<Bell className="w-8 h-8 text-primary-400" />}
              />
            ) : (
              <div className="divide-y divide-[#E8EAFF]">
                {notifications.map((notif) => (
                  <div key={notif.id} className="flex items-start gap-4 px-6 py-4 hover:bg-surface transition-colors">
                    <div className={`p-2.5 rounded-xl flex-shrink-0 ${typeIcon(notif.type)}`}>
                      <Bell className="w-4 h-4" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-2">
                        <p className="font-medium text-gray-900 text-sm">{notif.title}</p>
                        <div className="flex items-center gap-1.5 flex-shrink-0">
                          <StatusBadge status={notif.type} size="sm" />
                        </div>
                      </div>
                      <p className="text-sm text-gray-600 mt-0.5 leading-relaxed">{notif.message}</p>
                      <div className="flex items-center gap-3 mt-2">
                        <span className="inline-flex items-center gap-1 text-xs text-gray-500">
                          <Globe className="w-3 h-3" />
                          {TARGET_OPTIONS.find((t) => t.value === notif.target)?.label ?? notif.target}
                        </span>
                        {notif.sentAt && (
                          <span className="inline-flex items-center gap-1 text-xs text-gray-400">
                            <Clock className="w-3 h-3" />
                            {(() => { try { return format(new Date(notif.sentAt), 'MMM d, yyyy h:mm a'); } catch { return notif.sentAt; } })()}
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default NotificationsPage;
