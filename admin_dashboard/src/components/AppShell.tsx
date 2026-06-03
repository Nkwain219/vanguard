import React, { useState } from 'react';
import { NavLink, useLocation, useNavigate } from 'react-router-dom';
import {
  Shield,
  LayoutDashboard,
  Users,
  Heart,
  CalendarCheck,
  DollarSign,
  Wallet,
  MapPin,
  Bell,
  BarChart3,
  Settings,
  LogOut,
  Menu,
  X,
  ChevronRight,
} from 'lucide-react';
import { auth } from '../firebase';
import { signOut } from 'firebase/auth';

interface NavItem {
  path: string;
  label: string;
  icon: React.ReactNode;
  badge?: number;
}

const navItems: NavItem[] = [
  { path: '/dashboard', label: 'Dashboard', icon: <LayoutDashboard className="w-4.5 h-4.5" /> },
  { path: '/employees', label: 'Employees', icon: <Users className="w-4.5 h-4.5" /> },
  { path: '/volunteers', label: 'Volunteers', icon: <Heart className="w-4.5 h-4.5" /> },
  { path: '/leave', label: 'Leave Approvals', icon: <CalendarCheck className="w-4.5 h-4.5" /> },
  { path: '/salary', label: 'Salary Requests', icon: <DollarSign className="w-4.5 h-4.5" /> },
  { path: '/wallet', label: 'Wallet', icon: <Wallet className="w-4.5 h-4.5" /> },
  { path: '/locations', label: 'Work Locations', icon: <MapPin className="w-4.5 h-4.5" /> },
  { path: '/notifications', label: 'Notifications', icon: <Bell className="w-4.5 h-4.5" /> },
  { path: '/reports', label: 'Reports', icon: <BarChart3 className="w-4.5 h-4.5" /> },
  { path: '/settings', label: 'Settings', icon: <Settings className="w-4.5 h-4.5" /> },
];

const pageTitles: Record<string, string> = {
  '/dashboard': 'Dashboard',
  '/employees': 'Employees',
  '/volunteers': 'Volunteers',
  '/leave': 'Leave Approvals',
  '/salary': 'Salary Requests',
  '/wallet': 'Wallet',
  '/locations': 'Work Locations',
  '/notifications': 'Notifications',
  '/reports': 'Reports',
  '/settings': 'Settings',
};

interface AppShellProps {
  children: React.ReactNode;
}

