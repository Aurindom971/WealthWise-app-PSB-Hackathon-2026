# Setup & Local Installation Guide

This document contains step-by-step instructions for setting up both the Flutter frontend and the Node.js backend on your local development machine.

---

## 📋 Prerequisites

Ensure you have the following tools installed:

| Tool | Recommended Version | Purpose |
|---|---|---|
| **Git** | `2.x` or higher | Source control management |
| **Node.js** | `v18.x` or `v20.x` (LTS) | Backend runtime execution |
| **npm** | `v9.x` or `v10.x` | Node package manager |
| **Flutter SDK** | `3.19.x` or higher | Mobile development framework |
| **Android Studio** | Latest stable | Android emulator and SDK manager |
| **VS Code / Android Studio** | Latest | Recommended IDEs |

---

## 🛠️ Step-by-Step Installation

### 1. Clone the Repository
Clone the codebase to your local workspace:
```bash
git clone https://github.com/Aurindom971/PSB-Hackathon-Secure-wealth-app.git psb-hackathon
cd psb-hackathon
```

---

### 2. Backend Setup

1.  Navigate to the backend directory:
    ```bash
    cd backend
    ```
2.  Install all package dependencies:
    ```bash
    npm install
    ```
3.  Configure environment variables:
    Copy the `.env.example` template:
    ```bash
    cp .env.example .env
    ```
    Open `.env` and fill in the values described in [Environment Variables](#environment-variables-backend) below.

---

### 3. Frontend Setup

1.  Navigate to the frontend directory:
    ```bash
    cd ../frontend
    ```
2.  Install flutter packages:
    ```bash
    flutter pub get
    ```
3.  Configure environment variables:
    Copy the `.env.example` template:
    ```bash
    cp .env.example .env
    ```
    Open `.env` and configure the values described in [Environment Variables](#environment-variables-frontend) below.

---

## 🔑 Environment Variables Configuration

### Backend Environment (`backend/.env`)

```ini
# Database Connection
DATABASE_URL=postgresql://postgres.xxx:password@aws-pooler.supabase.com:5432/postgres

# Supabase Client Config (for dynamic user lookups in backend routes)
SUPABASE_URL=https://your-supabase-id.supabase.co
SUPABASE_KEY=your-supabase-anon-or-service-role-key

# Qdrant Vector Search Config
QDRANT_URL=https://your-qdrant-cluster.aws.cloud.qdrant.io
QDRANT_API_KEY=your-qdrant-secret-api-key

# AI Provider Selection
LLM_PROVIDER=groq
GROQ_API_KEY=gsk_your_groq_api_key

# Local Fallback (Ollama)
OLLAMA_URL=http://localhost:11434
PORT=3000
```

#### Detailed Breakdown:
*   `DATABASE_URL`: Direct connection string to Supabase PostgreSQL database. Used for transactional lookups and building fraud profiles.
*   `QDRANT_URL` & `QDRANT_API_KEY`: Connection details for your cloud-hosted vector database where policies are indexed.
*   `LLM_PROVIDER`: Set to `groq` to run cloud-based `llama-3.3-70b-versatile` or `ollama` for local development fallback.
*   `GROQ_API_KEY`: API access token obtained from the Groq console.

### Frontend Environment (`frontend/.env`)

```ini
SUPABASE_URL=https://your-supabase-id.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-public-key
```

---

## 🚀 Running the System

### 1. Launch the Backend Server
```bash
cd backend
npm start
```
*Alternatively, you can run in hot-reload mode during development:*
```bash
npm run dev
```

### 2. Launch the Flutter App
Ensure an emulator or a physical test device is running:
```bash
cd frontend
flutter run --dart-define-from-file=.env
```

---

## 🧪 Verifying the Deployment & Connectivity

Once both parts are running, verify they can communicate properly:

### 1. Backend Health Endpoint
Query the server health check from your command line:
```bash
curl http://localhost:3000/health
```
**Expected Response:**
```json
{ "status": "ok" }
```

### 2. Intent & Chat Verification
Verify that the AI service routes intents and answers questions via the configured Groq LLM:
```bash
curl -X POST http://localhost:3000/ai-chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What is my balance?", "cus_id": "CUST1"}'
```
**Expected Response:**
```json
{
  "success": true,
  "reply": "Your total account balance is ₹900,000. You have two savings accounts: one with ID 1 and a balance of ₹850,000, and another with ID 23 and a balance of ₹50,000."
}
```

### 3. RAG Search Verification
Query the search pipeline directly to verify connection to Qdrant Cloud:
```bash
curl -X POST http://localhost:3000/rag-search \
  -H "Content-Type: application/json" \
  -d '{"query": "What is a velocity attack?"}'
```
**Expected Response:**
```json
{
  "success": true,
  "results": [
    {
      "score": 0.6252,
      "source": "secure_wealth_overview.md",
      "chunk_index": 3,
      "text": "...Protect accounts using real-time behavioral and statistical anomaly monitoring..."
    }
  ]
}
```

### 4. Financial Copilot REST Endpoints Verification
Query the newly exposed analysis and advice endpoints to verify data integrations:

*   **Financial Insights (Wow/MoM trends)**:
    ```bash
    curl -X POST http://localhost:3000/financial-insights \
      -H "Content-Type: application/json" \
      -d '{"cus_id": "CUST1"}'
    ```
*   **Financial Health Score (0-100)**:
    ```bash
    curl -X POST http://localhost:3000/financial-health \
      -H "Content-Type: application/json" \
      -d '{"cus_id": "CUST1"}'
    ```
*   **Suspicious Transaction Detector**:
    ```bash
    curl -X POST http://localhost:3000/suspicious-transactions \
      -H "Content-Type: application/json" \
      -d '{"cus_id": "CUST1"}'
    ```
*   **Expense Analysis (Top Spends & Categories)**:
    ```bash
    curl -X POST http://localhost:3000/expense-analysis \
      -H "Content-Type: application/json" \
      -d '{"cus_id": "CUST1"}'
    ```
*   **Savings Advice (Runway & Subscriptions)**:
    ```bash
    curl -X POST http://localhost:3000/savings-advice \
      -H "Content-Type: application/json" \
      -d '{"cus_id": "CUST1"}'
    ```

