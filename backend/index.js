const express = require('express');
const cors = require('cors');
require('dotenv').config();
const axios = require('axios');

/**
 * 🌐 API GATEWAY & SECURITY MIDDLEWARE ROADMAP
 * ============================================
 * TODO: Harden entrypoints, authentication mechanisms, and rate limits.
 * Future improvements:
 *   - Implement rate limiting (e.g. rate-limit / express-rate-limit) to block automated brute-force velocity probes.
 *   - Enforce rigorous JSON schema validation (e.g., using Joi or Zod) to filter malicious payloads before database interaction.
 *   - Secure endpoints using standard JWT (JSON Web Token) bearer authentication linked to active sessions.
 *   - Integrate automated API metrics reporting (Prometheus/Grafana) for dashboard visibility of fraud alert occurrences.
 */

const { detectFraud } = require('./fraudDetection');
const {
  saveTransaction,
  saveFraudResult,
  buildUserProfile,
  pool
} = require('./db');
const ragService = require('./src/services/ragService');
const llmService = require('./src/services/llmService');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Request Logger
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Global Error Handlers
process.on('uncaughtException', (err) => {
  console.error('FATAL ERROR:', err);
});

process.on('unhandledRejection', (err) => {
  console.error('UNHANDLED REJECTION:', err);
});

// Test route
app.get('/', (req, res) => {
  res.send('Backend running');
});


// ======================================================
// 🔥 FRAUD CHECK (PHASE 6)
// ======================================================
app.post('/fraud-check', async (req, res) => {
  console.log('--- Fraud Check Request ---');

  try {
    const { cus_id, txn } = req.body;

    if (!cus_id || !txn) {
      return res.status(400).json({
        success: false,
        error: '"cus_id" and "txn" are required'
      });
    }

    if (txn.amount == null || !txn.timestamp) {
      return res.status(400).json({
        success: false,
        error: 'Transaction must include amount and timestamp'
      });
    }

    // 1. Save transaction
    const transaction_id = await saveTransaction(cus_id, txn);
    console.log('Transaction saved:', transaction_id);

    // 2. Build profile (pass txn timestamp for dynamic rolling window query)
    const profile = await buildUserProfile(cus_id, txn.timestamp || new Date());

    // 3. Fraud detection
    const result = detectFraud(txn, profile);

    // 4. Save fraud alert (non-blocking)
    await saveFraudResult(transaction_id, result, cus_id)
      .catch(err => console.warn('Fraud save failed:', err.message));

    return res.json({
      success: true,
      data: result
    });

  } catch (err) {
    console.error('Fraud check error:', err);
    return res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});


// ======================================================
// 🤖 AI EXPLAIN (PHASE 5)
// ======================================================
app.post('/ai-explain', async (req, res) => {
  try {
    const { txn, fraud } = req.body;

    if (!txn || !fraud || !Array.isArray(fraud.reasons)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid input'
      });
    }

    const prompt = `
You are a banking fraud analyst.

Explain this transaction risk simply (2-3 sentences).

Amount: ₹${txn.amount}
Time: ${txn.timestamp}
Location: ${txn.location || 'Unknown'}
Risk Score: ${fraud.risk_score}/100
Reasons: ${fraud.reasons.join(', ')}
`;

    const explanation = await llmService.generateResponse(prompt);

    return res.json({
      success: true,
      explanation
    });

  } catch (err) {
    console.error('AI explain error:', err);
    return res.status(500).json({
      success: false,
      error: 'AI explanation failed'
    });
  }
});


