/**
 * FINAL Dynamic Fraud Detection Engine (Balanced)
 * ===============================================
 * ✔ Correct UTC handling
 * ✔ Clean anomaly filtering
 * ✔ Balanced scoring (no over-aggression)
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
  if (!profile.recentTransactions?.length || !txn.timestamp) return null;

  const currentTxnTime = new Date(txn.timestamp).getTime();

  const recentTxns = profile.recentTransactions.filter((t) => {
    if (!t.timestamp) return false;

    const prevTxnTime = new Date(t.timestamp).getTime();

    const diffMinutes =
      Math.abs(currentTxnTime - prevTxnTime) / (1000 * 60);

    return diffMinutes <= 5;
  });

  const count = recentTxns.length;

  // Ignore normal behavior
  if (count < 3) return null;

  // More transactions in short time = higher score
  const score = clamp(count / 10);

  return {
    score,
    weight: 25,
    reason: `${count} transactions detected within 5 minutes`,
    flag: 'HIGH_VELOCITY',
  };
}

// -------------------- CORE ENGINE --------------------
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
  console.log({
    risk_score,
    reasons: triggered.map(t => t.reason),
    flags: triggered.map(t => t.flag),
  });

  return {
    risk_score,
    reasons: triggered.map(t => t.reason),
    flags: triggered.map(t => t.flag),
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