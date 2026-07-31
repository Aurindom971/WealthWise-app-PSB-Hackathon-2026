const express = require('express');
const cors = require('cors');
require('dotenv').config();
const axios = require('axios');

const app = express();
app.use(express.json());
app.use(cors());

const PORT = process.env.PORT || 5000;
const { detectFraud } = require('./fraudDetection');
const {
  saveTransaction,
  saveFraudResult,
  buildUserProfile,
  pool
} = require('./db');
const ragService = require('./src/services/ragService');
const llmService = require('./src/services/llmService');
const financialInsightsService = require('./src/services/financialInsightsService');
const financialHealthService = require('./src/services/financialHealthService');
const suspiciousTransactionService = require('./src/services/suspiciousTransactionService');

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
// 🔐 AUTHENTICATION & SESSION TOKENS (PHASE 12 / 16)
// ======================================================
const authController = require('./controllers/authController');
const { sessionMiddleware } = require('./middleware/sessionMiddleware');
app.post('/login', authController.login);
app.post('/logout', sessionMiddleware, authController.logout);
app.post('/refresh-session', sessionMiddleware, authController.refreshSession);

// ======================================================
// 🔒 KYC VERIFICATION ENDPOINTS
// ======================================================
const kycController = require('./controllers/kycController');
app.post('/kyc/save', kycController.saveKyc);
app.get('/kyc/status/:cus_id', kycController.getKycStatus);
app.get('/kyc/status', kycController.getKycStatus);
app.delete('/kyc/delete/:cus_id', kycController.deleteKyc);
app.post('/kyc/delete/:cus_id', kycController.deleteKyc);


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


