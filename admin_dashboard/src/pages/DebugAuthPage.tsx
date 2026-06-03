import { useState } from 'react';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { doc, getDoc, collection, getDocs } from 'firebase/firestore';
import { auth, db } from '../firebase';
import { COLLECTIONS } from '../lib/collections';

export default function DebugAuthPage() {
  const [email, setEmail] = useState('admin@vanguard.com');
  const [password, setPassword] = useState('');
  const [results, setResults] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);

  const log = (message: string) => {
    setResults(prev => [...prev, `[${new Date().toLocaleTimeString()}] ${message}`]);
  };

  const runDiagnostics = async () => {
    setResults([]);
    setLoading(true);
    log('🔍 Starting diagnostics...');

    try {
      // Test 1: Check Firebase Auth
      log('📝 Test 1: Attempting Firebase Auth login...');
      try {
        const credential = await signInWithEmailAndPassword(auth, email, password);
        log(`✅ Auth Success! UID: ${credential.user.uid}`);
        log(`   Email: ${credential.user.email}`);
        log(`   Email Verified: ${credential.user.emailVerified}`);

        const uid = credential.user.uid;

        // Test 2: Check Firestore Document
        log('📝 Test 2: Checking Firestore document...');
        try {
          const userDocRef = doc(db, COLLECTIONS.USERS, uid);
          const userDoc = await getDoc(userDocRef);
          
          if (userDoc.exists()) {
            log(`✅ Document found in ${COLLECTIONS.USERS}`);
            const data = userDoc.data();
            log(`   Document ID: ${userDoc.id}`);
            log(`   Data: ${JSON.stringify(data, null, 2)}`);
            
            // Check specific fields
            if (data.role === 'admin') {
              log('✅ Role is "admin" (correct)');
            } else {
              log(`❌ Role is "${data.role}" (should be "admin")`);
            }
            
            if (data.isActive === true) {
              log('✅ isActive is true (correct)');
            } else {
              log(`❌ isActive is ${data.isActive} (should be boolean true)`);
            }

            if (data.id === uid) {
              log('✅ ID field matches UID');
            } else {
              log(`⚠️  ID field (${data.id}) doesn't match UID (${uid})`);
            }
          } else {
            log(`❌ Document NOT found in ${COLLECTIONS.USERS}`);
            log(`   Expected document ID: ${uid}`);
          }
        } catch (firestoreError: any) {
          log(`❌ Firestore Error: ${firestoreError.message}`);
        }

        // Test 3: List all documents in vanguard_users
        log('📝 Test 3: Listing all documents in vanguard_users...');
        try {
          const usersSnapshot = await getDocs(collection(db, COLLECTIONS.USERS));
          log(`   Found ${usersSnapshot.size} document(s)`);
          usersSnapshot.forEach((doc) => {
            const data = doc.data();
            log(`   - Doc ID: ${doc.id}, Email: ${data.email}, Role: ${data.role}`);
          });
        } catch (listError: any) {
          log(`❌ Error listing documents: ${listError.message}`);
        }

        // Sign out after tests
        await auth.signOut();
        log('🔓 Signed out after tests');

      } catch (authError: any) {
        log(`❌ Auth Failed: ${authError.code}`);
        log(`   Message: ${authError.message}`);
        
        if (authError.code === 'auth/user-not-found') {
          log('   → User does not exist in Firebase Auth');
        } else if (authError.code === 'auth/wrong-password') {
          log('   → Password is incorrect');
        } else if (authError.code === 'auth/invalid-credential') {
          log('   → Email or password is invalid');
        }
      }

      // Test 4: Check database connection
      log('📝 Test 4: Checking database configuration...');
      log(`   Database ID: vanguard-db`);
      log(`   Collection: ${COLLECTIONS.USERS}`);
      log(`   Project ID: portfolio-5ee70`);

    } catch (error: any) {
      log(`❌ Unexpected error: ${error.message}`);
    }

    setLoading(false);
    log('✅ Diagnostics complete!');
  };

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-4xl mx-auto">
        <div className="bg-white rounded-lg shadow-lg p-6 mb-6">
          <h1 className="text-2xl font-bold mb-4">🔧 Authentication Debugger</h1>
          <p className="text-gray-600 mb-6">
            This page helps diagnose login issues. Enter your credentials and click "Run Diagnostics".
          </p>

          <div className="space-y-4 mb-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Email
              </label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="admin@vanguard.com"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Password
              </label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Enter password"
              />
            </div>

            <button
              onClick={runDiagnostics}
              disabled={loading || !email || !password}
              className="w-full bg-blue-600 text-white py-3 px-4 rounded-lg font-semibold hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {loading ? 'Running Diagnostics...' : 'Run Diagnostics'}
            </button>
          </div>
        </div>

        {results.length > 0 && (
          <div className="bg-gray-900 rounded-lg shadow-lg p-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-semibold text-white">Diagnostic Results</h2>
              <button
                onClick={() => setResults([])}
                className="text-sm text-gray-400 hover:text-white"
              >
                Clear
              </button>
            </div>
            <div className="bg-black rounded p-4 font-mono text-sm text-green-400 space-y-1 max-h-96 overflow-y-auto">
              {results.map((result, index) => (
                <div key={index} className="whitespace-pre-wrap break-all">
                  {result}
                </div>
              ))}
            </div>
          </div>
        )}

        <div className="mt-6 bg-yellow-50 border border-yellow-200 rounded-lg p-4">
          <h3 className="font-semibold text-yellow-900 mb-2">⚠️ Security Note</h3>
          <p className="text-sm text-yellow-800">
            This debug page should be removed before production deployment. It exposes sensitive authentication information.
          </p>
        </div>
      </div>
    </div>
  );
}
