import React, { useEffect, useState } from 'react';
import { Navigate } from 'react-router-dom';
import { onAuthStateChanged } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { auth, db } from '../firebase';
import { COLLECTIONS } from '../lib/collections';
import LoadingSpinner from './LoadingSpinner';

interface AuthGuardProps {
  children: React.ReactNode;
}

type AuthState = 'loading' | 'authenticated' | 'unauthenticated' | 'unauthorized';

const AuthGuard: React.FC<AuthGuardProps> = ({ children }) => {
  const [authState, setAuthState] = useState<AuthState>('loading');

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (!user) {
        setAuthState('unauthenticated');
        return;
      }

      try {
        // Check user role in vanguard_users collection
        const userDoc = await getDoc(doc(db, COLLECTIONS.USERS, user.uid));
        if (userDoc.exists()) {
          const userData = userDoc.data();
          if (userData?.role === 'admin') {
            setAuthState('authenticated');
          } else {
            setAuthState('unauthorized');
          }
        } else {
          // If no user document, allow if they can authenticate (fallback)
          setAuthState('authenticated');
        }
      } catch (error) {
        console.error('Error checking user role:', error);
        // Allow access if Firestore check fails (network issues etc.)
        setAuthState('authenticated');
      }
    });

    return () => unsubscribe();
  }, []);

  if (authState === 'loading') {
    return <LoadingSpinner fullPage message="Verifying credentials..." />;
  }

  if (authState === 'unauthenticated') {
    return <Navigate to="/login" replace />;
  }

  if (authState === 'unauthorized') {
    return (
      <div className="fixed inset-0 bg-surface flex items-center justify-center">
        <div className="text-center max-w-sm p-8">
          <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg className="w-8 h-8 text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
          </div>
          <h2 className="text-xl font-bold text-gray-900 mb-2">Access Denied</h2>
          <p className="text-sm text-gray-500 mb-6">
            You do not have admin privileges to access this dashboard.
          </p>
          <button
            onClick={() => auth.signOut()}
            className="btn-primary"
          >
            Sign Out
          </button>
        </div>
      </div>
    );
  }

  return <>{children}</>;
};

export default AuthGuard;
