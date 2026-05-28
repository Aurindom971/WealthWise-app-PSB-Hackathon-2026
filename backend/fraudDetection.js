/**
 * FINAL Dynamic Fraud Detection Engine (Balanced)
 * ===============================================
 * ✔ Correct UTC handling
 * ✔ Clean anomaly filtering
 * ✔ Balanced scoring (no over-aggression)
 * 
 * 🧠 ROADMAP & ARCHITECTURAL NOTE: FUTURE AI FRAUD ENGINE
 * =====================================================
 * TODO: Upgrade current rule-based fraud engine into hybrid AI-assisted fraud intelligence system.
 * Planned architecture:
 *   1. Rule-based baseline engine (deterministic baseline)
 *   2. AI anomaly interpretation layer (deep context understanding)
 *   3. Behavioral sequence analysis (pattern-over-time detection)
 *   4. Adaptive fraud learning (continuous feedback loop)
 *   5. Personalized fraud baselines (hyper-localized limits)
 *   6. Explainable fraud AI (SAGE explainability module)
 * 
 * Potential future models:
 *   - Anomaly detection ML (Isolation Forests / Autoencoders)
 *   - Sequence prediction (LSTMs / Transformers for next-action analysis)
 *   - Graph fraud analysis (Network structures for card-testing loops)
 *   - Behavioral clustering (DBSCAN for user spending archetypes)
 *   - Reinforcement-based fraud scoring (Dynamically adapting weights)
 */

const rules = [
  amountAnomaly,
  timeAnomaly,
  deviceAnomaly,
  locationAnomaly,
  frequencyAnomaly,
  velocityAnomaly,
];

// -------------------- 1. Amount --------------------
function amountAnomaly(txn, profile) {
  if (!profile.avgTransactionAmount || !txn.amount) return null;

  const avg = profile.avgTransactionAmount;
  const stdDev = profile.stdDevAmount || avg * 0.5;

  const deviation = Math.abs(txn.amount - avg);
  const zScore = deviation / stdDev;

  const score = clamp(1 - 1 / (1 + 0.3 * zScore * zScore));

  // Ignore small variation
  if (score < 0.15) return null;

  const ratio = (txn.amount / avg).toFixed(1);

  return {
    score,
    weight: 35,
    reason: `Transaction amount (₹${txn.amount.toLocaleString()}) is ${ratio}× the user's average (₹${avg.toLocaleString()})`,
    flag: 'AMOUNT_ANOMALY',
  };
}

// -------------------- 2. Time --------------------
function timeAnomaly(txn, profile) {
  if (profile.usualHoursStart == null || profile.usualHoursEnd == null) return null;
  if (!txn.timestamp) return null;

  const txnHour = new Date(txn.timestamp).getUTCHours();

  const { usualHoursStart, usualHoursEnd } = profile;

  const isWithinWindow = usualHoursStart <= usualHoursEnd
    ? txnHour >= usualHoursStart && txnHour <= usualHoursEnd
    : txnHour >= usualHoursStart || txnHour <= usualHoursEnd;

  if (isWithinWindow) return null;

  const distStart = circularDistance(txnHour, usualHoursStart, 24);
  const distEnd = circularDistance(txnHour, usualHoursEnd, 24);
  const minDist = Math.min(distStart, distEnd);

  const score = clamp(minDist / 5);

  return {
    score,
    weight: 20,
    reason: `Transaction at ${formatHour(txnHour)} is outside the user's usual hours (${formatHour(usualHoursStart)}–${formatHour(usualHoursEnd)})`,
    flag: 'UNUSUAL_TIME',
  };
}

// -------------------- 3. Device --------------------
// TODO: Implement production-grade device fingerprinting.
// Future improvements:
//   - hardware fingerprinting (WebGL/Canvas entropy)
//   - trusted device scoring & enrollment workflows
//   - SIM consistency & IMSI validation
//   - OS integrity, root/jailbreak detection
//   - emulator detection & memory tampering analysis
// Future AI enhancement:
//   - AI-driven device trust scoring based on historical location & behavior timelines.
function deviceAnomaly(txn, profile) {
  if (!txn.deviceId || !profile.knownDevices?.length) return null;

  const isKnown = profile.knownDevices.some(
    d => d.toLowerCase() === txn.deviceId.toLowerCase()
  );

  if (isKnown) return null;

  return {
    score: 0.85,
    weight: 25,
    reason: `Transaction from unrecognized device "${txn.deviceId}"`,
    flag: 'NEW_DEVICE',
  };
}

