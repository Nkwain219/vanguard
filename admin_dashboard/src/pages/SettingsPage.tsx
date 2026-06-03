import React, { useState } from 'react';
import { updateProfile, signOut, updatePassword } from 'firebase/auth';
import { doc, setDoc } from 'firebase/firestore';
import { User, Mail, LogOut, Save, Key, Shield, Info } from 'lucide-react';
import { auth, db } from '../firebase';
import { COLLECTIONS } from '../lib/collections';
import PageHeader from '../components/PageHeader';
import { useNavigate } from 'react-router-dom';

const SettingsPage: React.FC = () => {
  const navigate = useNavigate();
  const user = auth.currentUser;
  const [displayName, setDisplayName] = useState(user?.displayName ?? '');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [savingProfile, setSavingProfile] = useState(false);
  const [savingPassword, setSavingPassword] = useState(false);
  const [profileSuccess, setProfileSuccess] = useState('');
  const [profileError, setProfileError] = useState('');
  const [passwordSuccess, setPasswordSuccess] = useState('');
  const [passwordError, setPasswordError] = useState('');

  const handleSaveProfile = async (e: React.FormEvent) => {
    e.preventDefault();
    setProfileSuccess('');
    setProfileError('');
    setSavingProfile(true);
    try {
      if (user) {
        await updateProfile(user, { displayName: displayName.trim() || null });
        // Also update in Firestore
        try {
          await setDoc(
            doc(db, COLLECTIONS.USERS, user.uid),
            { name: displayName.trim(), updatedAt: new Date().toISOString() },
            { merge: true }
          );
        } catch { /* ignore Firestore errors */ }
        setProfileSuccess('Profile updated successfully.');
        setTimeout(() => setProfileSuccess(''), 3000);
      }
    } catch (err) {
      setProfileError('Failed to update profile. Please try again.');
    } finally {
      setSavingProfile(false);
    }
  };

  const handleChangePassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setPasswordSuccess('');
    setPasswordError('');
    if (newPassword !== confirmPassword) {
      setPasswordError('Passwords do not match.');
      return;
    }
    if (newPassword.length < 6) {
      setPasswordError('Password must be at least 6 characters.');
      return;
    }
    setSavingPassword(true);
    try {
      if (user) {
        await updatePassword(user, newPassword);
        setPasswordSuccess('Password updated successfully.');
        setNewPassword('');
        setConfirmPassword('');
        setTimeout(() => setPasswordSuccess(''), 3000);
      }
    } catch (err: unknown) {
      const code = (err as { code?: string })?.code;
      if (code === 'auth/requires-recent-login') {
        setPasswordError('Please sign out and sign in again before changing your password.');
      } else {
        setPasswordError('Failed to update password. Please try again.');
      }
    } finally {
      setSavingPassword(false);
    }
  };

  const handleSignOut = async () => {
    await signOut(auth);
    navigate('/login');
  };

  return (
    <div className="space-y-6 max-w-2xl">
      <PageHeader
        title="Settings"
        subtitle="Manage your account and preferences"
        breadcrumb={[{ label: 'Home' }, { label: 'Settings' }]}
      />

      {/* Profile Card */}
      <div className="card">
        <div className="flex items-center gap-3 mb-6">
          <div className="p-2 bg-primary-100 rounded-xl">
            <User className="w-4 h-4 text-primary-600" />
          </div>
          <div>
            <h3 className="font-semibold text-gray-900 text-sm">Profile Information</h3>
            <p className="text-xs text-gray-500">Update your display name</p>
          </div>
        </div>

        {/* User Card */}
        <div className="flex items-center gap-4 p-4 bg-surface rounded-xl mb-6">
          <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-primary-500 to-primary-700 flex items-center justify-center shadow-md">
            <span className="text-white text-xl font-bold">
              {(user?.displayName ?? user?.email ?? 'A').charAt(0).toUpperCase()}
            </span>
          </div>
          <div>
            <p className="font-semibold text-gray-900">{user?.displayName ?? 'Admin User'}</p>
            <p className="text-sm text-gray-500">{user?.email}</p>
            <div className="flex items-center gap-1.5 mt-1.5">
              <Shield className="w-3 h-3 text-primary-500" />
              <span className="text-xs text-primary-600 font-medium">Administrator</span>
            </div>
          </div>
        </div>

        {profileSuccess && (
          <div className="mb-4 p-3 bg-emerald-50 border border-emerald-200 rounded-xl text-sm text-emerald-700">
            {profileSuccess}
          </div>
        )}
        {profileError && (
          <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-xl text-sm text-red-700">
            {profileError}
          </div>
        )}

        <form onSubmit={handleSaveProfile} className="space-y-4">
          <div>
            <label className="form-label">Display Name</label>
            <input
              className="form-input"
              value={displayName}
              onChange={(e) => setDisplayName(e.target.value)}
              placeholder="Your display name"
            />
          </div>
          <div>
            <label className="form-label">Email Address</label>
            <div className="relative">
              <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
              <input
                className="form-input pl-9 bg-gray-50 cursor-not-allowed"
                value={user?.email ?? ''}
                disabled
                readOnly
              />
            </div>
            <p className="text-xs text-gray-400 mt-1 flex items-center gap-1">
              <Info className="w-3 h-3" />
              Email cannot be changed from this panel.
            </p>
          </div>
          <div className="flex justify-end">
            <button type="submit" disabled={savingProfile} className="btn-primary">
              <Save className="w-4 h-4" />
              {savingProfile ? 'Saving...' : 'Save Profile'}
            </button>
          </div>
        </form>
      </div>

      {/* Password Card */}
      <div className="card">
        <div className="flex items-center gap-3 mb-6">
          <div className="p-2 bg-amber-100 rounded-xl">
            <Key className="w-4 h-4 text-amber-600" />
          </div>
          <div>
            <h3 className="font-semibold text-gray-900 text-sm">Change Password</h3>
            <p className="text-xs text-gray-500">Update your account password</p>
          </div>
        </div>

        {passwordSuccess && (
          <div className="mb-4 p-3 bg-emerald-50 border border-emerald-200 rounded-xl text-sm text-emerald-700">
            {passwordSuccess}
          </div>
        )}
        {passwordError && (
          <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-xl text-sm text-red-700">
            {passwordError}
          </div>
        )}

        <form onSubmit={handleChangePassword} className="space-y-4">
          <div>
            <label className="form-label">New Password</label>
            <input
              type="password"
              className="form-input"
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              placeholder="Min. 6 characters"
              minLength={6}
            />
          </div>
          <div>
            <label className="form-label">Confirm New Password</label>
            <input
              type="password"
              className="form-input"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              placeholder="Repeat new password"
            />
          </div>
          <div className="flex justify-end">
            <button
              type="submit"
              disabled={savingPassword || !newPassword || !confirmPassword}
              className="btn-primary"
            >
              <Key className="w-4 h-4" />
              {savingPassword ? 'Updating...' : 'Update Password'}
            </button>
          </div>
        </form>
      </div>

      {/* Account Info */}
      <div className="card">
        <div className="flex items-center gap-3 mb-6">
          <div className="p-2 bg-gray-100 rounded-xl">
            <Info className="w-4 h-4 text-gray-600" />
          </div>
          <div>
            <h3 className="font-semibold text-gray-900 text-sm">Account Details</h3>
            <p className="text-xs text-gray-500">System information</p>
          </div>
        </div>
        <div className="space-y-3">
          {[
            { label: 'User ID', value: user?.uid ?? '—' },
            { label: 'Role', value: 'Administrator' },
            { label: 'Account Created', value: user?.metadata?.creationTime ? new Date(user.metadata.creationTime).toLocaleDateString() : '—' },
            { label: 'Last Sign In', value: user?.metadata?.lastSignInTime ? new Date(user.metadata.lastSignInTime).toLocaleDateString() : '—' },
            { label: 'Email Verified', value: user?.emailVerified ? 'Yes' : 'No' },
            { label: 'Platform', value: 'Vanguard Admin Dashboard v1.0' },
          ].map((item) => (
            <div key={item.label} className="flex items-center justify-between py-2 border-b border-[#E8EAFF] last:border-0">
              <span className="text-sm text-gray-500">{item.label}</span>
              <span className="text-sm font-medium text-gray-900 text-right max-w-xs truncate">{item.value}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Sign Out */}
      <div className="card border-red-100">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="font-semibold text-gray-900 text-sm">Sign Out</h3>
            <p className="text-xs text-gray-500 mt-0.5">Sign out of the admin dashboard</p>
          </div>
          <button onClick={handleSignOut} className="btn-danger">
            <LogOut className="w-4 h-4" />
            Sign Out
          </button>
        </div>
      </div>
    </div>
  );
};

export default SettingsPage;
