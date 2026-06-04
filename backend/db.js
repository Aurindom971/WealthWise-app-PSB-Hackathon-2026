const { Pool } = require('pg');
require('dotenv').config();

/**
 * 🗄️ DATABASE INFRASTRUCTURE & SCALABILITY ROADMAP
 * =================================================
 * TODO: Harden database access layer for production security and query throughput.
 * Future improvements:
 *   - Implement Redis-based distributed caching layer for recent transactions to prevent database pressure during bursts.
 *   - Optimize pg connections using transaction pooler (PgBouncer) instead of direct Supabase session pooling.
 *   - Audit and harden Row Level Security (RLS) policies for users, accounts, and cards.
 *   - Establish sliding partition tables for the `transactions` table to archive data older than 90 days.
 *   - Refine composite index strategy on (cus_id, created_at DESC) for sub-millisecond query evaluation.
 */

// ✅ Supabase connection (session pooler)
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});

// 🔧 Logs
pool.on('connect', () => {
  console.log('Connected to Supabase PostgreSQL');
});

pool.on('error', (err) => {
  console.error('Unexpected DB error', err);
});

/**
 * 🔥 Save transaction (aligned with your schema)
 */
async function saveTransaction(cus_id, txn) {
  const query = `
    INSERT INTO transactions (
      cus_id,
      account_id,
      amount,
      created_at,
      status,
      category,
      location
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING transaction_id;
  `;

  const values = [
    cus_id,
    txn.account_id || null,              // safe optional
    txn.amount,
    txn.timestamp || new Date(),
    'successful',                        // must match DB constraint
    txn.category || 'general',
    txn.location || 'unknown'
  ];

  const res = await pool.query(query, values);
  return res.rows[0].transaction_id;
}

/**
 * 🔥 Save fraud alert
 */
async function saveFraudResult(transaction_id, result, cus_id) {
  const query = `
    INSERT INTO fraud_alerts (
      cus_id,
      transaction_id
    )
    VALUES ($1, $2);
  `;

  await pool.query(query, [
    cus_id,
    transaction_id
  ]);
}
/**
 * 🔥 Build user profile (behavioral model)
 */
async function buildUserProfile(cus_id, txnTimestamp = new Date()) {
  // 1. Transaction stats
  const txnStatsQuery = `
    SELECT 
      AVG(amount) as avg_amount,
      STDDEV(amount) as stddev_amount,
      COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE) as today_count,
      COUNT(*) FILTER (
        WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
      ) / 30.0 as avg_daily_txns
    FROM transactions
    WHERE cus_id = $1;
  `;

  const txnStats = await pool.query(txnStatsQuery, [cus_id]);
  const stats = txnStats.rows[0] || {};

  const avgAmount = parseFloat(stats.avg_amount);
  const stdDev = parseFloat(stats.stddev_amount);

  // ✅ Safe defaults (important for new users)
  const safeAvg = avgAmount > 0 ? avgAmount : 1000;
  const safeStd = stdDev > 0 ? stdDev : safeAvg * 0.5;

  // 2. Login behavior (fallback since no login table match)
  const usualHoursStart = 9;
  const usualHoursEnd = 22;

  // 3. Known devices (NOTE: uses user_id in your schema)
  let devices = { rows: [] };
  try {
    const devicesQuery = `
      SELECT device_id FROM devices WHERE user_id = $1;
    `;
    devices = await pool.query(devicesQuery, [cus_id]);
  } catch (e) {
    console.warn('Devices table not available or mismatched');
  }

  // 4. Known locations
  let locations = { rows: [] };
  try {
    const locationsQuery = `
      SELECT DISTINCT location FROM location_history WHERE user_id = $1;
    `;
    locations = await pool.query(locationsQuery, [cus_id]);
  } catch (e) {
    console.warn('Location history table not available or mismatched');
  }

  // 5. Recent transactions (within 5-minute rolling window relative to txnTimestamp)
  let recentTransactions = [];
  try {
    const recentTxnsQuery = `
      SELECT created_at AS timestamp, amount, location, category
      FROM transactions
      WHERE cus_id = $1
      AND created_at >= $2::timestamp - INTERVAL '5 minutes'
      AND created_at <= $2::timestamp
      ORDER BY created_at DESC;
    `;
    const parsedTime = new Date(txnTimestamp).toISOString();
    const recentTxnsRes = await pool.query(recentTxnsQuery, [cus_id, parsedTime]);
    recentTransactions = recentTxnsRes.rows;
  } catch (e) {
    console.warn('Recent transactions query failed:', e.message);
  }

  return {
    avgTransactionAmount: safeAvg,
    stdDevAmount: safeStd,
    usualHoursStart,
    usualHoursEnd,

    knownDevices: devices.rows
      .map(r => r.device_id)
      .filter(Boolean),

    knownLocations: locations.rows
      .map(r => r.location)
      .filter(Boolean),

    avgDailyTransactions: parseFloat(stats.avg_daily_txns) || 1,
    dailyTransactionCount: parseInt(stats.today_count) || 0,
    recentTransactions,
    cus_id
  };
}

module.exports = {
  saveTransaction,
  saveFraudResult,
  buildUserProfile,
  pool
};