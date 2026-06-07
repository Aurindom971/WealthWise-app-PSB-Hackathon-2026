const { pool } = require('../../db');

/**
 * Calculates a comprehensive Financial Health Score (0-100) for a customer.
 */
async function calculateFinancialHealth(cusId) {
  // 1. Fetch Total Balance from accounts
  const accountsQuery = `
    SELECT COALESCE(SUM(balance), 0) as balance 
    FROM accounts 
    WHERE cus_id = $1
  `;
  
  // 2. Fetch Total Outstanding Debt from loans
  const loansQuery = `
    SELECT COALESCE(SUM(outstanding_amount), 0) as debt 
    FROM loans 
    WHERE cus_id = $1
  `;

  // 3. Fetch Total Assets from investments
  const investmentsQuery = `
    SELECT COALESCE(SUM(amount), 0) as assets 
    FROM investments 
    WHERE cus_id = $1
  `;

  // 4. Fetch Monthly Outflows (Debits) and Inflows (Credits)
  // Get max date to align with our transaction date anchoring
  const maxDateQuery = `SELECT MAX(created_at) as max_date FROM transactions WHERE cus_id = $1`;

  const [accRes, loanRes, invRes, maxDateRes] = await Promise.all([
    pool.query(accountsQuery, [cusId]),
    pool.query(loansQuery, [cusId]),
    pool.query(investmentsQuery, [cusId]),
    pool.query(maxDateQuery, [cusId])
  ]);

  const totalBalance = parseFloat(accRes.rows[0].balance) || 0;
  const totalDebt = parseFloat(loanRes.rows[0].debt) || 0;
  const totalInvestments = parseFloat(invRes.rows[0].assets) || 0;
  
  const refDate = maxDateRes.rows[0].max_date ? new Date(maxDateRes.rows[0].max_date) : new Date();
  const refDateStr = refDate.toISOString();

  // Outflows (last 30 days)
  const outflowQuery = `
    SELECT COALESCE(SUM(ABS(amount)), 0) as total
    FROM transactions
    WHERE cus_id = $1
      AND (transaction_type = 'debit' OR amount < 0)
      AND created_at >= $2::timestamp - INTERVAL '30 days'
      AND created_at <= $2::timestamp
  `;

  // Outflows (previous 30 days)
  const prevOutflowQuery = `
    SELECT COALESCE(SUM(ABS(amount)), 0) as total
    FROM transactions
    WHERE cus_id = $1
      AND (transaction_type = 'debit' OR amount < 0)
      AND created_at >= $2::timestamp - INTERVAL '60 days'
      AND created_at < $2::timestamp - INTERVAL '30 days'
  `;

  // Inflows (last 30 days)
  const inflowQuery = `
    SELECT COALESCE(SUM(amount), 0) as total
    FROM transactions
    WHERE cus_id = $1
      AND (transaction_type = 'credit' OR amount > 0)
      AND created_at >= $2::timestamp - INTERVAL '30 days'
      AND created_at <= $2::timestamp
  `;

  const [outflowRes, prevOutflowRes, inflowRes] = await Promise.all([
    pool.query(outflowQuery, [cusId, refDateStr]),
    pool.query(prevOutflowQuery, [cusId, refDateStr]),
    pool.query(inflowQuery, [cusId, refDateStr])
  ]);

  const monthlySpend = parseFloat(outflowRes.rows[0].total) || 0;
  const prevMonthlySpend = parseFloat(prevOutflowRes.rows[0].total) || 0;
  const monthlyInflow = parseFloat(inflowRes.rows[0].total) || 0;

  // SCORING LOGIC (Each worth up to 20 points, total 100)
  let savingsRateScore = 10;
  let debtLoadScore = 20;
  let emergencyRunwayScore = 5;
  let investmentRatioScore = 5;
  let spendingStabilityScore = 15;

  const strengths = [];
  const weaknesses = [];

  // A. Savings Rate (20 pts)
  // Let's use dynamic inflow/outflow savings rate or fallback based on balances
  const netSavings = monthlyInflow - monthlySpend;
  const savingsRate = monthlyInflow > 0 ? (netSavings / monthlyInflow) * 100 : 0;
  
  if (monthlyInflow > 0) {
    if (savingsRate >= 20) {
      savingsRateScore = 20;
      strengths.push('High monthly savings rate (>20%)');
    } else if (savingsRate >= 10) {
      savingsRateScore = 15;
      strengths.push('Healthy monthly savings rate (10-20%)');
    } else if (savingsRate > 0) {
      savingsRateScore = 10;
    } else {
      savingsRateScore = 5;
      weaknesses.push('Outflows exceed monthly income');
    }
  } else {
    // Fallback: If no inflow recorded, judge based on balance vs monthly spend
    if (totalBalance > monthlySpend * 6) {
      savingsRateScore = 20;
      strengths.push('Large liquid cash cushion relative to expenses');
    } else if (totalBalance > monthlySpend * 3) {
      savingsRateScore = 15;
    } else {
      savingsRateScore = 10;
      weaknesses.push('Low cash reserves relative to monthly spending');
    }
  }

  // B. Debt Load (20 pts)
  const netWorth = totalBalance + totalInvestments;
  if (totalDebt === 0) {
    debtLoadScore = 20;
    strengths.push('Completely debt-free');
  } else {
    const debtRatio = (totalDebt / (netWorth + 1)) * 100;
    if (debtRatio <= 20) {
      debtLoadScore = 18;
      strengths.push('Very manageable debt-to-asset ratio');
    } else if (debtRatio <= 50) {
      debtLoadScore = 12;
    } else {
      debtLoadScore = 6;
      weaknesses.push('High debt load relative to total assets');
    }
  }

  // C. Emergency Fund Runway (20 pts)
  const runway = monthlySpend > 0 ? totalBalance / monthlySpend : 12;
  if (runway >= 6) {
    emergencyRunwayScore = 20;
    strengths.push('Strong emergency fund (covers 6+ months of spending)');
  } else if (runway >= 3) {
    emergencyRunwayScore = 15;
    strengths.push('Adequate emergency fund (covers 3-6 months of spending)');
  } else if (runway >= 1) {
    emergencyRunwayScore = 10;
  } else {
    emergencyRunwayScore = 4;
    weaknesses.push('Critically low emergency runway (<1 month)');
  }

  // D. Investment Ratio (20 pts)
  const totalAssets = totalBalance + totalInvestments;
  if (totalAssets > 0) {
    const invRatio = (totalInvestments / totalAssets) * 100;
    if (invRatio >= 20 && invRatio <= 50) {
      investmentRatioScore = 20;
      strengths.push('Well-diversified asset allocation (20-50% in investments)');
    } else if (invRatio > 50) {
      investmentRatioScore = 17;
      strengths.push('Aggressive portfolio allocation (>50% in investments)');
    } else if (invRatio > 0) {
      investmentRatioScore = 12;
      weaknesses.push('Low investment allocation; funds are mostly sitting in cash');
    } else {
      investmentRatioScore = 6;
      weaknesses.push('No active investments in portfolio');
    }
  }

  // E. Spending Stability (20 pts)
  if (prevMonthlySpend > 0) {
    const spendIncrease = ((monthlySpend - prevMonthlySpend) / prevMonthlySpend) * 100;
    if (spendIncrease <= 0) {
      spendingStabilityScore = 20;
      strengths.push('Decreased or stable month-over-month spending');
    } else if (spendIncrease <= 15) {
      spendingStabilityScore = 15;
    } else {
      spendingStabilityScore = 8;
      weaknesses.push('High spending increase (>15%) compared to last month');
    }
  }

  const finalScore = savingsRateScore + debtLoadScore + emergencyRunwayScore + investmentRatioScore + spendingStabilityScore;

  return {
    score: Math.min(100, Math.max(0, finalScore)),
    metrics: {
      totalBalance,
      totalDebt,
      totalInvestments,
      monthlySpend,
      monthlyInflow,
      emergencyRunwayMonths: parseFloat(runway.toFixed(1))
    },
    strengths: [...new Set(strengths)],
    weaknesses: [...new Set(weaknesses)]
  };
}

module.exports = {
  calculateFinancialHealth
};