// ======================================================
// Helper: Detect Intent using Hybrid Rules + Ollama llama3
// ======================================================
async function detectIntent(message) {
  const lower = message.toLowerCase();
  
  // Keyword overrides to guarantee correct intent detection
  if (lower.includes('balance') || lower.includes('savings') || lower.includes('how much money') || lower.includes('current balance') || lower.includes('my balance') || lower.includes('my savings')) {
    return 'BALANCE';
  }
  if (lower.includes('spend') || lower.includes('expense') || lower.includes('transactions') || lower.includes('transaction history') || lower.includes('expenditure') || lower.includes('spent')) {
    return 'SPENDING';
  }
  if (lower.includes('fraud') || lower.includes('flagged') || lower.includes('risk score') || lower.includes('severity') || lower.includes('unauthorized') || lower.includes('suspicious')) {
    return 'FRAUD';
  }
  if (lower.includes('security') || lower.includes('mfa') || lower.includes('velocity attack') || lower.includes('cyber') || lower.includes('overlay')) {
    return 'SECURITY';
  }

  const prompt = `Classify the user message into one of the following intents:
- BALANCE: For inquiries about account balance, checking how much money is in an account, or account limits/status.
- SPENDING: For inquiries about expenses, past transactions, where money was spent, or recent transaction history.
- FRAUD: For inquiries about fraud, flagged transactions, unrecognized charges, risk score, blocked accounts/cards, or transaction alerts.
- SECURITY: For security guidelines, password changes, dynamic limits, multi-factor authentication, or safety protocols.
- GENERAL_BANKING: For general questions about customer support, banking hours, finding ATMs, card services, or general inquiries.

Rules:
1. Choose exactly one intent from: BALANCE, SPENDING, FRAUD, SECURITY, GENERAL_BANKING.
2. Respond with ONLY the uppercase word of the detected intent. No explanations, no greeting, no extra text.

User message: "${message}"`;

  try {
    const responseText = await llmService.generateResponse(prompt);
    const detected = responseText.toUpperCase();
    const valid = ['BALANCE', 'SPENDING', 'FRAUD', 'SECURITY', 'GENERAL_BANKING'];
    for (const v of valid) {
      if (detected.includes(v)) return v;
    }
    return 'GENERAL_BANKING';
  } catch (err) {
    console.error('Intent detection error:', err.message);
    return 'GENERAL_BANKING';
  }
}

