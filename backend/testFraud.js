/**
 * Quick smoke test for the fraud detection engine.
 * Run: node testFraud.js
 */

const { detectFraud } = require('./fraudDetection');

// --- Simulated user profile (built from historical behavior) ---
const profile = {
  avgTransactionAmount: 5000,
  stdDevAmount: 2000,
  usualHoursStart: 9,       // 9 AM
  usualHoursEnd: 22,        // 10 PM
  knownDevices: ['iPhone-14-ABC', 'Pixel-7-XYZ'],
  knownLocations: ['New Delhi', 'Mumbai'],
  avgDailyTransactions: 4,
};

console.log('=== Fraud Detection Engine — Test Suite ===\n');

// Test 1: Normal transaction — should score low
const normal = detectFraud(
  { amount: 4500, timestamp: '2026-04-23T14:30:00Z', deviceId: 'iPhone-14-ABC', location: 'New Delhi', dailyTransactionCount: 3 },
  profile
);
console.log('Test 1 — Normal transaction');
console.log(`  Risk Score : ${normal.risk_score}`);
console.log(`  Reasons    : ${normal.reasons.length ? normal.reasons.join('; ') : 'None'}`);
console.log(`  Flags      : ${normal.flags.length ? normal.flags.join(', ') : 'None'}`);
console.log();

// Test 2: High amount from unknown device at odd hour — should score high
const suspicious = detectFraud(
  { amount: 50000, timestamp: '2026-04-23T03:15:00Z', deviceId: 'Unknown-Phone-999', location: 'New Delhi', dailyTransactionCount: 2 },
  profile
);
console.log('Test 2 — Suspicious transaction (high amount + unknown device + odd hour)');
console.log(`  Risk Score : ${suspicious.risk_score}`);
console.log(`  Reasons    : ${suspicious.reasons.join('; ')}`);
console.log(`  Flags      : ${suspicious.flags.join(', ')}`);
console.log();

// Test 3: New location + high frequency
const mediumRisk = detectFraud(
  { amount: 6000, timestamp: '2026-04-23T11:00:00Z', deviceId: 'iPhone-14-ABC', location: 'Kolkata', dailyTransactionCount: 12 },
  profile
);
console.log('Test 3 — Medium risk (new location + high frequency)');
console.log(`  Risk Score : ${mediumRisk.risk_score}`);
console.log(`  Reasons    : ${mediumRisk.reasons.join('; ')}`);
console.log(`  Flags      : ${mediumRisk.flags.join(', ')}`);
console.log();

// Test 4: Everything anomalous — should score very high
const extreme = detectFraud(
  { amount: 200000, timestamp: '2026-04-23T03:00:00Z', deviceId: 'Burner-Phone-000', location: 'Lagos', dailyTransactionCount: 20 },
  profile
);
console.log('Test 4 — Extreme anomaly (all signals triggered)');
console.log(`  Risk Score : ${extreme.risk_score}`);
console.log(`  Reasons    : ${extreme.reasons.join('; ')}`);
console.log(`  Flags      : ${extreme.flags.join(', ')}`);
console.log();
