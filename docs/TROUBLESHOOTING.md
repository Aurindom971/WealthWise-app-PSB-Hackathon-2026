# Troubleshooting & Debugging Guide

This document lists common issues developers encounter when setting up or running the Secure Wealth application, along with steps to resolve them.

---

## 🔌 Connection & Network Routing Issues

### 1. Android Emulator cannot reach the Backend Server
*   **Symptom**: The mobile app loads but shows timed-out connections or failures when attempting to log in or talk to SAGE.
*   **Root Cause**: Local host loopback (`127.0.0.1` or `localhost`) on an Android emulator points to the virtual phone's internal loopback, not your host computer.
*   **Resolution**: Update your mobile configuration environment settings to point to the host machine via the virtual gateway address:
    *   Change `http://localhost:3000` or `http://127.0.0.1:3000` to `http://10.0.2.2:3000`.

---

### 2. EADDRINUSE — Port 3000 Already in Use
*   **Symptom**: Starting the backend via `npm start` crashes with:
    ```text
    FATAL ERROR: Error: listen EADDRINUSE: address already in use 0.0.0.0:3000
    ```
*   **Root Cause**: An instance of the node server is already running in the background.
*   **Resolution**:
    *   **Windows (PowerShell)**:
        ```powershell
        # Find the Process ID (PID)
        netstat -ano | findstr :3000
        # Kill the task (replace 12345 with the actual PID found)
        taskkill /PID 12345 /F
        ```
    *   **Mac / Linux**:
        ```bash
        lsof -i :3000
        kill -9 <PID>
        ```

---

## 🤖 AI & LLM Errors

### 3. Groq API Key Authentication Failures
*   **Symptom**: Requests to `/ai-chat` or `/ai-explain` return HTTP 500:
    ```text
    [LLM Service] Error generating response: API key is invalid or unauthorized
    ```
*   **Resolution**:
    1.  Ensure you have defined `GROQ_API_KEY` inside `backend/.env`.
    2.  Check that the API key does not contain trailing spaces, quotes, or newlines.
    3.  Verify your key permissions and status on the [Groq Console](https://console.groq.com/).

### 4. Qdrant / RAG Ingestion Returning Empty Results
*   **Symptom**: SAGE responds to queries but does not include any "Relevant Banking Knowledge" from the documentation.
*   **Resolution**:
    1.  Verify the Qdrant credentials inside `backend/.env` are correct.
    2.  Ensure local Ollama is running and has the `nomic-embed-text` model installed, as it is required to generate query vector embeddings:
        ```bash
        ollama run nomic-embed-text
        ```
    3.  Run the manual data ingestion utility from the backend root to seed the vector database:
        ```bash
        node scripts/ingest.js
        ```

---

## 🗄️ Database & Profile Sync Issues

### 5. SAGE Returns ₹0 or Incorrect Account Balance
*   **Symptom**: The SAGE chat screen states that the account balance is ₹0, but the dashboard widget shows a positive amount (e.g. ₹900,000).
*   **Root Cause**: 
    1.  The Flutter app failed to send the logged-in user's dynamic customer ID (`cus_id`) payload to `/ai-chat`.
    2.  The user's database session does not have accounts linked.
*   **Resolution**:
    *   Verify the backend server terminal console logs for the `[SAGE DEBUG]` output block:
        ```text
        [SAGE DEBUG]
        email=user5@mail.com
        customerId=CUST1
        accounts=[{"account_id":"1","balance":850000},{"account_id":"23","balance":50000}]
        totalBalance=900000
        ```
    *   If `customerId` is null or empty, trace the frontend request in `lib/services/ai_service.dart` and verify the payload contains:
        ```json
        {
          "message": "What is my balance?",
          "cus_id": "CUST1"
        }
        ```

---

### 6. SAGE Weekly Spending Returns ₹0
*   **Symptom**: Asking SAGE "How much did I spend this week?" returns ₹0, even though transactions exist in the dashboard.
*   **Root Cause**: The database records are historical (from 2024-2026). If the weekly spending logic evaluates the calendar week containing *today's current date*, it will find no records and return ₹0.
*   **Resolution**: SAGE uses an active transaction date anchoring mechanism. It finds `MAX(created_at)` for the customer's transactions and aligns the calendar week start and end relative to that reference date rather than `NOW()`. If it still returns ₹0, verify that the transaction records actually have a `debit` type or a negative amount in the `amount` column.

---

## 💻 Developer Quick Commands Reference

### Backend Terminal
*   Install project dependencies: `npm install`
*   Start production node engine: `npm start`
*   Start developer reload instance: `npm run dev`
*   Run manual document embedding ingestion: `node scripts/ingest.js`
*   Run SAGE Copilot verification tests: `node scripts/test-copilot.js`

### Frontend Terminal
*   Fetch packages: `flutter pub get`
*   Build and launch app: `flutter run --dart-define-from-file=.env`
*   Clean temporary build files: `flutter clean`

### API Endpoint Validation Checks
*   **Health Status**:
    ```bash
    curl http://localhost:3000/health
    ```
*   **Query Chat (Postman Body equivalent)**:
    ```bash
    curl -X POST http://localhost:3000/ai-chat \
      -H "Content-Type: application/json" \
      -d '{"message": "What is my balance?", "cus_id": "CUST1"}'
    ```
*   **Query Financial Insights**:
    ```bash
    curl -X POST http://localhost:3000/financial-insights \
      -H "Content-Type: application/json" \
      -d '{"cus_id": "CUST1"}'
    ```

