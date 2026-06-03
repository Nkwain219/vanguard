import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { auth, db } from '../firebase';
import { COLLECTIONS } from '../lib/collections';
import { Shield, Eye, EyeOff, Mail, Lock, AlertCircle } from 'lucide-react';

const LoginPage: React.FC = () => {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      console.log('🔐 Attempting login with:', email);
      const credential = await signInWithEmailAndPassword(auth, email, password);
      console.log('✅ Firebase Auth successful! UID:', credential.user.uid);

      // Check admin role
      try {
        console.log('📄 Checking user document in vanguard_users...');
        const userDoc = await getDoc(doc(db, COLLECTIONS.USERS, credential.user.uid));
        console.log('📄 Document exists:', userDoc.exists());
        
        if (userDoc.exists()) {
          const userData = userDoc.data();
          console.log('📄 User data:', userData);
          console.log('👤 User role:', userData?.role);
          
          if (userData?.role !== 'admin') {
            await auth.signOut();
            setError('Access denied. Admin privileges required.');
            setLoading(false);
            return;
          }
          console.log('✅ Admin role confirmed!');
        } else {
          console.warn('⚠️ User document not found, but allowing login');
        }
      } catch (firestoreErr) {
        console.error('❌ Firestore check failed:', firestoreErr);
        // Allow if Firestore check fails
      }

      console.log('🎉 Login successful, navigating to dashboard...');
      navigate('/dashboard');
    } catch (err: unknown) {
      console.error('❌ Login error:', err);
      const code = (err as { code?: string })?.code;
      const message = (err as { message?: string })?.message;
      console.error('Error code:', code);
      console.error('Error message:', message);
      
      switch (code) {
        case 'auth/user-not-found':
        case 'auth/wrong-password':
        case 'auth/invalid-credential':
          setError('Invalid email or password.');
          break;
        case 'auth/too-many-requests':
          setError('Too many failed attempts. Please try again later.');
          break;
        case 'auth/user-disabled':
          setError('This account has been disabled.');
          break;
        default:
          setError(`Sign in failed: ${message || 'Please check your credentials.'}`);
      }
      setLoading(false);
    }
  };

  return (
    <div
      className="min-h-screen flex items-center justify-center p-4"
      style={{
        background: 'linear-gradient(135deg, #080C18 0%, #0E2355 50%, #1E1B4B 100%)',
      }}
    >
      {/* Background dots */}
      <div
        className="absolute inset-0 opacity-5"
        style={{
          backgroundImage:
            'radial-gradient(circle, #ffffff 1px, transparent 1px)',
          backgroundSize: '30px 30px',
        }}
      />

      <div className="relative w-full max-w-sm">
        {/* Glow effect */}
        <div className="absolute -inset-4 bg-primary-500/10 rounded-3xl blur-2xl" />

        {/* Card */}
        <div className="relative bg-white/[0.06] backdrop-blur-xl border border-white/10 rounded-2xl p-8 shadow-2xl">
          {/* Logo */}
          <div className="flex flex-col items-center mb-8">
            <div className="w-16 h-16 bg-gradient-to-br from-primary-500 to-primary-700 rounded-2xl flex items-center justify-center shadow-lg mb-4">
              <Shield className="w-8 h-8 text-white" />
            </div>
            <h1 className="text-2xl font-bold text-white tracking-wider">VANGUARD</h1>
            <p className="text-blue-300/60 text-sm mt-1">Admin Console</p>
          </div>

          {/* Error */}
          {error && (
            <div className="flex items-start gap-2.5 bg-red-500/10 border border-red-500/20 rounded-xl px-4 py-3 mb-6">
              <AlertCircle className="w-4 h-4 text-red-400 flex-shrink-0 mt-0.5" />
              <p className="text-red-300 text-sm">{error}</p>
            </div>
          )}

          {/* Form */}
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-blue-200/80 mb-1.5">
                Email address
              </label>
              <div className="relative">
                <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-blue-300/40" />
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="admin@vanguard.com"
                  required
                  autoComplete="email"
                  className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 pl-10
                             text-white placeholder-blue-300/30 text-sm
                             focus:outline-none focus:border-primary-500/60 focus:ring-1 focus:ring-primary-500/30
                             transition-colors"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-blue-200/80 mb-1.5">
                Password
              </label>
              <div className="relative">
                <Lock className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-blue-300/40" />
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Enter your password"
                  required
                  autoComplete="current-password"
                  className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 pl-10 pr-10
                             text-white placeholder-blue-300/30 text-sm
                             focus:outline-none focus:border-primary-500/60 focus:ring-1 focus:ring-primary-500/30
                             transition-colors"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword((s) => !s)}
                  className="absolute right-3.5 top-1/2 -translate-y-1/2 text-blue-300/40 hover:text-blue-300/80 transition-colors"
                >
                  {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
            </div>

            <button
              type="submit"
              disabled={loading || !email || !password}
              className="w-full mt-2 py-3 px-4 rounded-xl font-semibold text-sm text-white
                         bg-gradient-to-r from-primary-500 to-primary-600
                         hover:from-primary-600 hover:to-primary-700
                         disabled:opacity-50 disabled:cursor-not-allowed
                         transition-all duration-200 shadow-lg shadow-primary-500/25
                         focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 focus:ring-offset-transparent"
            >
              {loading ? (
                <span className="flex items-center justify-center gap-2">
                  <span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                  Signing in...
                </span>
              ) : (
                'Sign in to Dashboard'
              )}
            </button>
          </form>

          <p className="text-center text-blue-300/40 text-xs mt-6">
            Vanguard Workforce Management &copy; {new Date().getFullYear()}
          </p>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;
