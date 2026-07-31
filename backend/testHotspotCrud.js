const hotspotService = require('./src/services/hotspotService');
const { detectFraud } = require('./fraudDetection');

console.log('================================================================');
console.log('🛡️  VERIFYING ADMIN HOTSPOT CONTROL CENTER & FRAUD ENGINE SYNC');
console.log('================================================================\n');

// 1. Verify Statistics
const stats = hotspotService.getStats();
console.log('📊 Dashboard Stats:');
console.log(`- Total Checkpoints: ${stats.totalCheckpoints}`);
console.log(`- Risk Checkpoints: ${stats.riskCheckpoints}`);
console.log(`- Warning Checkpoints: ${stats.warningCheckpoints}`);
console.log(`- Total Accounts in Hotspots: ${stats.totalAccountsInHotspots}`);
console.log(`- Average Risk Score: ${stats.averageRiskScore}%`);
console.log(`- Start Monitoring Count: ${stats.startMonitoringCount}`);
console.log(`- Store Only Count: ${stats.storeOnlyCount}`);

if (stats.totalCheckpoints !== 20 || stats.riskCheckpoints !== 18 || stats.warningCheckpoints !== 2) {
  console.error('❌ FAIL: Initial checkpoint counts mismatch!');
  process.exit(1);
}
console.log('✅ Stats Verification Passed!\n');

// 2. Verify Accessibility Mode Behavior in Live Fraud Detection
const userProfile = {
  cus_id: 'TEST_USER_101',
  avgTransactionAmount: 5000,
  stdDevAmount: 2000,
  usualHoursStart: 8,
  usualHoursEnd: 22,
  knownDevices: ['Pixel-8'],
  knownLocations: ['Kolkata'],
  avgDailyTransactions: 3
};

console.log('🧪 Testing Fraud Engine Accessibility Mode Logic:');

// Test A: Pincode 110001 (Connaught Place - Start Monitoring)
const txnA = { timestamp: '2026-07-31T12:00:00Z', amount: 4000, location: 'Kolkata', deviceId: 'Pixel-8', pincode: '110001' };
const resA = detectFraud(txnA, userProfile);
console.log(`- Pincode 110001 (Start Monitoring) -> Flagged HOTSPOT_AREA: ${resA.flags.includes('HOTSPOT_AREA') ? 'YES ✅' : 'NO ❌'}`);
if (!resA.flags.includes('HOTSPOT_AREA')) {
  console.error('❌ FAIL: Start Monitoring checkpoint 110001 was NOT flagged!');
  process.exit(1);
}

// Test B: Pincode 734001 (Siliguri - Store Only)
const txnB = { timestamp: '2026-07-31T12:00:00Z', amount: 4000, location: 'Kolkata', deviceId: 'Pixel-8', pincode: '734001' };
const resB = detectFraud(txnB, userProfile);
console.log(`- Pincode 734001 (Store Only) -> Flagged HOTSPOT_AREA: ${resB.flags.includes('HOTSPOT_AREA') ? 'YES (Unexpected) ❌' : 'NO (Correct) ✅'}`);
if (resB.flags.includes('HOTSPOT_AREA')) {
  console.error('❌ FAIL: Store Only checkpoint 734001 should NOT be evaluated in live fraud scoring!');
  process.exit(1);
}

// Test C: Dynamically toggle 734001 to Start Monitoring via Admin API service
console.log('\n🔄 Toggling 734001 (Siliguri) to "Start Monitoring"...');
hotspotService.toggleAccessibilityMode('CHK-1019', 'Start Monitoring');

const resC = detectFraud(txnB, userProfile);
console.log(`- Pincode 734001 after toggle -> Flagged HOTSPOT_AREA: ${resC.flags.includes('HOTSPOT_AREA') ? 'YES ✅' : 'NO ❌'}`);
if (!resC.flags.includes('HOTSPOT_AREA')) {
  console.error('❌ FAIL: Checkpoint 734001 did not trigger after toggle!');
  process.exit(1);
}

// Revert 734001 back to Store Only
hotspotService.toggleAccessibilityMode('CHK-1019', 'Store Only');
console.log('🔄 Reverted 734001 back to "Store Only".');

console.log('\n================================================================');
console.log('✅ ALL ADMIN HOTSPOT CONTROL CENTER INTEGRATION TESTS PASSED!');
console.log('================================================================');
