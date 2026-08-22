const { detectFraud } = require('./fraudDetection');

console.log('===============================================================');
console.log('🛡️  WEALTHWISE - FRAUD HOTSPOT INTELLIGENCE ENGINE TESTS');
console.log('===============================================================\n');

const baseProfile = {
  cus_id: 'CUST_TEST_1',
  avgTransactionAmount: 5000,
  stdDevAmount: 2000,
  usualHoursStart: 9,
  usualHoursEnd: 22,
  knownDevices: ['iPhone-15-Pro'],
  knownLocations: ['Mumbai'],
  avgDailyTransactions: 4,
};

// Scenario 1: Non-hotspot pincode transaction
console.log('--- SCENARIO 1: Non-Hotspot Area Transaction ---');
const txn1 = {
  timestamp: '2026-07-21T10:00:00Z', 
  amount: 4000, 
  location: 'Mumbai', 
  deviceId: 'iPhone-15-Pro',
  pincode: '400099' // safe area
};
const res1 = detectFraud(txn1, baseProfile);
console.log(`Hotspot Area Flagged: ${res1.flags.includes('HOTSPOT_AREA') ? 'YES ❌' : 'NO ✅ (Safe)'}`);
console.log(`Risk Score: ${res1.risk_score}`);
console.log(`Breakdown keys:`, Object.keys(res1.breakdown));
console.log(`Breakdown hotspot value: ${res1.breakdown.hotspot}`);
if (res1.flags.includes('HOTSPOT_AREA') || res1.breakdown.hotspot !== 0) {
  console.error('FAIL: Flagged safe area as hotspot or registered positive breakdown!');
  process.exit(1);
}
console.log('---------------------------------------------------------------\n');

// Scenario 2: Hotspot pincode transaction (110001, risk level critical, score 0.92)
console.log('--- SCENARIO 2: Hotspot Area Transaction (110001) ---');
const txn2 = {
  timestamp: '2026-07-21T10:00:00Z', 
  amount: 4000, 
  location: 'Mumbai', 
  deviceId: 'iPhone-15-Pro',
  pincode: '110001' // Connaught Place (New Delhi Central)
};
const res2 = detectFraud(txn2, baseProfile);
console.log(`Hotspot Area Flagged: ${res2.flags.includes('HOTSPOT_AREA') ? 'YES ✅' : 'NO ❌'}`);
console.log(`Flags: ${res2.flags.join(', ')}`);
console.log(`Reasons: ${res2.reasons.join('; ')}`);
console.log(`Risk Score: ${res2.risk_score}`);
console.log(`Breakdown details:`, res2.breakdown);
if (!res2.flags.includes('HOTSPOT_AREA') || res2.breakdown.hotspot === 0) {
  console.error('FAIL: Did not flag hotspot area or hotspot breakdown is zero!');
  process.exit(1);
}
// Expected contribution for 110001 hotspot: score (0.92) * weight (20) = 18.4
const expectedHotspotContribution = parseFloat((0.92 * 20).toFixed(2));
if (res2.breakdown.hotspot !== expectedHotspotContribution) {
  console.error(`FAIL: Expected hotspot contribution ${expectedHotspotContribution}, got ${res2.breakdown.hotspot}`);
  process.exit(1);
}
console.log('---------------------------------------------------------------\n');

// Scenario 3: Check normalization constant (155 weight)
console.log('--- SCENARIO 3: Multiple Anomalies & Normalization Test ---');
const txn3 = {
  timestamp: '2026-07-21T10:00:00Z', 
  amount: 15000, 
  location: 'Delhi', 
  deviceId: 'iPhone-16', 
  pincode: '110001' 
};
const res3 = detectFraud(txn3, baseProfile);
console.log(`Flags triggered: ${res3.flags.join(', ')}`);
console.log(`Risk Score: ${res3.risk_score}`);
console.log(`Breakdown details:`, res3.breakdown);

const sumBreakdown = Object.values(res3.breakdown).reduce((a, b) => a + b, 0);
console.log(`Sum of contributions from breakdown: ${sumBreakdown}`);

const normalized = sumBreakdown / 155;
const curved = Math.pow(Math.max(0, Math.min(1, normalized)), 0.85);
const expectedRisk = Math.round(curved * 100);
if (res3.risk_score !== expectedRisk) {
  console.error(`FAIL: Expected risk score ${expectedRisk}, got ${res3.risk_score}`);
  process.exit(1);
}
console.log('Verification Success: Normalization constant and breakdown correctly calculated! ✅');
console.log('===============================================================');
console.log('✅ ALL FRAUD DETECTION INTELLIGENCE TESTS PASSED!');
console.log('===============================================================');