// ================================================// Helper: Detect Intent using Hybrid Rules + LLM
// ======================================================
async function detectIntent(message) {
  const lower = message.toLowerCase();
  
  // Keyword overrides to guarantee correct intent detection
  if (lower.includes('savings advice') || lower.includes('save money') || lower.includes('saving advice') || lower.includes('savings recommendations') || lower.includes('overspending advice') || lower.includes('how can i save')) {
    return 'SAVINGS_ADVICE';
  }
  if (lower.includes('financial health') || lower.includes('healthy are my finances') || lower.includes('financial score') || lower.includes('health score') || lower.includes('finances healthy') || lower.includes('financial health score')) {
    return 'FINANCIAL_HEALTH';
  }
  if (lower.includes('suspicious transactions') || lower.includes('show suspicious') || lower.includes('suspicious charges') || lower.includes('suspicious transaction')) {
    return 'SUSPICIOUS_TRANSACTIONS';
  }
  if (lower.includes('why was my transaction flagged') || lower.includes('why was my payment flagged') || lower.includes('explain risk score') || lower.includes('fraud factors') || lower.includes('why flagged') || lower.includes('flagged as fraudulent') || lower.includes('explain fraud alert')) {
    return 'FRAUD_EXPLAINABILITY';
  }
  if (lower.includes('highest expenses') || lower.includes('top expenses') || lower.includes('largest expenses') || lower.includes('largest transactions') || lower.includes('highest spending') || lower.includes('highest transaction')) {
    return 'TOP_EXPENSES';
  }
  if (lower.includes('expense breakdown') || lower.includes('breakdown by category') || lower.includes('spending by category') || lower.includes('spending category') || lower.includes('expenses categories') || lower.includes('expense categories')) {
    return 'EXPENSE_BREAKDOWN';
  }
  if (lower.includes('spend this week') || lower.includes('spending this week') || lower.includes('spend this month') || lower.includes('spending this month') || lower.includes('how much did i spend') || lower.includes('spending trend') || lower.includes('spending analysis')) {
    return 'SPENDING_ANALYSIS';
  }
  if (lower.includes('investment summary') || lower.includes('what are my investments') || lower.includes('list my assets') || lower.includes('my investment portfolio') || lower.includes('show investments') || lower.includes('my asset details') || lower.includes('investment information')) {
    return 'INVESTMENT_SUMMARY';
  }
  if (lower.includes('balance') || lower.includes('savings') || lower.includes('how much money') || lower.includes('current balance') || lower.includes('my balance') || lower.includes('my savings')) {
    return 'BALANCE';
  }
  if (lower.includes('spend') || lower.includes('expense') || lower.includes('transactions') || lower.includes('transaction history') || lower.includes('expenditure') || lower.includes('spent')) {
    return 'SPENDING_ANALYSIS';
  }
  if (lower.includes('fraud') || lower.includes('flagged') || lower.includes('risk score') || lower.includes('severity') || lower.includes('unauthorized') || lower.includes('suspicious')) {
    return 'FRAUD_EXPLAINABILITY';
  }
  if (lower.includes('security') || lower.includes('mfa') || lower.includes('velocity attack') || lower.includes('cyber') || lower.includes('overlay')) {
    return 'SECURITY';
  }

  const prompt = `Classify the user message into one of the following intents:
- BALANCE: For inquiries about account balance, checking how much money is in an account.
- SPENDING_ANALYSIS: For overall spending over time, weekly/monthly spending trends.
- EXPENSE_BREAKDOWN: For category breakdown of expenses.
- TOP_EXPENSES: For highest debit transactions.
- SAVINGS_ADVICE: For recommendations on how to save, overspending detection, subscription tracking.
- SUSPICIOUS_TRANSACTIONS: For identifying high-risk or unusual transactions.
- FRAUD_EXPLAINABILITY: For detailing why a transaction was flagged as fraudulent.
- INVESTMENT_SUMMARY: For investment holdings and asset totals.
- FINANCIAL_HEALTH: For overall health score assessment.
- SECURITY: For security guidelines, multi-factor authentication, or safety protocols.
- GENERAL_BANKING: For general questions.

Rules:
1. Choose exactly one intent from the list above.
2. Respond with ONLY the uppercase word of the detected intent. No explanations, no greeting, no extra text.

User message: "${message}"`;

  try {
    const responseText = await llmService.generateResponse(prompt);
    const detected = responseText.toUpperCase();
    const valid = [
      'BALANCE', 'SPENDING_ANALYSIS', 'EXPENSE_BREAKDOWN', 'TOP_EXPENSES',
      'SAVINGS_ADVICE', 'SUSPICIOUS_TRANSACTIONS', 'FRAUD_EXPLAINABILITY',
      'INVESTMENT_SUMMARY', 'FINANCIAL_HEALTH', 'SECURITY', 'GENERAL_BANKING'
    ];
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

    // 🛡️ 1. SECURITY FILTER: Detect Action Requests (not informational/advisory queries)
    const actionKeywords = ['send', 'transfer', 'pay', 'invest', 'withdraw', 'deposit', 'purchase', 'buy', 'sell'];
    
    // Check if the user is asking a question or seeking advice/information rather than executing an action
    const isInformational = /\b(should|how|what|why|which|whether|recommend|suggest|advice|opinion|tell|explain|predict|forecast|info|analysis|compare|difference|list|show|view|status|eligibility)\b/.test(lower);
    
    const isActionRequest = actionKeywords.some(word => lower.includes(word)) && !isInformational;

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

    // 🔍 Context Variables
    let accountData = 'No account details fetched.';
    let accountContextObj = null;
    let spendingAnalysisContext = 'No spending analysis requested.';
    let expenseBreakdownContext = 'No expense category breakdown requested.';
    let topExpensesContext = 'No top expenses list requested.';
    let savingsAdviceContext = 'No savings advice requested.';
    let suspiciousTransactionsContext = 'No suspicious transactions list requested.';
    let fraudExplainabilityContext = 'No fraud explainability context requested.';
    let investmentSummaryContext = 'No investment summary requested.';
    let financialHealthContext = 'No financial health score requested.';

    // 💰 Query accounts if cus_id is available (used for BALANCE, SAVINGS_ADVICE, FINANCIAL_HEALTH, etc.)
    if (cus_id) {
      try {
        const accountsRes = await pool.query(
          `SELECT account_id, account_type, balance FROM accounts WHERE cus_id = $1`,
          [cus_id]
        );
        let totalBalance = 0;
        const accountDetails = accountsRes.rows.map(row => {
          const bal = parseFloat(row.balance) || 0;
          totalBalance += bal;
          return {
            account_id: row.account_id,
            account_type: row.account_type,
            balance: bal
          };
        });
        if (accountsRes.rows.length > 0) {
          accountContextObj = {
            cus_id,
            total_balance: totalBalance,
            accounts: accountDetails
          };
          const lines = accountDetails.map(a => {
            const typeLabel = a.account_type.charAt(0).toUpperCase() + a.account_type.slice(1);
            return `${typeLabel} Account (ID: ${a.account_id}): ₹${a.balance.toLocaleString('en-IN')}`;
          });
          lines.push(`Total Balance: ₹${totalBalance.toLocaleString('en-IN')}`);
          accountData = lines.join('\n');
        } else {
          accountData = 'No accounts found for this user.';
        }

        // --- DYNAMIC INTENT CONTEXT AGGREGATION ---
        
        // 1. SPENDING_ANALYSIS
        if (detectedIntent === 'SPENDING_ANALYSIS') {
          const weekly = await financialInsightsService.getWeeklySpending(cus_id);
          const monthly = await financialInsightsService.getMonthlySpending(cus_id);
          const avgDaily = await financialInsightsService.getAverageDailySpend(cus_id);
          spendingAnalysisContext = `
Weekly Spending:
- Current Week: ₹${weekly.totalSpent.toLocaleString('en-IN')}
- Previous Week: ₹${weekly.previousSpent.toLocaleString('en-IN')}
- Trend: ${weekly.differencePercent}% ${weekly.trend} than previous week

Monthly Spending:
- Current Month: ₹${monthly.totalSpent.toLocaleString('en-IN')}
- Previous Month: ₹${monthly.previousSpent.toLocaleString('en-IN')}
- Trend: ${monthly.differencePercent}% ${monthly.trend} than previous month

Average Daily Spend:
- ₹${avgDaily.toLocaleString('en-IN')}/day (calculated over the last 30 days)
`.trim();
        }

        // 2. EXPENSE_BREAKDOWN
        if (detectedIntent === 'EXPENSE_BREAKDOWN') {
          const breakdown = await financialInsightsService.getCategoryBreakdown(cus_id);
          expenseBreakdownContext = breakdown.length > 0
            ? breakdown.map(b => `${b.category}: ₹${b.amount.toLocaleString('en-IN')}`).join('\n')
            : 'No expense category records found for the last 30 days.';
        }

        // 3. TOP_EXPENSES
        if (detectedIntent === 'TOP_EXPENSES') {
          const top = await financialInsightsService.getTopExpenses(cus_id);
          topExpensesContext = top.length > 0
            ? top.map((t, i) => `${i + 1}. ${t.merchant}: ₹${t.amount.toLocaleString('en-IN')} [${t.category}] (${new Date(t.date).toLocaleDateString()})`).join('\n')
            : 'No expense records found.';
        }

        // 4. SAVINGS_ADVICE
        if (detectedIntent === 'SAVINGS_ADVICE') {
          const bal = accountContextObj ? accountContextObj.total_balance : 0;
          const savings = await financialInsightsService.getSavingsInsights(cus_id, bal);
          
          let overspendStr = 'No category overspending trends detected.';
          if (savings.overspending.length > 0) {
            overspendStr = savings.overspending.map(o => `- ${o.category} spending increased by ${o.increasePercent}% (+₹${o.amountIncrease.toLocaleString('en-IN')})`).join('\n');
          }

          let subStr = 'No recurring subscriptions detected.';
          if (savings.subscriptions.length > 0) {
            subStr = savings.subscriptions.map(s => `- ${s.name}: ₹${s.amount.toLocaleString('en-IN')}/month`).join('\n');
          }

          savingsAdviceContext = `
Overspending Trends (MoM):
${overspendStr}

Detected Monthly Subscriptions:
${subStr}
- Total Subscription Spending: ₹${savings.totalRecurringSpend.toLocaleString('en-IN')}/month

Savings Opportunity:
- Reducing discretionary categories by 15% could save ₹${savings.discretionarySavingsOpportunity.toLocaleString('en-IN')}/month.

Emergency Fund Runway:
- Runway: ${savings.emergencyRunwayMonths} months of spending covered.
- Liquid Cash Balance: ₹${bal.toLocaleString('en-IN')}
- Average Monthly Outflow: ₹${savings.averageMonthlySpend.toLocaleString('en-IN')}
`.trim();
        }

        // 5. SUSPICIOUS_TRANSACTIONS
        if (detectedIntent === 'SUSPICIOUS_TRANSACTIONS') {
          const suspicious = await suspiciousTransactionService.detectSuspiciousTransactions(cus_id);
          suspiciousTransactionsContext = suspicious.length > 0
            ? suspicious.map(s => `
Transaction ID: ${s.transaction_id}
- Merchant: ${s.merchant}
- Amount: ₹${s.amount.toLocaleString('en-IN')}
- Risk Score: ${s.riskScore}/100
- Reasons: ${s.reasons.join(', ')}
- Location: ${s.location}
- Date: ${new Date(s.date).toLocaleDateString()}
`.trim()).join('\n\n')
            : 'No suspicious transactions detected.';
        }

        // 6. FRAUD_EXPLAINABILITY
        if (detectedIntent === 'FRAUD_EXPLAINABILITY') {
          const profile = await buildUserProfile(cus_id);
          const txnRes = await pool.query(
            `SELECT * FROM transactions WHERE cus_id = $1 ORDER BY created_at DESC LIMIT 1`,
            [cus_id]
          );
          const txn = txnRes.rows[0];
          if (txn) {
            const amount = Math.abs(parseFloat(txn.amount)) || 0;
            const txnData = {
              amount,
              timestamp: txn.created_at,
              location: txn.location,
              dailyTransactionCount: profile.dailyTransactionCount + 1
            };
            const fraud = detectFraud(txnData, profile);
            
            // Reconstruct scoring rules
            const contributionList = [];
            let simulatedScore = 0;

            // Geo-velocity mismatch
            if (txn.location && txn.location.toLowerCase() !== 'unknown') {
              const locationsQuery = `SELECT DISTINCT LOWER(city) FROM location_history WHERE cus_id = $1`;
              const locs = await pool.query(locationsQuery, [cus_id]);
              const cities = locs.rows.map(r => r.lower);
              if (cities.length > 0 && !cities.includes(txn.location.toLowerCase())) {
                simulatedScore += 25;
                contributionList.push(`✓ Unusual Location Mismatch (+25)`);
              }
            }

            // High Amount Outlier
            if (amount > profile.avgTransactionAmount + 3 * profile.stdDevAmount) {
              simulatedScore += 40;
              contributionList.push(`✓ Critical Transaction Amount Outlier (+40)`);
            } else if (amount > profile.avgTransactionAmount + 2 * profile.stdDevAmount) {
              simulatedScore += 20;
              contributionList.push(`✓ Elevated Transaction Amount (+20)`);
            }

            // Rapid velocity bursts
            if (profile.recentTransactions && profile.recentTransactions.length >= 2) {
              simulatedScore += 25;
              contributionList.push(`✓ Velocity burst detected (+25)`);
            }

            // Match active system alert flag
            const alertRes = await pool.query(`SELECT 1 FROM fraud_alerts WHERE transaction_id = $1`, [txn.transaction_id]);
            if (alertRes.rows.length > 0) {
              simulatedScore = Math.max(simulatedScore, 75);
              contributionList.push(`✓ Behavioral engine auto-flag alert matched (+50)`);
            }

            const finalRisk = Math.min(100, fraud.risk_score || simulatedScore);
            let severity = 'LOW';
            if (finalRisk >= 70) severity = 'HIGH';
            else if (finalRisk >= 30) severity = 'MEDIUM';

            fraudExplainabilityContext = `
Flagged Transaction Details:
- Transaction ID: ${txn.transaction_id}
- Merchant/Counterparty: ${txn.counterparty_name || 'Unknown'}
- Amount: ₹${amount.toLocaleString('en-IN')}
- Date: ${new Date(txn.created_at).toLocaleString()}
- Location: ${txn.location || 'Unknown'}

Fraud Score & Rules Breakdown:
- Risk Score: ${finalRisk}/100
- Severity Level: ${severity}
- Contributing Rule Matches:
${contributionList.length > 0 ? contributionList.join('\n') : '- No rule contributions computed (Low Risk)'}
- Heuristics: Average standard amount was ₹${Math.round(profile.avgTransactionAmount).toLocaleString('en-IN')} (StdDev: ₹${Math.round(profile.stdDevAmount).toLocaleString('en-IN')})
`.trim();
          } else {
            fraudExplainabilityContext = 'No transactions found to explain.';
          }
        }

        // 7. INVESTMENT_SUMMARY
        if (detectedIntent === 'INVESTMENT_SUMMARY') {
          const invRes = await pool.query(
            `SELECT investment_type, asset_name, amount FROM investments WHERE cus_id = $1`,
            [cus_id]
          );
          if (invRes.rows.length > 0) {
            let totalInv = 0;
            const lines = invRes.rows.map(r => {
              const amt = parseFloat(r.amount) || 0;
              totalInv += amt;
              return `- ${r.asset_name} (${r.investment_type}): ₹${amt.toLocaleString('en-IN')}`;
            });
            lines.unshift(`Total Portfolio Assets: ₹${totalInv.toLocaleString('en-IN')}`);
            investmentSummaryContext = lines.join('\n');
          } else {
            investmentSummaryContext = 'No investment assets found for this portfolio.';
          }
        }

        // 8. FINANCIAL_HEALTH
        if (detectedIntent === 'FINANCIAL_HEALTH') {
          const health = await financialHealthService.calculateFinancialHealth(cus_id);
          financialHealthContext = `
Financial Health Score: ${health.score}/100

Key Financial Strengths:
${health.strengths.length > 0 ? health.strengths.map(s => `✓ ${s}`).join('\n') : '- None identified'}

Areas for Improvement (Weaknesses):
${health.weaknesses.length > 0 ? health.weaknesses.map(w => `⚠ ${w}`).join('\n') : '- None identified'}

Metrics:
- Monthly Outflows: ₹${health.metrics.monthlySpend.toLocaleString('en-IN')}
- Monthly Inflows: ₹${health.metrics.monthlyInflow.toLocaleString('en-IN')}
- Outstanding Debts: ₹${health.metrics.totalDebt.toLocaleString('en-IN')}
- Active Investments: ₹${health.metrics.totalInvestments.toLocaleString('en-IN')}
- Liquidity Cushion: Covers ${health.metrics.emergencyRunwayMonths} months
`.trim();
        }

      } catch (err) {
        console.warn('[Copilot Context Integration] Aggregation failed:', err.message);
      }
    }

    const intent = detectedIntent;
    const insights = {
      spendingAnalysis: spendingAnalysisContext,
      expenseBreakdown: expenseBreakdownContext,
      topExpenses: topExpensesContext,
      savingsAdvice: savingsAdviceContext,
      financialHealth: financialHealthContext
    };
    const fraudData = {
      suspiciousTransactions: suspiciousTransactionsContext,
      fraudExplainability: fraudExplainabilityContext
    };

    console.log("Detected Intent:", intent);
    console.log("Financial Insights:", insights);
    console.log("Fraud Context:", fraudData);
    console.log("Account Context:", accountData);

    // 🧠 6. Upgraded SAGE Prompt Construction
    const prompt = `You are SAGE, an AI Financial Copilot.

User Question:
${message}

=== CONTEXT ===

Account Information:
${accountContextObj ? JSON.stringify(accountContextObj) : accountData}

Weekly/Monthly Spending Analysis:
${spendingAnalysisContext}

Expense Categories Breakdown:
${expenseBreakdownContext}

Top 10 Largest Expenses:
${topExpensesContext}

Savings Advisor Insights:
${savingsAdviceContext}

Suspicious Transaction Detection:
${suspiciousTransactionsContext}

Fraud Explainability Details:
${fraudExplainabilityContext}

Investment Holdings Summary:
${investmentSummaryContext}

Financial Health Score & Assessment:
${financialHealthContext}

Relevant Banking & Security Knowledge (RAG Docs):
${retrievedKnowledge}

=== RULES ===
* You MUST answer user questions using the actual, live data provided in the CONTEXT sections above.
* Report the overall total account balance primarily if queried about balance (e.g. "Your total account balance is ₹900,000.").
* Do NOT mention, list, or disclose the user's account balance, savings, investments, or other personal financial figures in greetings (like "hello"), general banking questions, or topics unrelated to their account status.
* Never invent, estimate, or round balances, transaction records, risk scores, or spending figures. Always use exact numbers.
* Never say you cannot access account or transaction data if it is populated in the context above.
* Never return generic answers when live financial analysis data is present.
* Strictly enforce safety limits: SAGE cannot perform transactions, transfer money, or invest on behalf of users. Only provide explanations, analysis, and recommendations.`;

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
// 📊 FINANCIAL COPILOT ENDPOINTS (PHASE H)
// ======================================================

// 1. POST /financial-insights
app.post('/financial-insights', sessionMiddleware, async (req, res) => {
  const { cus_id } = req.body;
  if (!cus_id) {
    return res.status(400).json({ success: false, error: 'cus_id is required' });
  }
  try {
    const weekly = await financialInsightsService.getWeeklySpending(cus_id);
    const monthly = await financialInsightsService.getMonthlySpending(cus_id);
    const avgDaily = await financialInsightsService.getAverageDailySpend(cus_id);
    return res.json({
      success: true,
      data: { weekly, monthly, averageDailySpend: avgDaily }
    });
  } catch (err) {
    console.error('Error fetching financial insights:', err);
    return res.status(500).json({ success: false, error: err.message });
  }
});

// 2. POST /financial-health
app.post('/financial-health', sessionMiddleware, async (req, res) => {
  const { cus_id } = req.body;
  if (!cus_id) {
    return res.status(400).json({ success: false, error: 'cus_id is required' });
  }
  try {
    const health = await financialHealthService.calculateFinancialHealth(cus_id);
    return res.json({ success: true, data: health });
  } catch (err) {
    console.error('Error calculating financial health:', err);
    return res.status(500).json({ success: false, error: err.message });
  }
});

// 3. POST /suspicious-transactions
app.post('/suspicious-transactions', sessionMiddleware, async (req, res) => {
  const { cus_id } = req.body;
  if (!cus_id) {
    return res.status(400).json({ success: false, error: 'cus_id is required' });
  }
  try {
    const suspicious = await suspiciousTransactionService.detectSuspiciousTransactions(cus_id);
    return res.json({ success: true, data: suspicious });
  } catch (err) {
    console.error('Error fetching suspicious transactions:', err);
    return res.status(500).json({ success: false, error: err.message });
  }
});

// 4. POST /expense-analysis
app.post('/expense-analysis', sessionMiddleware, async (req, res) => {
  const { cus_id } = req.body;
  if (!cus_id) {
    return res.status(400).json({ success: false, error: 'cus_id is required' });
  }
  try {
    const categories = await financialInsightsService.getCategoryBreakdown(cus_id);
    const topExpenses = await financialInsightsService.getTopExpenses(cus_id);
    return res.json({ success: true, data: { categories, topExpenses } });
  } catch (err) {
    console.error('Error fetching expense analysis:', err);
    return res.status(500).json({ success: false, error: err.message });
  }
});

// 5. POST /savings-advice
app.post('/savings-advice', sessionMiddleware, async (req, res) => {
  const { cus_id } = req.body;
  if (!cus_id) {
    return res.status(400).json({ success: false, error: 'cus_id is required' });
  }
  try {
    const accountsRes = await pool.query(
      `SELECT COALESCE(SUM(balance), 0) as balance FROM accounts WHERE cus_id = $1`,
      [cus_id]
    );
    const totalBalance = parseFloat(accountsRes.rows[0].balance) || 0;
    const savings = await financialInsightsService.getSavingsInsights(cus_id, totalBalance);
    return res.json({ success: true, data: savings });
  } catch (err) {
    console.error('Error fetching savings advice:', err);
    return res.status(500).json({ success: false, error: err.message });
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
app.get('/api/investments/stocks', sessionMiddleware, async (req, res) => {
  try {
    const stocks = await getStocks();
    return res.json(stocks);
  } catch (err) {
    console.error('Stocks API error:', err);
    return res.status(500).json({ error: 'Failed to fetch stock data' });
  }
});

// GET /api/investments/funds
app.get('/api/investments/funds', sessionMiddleware, async (req, res) => {
  try {
    const funds = await getMutualFunds();
    return res.json(funds);
  } catch (err) {
    console.error('Funds API error:', err);
    return res.status(500).json({ error: 'Failed to fetch mutual fund data' });
  }
});

// GET /api/investments/options
app.get('/api/investments/options', sessionMiddleware, async (req, res) => {
  try {
    const options = await getOptionChains();
    return res.json(options);
  } catch (err) {
    console.error('Options API error:', err);
    return res.status(500).json({ error: 'Failed to fetch option chain data' });
  }
});

// GET /api/investments/ipos
app.get('/api/investments/ipos', sessionMiddleware, async (req, res) => {
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