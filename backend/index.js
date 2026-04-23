const express = require('express');
const cors = require('cors');
require('dotenv').config();
const axios = require('axios');

const { detectFraud } = require('./fraudDetection');
const {
  saveTransaction,
  saveFraudResult,
  buildUserProfile,
  pool
} = require('./db');

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

    // 2. Build profile
    const profile = await buildUserProfile(cus_id);

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

    const ollamaRes = await axios.post(
      'http://localhost:11434/api/generate',
      {
        model: 'llama3',
        prompt,
        stream: false
      }
    );

    return res.json({
      success: true,
      explanation: ollamaRes.data.response.trim()
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

    let context = '';
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

    // 🔍 2. Detect Informational Intents
    const isFraudQuery = lower.includes('risk') || lower.includes('fraud') || lower.includes('suspicious');
    const isBalanceQuery = lower.includes('balance') || lower.includes('saving') || lower.includes('account');
    const isSpendingQuery = lower.includes('spend') || lower.includes('spent');

    // 💰 3. Fetch Data: BALANCE / SAVINGS
    if (isBalanceQuery && cus_id) {
      try {
        const balanceRes = await pool.query(
          `SELECT SUM(amount) as balance 
           FROM transactions 
           WHERE cus_id = $1 AND status = 'successful'`,
          [cus_id]
        );
        const balance = balanceRes.rows[0]?.balance || 0;
        context += `User balance: ₹${balance}\n`;
      } catch (err) {
        console.warn('Balance fetch failed:', err.message);
      }
    }

    // 📊 4. Fetch Data: SPENDING (LAST 7 DAYS)
    if (isSpendingQuery && cus_id) {
      try {
        const spendingRes = await pool.query(
          `SELECT SUM(amount) as spent 
           FROM transactions 
           WHERE cus_id = $1 
           AND created_at >= CURRENT_DATE - INTERVAL '7 days'`,
          [cus_id]
        );
        const spent = spendingRes.rows[0]?.spent || 0;
        context += `User spent this week: ₹${spent}\n`;
      } catch (err) {
        console.warn('Spending fetch failed:', err.message);
      }
    }

    // 🔍 5. Fetch Data: FRAUD / LAST TRANSACTION
    if (isFraudQuery && cus_id) {
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
          context += `
Last Transaction Risk Data:
Amount: ₹${txn.amount}
Time: ${txn.created_at}
Risk Score: ${fraud.risk_score}/100
Reasons: ${fraud.reasons.join(', ')}
          `;
        }
      } catch (err) {
        console.warn('Fraud context fetch failed:', err.message);
      }
    }

    // 🧠 6. Final AI Prompt (Hardened Security)
    const prompt = `
You are SAGE, a smart banking assistant for Secure Wealth.

IMPORTANT RULES:
- You CANNOT perform any actions like sending money, investing, or transactions.
- You DO NOT execute requests for financial transfers.
- You ONLY explain, guide, and provide insights.
- If user asks for an action, politely refuse and guide them to the app menu.

User question:
"${message}"

${context ? `Data:\n${context}` : ''}

Behavior:
- If user asks about data -> answer using provided data accurately.
- Keep response short (2-3 sentences).
`;

    const ollamaRes = await axios.post(
      'http://localhost:11434/api/generate',
      {
        model: 'llama3',
        prompt,
        stream: false
      }
    );

    return res.json({
      success: true,
      reply: ollamaRes.data.response.trim()
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
// 🚀 START SERVER
// ======================================================
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on http://0.0.0.0:${PORT}`);
});