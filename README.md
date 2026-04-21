# SecureWealth Twin

A dynamic AI-powered wealth management app with a built-in cyber-fraud protection layer, built for the PSB Hackathon 2026.

## Features
- **Wealth Intelligence Engine**: AI-driven insights for savings, investments, and overspending.
- **Cyber Protection Layer**: A real-time rule-based risk scoring system.
- **Modern UI**: Clean, responsive fintech design mimicking real-world banking apps.
- **Scalable Architecture**: Modular codebase ready for robust SQL/API integration.

## Architecture
Built using Flutter and Provider for State Management. Follows a Feature-First modular structure (`lib/features`, `lib/core`, `lib/data`). Supports local SQLite persistence using `sqflite`.

## 🛠️ Local Setup & Security
To protect sensitive infrastructure keys (Supabase), this project uses environment variables.

1.  **Configuration**:
    - Copy `.env.example` to a new file named `.env`.
    - Fill in your `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
    - *Note*: `.env` is ignored by Git to prevent secret leakage.

2.  **Running the App**:
    - **VS Code (Recommended)**: Simply press **F5** or use the "Run and Debug" tab. The `launch.json` is pre-configured to load your `.env`.
    - **Terminal**: Use the following command to load the environment variables:
      ```bash
      flutter run --dart-define-from-file=.env
      ```

## Updated authentication feature-dekho
