const { pool } = require('../../db');

/**
 * Helper to get the reference date (max transaction date) for a customer.
 * If no transactions, defaults to current date.
 */
async function getReferenceDate(cusId) {
  const query = `
    SELECT MAX(created_at) as max_date 
    FROM transactions 
    WHERE cus_id = $1
  `;
  const res = await pool.query(query, [cusId]);
  return res.rows[0].max_date ? new Date(res.rows[0].max_date) : new Date();
}

/**
 * Calculates spending for current calendar week vs previous calendar week.
 */
async function getWeeklySpending(cusId) {
  const refDate = await getReferenceDate(cusId);
  const refDateStr = refDate.toISOString();

  // Current week starts on Monday of the week containing refDate
  const currWeekQuery = `
    SELECT COALESCE(SUM(ABS(amount)), 0) as total
    FROM transactions
    WHERE cus_id = $1
      AND (transaction_type = 'debit' OR amount < 0)
      AND created_at >= date_trunc('week', $2::timestamp)
      AND created_at <= $2::timestamp
  `;
  
  const prevWeekQuery = `
    SELECT COALESCE(SUM(ABS(amount)), 0) as total
    FROM transactions
    WHERE cus_id = $1
      AND (transaction_type = 'debit' OR amount < 0)
      AND created_at >= date_trunc('week', $2::timestamp) - INTERVAL '7 days'
      AND created_at < date_trunc('week', $2::timestamp)
  `;

  const [currRes, prevRes] = await Promise.all([
    pool.query(currWeekQuery, [cusId, refDateStr]),
    pool.query(prevWeekQuery, [cusId, refDateStr])
  ]);

  const currentTotal = parseFloat(currRes.rows[0].total) || 0;
  const prevTotal = parseFloat(prevRes.rows[0].total) || 0;

  let diffPercent = 0;
  let trend = 'stable';
  if (prevTotal > 0) {
    diffPercent = Math.round(((currentTotal - prevTotal) / prevTotal) * 100);
    trend = currentTotal > prevTotal ? 'higher' : 'lower';
  } else if (currentTotal > 0) {
    diffPercent = 100;
    trend = 'higher';
  }

  return {
    totalSpent: currentTotal,
    previousSpent: prevTotal,
    differencePercent: Math.abs(diffPercent),
    trend,
    referenceDate: refDate
  };
}

/**
 * Calculates spending for current calendar month vs previous calendar month.
 */
async function getMonthlySpending(cusId) {
  const refDate = await getReferenceDate(cusId);
  const refDateStr = refDate.toISOString();

  const currMonthQuery = `
    SELECT COALESCE(SUM(ABS(amount)), 0) as total
    FROM transactions
    WHERE cus_id = $1
      AND (transaction_type = 'debit' OR amount < 0)
      AND created_at >= date_trunc('month', $2::timestamp)
      AND created_at <= $2::timestamp
  `;

  const prevMonthQuery = `
    SELECT COALESCE(SUM(ABS(amount)), 0) as total
    FROM transactions
    WHERE cus_id = $1
      AND (transaction_type = 'debit' OR amount < 0)
      AND created_at >= date_trunc('month', $2::timestamp) - INTERVAL '1 month'
      AND created_at < date_trunc('month', $2::timestamp)
  `;

  const [currRes, prevRes] = await Promise.all([
    pool.query(currMonthQuery, [cusId, refDateStr]),
    pool.query(prevMonthQuery, [cusId, refDateStr])
  ]);

  const currentTotal = parseFloat(currRes.rows[0].total) || 0;
  const prevTotal = parseFloat(prevRes.rows[0].total) || 0;

  let diffPercent = 0;
  let trend = 'stable';
  if (prevTotal > 0) {
    diffPercent = Math.round(((currentTotal - prevTotal) / prevTotal) * 100);
    trend = currentTotal > prevTotal ? 'higher' : 'lower';
  } else if (currentTotal > 0) {
    diffPercent = 100;
    trend = 'higher';
  }

  return {
    totalSpent: currentTotal,
    previousSpent: prevTotal,
    differencePercent: Math.abs(diffPercent),
    trend,
    referenceDate: refDate
  };
}

/**
 * Groups spending by category.
 */
async function getCategoryBreakdown(cusId) {
  const refDate = await getReferenceDate(cusId);
  const refDateStr = refDate.toISOString();

  const query = `
    SELECT COALESCE(category, 'general') as category, COALESCE(SUM(ABS(amount)), 0) as total
    FROM transactions
    WHERE cus_id = $1
      AND (transaction_type = 'debit' OR amount < 0)
      AND created_at >= $2::timestamp - INTERVAL '30 days'
      AND created_at <= $2::timestamp
    GROUP BY category
    ORDER BY total DESC
  `;

  const res = await pool.query(query, [cusId, refDateStr]);
  return res.rows.map(r => ({
    category: r.category.charAt(0).toUpperCase() + r.category.slice(1),
    amount: parseFloat(r.total) || 0
  }));
}

/**
 * Retrieves the top 10 largest debit transactions.
 */
async function getTopExpenses(cusId) {
  const query = `
    SELECT 
      COALESCE(counterparty_name, 'Unknown Merchant') as merchant,
      ABS(amount) as amount,
      created_at as date,
      COALESCE(category, 'general') as category
    FROM transactions
    WHERE cus_id = $1
      AND (transaction_type = 'debit' OR amount < 0)
    ORDER BY ABS(amount) DESC
    LIMIT 10
  `;

  const res = await pool.query(query, [cusId]);
  return res.rows.map(r => ({
    merchant: r.merchant,
    amount: parseFloat(r.amount) || 0,
    date: r.date,
    category: r.category
  }));
}

