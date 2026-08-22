/**
 * Transaction Velocity Monitor - Comprehensive Test Suite
 * =======================================================
 * Runs: node testFraud.js
 * 
 * Verifies all Scenarios A through E to validate correctness,
 * security, dynamic behavior, and balanced risk scoring.
 */

const { detectFraud } = require('./fraudDetection');

console.log('===============================================================');
console.log('🛡️  WEALTHWISE TWIN - TRANSACTION VELOCITY MONITOR TEST SUITE');
console.log('===============================================================\n');

// -------------------------------------------------------------
// Base mock profile
// -------------------------------------------------------------
const baseProfile = {
  cus_id: 'CUST_V1',
  avgTransactionAmount: 5000,
  stdDevAmount: 2000,
  usualHoursStart: 9,       // 9 AM
  usualHoursEnd: 22,        // 10 PM
  knownDevices: ['iPhone-15-Pro'],
  knownLocations: ['Mumbai', 'Pune'],
  avgDailyTransactions: 4,
};

// =============================================================
// SCENARIO A: 3 transactions in 2 minutes (Anomaly triggers)
// =============================================================
console.log('--- SCENARIO A: Rapid Transaction Burst (3 in 2 mins) ---');
const profileA = {
  ...baseProfile,
  recentTransactions: [
    { timestamp: '2026-05-28T22:00:00Z', amount: 1000, location: 'Mumbai', category: 'general' },
    { timestamp: '2026-05-28T22:01:00Z', amount: 1200, location: 'Mumbai', category: 'dining' },
  ]
};
const txnA = { timestamp: '2026-05-28T22:02:00Z', amount: 1500, location: 'Mumbai', category: 'travel' };
const resA = detectFraud(txnA, profileA);

console.log(`Anomaly Triggered: ${resA.flags.includes('VELOCITY_ATTACK') ? 'YES ✅' : 'NO ❌'}`);
console.log(`Flags: ${resA.flags.join(', ')}`);
console.log(`Reasons: ${resA.reasons.join('; ')}`);
console.log(`Risk Score: ${resA.risk_score}`);
console.log('---------------------------------------------------------------\n');


// =============================================================
// SCENARIO B: 2 transactions spaced across 20 minutes (No trigger)
// =============================================================
console.log('--- SCENARIO B: Normal Activity Spaced Out (2 in 20 mins) ---');
const profileB = {
  ...baseProfile,
  recentTransactions: [
    { timestamp: '2026-05-28T21:40:00Z', amount: 2000, location: 'Mumbai', category: 'shopping' }
  ]
};
const txnB = { timestamp: '2026-05-28T22:00:00Z', amount: 2500, location: 'Mumbai', category: 'general' };
const resB = detectFraud(txnB, profileB);

console.log(`Anomaly Triggered: ${resB.flags.includes('VELOCITY_ATTACK') ? 'YES ❌' : 'NO ✅ (Safe)'}`);
console.log(`Flags: ${resB.flags.join(', ') || 'None'}`);
console.log(`Risk Score: ${resB.risk_score}`);
console.log('---------------------------------------------------------------\n');


// =============================================================
// SCENARIO C: Rapid high-value transfers (High combined score)
// =============================================================
console.log('--- SCENARIO C: Rapid High-Value Transfers (Burst + High Amount) ---');
const profileC = {
  ...baseProfile,
  recentTransactions: [
    { timestamp: '2026-05-28T22:00:00Z', amount: 45000, location: 'Mumbai', category: 'general' },
    { timestamp: '2026-05-28T22:01:00Z', amount: 50000, location: 'Mumbai', category: 'general' },
  ]
};
// Note: avgTransactionAmount is 5000, so 60000 triggers AMOUNT_ANOMALY + VELOCITY_ATTACK
const txnC = { timestamp: '2026-05-28T22:02:00Z', amount: 60000, location: 'Mumbai', category: 'general' };
const resC = detectFraud(txnC, profileC);