// ======================================================
// 🧠 AI CHAT (INTEGRATED INTENTS)
// ======================================================
app.post('/ai-chat', async (req, res) => {
  try {
    const { message, cus_id } = req.body;

    if (!message) {
      return res.status(400).json({
        success: false,
        error: 'message is required'
      });
    }

    console.log('AI Query:', message);

    const lower = message.toLowerCase();

    // 🛡️ 1. SECURITY FILTER: Detect Action Requests
    const actionKeywords = ['send', 'transfer', 'pay', 'invest', 'withdraw', 'deposit', 'purchase', 'buy', 'sell'];
    const isActionRequest = actionKeywords.some(word => lower.includes(word));

    if (isActionRequest) {
      console.log('SECURITY: Action request blocked');
      return res.json({
        success: true,
        reply: "I cannot perform transactions or actions like sending money or investing, but I can guide you on how to do it safely in the app. Please use the appropriate menus for these actions."
      });
    }

    // 🤖 2. Detect Intent
    const detectedIntent = await detectIntent(message);
    console.log(`Detected Intent: ${detectedIntent}`);

    // 📚 3. Always Retrieve Relevant Knowledge Chunks (RAG)
    const startRetTime = Date.now();
    const retrievedDocs = await ragService.search(message);
    const retrievalLatency = Date.now() - startRetTime;

    const retrievedKnowledge = retrievedDocs.length > 0
      ? retrievedDocs.map(c => `[Source: ${c.source}] ${c.text}`).join('\n\n')
      : 'No relevant banking knowledge found.';

    // 🔍 4. Conditional Context: Fraud Context (Only for FRAUD intent)
    let fraudData = 'No fraud data requested for this intent.';
    if (detectedIntent === 'FRAUD' && cus_id) {
      try {
        const txnRes = await pool.query(
          `SELECT * FROM transactions 
           WHERE cus_id = $1 
           ORDER BY created_at DESC 
           LIMIT 1`,
          [cus_id]
        );

        const txn = txnRes.rows[0];
        if (txn) {
          const profile = await buildUserProfile(cus_id);
          const txnData = {
            amount: txn.amount,
            timestamp: txn.created_at,
            location: txn.location,
            dailyTransactionCount: profile.dailyTransactionCount + 1
          };

          const fraud = detectFraud(txnData, profile);
          let severity = 'LOW';
          if (fraud.risk_score >= 70) severity = 'HIGH';
          else if (fraud.risk_score >= 30) severity = 'MEDIUM';

          fraudData = `Last Transaction Risk Score: ${fraud.risk_score}/100\nSeverity: ${severity}\nReasons: ${fraud.reasons.join(', ')}\nAmount: ₹${txn.amount}\nTime: ${txn.created_at}\nLocation: ${txn.location}`;
        } else {
          fraudData = 'No transactions found for this user.';
        }
      } catch (err) {
        console.warn('[RAG Integration] Fraud context fetch failed:', err.message);
        fraudData = 'Failed to fetch fraud context.';
      }
    }

    // 💰 5. Conditional Context: Account Context (Only for BALANCE / SPENDING intents)
    let accountData = 'No account data requested for this intent.';
    let accountContext = null; // structured object for prompt
    if ((detectedIntent === 'BALANCE' || detectedIntent === 'SPENDING') && cus_id) {
      try {
        // Fetch authenticated user info for debugging logs
        const userRes = await pool.query(
          `SELECT email, auth_user_id FROM users WHERE cus_id = $1`,
          [cus_id]
        );
        const authUser = userRes.rows[0] || { email: 'unknown', auth_user_id: 'unknown' };

        const queryText = `SELECT account_id, account_type, balance 
           FROM accounts 
           WHERE cus_id = $1`;
        const accountsRes = await pool.query(queryText, [cus_id]);

        // Sum all accounts — matches dashboard logic (home_screen.dart _buildCard)
        let totalBalance = 0;
        const balanceSummationCode = `
          let totalBalance = 0;
          const accountDetails = accountsRes.rows.map(row => {
            const bal = parseFloat(row.balance) || 0;
            totalBalance += bal;
            return { account_id: row.account_id, balance: bal };
          });
        `;

        const accountDetails = accountsRes.rows.map(row => {
          const bal = parseFloat(row.balance) || 0;
          totalBalance += bal;
          return {
            account_id: row.account_id,
            account_type: row.account_type,
            balance: bal
          };
        });

        console.log('\n[SAGE DEBUG]');
        console.log(`email=${authUser.email}`);
        console.log(`authenticated_user_id=${authUser.auth_user_id}`);
        console.log(`customerId=${cus_id}`);
        console.log(`queryExecuted=${queryText}`);
        console.log(`rawSupabaseResponse=`, JSON.stringify(accountsRes.rows));
        console.log(`accounts=`, JSON.stringify(accountDetails.map(a => ({ account_id: a.account_id, balance: a.balance }))));
        console.log(`balanceSummationCode=${balanceSummationCode.trim()}`);
        console.log(`totalBalance=${totalBalance}`);
        console.log('============================\n');

        if (accountsRes.rows.length > 0) {
          accountContext = {
            cus_id,
            total_balance: totalBalance,
            accounts: accountDetails
          };

          // Build human-readable context for the prompt
          const lines = accountDetails.map(a => {
            const typeLabel = a.account_type.charAt(0).toUpperCase() + a.account_type.slice(1);
            return `${typeLabel} Account (ID: ${a.account_id}): ₹${a.balance.toLocaleString('en-IN')}`;
          });
          lines.push(`Total Balance: ₹${totalBalance.toLocaleString('en-IN')}`);
          accountData = lines.join('\n');
        } else {
          accountData = 'No accounts found for this user.';
        }
      } catch (err) {
        console.warn('[RAG Integration] Account context fetch failed:', err.message);
        accountData = 'Failed to fetch account context.';
      }
    }

    // 🧠 6. Final SAGE Prompt Construction
    const prompt = `You are SAGE, an AI banking assistant.

User Question:
${message}

Account Information:
${accountContext ? JSON.stringify(accountContext) : accountData}

Fraud Context:
${fraudData}

Relevant Banking Knowledge:
${retrievedKnowledge}

Rules:
* If the user asks about their balance, savings, or account money, you MUST answer using ONLY the exact values from Account Information above.
* Report the Total Balance as the primary answer (e.g. "Your total account balance is ₹900,000.").
* If multiple accounts exist, also list individual account balances.
* NEVER invent, estimate, or round balances. Use the exact numbers from Account Information.
* NEVER say you cannot access account information.
* NEVER return generic banking explanations when account data is available.
* Never perform transactions.
* Never transfer money.
* Never invest on behalf of users.
* Only provide explanations and guidance.`;

    const promptSize = prompt.length;

    // 📊 7. Logging Metrics
    console.log('\n=========================================');
    console.log('🧠 SAGE Context Orchestration Metrics');
    console.log(`Detected Intent:       ${detectedIntent}`);
    console.log(`Retrieval Latency:     ${retrievalLatency}ms`);
    console.log(`Prompt Size (chars):   ${promptSize}`);
    console.log('Retrieved Chunks:');
    retrievedDocs.forEach((doc, idx) => {
      console.log(`  [${idx + 1}] Source: ${doc.source} | Score: ${doc.score.toFixed(4)}`);
    });
    console.log('=========================================');
    console.log('\n--- EXACT PROMPT SENT TO LLM ---');
    console.log(prompt);
    console.log('------------------------------------\n');

    const reply = await llmService.generateResponse(prompt);

    return res.json({
      success: true,
      reply
    });

  } catch (err) {
    console.error('AI chat error:', err);
    return res.status(500).json({
      success: false,
      error: 'AI chat failed'
    });
  }
});