/**
 * Calculates average daily spend in the last 30 days.
 */
async function getAverageDailySpend(cusId) {
  const refDate = await getReferenceDate(cusId);
  const refDateStr = refDate.toISOString();

  const query = `
    SELECT COALESCE(SUM(ABS(amount)), 0) as total
    FROM transactions
    WHERE cus_id = $1
      AND (transaction_type = 'debit' OR amount < 0)
      AND created_at >= $2::timestamp - INTERVAL '30 days'
      AND created_at <= $2::timestamp
  `;

  const res = await pool.query(query, [cusId, refDateStr]);
  const total = parseFloat(res.rows[0].total) || 0;
  return Math.round(total / 30);
}

/**
 * Generates savings recommendations and analysis.
 */
async function getSavingsInsights(cusId, totalBalance) {
  const refDate = await getReferenceDate(cusId);
  const refDateStr = refDate.toISOString();

  // 1. Overspending detection: compare category spending in the last 30 days vs the previous 30 days
  const overspendingQuery = `
    WITH last_30 as (
      SELECT category, SUM(ABS(amount)) as total
      FROM transactions
      WHERE cus_id = $1
        AND (transaction_type = 'debit' OR amount < 0)
        AND created_at >= $2::timestamp - INTERVAL '30 days'
        AND created_at <= $2::timestamp
      GROUP BY category
    ),
    prev_30 as (
      SELECT category, SUM(ABS(amount)) as total
      FROM transactions
      WHERE cus_id = $1
        AND (transaction_type = 'debit' OR amount < 0)
        AND created_at >= $2::timestamp - INTERVAL '60 days'
        AND created_at < $2::timestamp - INTERVAL '30 days'
      GROUP BY category
    )
    SELECT 
      l.category, 
      l.total as current_spend, 
      COALESCE(p.total, 0) as previous_spend
    FROM last_30 l
    LEFT JOIN prev_30 p ON l.category = p.category
    WHERE l.total > COALESCE(p.total, 0)
    ORDER BY (l.total - COALESCE(p.total, 0)) DESC
    LIMIT 3
  `;

  // 2. Subscription detection: look for recurring patterns or names containing typical services
  const subscriptionQuery = `
    SELECT counterparty_name, ABS(amount) as amount, COUNT(*) as count
    FROM transactions
    WHERE cus_id = $1
      AND (transaction_type = 'debit' OR amount < 0)
      AND (
        LOWER(counterparty_name) LIKE '%netflix%' OR
        LOWER(counterparty_name) LIKE '%spotify%' OR
        LOWER(counterparty_name) LIKE '%prime%' OR
        LOWER(counterparty_name) LIKE '%youtube%' OR
        LOWER(counterparty_name) LIKE '%apple%' OR
        LOWER(counterparty_name) LIKE '%google%' OR
        LOWER(counterparty_name) LIKE '%microsoft%' OR
        LOWER(counterparty_name) LIKE '%adobe%' OR
        LOWER(counterparty_name) LIKE '%subscription%'
      )
    GROUP BY counterparty_name, amount
  `;

  // 3. Average monthly spending (last 30 days) to compute Emergency runway
  const monthlySpendQuery = `
    SELECT COALESCE(SUM(ABS(amount)), 0) as total
    FROM transactions
    WHERE cus_id = $1
      AND (transaction_type = 'debit' OR amount < 0)
      AND created_at >= $2::timestamp - INTERVAL '30 days'
      AND created_at <= $2::timestamp
  `;

  const [overspendRes, subRes, monthlyRes] = await Promise.all([
    pool.query(overspendingQuery, [cusId, refDateStr]),
    pool.query(subscriptionQuery, [cusId]),
    pool.query(monthlySpendQuery, [cusId, refDateStr])
  ]);

  // Format Overspending list
  const overspending = overspendRes.rows.map(r => {
    const prev = parseFloat(r.previous_spend) || 0;
    const curr = parseFloat(r.current_spend) || 0;
    const diff = curr - prev;
    const increasePercent = prev > 0 ? Math.round((diff / prev) * 100) : 100;
    return {
      category: r.category.charAt(0).toUpperCase() + r.category.slice(1),
      increasePercent,
      amountIncrease: diff
    };
  });

  // Subscriptions
  let totalRecurringSpend = 0;
  const subscriptions = subRes.rows.map(r => {
    const amt = parseFloat(r.amount) || 0;
    totalRecurringSpend += amt;
    return {
      name: r.counterparty_name,
      amount: amt
    };
  });

  const monthlySpend = parseFloat(monthlyRes.rows[0].total) || 0;
  
  // Calculate Emergency fund runway (in months)
  let emergencyRunwayMonths = 0;
  if (monthlySpend > 0) {
    emergencyRunwayMonths = parseFloat((totalBalance / monthlySpend).toFixed(1));
  } else if (totalBalance > 0) {
    emergencyRunwayMonths = 12; // cap/default if spending is zero but balance exists
  }

  // Savings opportunity: e.g. reducing discretionary spending by 15%
  const discretionarySavings = Math.round(monthlySpend * 0.15);

  return {
    overspending,
    subscriptions,
    totalRecurringSpend,
    discretionarySavingsOpportunity: discretionarySavings,
    emergencyRunwayMonths,
    averageMonthlySpend: monthlySpend
  };
}

module.exports = {
  getWeeklySpending,
  getMonthlySpending,
  getCategoryBreakdown,
  getTopExpenses,
  getAverageDailySpend,
  getSavingsInsights
};
