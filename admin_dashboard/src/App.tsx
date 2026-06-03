import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import AuthGuard from './components/AuthGuard';
import AppShell from './components/AppShell';

// Pages
import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';
import EmployeesPage from './pages/EmployeesPage';
import VolunteersPage from './pages/VolunteersPage';
import LeaveApprovalsPage from './pages/LeaveApprovalsPage';
import SalaryRequestsPage from './pages/SalaryRequestsPage';
import WalletPage from './pages/WalletPage';
import WorkLocationsPage from './pages/WorkLocationsPage';
import NotificationsPage from './pages/NotificationsPage';
import ReportsPage from './pages/ReportsPage';
import SettingsPage from './pages/SettingsPage';

const ProtectedPage: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <AuthGuard>
    <AppShell>{children}</AppShell>
  </AuthGuard>
);

const App: React.FC = () => {
  return (
    <BrowserRouter>
      <Routes>
        {/* Public */}
        <Route path="/login" element={<LoginPage />} />

        {/* Root redirect */}
        <Route path="/" element={<Navigate to="/dashboard" replace />} />

        {/* Protected Routes */}
        <Route
          path="/dashboard"
          element={
            <ProtectedPage>
              <DashboardPage />
            </ProtectedPage>
          }
        />
        <Route
          path="/employees"
          element={
            <ProtectedPage>
              <EmployeesPage />
            </ProtectedPage>
          }
        />
        <Route
          path="/volunteers"
          element={
            <ProtectedPage>
              <VolunteersPage />
            </ProtectedPage>
          }
        />
        <Route
          path="/leave"
          element={
            <ProtectedPage>
              <LeaveApprovalsPage />
            </ProtectedPage>
          }
        />
        <Route
          path="/salary"
          element={
            <ProtectedPage>
              <SalaryRequestsPage />
            </ProtectedPage>
          }
        />
        <Route
          path="/wallet"
          element={
            <ProtectedPage>
              <WalletPage />
            </ProtectedPage>
          }
        />
        <Route
          path="/locations"
          element={
            <ProtectedPage>
              <WorkLocationsPage />
            </ProtectedPage>
          }
        />
        <Route
          path="/notifications"
          element={
            <ProtectedPage>
              <NotificationsPage />
            </ProtectedPage>
          }
        />
        <Route
          path="/reports"
          element={
            <ProtectedPage>
              <ReportsPage />
            </ProtectedPage>
          }
        />
        <Route
          path="/settings"
          element={
            <ProtectedPage>
              <SettingsPage />
            </ProtectedPage>
          }
        />

        {/* Catch-all */}
        <Route path="*" element={<Navigate to="/dashboard" replace />} />
      </Routes>
    </BrowserRouter>
  );
};

export default App;
