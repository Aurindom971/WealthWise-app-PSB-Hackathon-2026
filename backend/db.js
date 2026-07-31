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

/**
 * 🔒 Initialize KYC table schema
 */
async function initKycDb() {
  const createTableQuery = `
    CREATE TABLE IF NOT EXISTS kyc_records (
      cus_id VARCHAR(50) PRIMARY KEY,
      full_name VARCHAR(150),
      dob VARCHAR(20),
      gender VARCHAR(20),
      pan_number VARCHAR(20),
      aadhaar_number VARCHAR(30),
      ovd_type VARCHAR(50),
      ovd_number VARCHAR(50),
      address_line1 TEXT,
      address_line2 TEXT,
      city VARCHAR(100),
      state VARCHAR(100),
      pincode VARCHAR(20),
      occupation VARCHAR(100),
      annual_income VARCHAR(100),
      fatca_resident BOOLEAN DEFAULT TRUE,
      pep_status BOOLEAN DEFAULT FALSE,
      status VARCHAR(30) DEFAULT 'VERIFIED',
      ckyc_ref_no VARCHAR(50),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;
  try {
    await pool.query(createTableQuery);
    console.log('[DB] KYC records table ready');
  } catch (err) {
    console.error('[DB] Error initializing KYC table:', err.message);
  }
}

// Auto-run init
initKycDb();

/**
 * 🔒 Save or Update KYC Record
 */
async function saveKycToDb(cusId, data) {
  const ckycRefNo = data.ckyc_ref_no || `CKYC-${Math.floor(1000000000 + Math.random() * 9000000000)}`;
  const query = `
    INSERT INTO kyc_records (
      cus_id, full_name, dob, gender, pan_number, aadhaar_number,
      ovd_type, ovd_number, address_line1, address_line2, city, state, pincode,
      occupation, annual_income, fatca_resident, pep_status, status, ckyc_ref_no, updated_at
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, CURRENT_TIMESTAMP)
    ON CONFLICT (cus_id) DO UPDATE SET
      full_name = EXCLUDED.full_name,
      dob = EXCLUDED.dob,
      gender = EXCLUDED.gender,
      pan_number = EXCLUDED.pan_number,
      aadhaar_number = EXCLUDED.aadhaar_number,
      ovd_type = EXCLUDED.ovd_type,
      ovd_number = EXCLUDED.ovd_number,
      address_line1 = EXCLUDED.address_line1,
      address_line2 = EXCLUDED.address_line2,
      city = EXCLUDED.city,
      state = EXCLUDED.state,
      pincode = EXCLUDED.pincode,
      occupation = EXCLUDED.occupation,
      annual_income = EXCLUDED.annual_income,
      fatca_resident = EXCLUDED.fatca_resident,
      pep_status = EXCLUDED.pep_status,
      status = EXCLUDED.status,
      updated_at = CURRENT_TIMESTAMP
    RETURNING *;
  `;

  const values = [
    cusId,
    data.full_name || 'Rajesh Kumar',
    data.dob || '15/08/1990',
    data.gender || 'Male',
    data.pan_number || 'ABCDE1234F',
    data.aadhaar_number || '9876 5432 1098',
    data.ovd_type || 'Aadhaar Card',
    data.ovd_number || '9876 5432 1098',
    data.address_line1 || '',
    data.address_line2 || '',
    data.city || '',
    data.state || '',
    data.pincode || '',
    data.occupation || 'Salaried',
    data.annual_income || '₹5 Lakhs - ₹10 Lakhs',
    data.fatca_resident !== undefined ? data.fatca_resident : true,
    data.pep_status !== undefined ? data.pep_status : false,
    data.status || 'VERIFIED',
    ckycRefNo
  ];

  const res = await pool.query(query, values);
  return res.rows[0];
}

/**
 * 🔒 Get KYC Record
 */
async function getKycFromDb(cusId) {
  const query = `SELECT * FROM kyc_records WHERE cus_id = $1;`;
  const res = await pool.query(query, [cusId]);
  return res.rows[0] || null;
}

/**
 * 🗑️ Delete / Mark Removed KYC Record
 */
async function deleteKycFromDb(cusId) {
  const query = `
    UPDATE kyc_records 
    SET status = 'REMOVED', updated_at = NOW() 
    WHERE cus_id = $1 
    RETURNING *;
  `;
  const res = await pool.query(query, [cusId]);
  return res.rows[0] || null;
}

module.exports = {
  saveTransaction,
  saveFraudResult,
  buildUserProfile,
  saveKycToDb,
  getKycFromDb,
  deleteKycFromDb,
  pool
};