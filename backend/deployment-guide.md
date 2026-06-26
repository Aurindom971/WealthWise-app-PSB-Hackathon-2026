# SAGE Backend Deployment Guide (Groq + Railway)

This guide walks through configuring and deploying the SAGE backend to Railway, migrating from a local Ollama environment to cloud-hosted Groq.

## 🔑 Environment Variables Setup

Configure the following environment variables in your Railway Project Settings:

| Environment Variable | Description | Example / Recommended Value |
|----------------------|-------------|----------------------------|
| `PORT` | The network port the Express application listens on. | `3000` (Railway automatically overrides this) |
| `DATABASE_URL` | PostgreSQL connection string for Supabase db. | `postgresql://postgres:...` |
| `SUPABASE_URL` | URL endpoint for Supabase client. | `https://your-project.supabase.co` |
| `SUPABASE_KEY` | Supabase service role or anon key. | `eyJhbGciOi...` |
| `QDRANT_URL` | Cloud Qdrant cluster endpoint. | `https://xxx.gcp.qdrant.io:6333` |
| `QDRANT_API_KEY` | API Key for Qdrant Cloud. | `your-qdrant-api-key` |
| `GROQ_API_KEY` | Groq API access token. | `gsk_your_groq_key` |
| `LLM_PROVIDER` | Service provider for SAGE chat/intent. | `groq` (set to `ollama` for local dev) |
| `OLLAMA_URL` | Local Ollama endpoint. | `http://localhost:11434` (only used if provider is `ollama`) |

## 🚀 Deployment Steps (Railway)

### Option 1: Via Railway CLI (Fastest)

1. **Install Railway CLI** (if not already installed):
   ```bash
   npm i -g @railway/cli
   ```
2. **Login to Railway**:
   ```bash
   railway login
   ```
3. **Link to your project**:
   ```bash
   railway link
   ```
4. **Deploy the repository**:
   ```bash
   railway up
   ```

### Option 2: Via GitHub Integration (Continuous Deployment)

1. Push your changes to a repository on GitHub.
2. Go to the [Railway Dashboard](https://railway.app/).
3. Click **New Project** → **Deploy from GitHub repo**.
4. Select the repository and branch.
5. In the service settings, go to the **Variables** tab and add the variables listed in the Environment Variables section above.
6. Railway will automatically trigger a build and deploy on every push.

## 🏥 Verification

1. **Check Application Health**:
   Locate your public Railway URL (e.g. `https://your-service.up.railway.app`) and query the health endpoint:
   ```bash
   curl https://your-service.up.railway.app/health
   ```
   **Expected Response:**
   ```json
   { "status": "ok" }
   ```

2. **Verify AI Chat Endpoint**:
   Use a tool like Postman or `curl` to verify response from Groq:
   ```bash
   curl -X POST https://your-service.up.railway.app/ai-chat \
     -H "Content-Type: application/json" \
     -d '{"message": "What is my balance?", "cus_id": "CUST1"}'
   ```

## ⚠️ Notes on RAG & Embeddings
- The `embeddingService.js` uses local Ollama `nomic-embed-text` for calculating text embeddings. 
- During runtime, SAGE queries the **Qdrant Cloud** vector search using the pre-indexed data.
- If you need to re-run ingestion (`npm run ingest` or `node scripts/ingest.js`), you must run it locally in an environment where local Ollama is active to generate the embeddings, which are then written directly to Qdrant Cloud.