// ======================================================
// 🔍 STANDALONE RETRIEVAL API (RAG-SEARCH)
// ======================================================
app.post('/rag-search', async (req, res) => {
  const { query } = req.body;
  if (!query) {
    return res.status(400).json({
      success: false,
      error: 'query is required'
    });
  }

  const startTime = Date.now();
  console.log(`[RAG Search API] Received query: "${query}"`);

  try {
    const results = await ragService.search(query);
    const latency = Date.now() - startTime;
    console.log(`[RAG Search API] Success: Returned ${results.length} chunks. Latency: ${latency}ms`);

    return res.json({
      success: true,
      results: results.map(r => ({
        score: r.score,
        source: r.source,
        chunk_index: r.chunk_index,
        text: r.text
      }))
    });
  } catch (err) {
    const latency = Date.now() - startTime;
    console.error(`[RAG Search API] Failed search for query: "${query}" after ${latency}ms. Error:`, err.message || err);
    return res.status(500).json({
      success: false,
      error: 'RAG search failed'
    });
  }
});


// ======================================================
// 📈 INVESTMENT MARKET DATA (FREE APIs)
// ======================================================
const { getStocks } = require('./services/stockService');
const { getMutualFunds } = require('./services/mutualFundService');
const { getOptionChains } = require('./services/optionChainService');
const { getIPOs } = require('./services/ipoService');

// GET /api/investments/stocks
app.get('/api/investments/stocks', async (req, res) => {
  try {
    const stocks = await getStocks();
    return res.json(stocks);
  } catch (err) {
    console.error('Stocks API error:', err);
    return res.status(500).json({ error: 'Failed to fetch stock data' });
  }
});

// GET /api/investments/funds
app.get('/api/investments/funds', async (req, res) => {
  try {
    const funds = await getMutualFunds();
    return res.json(funds);
  } catch (err) {
    console.error('Funds API error:', err);
    return res.status(500).json({ error: 'Failed to fetch mutual fund data' });
  }
});

// GET /api/investments/options
app.get('/api/investments/options', async (req, res) => {
  try {
    const options = await getOptionChains();
    return res.json(options);
  } catch (err) {
    console.error('Options API error:', err);
    return res.status(500).json({ error: 'Failed to fetch option chain data' });
  }
});

// GET /api/investments/ipos
app.get('/api/investments/ipos', async (req, res) => {
  try {
    const ipos = await getIPOs();
    return res.json(ipos);
  } catch (err) {
    console.error('IPOs API error:', err);
    return res.status(500).json({ error: 'Failed to fetch IPO data' });
  }
});


// ======================================================
// 🏥 HEALTH CHECK
// ======================================================
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// ======================================================
// 🚀 START SERVER
// ======================================================
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on http://0.0.0.0:${PORT}`);
});