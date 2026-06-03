export interface Employee {
  id: string;
  name: string;
  email: string;
  role: string;
  department: string;
  status: 'active' | 'inactive';
  joinDate: string;
  phone?: string;
  avatar?: string;
  userId?: string;
}

export interface Volunteer {
  id: string;
  name: string;
  email: string;
  role: string;
  department: string;
  status: 'active' | 'inactive';
  joinDate: string;
  phone?: string;
  avatar?: string;
  userId?: string;
  hoursVolunteered?: number;
}

export interface VanguardUser {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'employee' | 'volunteer';
  status: 'active' | 'inactive';
  createdAt: string;
}

export interface LeaveRequest {
  id: string;
  employeeId: string;
  employeeFullName?: string;
  employeeName?: string; // For backward compatibility
  userId?: string; // For backward compatibility
  type: 'annual' | 'sick' | 'personal' | 'maternity' | 'paternity' | 'emergency' | 'unpaid';
  startDate: string;
  endDate: string;
  days: number;
  reason: string;
  status: 'pending' | 'approved' | 'rejected';
  requestDate: string;
  appliedAt?: string; // For backward compatibility
  approvedBy?: string;
  approvalDate?: string;
  reviewedBy?: string; // For backward compatibility
  reviewedAt?: string; // For backward compatibility
  notes?: string;
}

export interface SalaryRequest {
  id: string;
  userId: string;
  employeeId: string;
  employeeName: string;
  amount: number;
  period: string;
  status: 'pending' | 'approved' | 'disbursed' | 'rejected';
  requestedAt: string;
  disbursedAt?: string;
  notes?: string;
}

export interface WalletTransaction {
  id: string;
  type: 'credit' | 'debit';
  amount: number;
  description: string;
  category: 'salary' | 'deposit' | 'expense' | 'refund' | 'other';
  reference?: string;
  createdAt: string;
  balance?: number;
}

export interface WalletSummary {
  id: string;
  balance: number;
  totalRevenue: number;
  totalExpenses: number;
  lastUpdated: string;
  monthlyData?: MonthlyWalletData[];
}

export interface MonthlyWalletData {
  month: string;
  revenue: number;
  expenses: number;
}

export interface WorkLocation {
  id: string;
  name: string;
  address: string;
  city?: string;
  country?: string;
  latitude?: number;
  longitude?: number;
  radius: number;
  status: 'active' | 'inactive';
  createdAt: string;
}

export interface Notification {
  id: string;
  title: string;
  message: string;
  target: 'all' | 'employees' | 'volunteers' | 'admins';
  type: 'info' | 'warning' | 'success' | 'alert';
  sentBy: string;
  sentAt: string;
  readBy?: string[];
}

export interface AttendanceRecord {
  id: string;
  userId: string;
  employeeName: string;
  date: string;
  checkIn?: string;
  checkOut?: string;
  locationId?: string;
  locationName?: string;
  status: 'present' | 'absent' | 'late' | 'half-day';
  hoursWorked?: number;
}

export interface Project {
  id: string;
  name: string;
  description?: string;
  status: 'planning' | 'active' | 'completed' | 'on-hold';
  startDate: string;
  endDate?: string;
  managerId?: string;
  teamMembers?: string[];
  progress?: number;
}

export interface Task {
  id: string;
  projectId: string;
  title: string;
  description?: string;
  assigneeId?: string;
  assigneeName?: string;
  status: 'todo' | 'in-progress' | 'review' | 'done';
  priority: 'low' | 'medium' | 'high' | 'urgent';
  dueDate?: string;
  createdAt: string;
}

export interface DashboardStats {
  totalEmployees: number;
  activeVolunteers: number;
  pendingLeaves: number;
  walletBalance: number;
  employeeGrowth?: number;
  volunteerGrowth?: number;
  leaveChange?: number;
  balanceChange?: number;
}
