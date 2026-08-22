# WealthWise 🛡️💰

> **An Intelligent, Security-First Wealth Management Application with an Integrated RAG AI Assistant and Automated Cyber-Defense System.**

WealthWise bridges the gap between modern digital banking, automated wealth management, and cybersecurity. It enables users to view live balances, manage investments (stocks, mutual funds, IPOs, options), analyze spending patterns, and interact with **SAGE**—a context-aware AI banking and security assistant.

---

## 🌟 Key Features

### 🏛️ Digital Banking & Wealth Management
*   **Multi-Asset Management**: Real-time portfolios across Stocks, Mutual Funds, IPO applications, and Derivatives.
*   **Intelligent Transfers**: Dynamic UPI, IMPS, and Account-to-Account money transfers.
*   **Panic Mode Defense**: Decoy system activation with isolated mock transactions during forced logins.
*   **Dynamic ATM Locator**: Nearby branch & ATM navigation with integrated safety metrics.

### 🤖 SAGE — RAG-Powered AI Banking Assistant
*   **Savings Advisor**: Detect overspending spikes, identify monthly subscription commitments, calculate cash runway months, and suggest savings opportunities.
*   **Fraud Explainability**: Provide real-time breakdowns of transaction risks (e.g., explaining flagged payments, risk scores, and matching rules).
*   **Financial Health Scoring**: Calculate a mathematical index (0-100) assessing strengths and weaknesses across assets, debts, and cash flows.
*   **Security Restrictions**: Enforce absolute safety guardrails (refusing to perform transfers, execute actions, or download/run code).

### 🛡️ Fraud Detection Engine
An analytics and rule-based system running on the backend that calculates:
*   **Risk Scores (0-100)**: Evaluates transaction amounts, geographical velocity anomalies, timing windows, VPN/Proxy utilization, and card-testing patterns.
*   **Severity Levels (LOW, MEDIUM, HIGH)**: Triggers dynamic security actions in the app based on risk.

### 📚 RAG Architecture
SAGE reads knowledge from a semantic vector index containing regulatory policies, security manuals, and bank guidelines. It performs hybrid search and reranking on **Qdrant Cloud** to provide grounded, hallucination-free guidance.

---

## 🛠️ Technology Stack

| Layer | Technology | Details |
|---|---|---|
| **Frontend** | Flutter | Cross-platform UI, Provider state management, Local SQLite (sqflite) |
| **Backend** | Node.js / Express | REST API server, PostgreSQL client, AI middleware orchestration |
| **Python Microservice** | FastAPI / PyTorch | Computer vision entropy engine, frame analysis, token service |
| **Database** | Supabase | PostgreSQL backend for core transactions, user settings, and account details |
| **Vector DB** | Qdrant Cloud | HNSW indexing, semantic vector searches, and hybrid reranking |
| **AI Engine** | Groq Cloud | Powered by `llama-3.3-70b-versatile` for low-latency, high-accuracy inference |
| **Local Dev LLM** | Ollama | Fallback option running `nomic-embed-text` / `llama3` locally |

---

## 🚀 Setup & Execution Instructions

### 1. Environment Configuration

#### Frontend (`frontend/.env`)
Rename `frontend/.env.example` to `.env` (or create `frontend/.env`) and add:
```env
SUPABASE_URL=YOUR_SUPABASE_URL
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
BACKEND_URL=http://<YOUR_IPV4_ADDRESS>:3000
```
> 💡 *Replace `<YOUR_IPV4_ADDRESS>` with your laptop's IPv4 address (found using `ipconfig`).*

#### Backend (`backend/.env`)
Rename `backend/.env.example` to `.env` (or create `backend/.env`) and add:
```env
DATABASE_URL=YOUR_DATABASE_URL
QDRANT_URL=YOUR_QDRANT_URL
QDRANT_API_KEY=YOUR_QDRANT_API_KEY
GROQ_API_KEY=YOUR_GROQ_API_KEY
LLM_PROVIDER=groq
PYTHON_TOKEN_SERVICE=http://localhost:8100
```

---

### 2. Optional Setup (Graphics Card with ≥6GB VRAM)
In CMD / Terminal run:
```bash
ollama pull nomic-embed-text
```

---

### 3. IP Address Configuration in `ai_service.dart`
In `frontend/lib/services/ai_service.dart`, locate `http://10.0.2.2:3000` (or local host IP) and update it with your laptop's IPv4 address.

To find your laptop's IP address:
1. Open CMD and run `ipconfig`.
2. Find your **IPv4 Address** under Wireless LAN or Ethernet adapter (e.g. `111.23.1.34`).
3. Replace the URL in `ai_service.dart` with `http://111.23.1.34:3000`.

---

### 4. Git Workflow Guidelines (Always Keep in Mind)

Always pull stable updates on `main` branch before creating features:
```bash
git switch main
git pull
git checkout -b feature_<your_feature_name>
```

Work on your task within your feature branch (do NOT switch to `main` mid-development). Once completed:
```bash
git add .
git commit -m "your message"
git push origin feature_<your_feature_name>
```

After pushing, open a Pull Request on GitHub. **DO NOT MERGE DIRECTLY INTO MAIN**. Switch back to main when needed:
```bash
git switch main
```

---

### 5. Prerequisites & Environment Setup

#### Node.js
If Node.js is not installed, download the MSI installer from [Node.js Official Website](https://nodejs.org/).
Open PowerShell as Administrator and execute:
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```
Type `Y` and press Enter.

#### Required Libraries / Dependencies:
*   PyTorch
*   NumPy
*   Pillow
*   OpenCV (`opencv-python`)
*   Pydantic
*   Uvicorn [standard]
*   FastAPI
*   Ultralytics
*   Cryptography

#### Assets Setup
1. Inside `backend`, create an `assets` folder with a `videos` subfolder (`backend/assets/videos/`).
2. Download the fish tank video from: [Google Drive Link](https://drive.google.com/file/d/1c9GOVuMClevU1RhNtBInHbbGPnuEzrq0/view?usp=sharing).
3. Place the video file inside `backend/assets/videos/`.

---

### 6. Running the Software

Open separate terminal windows for each process:

#### Terminal 1 — Frontend
```bash
cd frontend
flutter run --dart-define-from-file=.env
```

#### Terminal 2 — Node.js Backend Server
```bash
cd backend
npm install
node index.js
```

#### Terminal 3 — Python Service
```bash
cd backend
python -m uvicorn python_service.app:app --port 8100 --host 0.0.0.0
```

#### Terminal 4 — Hotspot Detection GUI (Optional)
*(For systems with GUI to display actual fish detection)*
```bash
cd backend
python dashboard/main.py
```

#### Hotspot Dashboard Access (Browser URL)
To monitor hotspot fraud intelligence via web browser:
`http://localhost:3000/admin/hotspots`
