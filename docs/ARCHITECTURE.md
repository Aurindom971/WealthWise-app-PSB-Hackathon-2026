# System Architecture Manual

This document details the high-level architecture, dynamic pipelines, and request lifecycles of the Secure Wealth application.

---

## 🏗️ High-Level System Architecture

The application is structured around a decoupled Client-Server architecture. The Flutter mobile app communicates directly with a Node.js API Gateway, which coordinates access to databases, search databases, fraud rule engines, and cloud AI services.

```mermaid
graph TD
    A[Flutter Mobile App] <-->|HTTP REST / JSON| B[Node.js Express Backend]
    B <-->|PostgreSQL Client / pg| C[(Supabase Database)]
    B -->|Rules / Anomaly Engine| D[Fraud Detection Engine]
    B <-->|nomic-embed-text / REST| E[(Qdrant Cloud Vector DB)]
    B <-->|Chat API / groq-sdk| F[Groq Cloud LLM]
    
    style A fill:#47A7F5,stroke:#1E88E5,stroke-width:2px,color:#fff
    style B fill:#80C080,stroke:#2E7D32,stroke-width:2px,color:#fff
    style C fill:#ECA24F,stroke:#EF6C00,stroke-width:2px,color:#fff
    style D fill:#EF5350,stroke:#C62828,stroke-width:2px,color:#fff
    style E fill:#AB47BC,stroke:#6A1B9A,stroke-width:2px,color:#fff
    style F fill:#26A69A,stroke:#00695C,stroke-width:2px,color:#fff
```

---

## ⚙️ Core Architectural Components

### 1. Intent Detection System
Before processing queries through SAGE, the backend routes them to an Intent Classifier. 
*   **Keyword Matches (Immediate)**: High-speed override rules match queries matching phrases like *balance, savings, spend, transaction history, fraud, flagged, security, mfa* to prevent LLM latency or model misclassification.
*   **LLM Classifier (Fallback)**: When no keywords trigger, a strict zero-temperature classification prompt runs against Groq to assign one of the 5 intents: `BALANCE`, `SPENDING`, `FRAUD`, `SECURITY`, or `GENERAL_BANKING`.

### 2. Rule-Based Fraud Detection Engine
An analytical service that assesses transaction risks before writing record data to the SQL DB.
*   **Behavioral Rules**: Tracks geo-velocity parameters (e.g. traveling from Kolkata to Delhi too fast), transaction timestamps, transaction frequency bursts (velocity attacks), and proxy/VPN networks.
*   **Risk Scores**: Outputs a risk rating `0-100` and flags transactions as `LOW`, `MEDIUM`, or `HIGH` severity.
*   **Security Lockouts**: High-severity events lock transactions and set a `reauth_required` flag on the account, requiring immediate user biometric verification (face scan/passcode verification) to release the funds.

### 3. RAG Pipeline (Retrieval-Augmented Generation)
SAGE draws context from local knowledge files (` rbi_guidelines.md`, `banking_faq.md`, `app_help.md`) stored semantically.
*   **Search**: Converts the user's message into an embedding vector via local Ollama `nomic-embed-text` and queries **Qdrant Cloud** vector search.
*   **Dedup & Reranking**: Deduplicates matches from the same source file and reranks them using a composite semantic scoring algorithm before assembling the top 5 chunks into the prompt context.

### 4. Live Account Context Aggregation
For queries with a `BALANCE` or `SPENDING` intent:
*   Queries the Supabase `accounts` table for all accounts owned by the authenticated `cus_id`.
*   Iteratively sums up account balances (Savings, Checking) to calculate a single total balance matching the user's dashboard interface.
*   Formats the balances into structured context injected directly into the SAGE prompt template.

### 5. Security Guardrails
SAGE enforces absolute runtime safety policies before submitting inputs to the LLM:
*   **Action Filters**: Intercepts requests containing transaction keywords like *send, transfer, pay, withdraw, purchase, buy*.
*   **Denial Handlers**: Blocks transaction requests with a clean notice directing the user to complete payments through safe in-app menus. SAGE is strictly restricted from performing mutations.

---

## 🔄 Complete Request Lifecycle Flow

Here is a step-by-step trace of how a chat query (e.g., `"What is my account balance?"`) flows through the application:

```mermaid
sequenceDiagram
    autonumber
    actor User as User App
    participant BE as Express Backend
    participant DB as Supabase DB
    participant Qdrant as Qdrant Cloud
    participant Groq as Groq LLM

    User->>BE: POST /ai-chat { message: "What is my balance?", cus_id: "CUST1" }
    
    note over BE: Security Interceptor Checks<br/>(Keyword filter checks if it's an action/transfer request)
    BE->>BE: Detect Intent (Triggered: BALANCE)
    
    note over BE: Context Aggregation
    rect rgb(240, 248, 255)
        BE->>DB: SELECT * FROM accounts WHERE cus_id = 'CUST1'
        DB-->>BE: Returns Accounts (1: 850000, 23: 50000)
        BE->>BE: Compute Total Balance (900000) & format context
    end

    rect rgb(245, 240, 245)
        note over BE: RAG Ingestion
        BE->>Qdrant: Vector Search (nomic-embed-text)
        Qdrant-->>BE: Returns top 5 relevant policy chunks
    end

    BE->>BE: Build Prompt (User Query + Account Context + RAG Chunks + SAGE Rules)
    BE->>Groq: Chat Completion (llama-3.3-70b-versatile)
    Groq-->>BE: Returns formatted text response
    BE-->>User: HTTP 200 { success: true, reply: "Your total balance is ₹900,000..." }
```