// -------------------- 4. Location --------------------
// TODO: Improve geographic anomaly intelligence.
// Future improvements:
//   - impossible travel speed analysis (velocity threshold check between consecutive cities)
//   - GPS consistency checks against reported IP block Ranges
//   - IP reputation analysis (proxy, VPN, Tor exit nodes detection)
//   - regional fraud density heatmaps
// Future AI enhancement:
//   - AI-powered behavioral geolocation modeling representing individual travel baselines.
function locationAnomaly(txn, profile) {
  if (!txn.location || !profile.knownLocations?.length) return null;

  const isKnown = profile.knownLocations.some(
    loc => loc.toLowerCase() === txn.location.toLowerCase()
  );

  if (isKnown) return null;

  return {
    score: 0.7,
    weight: 15,
    reason: `Transaction from unfamiliar location "${txn.location}"`,
    flag: 'NEW_LOCATION',
  };
}

// -------------------- 5. Frequency --------------------
function frequencyAnomaly(txn, profile) {
  if (!profile.avgDailyTransactions || !txn.dailyTransactionCount) return null;

  const avg = profile.avgDailyTransactions;
  const current = txn.dailyTransactionCount;

  if (current <= avg) return null;

  const ratio = current / avg;
  const score = clamp((ratio - 1) / 3);

  if (score < 0.1) return null;

  return {
    score,
    weight: 15,
    reason: `User has made ${current} transactions today vs. average ${avg}`,
    flag: 'HIGH_FREQUENCY',
  };
}

// -------------------- 6. Velocity --------------------
function velocityAnomaly(txn, profile) {
  if (!txn.timestamp) return null;

  // Combine current transaction and recentTransactions for evaluation, ensuring we have a complete list
  let allTxns = [];
  if (profile.recentTransactions && Array.isArray(profile.recentTransactions)) {
    allTxns = [...profile.recentTransactions];
  }

  // Ensure current txn is included in the set
  const currentTxnTime = new Date(txn.timestamp).getTime();
  const exists = allTxns.some(t => {
    if (!t.timestamp) return false;
    return Math.abs(new Date(t.timestamp).getTime() - currentTxnTime) < 500 && // close timestamp (within 0.5s)
           parseFloat(t.amount) === parseFloat(txn.amount) &&
           (t.location || '').toLowerCase() === (txn.location || '').toLowerCase() &&
           (t.category || '').toLowerCase() === (txn.category || '').toLowerCase();
  });
  if (!exists) {
    allTxns.push({
      timestamp: txn.timestamp,
      amount: txn.amount,
      location: txn.location,
      category: txn.category
    });
  }

  // Sort chronologically
  allTxns.sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());

  // Deduplicate rapid identical submissions (same amount, location, category within 3 seconds)
  // to separate accidental double-clicks/retries from actual distinct high-velocity bursts
  // TODO: Implement production-grade duplicate transaction prevention.
  // Future improvements:
  //   - transaction fingerprint hashing (SHA-256 over key transaction fields)
  //   - strict deduplication windows at API gateway
  //   - client-supplied idempotency keys
  //   - cryptographically signed replay attack protection
  //   - duplicate transaction suppression rules
  // Future AI enhancement:
  //   - Use behavioral AI models to distinguish legitimate high-speed user actions from automated replay attacks.
  const uniqueTxns = [];
  for (let i = 0; i < allTxns.length; i++) {
    const current = allTxns[i];
    if (i === 0) {
      uniqueTxns.push(current);
      continue;
    }
    const prev = uniqueTxns[uniqueTxns.length - 1];
    const timeDiff = Math.abs(new Date(current.timestamp).getTime() - new Date(prev.timestamp).getTime()) / 1000;
    
    const isDuplicate = timeDiff <= 3 &&
                        parseFloat(current.amount) === parseFloat(prev.amount) &&
                        (current.location || '').toLowerCase() === (prev.location || '').toLowerCase() &&
                        (current.category || '').toLowerCase() === (prev.category || '').toLowerCase();
    
    if (!isDuplicate) {
      uniqueTxns.push(current);
    }
  }

  // Filter to 5-minute rolling window relative to current transaction
  const rollingTxns = uniqueTxns.filter((t) => {
    if (!t.timestamp) return false;
    const tTime = new Date(t.timestamp).getTime();
    const diffMinutes = Math.abs(currentTxnTime - tTime) / (1000 * 60);
    return diffMinutes <= 5;
  });

  const count = rollingTxns.length;

  // Ignore normal behavior
  if (count < 3) return null;

  // Behavioral progressive velocity scoring:
  // 3 txns -> 0.25
  // 5 txns -> 0.45
  // 8 txns -> 0.72
  // 12+ txns -> 0.90
  // TODO: Improve fraud score realism using adaptive behavioral scaling.
  // Future improvements:
  //   - nonlinear risk scaling based on user historical transaction distributions
  //   - adaptive dynamic fraud thresholds that change based on global merchant security status
  //   - user-specific fraud tolerance based on credit score & history
  //   - contextual risk amplification (e.g. higher risk when user is international)
  //   - financial-risk calibration models mapping scores to actual capital exposure
  // Future AI enhancement:
  //   - Use AI-assisted anomaly severity prediction instead of static weighted scoring.
  let score = 0;
  if (count === 3) score = 0.25;
  else if (count === 4) score = 0.35;
  else if (count === 5) score = 0.45;
  else if (count === 6) score = 0.54;
  else if (count === 7) score = 0.63;
  else if (count === 8) score = 0.72;
  else if (count === 9) score = 0.77;
  else if (count === 10) score = 0.82;
  else if (count === 11) score = 0.86;
  else if (count >= 12) score = 0.90;

  return {
    score,
    weight: 25,
    reason: `${count} transactions detected within 5 minutes — unusual for this user`,
    flag: 'VELOCITY_ATTACK',
  };
}

