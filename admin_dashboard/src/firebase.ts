import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getAuth } from 'firebase/auth';
import { getFunctions } from 'firebase/functions';

const firebaseConfig = {
  apiKey: import.meta.env?.VITE_FIREBASE_API_KEY || "YOUR_API_KEY",
  authDomain: "portfolio-5ee70.firebaseapp.com",
  projectId: "portfolio-5ee70",
  storageBucket: "portfolio-5ee70.firebasestorage.app",
  messagingSenderId: "1082604851100",
  appId: "1:1082604851100:web:91106c58186fd8f360c259",
  measurementId: "G-G9PT3W6FRR"
};

console.log('🔥 Firebase Config Loaded:', {
  apiKey: firebaseConfig.apiKey.substring(0, 20) + '...',
  projectId: firebaseConfig.projectId
});

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app, 'vanguard-db');
export const auth = getAuth(app);
export const functions = getFunctions(app);
