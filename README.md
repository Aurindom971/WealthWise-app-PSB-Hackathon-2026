# Secure Wealth 🛡️💰

A next-generation AI-powered wealth management application with an integrated real-time cyber-fraud protection layer, built for the PSB Hackathon 2026.

Secure Wealth bridges the gap between modern digital banking, automated wealth management, and cybersecurity. It enables users to view live balances, manage investments (stocks, mutual funds, IPOs, options), analyze spending patterns, and interact with **SAGE**—a context-aware AI banking and security assistant.

---

## 📖 Table of Contents
1. [Project Overview](#-project-overview)
2. [Technology Stack](#-technology-stack)
3. [Folder Structure](#-folder-structure)
4. [Quick Start](#-quick-start)
5. [Detailed Documentation](#-detailed-documentation)

---

## 🌟 Project Overview

### Secure Wealth
Secure Wealth is a secure fintech application designed to deliver advanced wealth management features while defending users from modern cyber threats like account takeovers, velocity attacks, screen overlay exploits, and transaction fraud.

### Key Features
*   **Integrated Retail Banking & Portfolio Management**: Track account balances, savings details, stock prices, mutual funds, options chains, and active IPO listings.
*   **Biometric & Dynamic Re-Authentication**: Implements risk-based step-up authentication (face verification/passcode checks) for suspicious transactions.
*   **Security Blanket Shielding**: Implements overlay attack mitigation (detecting background drawing apps) to prevent credential theft.

### AI Features (SAGE Assistant)
SAGE is an advanced, secure natural language interface built into the app to:
*   Answer support and general banking queries.
*   Provide real-time breakdowns of transaction risks (e.g., explaining flagged payments).
*   Answer questions about account balances with actual, live data retrieved on-demand.
*   Enforce absolute security guardrails (refusing to perform transfers, execute actions, or download/run code).

### Fraud Detection Engine
An analytics and rule-based system running on the backend that calculates:
*   **Risk Scores (0-100)**: Evaluates transaction amounts, geographical velocity anomalies, timing windows, VPN/Proxy utilization, and card-testing patterns.
*   **Severity Levels (LOW, MEDIUM, HIGH)**: Triggers dynamic security actions in the app based on risk.

### RAG Architecture
SAGE reads knowledge from a semantic vector index containing regulatory policies, security manuals, and bank guidelines. It performs hybrid search and reranking on **Qdrant Cloud** to provide grounded, hallucination-free guidance.

---

## 🛠️ Technology Stack

| Layer | Technology | Details |
|---|---|---|
| **Frontend** | Flutter | Cross-platform UI, Provider state management, Local SQLite (sqflite) |
| **Backend** | Node.js / Express | REST API server, PostgreSQL client, AI middleware orchestration |
| **Database** | Supabase | PostgreSQL backend for core transactions, user settings, and account details |
| **Vector DB** | Qdrant Cloud | HNSW indexing, semantic vector searches, and hybrid reranking |
| **AI Engine** | Groq Cloud | Powered by `llama-3.3-70b-versatile` for low-latency, high-accuracy inference |
| **Local Dev LLM** | Ollama | Fallback option running `llama3` locally |

---

## 📁 Folder Structure

```text
psb-hackathon/
├── README.md                  # Main project introduction & overview
├── docs/                      # Dedicated technical documentation directory
│   ├── SETUP.md               # Onboarding and environment configuration
│   ├── ARCHITECTURE.md        # System architecture and request flow diagrams
│   ├── AI_SYSTEM.md           # SAGE assistant internals and prompt designs
│   └── TROUBLESHOOTING.md     # Common errors, local dev gotchas, and fixes
│
├── frontend/                  # Flutter application
│   ├── lib/
│   │   ├── core/              # Theme, navigation, shared constants
│   │   ├── data/              # SQLite database services & local storage
│   │   ├── features/          # UI features (auth, home, ai-chat, investments)
│   │   ├── routes/            # App route configuration
│   │   ├── services/          # API services (ai_service.dart, security_service.dart)
│   │   └── widgets/           # Global reusable UI components
│   ├── assets/                # App icons, vectors, and UI images
│   ├── pubspec.yaml           # Flutter dependencies and assets config
│   └── .env.example           # Example environment variables template for mobile
│
└── backend/                   # Node.js Express server
    ├── index.js               # Main API routes and server runner
    ├── db.js                  # Database connection pool & user profiles queries
    ├── fraudDetection.js      # Behavioral and heuristic fraud-scoring algorithms
    ├── src/
    │   ├── config/            # Supabase & Qdrant configuration
    │   └── services/          # Services layer (llmService.js, embeddingService.js, ragService.js)
    ├── scripts/               # Utility scripts (test-ai-chat.js, ingest.js)
    ├── package.json           # Node.js dependencies
    └── .env.example           # Environment template for server configuration
```

---

## 🚀 Quick Start

Get the entire environment up and running in minutes:

### 1. Run the Backend
```bash
cd backend
npm install
# Rename .env.example to .env and configure keys
npm start
```
Verify the server is online at `http://localhost:3000/health`.

### 2. Run the Frontend
```bash
cd frontend
flutter pub get
# Copy .env.example to .env and configure
flutter run
```

---

## 📘 Detailed Documentation

For a comprehensive guide to understanding and developing on Secure Wealth, refer to our sub-documentation files:

*   **[Setup & Local Installation Guide](file:///c:/APPS/programs/projects/psb%20hackathon/docs/SETUP.md)**: Details tools versioning, environment configurations, and validation testing.
*   **[System Architecture Manual](file:///c:/APPS/programs/projects/psb%20hackathon/docs/ARCHITECTURE.md)**: Diagrams system interactions, request lifecycles, and RAG architectures.
*   **[SAGE AI Assistant Internals](file:///c:/APPS/programs/projects/psb%20hackathon/docs/AI_SYSTEM.md)**: Covers prompt designs, dynamic contexts injection, and query workflows.
*   **[Troubleshooting & Debugging Guide](file:///c:/APPS/programs/projects/psb%20hackathon/docs/TROUBLESHOOTING.md)**: Resolves emulator routing issues, EADDRINUSE conflicts, and empty RAG indices.