console.log(`Anomaly Triggered: ${resC.flags.includes('VELOCITY_ATTACK') ? 'YES ✅' : 'NO ❌'}`);
console.log(`Amount Anomaly Triggered: ${resC.flags.includes('AMOUNT_ANOMALY') ? 'YES ✅' : 'NO ❌'}`);
console.log(`Flags: ${resC.flags.join(', ')}`);
console.log(`Reasons: ${resC.reasons.join('; ')}`);
console.log(`Risk Score: ${resC.risk_score} (Should be highly elevated due to multiple signals)`);
console.log('---------------------------------------------------------------\n');


// =============================================================
// SCENARIO D: Rapid low-value micro-transactions (Should still trigger)
// =============================================================
console.log('--- SCENARIO D: Rapid Low-Value Micro-Transactions (Micro-Attack) ---');
const profileD = {
  ...baseProfile,
  recentTransactions: [
    { timestamp: '2026-05-28T22:00:00Z', amount: 10, location: 'Mumbai', category: 'micro' },
    { timestamp: '2026-05-28T22:01:00Z', amount: 15, location: 'Mumbai', category: 'micro' },
  ]
};
const txnD = { timestamp: '2026-05-28T22:02:00Z', amount: 8, location: 'Mumbai', category: 'micro' };
const resD = detectFraud(txnD, profileD);

console.log(`Anomaly Triggered: ${resD.flags.includes('VELOCITY_ATTACK') ? 'YES ✅' : 'NO ❌'}`);
console.log(`Flags: ${resD.flags.join(', ')}`);
console.log(`Reasons: ${resD.reasons.join('; ')}`);
console.log(`Risk Score: ${resD.risk_score}`);
console.log('---------------------------------------------------------------\n');


// =============================================================
// SCENARIO E: Old transactions outside time window (No trigger)
// =============================================================
console.log('--- SCENARIO E: Transactions Outside Rolling 5-min Window ---');
const profileE = {
  ...baseProfile,
  recentTransactions: [
    { timestamp: '2026-05-28T21:40:00Z', amount: 1000, location: 'Mumbai', category: 'general' },
    { timestamp: '2026-05-28T21:50:00Z', amount: 1200, location: 'Mumbai', category: 'dining' },
  ]
};
const txnE = { timestamp: '2026-05-28T22:00:00Z', amount: 1500, location: 'Mumbai', category: 'travel' };
const resE = detectFraud(txnE, profileE);

console.log(`Anomaly Triggered: ${resE.flags.includes('VELOCITY_ATTACK') ? 'YES ❌' : 'NO ✅ (Safe)'}`);
console.log(`Flags: ${resE.flags.join(', ') || 'None'}`);
console.log(`Risk Score: ${resE.risk_score}`);
console.log('---------------------------------------------------------------\n');


// =============================================================
// BONUS SCENARIO: Duplicate Submission Prevention (Same location/amount/time)
// =============================================================
console.log('--- BONUS SCENARIO: Accidental Retry / Double-Click Deduplication ---');
const profileBonus = {
  ...baseProfile,
  recentTransactions: [
    { timestamp: '2026-05-28T22:00:00Z', amount: 500, location: 'Mumbai', category: 'dining' },
    // Duplicate transaction within 1.5 seconds (accidental double submission)
    { timestamp: '2026-05-28T22:00:01.5Z', amount: 500, location: 'Mumbai', category: 'dining' },
  ]
};
// If double click was counted, this 3rd submission within 2 seconds of the first would trigger velocity.
// But since we deduplicate identical txns within 3s, it should evaluate to only 2 unique transactions and not trigger.
const txnBonus = { timestamp: '2026-05-28T22:00:02Z', amount: 500, location: 'Mumbai', category: 'dining' };
const resBonus = detectFraud(txnBonus, profileBonus);

console.log(`Anomaly Triggered: ${resBonus.flags.includes('VELOCITY_ATTACK') ? 'YES ❌' : 'NO ✅ (Deduplicated successfully!)'}`);
console.log(`Flags: ${resBonus.flags.join(', ') || 'None'}`);
console.log('===============================================================\n');
