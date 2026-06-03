/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#F0F4FF',
          100: '#E0E8FF',
          500: '#4F46E5',
          600: '#4338CA',
          700: '#3730A3',
          900: '#1E1B4B',
        },
        midnight: '#080C18',
        navy: '#0E2355',
        gold: {
          400: '#FBBF24',
          500: '#EAB308',
          600: '#D97706',
        },
        surface: '#F8F9FF',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      boxShadow: {
        card: '0 1px 3px 0 rgba(79, 70, 229, 0.08)',
        modal: '0 20px 60px -10px rgba(14, 35, 85, 0.25)',
      },
    },
  },
  plugins: [],
}