// -------------------- CORE ENGINE --------------------
// TODO: Improve combined anomaly fusion logic.
// Future improvements:
//   - anomaly correlation engine that matches co-occurring risk factors
//   - compound risk amplification (multiplying/amplifying when specific features co-trigger)
//   - multi-factor fraud escalation (e.g. triggering 3D Secure 2.0 based on anomaly clusters)
//   - cross-signal weighting optimization using genetic algorithms / parameter tuning
// Example:
//   High amount + odd time + new device + velocity burst should produce exponentially higher fraud risk.
// Future AI enhancement:
//   - Use graph-based or ML-assisted fraud correlation models (GNNs for identity theft).
function detectFraud(txn, profile) {
  const triggered = [];
  let totalWeightedScore = 0;

  for (const rule of rules) {
    const result = rule(txn, profile);
    if (result) {
      triggered.push(result);
      totalWeightedScore += result.score * result.weight;
    }
  }

  // 🔥 FINAL FIX: balanced normalization
  const MAX_WEIGHT = 135; // 35 + 20 + 25 + 15 + 15 + 25 = 135

  const normalized = totalWeightedScore / MAX_WEIGHT;

  // Soft curve (not aggressive)
  const curved = Math.pow(clamp(normalized), 0.85);

  const risk_score = Math.round(curved * 100);

  // Velocity specific metrics for logging
  const velocityResult = triggered.find(t => t.flag === 'VELOCITY_ATTACK');
  
  // Calculate rolling count for logging purposes (including the current txn)
  let allTxns = [];
  if (profile.recentTransactions && Array.isArray(profile.recentTransactions)) {
    allTxns = [...profile.recentTransactions];
  }
  const currentTxnTime = new Date(txn.timestamp).getTime();
  const exists = allTxns.some(t => t.timestamp && Math.abs(new Date(t.timestamp).getTime() - currentTxnTime) < 500);
  if (!exists) {
    allTxns.push({ timestamp: txn.timestamp });
  }
  const rollingCount = allTxns.filter(t => {
    if (!t.timestamp) return false;
    const diff = Math.abs(currentTxnTime - new Date(t.timestamp).getTime()) / (1000 * 60);
    return diff <= 5;
  }).length;

  const velScore = velocityResult ? velocityResult.score : 0;
  const velWeighted = velScore * 25;

  console.log('\n[Velocity Monitor]');
  console.log(`Customer: ${profile.cus_id || 'CUST1'}`);
  console.log(`Transactions in active window: ${rollingCount}`);
  console.log(`Historical avg: ${parseFloat(profile.avgDailyTransactions || 2).toFixed(1)}/day`);
  console.log(`Window: 5 mins`);
  console.log(`Velocity score: ${velScore.toFixed(2)}`);
  console.log(`Weighted contribution: ${velWeighted.toFixed(0)}`);
  console.log(`Final fraud score: ${risk_score}\n`);

  // Optionally trigger re-authentication if velocity attack is detected
  const reauth_required = !!velocityResult;

  return {
    risk_score,
    reasons: triggered.map(t => t.reason),
    flags: triggered.map(t => t.flag),
    reauth_required
  };
}

// -------------------- UTILITIES --------------------
function clamp(val) {
  return Math.max(0, Math.min(1, val));
}

function circularDistance(a, b, mod) {
  const diff = Math.abs(a - b) % mod;
  return Math.min(diff, mod - diff);
}

function formatHour(h) {
  const suffix = h >= 12 ? 'PM' : 'AM';
  const display = h % 12 === 0 ? 12 : h % 12;
  return `${display} ${suffix}`;
}

// -------------------- EXPORT --------------------
module.exports = { detectFraud };