const AppShell: React.FC<AppShellProps> = ({ children }) => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [collapsed, setCollapsed] = useState(false);
  const location = useLocation();
  const navigate = useNavigate();
  const user = auth.currentUser;
  const pageTitle = pageTitles[location.pathname] ?? 'Vanguard';

  const handleSignOut = async () => {
    await signOut(auth);
    navigate('/login');
  };

  const SidebarContent = () => (
    <div className="flex flex-col h-full">
      {/* Logo */}
      <div className="flex items-center gap-3 px-5 py-5 border-b border-white/10">
        <div className="w-9 h-9 bg-gradient-to-br from-primary-500 to-primary-700 rounded-xl flex items-center justify-center flex-shrink-0 shadow-lg">
          <Shield className="w-5 h-5 text-white" />
        </div>
        {!collapsed && (
          <div className="min-w-0">
            <p className="text-white font-bold text-sm tracking-widest leading-none">VANGUARD</p>
            <p className="text-blue-300/60 text-xs mt-0.5 leading-none">Admin Console</p>
          </div>
        )}
      </div>

      {/* Nav */}
      <nav className="flex-1 px-3 py-4 space-y-0.5 overflow-y-auto scrollbar-thin">
        {navItems.map((item) => (
          <NavLink
            key={item.path}
            to={item.path}
            onClick={() => setSidebarOpen(false)}
            className={({ isActive }) =>
              `nav-item ${isActive ? 'active' : ''} ${collapsed ? 'justify-center px-2' : ''}`
            }
            title={collapsed ? item.label : undefined}
          >
            <span className="flex-shrink-0">{item.icon}</span>
            {!collapsed && <span className="truncate">{item.label}</span>}
            {!collapsed && item.badge !== undefined && item.badge > 0 && (
              <span className="ml-auto bg-amber-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center flex-shrink-0">
                {item.badge}
              </span>
            )}
          </NavLink>
        ))}
      </nav>

      {/* User */}
      <div className="px-3 py-4 border-t border-white/10">
        {!collapsed ? (
          <div className="flex items-center gap-3 px-3 py-3 rounded-xl bg-white/5">
            <div className="w-8 h-8 rounded-full bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center flex-shrink-0">
              <span className="text-white text-xs font-bold">
                {(user?.displayName ?? user?.email ?? 'A').charAt(0).toUpperCase()}
              </span>
            </div>
            <div className="min-w-0 flex-1">
              <p className="text-white text-xs font-semibold truncate">
                {user?.displayName ?? 'Admin'}
              </p>
              <p className="text-blue-300/60 text-xs truncate">{user?.email}</p>
            </div>
            <button
              onClick={handleSignOut}
              title="Sign out"
              className="p-1.5 rounded-lg text-blue-300/60 hover:text-white hover:bg-white/10 transition-colors flex-shrink-0"
            >
              <LogOut className="w-3.5 h-3.5" />
            </button>
          </div>
        ) : (
          <button
            onClick={handleSignOut}
            title="Sign out"
            className="nav-item justify-center px-2 w-full"
          >
            <LogOut className="w-4.5 h-4.5" />
          </button>
        )}
      </div>
    </div>
  );

  return (
    <div className="flex h-screen bg-surface overflow-hidden">
      {/* Desktop Sidebar */}
      <aside
        className={`hidden lg:flex flex-col flex-shrink-0 transition-all duration-300
                    bg-gradient-to-b from-navy to-midnight
                    ${collapsed ? 'w-16' : 'w-60'}`}
      >
        <SidebarContent />
        {/* Collapse toggle */}
        <button
          onClick={() => setCollapsed((c) => !c)}
          className="absolute left-0 top-1/2 -translate-y-1/2 translate-x-full
                     bg-navy text-blue-300 rounded-r-lg p-1 shadow-lg border-r border-t border-b border-white/10
                     hover:text-white transition-colors z-10"
          style={{ marginLeft: collapsed ? '4rem' : '15rem' }}
        >
          <ChevronRight className={`w-3 h-3 transition-transform duration-300 ${collapsed ? '' : 'rotate-180'}`} />
        </button>
      </aside>

      {/* Mobile Sidebar Overlay */}
      {sidebarOpen && (
        <div className="lg:hidden fixed inset-0 z-50 flex">
          <div
            className="fixed inset-0 bg-midnight/60 backdrop-blur-sm"
            onClick={() => setSidebarOpen(false)}
          />
          <aside className="relative w-64 flex flex-col bg-gradient-to-b from-navy to-midnight">
            <button
              onClick={() => setSidebarOpen(false)}
              className="absolute top-4 right-4 p-1.5 rounded-lg text-blue-300/60 hover:text-white hover:bg-white/10 transition-colors"
            >
              <X className="w-5 h-5" />
            </button>
            <SidebarContent />
          </aside>
        </div>
      )}

      {/* Main Content */}
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
        {/* Top Bar */}
        <header className="flex-shrink-0 bg-white border-b border-[#E8EAFF] px-4 lg:px-6 py-3.5 flex items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <button
              onClick={() => setSidebarOpen(true)}
              className="lg:hidden p-2 rounded-lg text-gray-500 hover:bg-gray-100 transition-colors"
            >
              <Menu className="w-5 h-5" />
            </button>
            <div>
              <h2 className="font-semibold text-gray-900 text-sm">{pageTitle}</h2>
              <p className="text-xs text-gray-500 hidden sm:block">
                Vanguard Admin Console
              </p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <NavLink
              to="/notifications"
              className="p-2 rounded-lg text-gray-500 hover:bg-gray-100 hover:text-gray-700 transition-colors relative"
            >
              <Bell className="w-5 h-5" />
              <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-amber-500 rounded-full" />
            </NavLink>
            <div className="w-8 h-8 rounded-full bg-gradient-to-br from-primary-500 to-primary-700 flex items-center justify-center cursor-pointer">
              <span className="text-white text-xs font-bold">
                {(user?.displayName ?? user?.email ?? 'A').charAt(0).toUpperCase()}
              </span>
            </div>
          </div>
        </header>

        {/* Page Content */}
        <main className="flex-1 overflow-y-auto scrollbar-thin p-4 lg:p-6">
          {children}
        </main>
      </div>
    </div>
  );
};

export default AppShell;
