# WealthWise

A dynamic AI-powered wealth management app with a built-in cyber-fraud protection layer, built for the PSB Hackathon 2026.

## Project Structure

```
PSB-Hackathon/
│
├── frontend/        ← Flutter app
│   ├── lib/
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── windows/
│   └── ...
│
├── backend/         ← Node.js server
│   ├── index.js
│   ├── package.json
│
└── README.md
```

## Features
- **Wealth Intelligence Engine**: AI-driven insights for savings, investments, and overspending.
- **Cyber Protection Layer**: A real-time rule-based risk scoring system.
- **Modern UI**: Clean, responsive fintech design mimicking real-world banking apps.
- **Scalable Architecture**: Modular codebase ready for robust SQL/API integration.

## Architecture
- **Frontend**: Built using Flutter and Provider for State Management. Follows a Feature-First modular structure (`lib/features`, `lib/core`, `lib/data`). Supports local SQLite persistence using `sqflite`.
- **Backend**: Node.js server with Express.js for API endpoints.

## 🛠️ Local Setup & Security

### Frontend (Flutter)
1. Navigate to the `frontend/` directory.
2. Copy `.env.example` to `.env` and fill in your `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
3. Run the app:
   ```bash
   cd frontend
   flutter run --dart-define-from-file=.env
   ```

### Backend (Node.js)
1. Navigate to the `backend/` directory.
2. Install dependencies:
   ```bash
   cd backend
   npm install
   ```
3. Start the server:
   ```bash
   npm run dev
   ```
