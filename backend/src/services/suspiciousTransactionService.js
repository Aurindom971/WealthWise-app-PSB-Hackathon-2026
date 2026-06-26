const { pool } = require('../../db');

/**
 * Scans a user's recent transactions and flags suspicious patterns with risk scores and evidence.
 */
async function detectSuspiciousTransactions(cusId) {
  // 1. Fetch user baseline stats
  const statsQuery = `
    SELECT 
      COALESCE(AVG(ABS(amount)), 0) as avg_amount,
      COALESCE(STDDEV(ABS(amount)), 0) as stddev_amount
    FROM transactions
    WHERE cus_id = $1 AND (transaction_type = 'debit' OR amount < 0)
  `;

  // 2. Fetch known cities from location history
  const locationsQuery = `
    SELECT DISTINCT LOWER(city) as city 
    FROM location_history 
    WHERE cus_id = $1 AND city IS NOT NULL
  `;

  // 3. Fetch known devices
  const devicesQuery = `
    SELECT DISTINCT LOWER(device_name) as device 
    FROM devices 
    WHERE cus_id = $1
  `;

  // 4. Fetch all fraud alert transactions
  const fraudAlertsQuery = `
    SELECT transaction_id 
    FROM fraud_alerts 
    WHERE cus_id = $1
  `;

  // 5. Fetch transactions to evaluate
  const txnsQuery = `
    SELECT 
      transaction_id,
      account_id,
      amount,
      category,
      payment_method,
      counterparty_name,
      location,
      created_at
    FROM transactions
    WHERE cus_id = $1
    ORDER BY created_at DESC
    LIMIT 20
  `;

  const [statsRes, locRes, devRes, fraudRes, txnsRes] = await Promise.all([
    pool.query(statsQuery, [cusId]),
    pool.query(locationsQuery, [cusId]),
    pool.query(devicesQuery, [cusId]),
    pool.query(fraudAlertsQuery, [cusId]),
    pool.query(txnsQuery, [cusId])
  ]);

  const avgAmount = parseFloat(statsRes.rows[0].avg_amount) || 1000;
  const stdDev = parseFloat(statsRes.rows[0].stddev_amount) || 500;
  const knownCities = new Set(locRes.rows.map(r => r.city));
  const knownDevices = new Set(devRes.rows.map(r => r.device));
  const fraudTxnIds = new Set(fraudRes.rows.map(r => r.transaction_id.toString()));

  const evaluated = [];

  for (const txn of txnsRes.rows) {
    const txnId = txn.transaction_id.toString();
    const amount = Math.abs(parseFloat(txn.amount)) || 0;
    const isDebit = parseFloat(txn.amount) < 0 || txn.transaction_type === 'debit';
    
    // Skip credits from suspicious classification unless abnormal
    if (!isDebit) continue;

    let riskScore = 0;
    const reasons = [];
    const evidence = {};

    // Check 1: High Amount Anomaly
    if (amount > avgAmount + 3 * stdDev) {
      riskScore += 45;
      reasons.push('High Amount (exceeds 3 standard deviations of typical spending)');
      evidence.highAmount = `Amount ₹${amount.toLocaleString('en-IN')} exceeds average ₹${Math.round(avgAmount).toLocaleString('en-IN')} with StdDev ₹${Math.round(stdDev).toLocaleString('en-IN')}`;
    } else if (amount > avgAmount + 2 * stdDev) {
      riskScore += 25;
      reasons.push('Elevated Amount (exceeds normal spending pattern)');
      evidence.highAmount = `Amount ₹${amount.toLocaleString('en-IN')} is higher than average ₹${Math.round(avgAmount).toLocaleString('en-IN')}`;
    }

    // Check 2: New Location
    if (txn.location && txn.location.toLowerCase() !== 'unknown') {
      const locLower = txn.location.toLowerCase();
      // Match city in location history
      let found = false;
      for (const city of knownCities) {
        if (locLower.includes(city) || city.includes(locLower)) {
          found = true;
          break;
        }
      }
      if (!found && knownCities.size > 0) {
        riskScore += 25;
        reasons.push(`Unusual Location (${txn.location} is not in customer history)`);
        evidence.newLocation = `Transaction location ${txn.location} has no matching historical records`;
      }
    }

    // Check 3: Active Fraud Alert Matching
    if (fraudTxnIds.has(txnId)) {
      riskScore += 50;
      reasons.push('Direct System Fraud Alert Match');
      evidence.fraudMatch = 'Transaction flagged by behavioral rules engine';
    }

    // Check 4: Velocity Check (look for high frequency of transaction counts around this timestamp)
    const timeLimit = new Date(txn.created_at);
    const velocityQuery = `
      SELECT COUNT(*) as count 
      FROM transactions 
      WHERE cus_id = $1 
        AND created_at >= $2::timestamp - INTERVAL '5 minutes'
        AND created_at <= $2::timestamp + INTERVAL '5 minutes'
        AND transaction_id != $3
    `;
    const velRes = await pool.query(velocityQuery, [cusId, timeLimit.toISOString(), txn.transaction_id]);
    const siblingCount = parseInt(velRes.rows[0].count) || 0;
    if (siblingCount >= 2) {
      riskScore += 20;
      reasons.push(`High Velocity Alert (${siblingCount} adjacent transactions within a 10-minute window)`);
      evidence.velocity = `${siblingCount} transaction attempts processed in close succession`;
    }

    // Cap score at 100
    riskScore = Math.min(100, riskScore);

    // Only flag as suspicious if risk is elevated
    if (riskScore >= 20) {
      evaluated.push({
        transaction_id: txnId,
        amount,
        merchant: txn.counterparty_name || 'Unknown Merchant',
        category: txn.category,
        payment_method: txn.payment_method,
        location: txn.location || 'Unknown',
        date: txn.created_at,
        riskScore,
        reasons,
        evidence
      });
    }
  }

  // Sort by highest risk score first
  return evaluated.sort((a, b) => b.riskScore - a.riskScore);
}

module.exports = {
  detectSuspiciousTransactions
};
