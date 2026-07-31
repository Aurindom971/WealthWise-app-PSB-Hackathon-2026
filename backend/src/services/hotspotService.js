const fs = require('fs');
const path = require('path');

const DATA_FILE = path.join(__dirname, '../../data/fraudHotspots.json');

const INITIAL_CHECKPOINTS = [
  {
    id: "CHK-1001",
    name: "Connaught Place Hub",
    state: "Delhi",
    district: "New Delhi Central",
    pincode: "110001",
    latitude: 28.6315,
    longitude: 77.2167,
    type: "Risk",
    riskLevel: "Critical",
    score: 0.92,
    riskScore: 92,
    accessibilityMode: "Start Monitoring",
    status: "Active",
    fraudCases: 182,
    accountsCount: 1420,
    lastUpdated: "2026-07-20T10:00:00Z",
    lastReviewDate: "2026-07-18",
    notes: "High concentration of synthetic identity card-testing attacks."
  },
  {
    id: "CHK-1002",
    name: "Fort Banking Zone",
    state: "Maharashtra",
    district: "Mumbai Fort",
    pincode: "400001",
    latitude: 18.9348,
    longitude: 72.8354,
    type: "Risk",
    riskLevel: "High",
    score: 0.78,
    riskScore: 78,
    accessibilityMode: "Start Monitoring",
    status: "Active",
    fraudCases: 94,
    accountsCount: 890,
    lastUpdated: "2026-07-19T14:30:00Z",
    lastReviewDate: "2026-07-15",
    notes: "Repeated unauthorized rapid transfers from newly opened savings accounts."
  },
  {
    id: "CHK-1003",
    name: "MG Road Commercial Corridor",
    state: "Karnataka",
    district: "Bangalore Urban",
    pincode: "560001",
    latitude: 12.9756,
    longitude: 77.6086,
    type: "Risk",
    riskLevel: "Medium",
    score: 0.55,
    riskScore: 55,
    accessibilityMode: "Start Monitoring",
    status: "Active",
    fraudCases: 41,
    accountsCount: 510,
    lastUpdated: "2026-07-18T09:15:00Z",
    lastReviewDate: "2026-07-10",
    notes: "Elevated phishing activity targeting online wallet loads."
  },
  {
    id: "CHK-1004",
    name: "BBD Bagh Financial District",
    state: "West Bengal",
    district: "Kolkata Central",
    pincode: "700001",
    latitude: 22.5726,
    longitude: 88.3499,
    type: "Risk",
    riskLevel: "High",
    score: 0.70,
    riskScore: 70,
    accessibilityMode: "Start Monitoring",
    status: "Active",
    fraudCases: 72,
    accountsCount: 640,
    lastUpdated: "2026-07-15T11:20:00Z",
    lastReviewDate: "2026-07-12",
    notes: "Mule account clusters identified during festive loan surges."
  },
  {
    id: "CHK-1005",
    name: "Parrys Corner Gateway",
    state: "Tamil Nadu",
    district: "Chennai North",
    pincode: "600001",
    latitude: 13.0891,
    longitude: 80.2877,
    type: "Warning",
    riskLevel: "Low",
    score: 0.25,
    riskScore: 25,
    accessibilityMode: "Start Monitoring",
    status: "Active",
    fraudCases: 12,
    accountsCount: 310,
    lastUpdated: "2026-07-10T16:45:00Z",
    lastReviewDate: "2026-07-05",
    notes: "Preemptively placed on warning monitoring due to neighboring region incidents."
  },
  {
    id: "CHK-1006",
    name: "Jamtara Cyber Cluster",
    state: "Jharkhand",
    district: "Jamtara",
    pincode: "815351",
    latitude: 23.9631,
    longitude: 86.8027,
    type: "Risk",
    riskLevel: "Critical",
    score: 0.96,
    riskScore: 96,
    accessibilityMode: "Start Monitoring",
    status: "Active",
    fraudCases: 345,
    accountsCount: 2150,
    lastUpdated: "2026-07-21T08:00:00Z",
    lastReviewDate: "2026-07-20",
    notes: "Primary vishing & APK malware scam node. High vulnerability radius."
  },
  {
    id: "CHK-1007",
    name: "Mewat Cyber Ring",
    state: "Haryana",
    district: "Nuh",
    pincode: "122107",
    latitude: 28.1027,
    longitude: 77.0006,
    type: "Risk",
    riskLevel: "Critical",
    score: 0.94,
    riskScore: 94,
    accessibilityMode: "Start Monitoring",
    status: "Active",
    fraudCases: 290,
    accountsCount: 1890,
    lastUpdated: "2026-07-21T09:30:00Z",
    lastReviewDate: "2026-07-19",
    notes: "Sextortion and marketplace fraud origins."
  },
  {
    id: "CHK-1008",
    name: "Bharatpur Border Hotspot",
    state: "Rajasthan",
    district: "Bharatpur",
    pincode: "321001",
    latitude: 27.2170,
    longitude: 77.4895,
    type: "Risk",
    riskLevel: "High",
    score: 0.85,
    riskScore: 85,
    accessibilityMode: "Start Monitoring",
    status: "Active",
    fraudCases: 168,
    accountsCount: 1120,
    lastUpdated: "2026-07-20T17:10:00Z",
    lastReviewDate: "2026-07-17",
    notes: "Fake SIM cards registered with forged KYC credentials."
  },
  {
    id: "CHK-1009",
    name: "Abids Commercial Hub",
    state: "Telangana",
    district: "Hyderabad Central",
    pincode: "500001",
    latitude: 17.3891,
    longitude: 78.4744,
    type: "Risk",
    riskLevel: "Medium",
    score: 0.62,
    riskScore: 62,
    accessibilityMode: "Start Monitoring",
    status: "Active",
    fraudCases: 58,
    accountsCount: 730,
    lastUpdated: "2026-07-17T12:00:00Z",
    lastReviewDate: "2026-07-11",
    notes: "Atm card cloning attempts detected near transport hubs."
  },
  {
    id: "CHK-1010",
    name: "CG Road Tech Corridor",
    state: "Gujarat",
    district: "Ahmedabad West",
    pincode: "380009",
    latitude: 23.0336,
    longitude: 72.5645,
    type: "Risk",
    riskLevel: "Medium",
    score: 0.58,
    riskScore: 58,
    accessibilityMode: "Start Monitoring",
    status: "Active",
    fraudCases: 49,
    accountsCount: 680,
    lastUpdated: "2026-07-16T15:00:00Z",
    lastReviewDate: "2026-07-09",
    notes: "High velocity investment scheme scams targeting retail investors."
  },
  {
    id: "CHK-1011",
    name: "Hazratganj Plaza",
    state: "Uttar Pradesh",
    district: "Lucknow Central",
    pincode: "226001",
    latitude: 26.8467,
    longitude: 80.9462,
    type: "Risk",
    riskLevel: "High",
    score: 0.76,
    riskScore: 76,
    accessibilityMode: "Start Monitoring",
    status: "Active",
    fraudCases: 112,
    accountsCount: 950,
    lastUpdated: "2026-07-19T18:40:00Z",
    lastReviewDate: "2026-07-14",
    notes: "Fake job portal upfront fee scams routed through regional accounts."
  },
  {
    id: "CHK-1012",
    name: "Sector 17 Plaza",
    state: "Punjab",
    district: "Chandigarh",
    pincode: "160017",
    latitude: 30.7398,
    longitude: 76.7827,
    type: "Warning",
    riskLevel: "Low",
    score: 0.28,
    riskScore: 28,
    accessibilityMode: "Start Monitoring",
    status: "Active",
    fraudCases: 15,
    accountsCount: 290,
    lastUpdated: "2026-07-11T10:15:00Z",
    lastReviewDate: "2026-07-04",
    notes: "Pre-watchlist warning for foreign visa processing payment fraud."
  },
  {
    id: "CHK-1013",
    name: "Vashi Sector 17",
    state: "Maharashtra",
    district: "Navi Mumbai",
    pincode: "400703",
    latitude: 19.0770,
    longitude: 73.0033,
    type: "Risk",
    riskLevel: "High",
    score: 0.74,
    riskScore: 74,
    accessibilityMode: "Start Monitoring",
    status: "Active",
    fraudCases: 87,
    accountsCount: 810,
    lastUpdated: "2026-07-18T13:25:00Z",
    lastReviewDate: "2026-07-13",
    notes: "Part-time job task scam payouts tracked to shell accounts."
  },
  {
    id: "CHK-1014",
    name: "Patna Main Junction Ring",
    state: "Bihar",
    district: "Patna Central",
    pincode: "800001",
    latitude: 25.6093,
    longitude: 85.1376,
    type: "Risk",
    riskLevel: "High",
    score: 0.81,
    riskScore: 81,
    accessibilityMode: "Start Monitoring",
    status: "Active",
    fraudCases: 143,
    accountsCount: 1040,
    lastUpdated: "2026-07-20T11:00:00Z",
    lastReviewDate: "2026-07-16",
    notes: "Fake loan app auto-debit extortion complaints."
  },
  {
    id: "CHK-1015",
    name: "Koramangala Tech Park",
    state: "Karnataka",
    district: "Bangalore South",
    pincode: "560034",
    latitude: 12.9352,
    longitude: 77.6245,
    type: "Risk",
    riskLevel: "Medium",
    score: 0.50,
    riskScore: 50,
    accessibilityMode: "Start Monitoring",
    status: "Active",
    fraudCases: 38,
    accountsCount: 620,
    lastUpdated: "2026-07-14T08:30:00Z",
    lastReviewDate: "2026-07-08",
    notes: "SIM swap OTP bypass attacks reported by corporate users."
  },
  {
    id: "CHK-1016",
    name: "Bhubaneswar Smart City Hub",
    state: "Odisha",
    district: "Khurda",
    pincode: "751001",
    latitude: 20.2961,
    longitude: 85.8245,
    type: "Risk",
    riskLevel: "Medium",
    score: 0.48,
    riskScore: 48,
    accessibilityMode: "Start Monitoring",
    status: "Active",
    fraudCases: 32,
    accountsCount: 450,
    lastUpdated: "2026-07-13T14:10:00Z",
    lastReviewDate: "2026-07-07",
    notes: "Utility bill scam SMS link clickthroughs."
  },
  {
    id: "CHK-1017",
    name: "Indore Rajwada Sector",
    state: "Madhya Pradesh",
    district: "Indore",
    pincode: "452002",
    latitude: 22.7196,
    longitude: 75.8577,
    type: "Risk",
    riskLevel: "High",
    score: 0.72,
    riskScore: 72,
    accessibilityMode: "Start Monitoring",
    status: "Active",
    fraudCases: 76,
    accountsCount: 780,
    lastUpdated: "2026-07-17T16:50:00Z",
    lastReviewDate: "2026-07-12",
    notes: "Unregistered payment aggregators operating without KYC."
  },
  {
    id: "CHK-1018",
    name: "Dehradun Rajpur Belt",
    state: "Uttarakhand",
    district: "Dehradun",
    pincode: "248001",
    latitude: 30.3165,
    longitude: 78.0322,
    type: "Risk",
    riskLevel: "Medium",
    score: 0.42,
    riskScore: 42,
    accessibilityMode: "Start Monitoring",
    status: "Active",
    fraudCases: 24,
    accountsCount: 390,
    lastUpdated: "2026-07-12T10:00:00Z",
    lastReviewDate: "2026-07-06",
    notes: "Homestay booking phishing site payments."
  },
  {
    id: "CHK-1019",
    name: "Siliguri Junction Archive Zone",
    state: "West Bengal",
    district: "Darjeeling",
    pincode: "734001",
    latitude: 26.7271,
    longitude: 88.4235,
    type: "Risk",
    riskLevel: "High",
    score: 0.68,
    riskScore: 68,
    accessibilityMode: "Store Only",
    status: "Active",
    fraudCases: 64,
    accountsCount: 580,
    lastUpdated: "2026-07-15T09:00:00Z",
    lastReviewDate: "2026-07-10",
    notes: "Archived historical hotspot kept for cross-border anomaly research without affecting live scores."
  },
  {
    id: "CHK-1020",
    name: "Guwahati Fancy Bazaar Reserve",
    state: "Assam",
    district: "Kamrup Metropolitan",
    pincode: "781001",
    latitude: 26.1858,
    longitude: 91.7477,
    type: "Risk",
    riskLevel: "Medium",
    score: 0.52,
    riskScore: 52,
    accessibilityMode: "Store Only",
    status: "Active",
    fraudCases: 45,
    accountsCount: 470,
    lastUpdated: "2026-07-14T11:45:00Z",
    lastReviewDate: "2026-07-08",
    notes: "Stored checkpoint maintained in database for future risk activation model testing."
  }
];

let hotspots = [];
let recentActivity = [];
let recentAlerts = [];

function init() {
  try {
    if (fs.existsSync(DATA_FILE)) {
      const data = fs.readFileSync(DATA_FILE, 'utf8');
      hotspots = JSON.parse(data);
      // Ensure all objects have full fields
      hotspots = normalizeCheckpoints(hotspots);
    } else {
      hotspots = [...INITIAL_CHECKPOINTS];
      saveData();
    }
  } catch (err) {
    console.error('[HotspotService] Initialization error:', err);
    hotspots = [...INITIAL_CHECKPOINTS];
  }

  // Seed default activities & alerts if empty
  recentActivity = [
    { id: 'ACT-101', text: 'System initialized 20 hotspot checkpoints (18 Start Monitoring, 2 Store Only)', timestamp: new Date().toISOString() },
    { id: 'ACT-102', text: 'Jamtara Cyber Cluster updated to Critical Risk (96%)', timestamp: new Date(Date.now() - 3600000 * 4).toISOString() },
    { id: 'ACT-103', text: 'Accessibility mode for CHK-1019 set to Store Only', timestamp: new Date(Date.now() - 3600000 * 12).toISOString() }
  ];

  recentAlerts = [
    { id: 'ALT-501', pincode: '815351', region: 'Jamtara, Jharkhand', riskLevel: 'Critical', text: 'Sudden spike in APK malware phishing cases (+45 cases)', timestamp: new Date(Date.now() - 3600000 * 2).toISOString() },
    { id: 'ALT-502', pincode: '122107', region: 'Nuh (Mewat), Haryana', riskLevel: 'Critical', text: 'High velocity sextortion ring detected across 12 newly opened accounts', timestamp: new Date(Date.now() - 3600000 * 6).toISOString() },
    { id: 'ALT-503', pincode: '110001', region: 'Connaught Place, Delhi', riskLevel: 'Critical', text: 'Multiple synthetic identity card-testing bursts detected', timestamp: new Date(Date.now() - 3600000 * 18).toISOString() }
  ];
}

function normalizeCheckpoints(list) {
  return list.map((item, idx) => {
    const rawScore = item.score != null ? parseFloat(item.score) : 0.5;
    const rScore = item.riskScore != null ? parseInt(item.riskScore, 10) : Math.round(rawScore * 100);

    return {
      id: item.id || `CHK-${1001 + idx}`,
      name: item.name || `${item.district || 'Checkpoint'} Zone`,
      state: item.state || 'Unknown State',
      district: item.district || 'Unknown District',
      pincode: String(item.pincode || '000000'),
      latitude: item.latitude != null ? parseFloat(item.latitude) : 20.5937,
      longitude: item.longitude != null ? parseFloat(item.longitude) : 78.9629,
      type: item.type || (rScore >= 35 ? 'Risk' : 'Warning'),
      riskLevel: item.riskLevel ? (item.riskLevel.charAt(0).toUpperCase() + item.riskLevel.slice(1).toLowerCase()) : 'Medium',
      score: rawScore,
      riskScore: rScore,
      accessibilityMode: item.accessibilityMode || (idx >= 18 ? 'Store Only' : 'Start Monitoring'),
      status: item.status || 'Active',
      fraudCases: item.fraudCases != null ? parseInt(item.fraudCases, 10) : 10,
      accountsCount: item.accountsCount != null ? parseInt(item.accountsCount, 10) : 250,
      lastUpdated: item.lastUpdated || new Date().toISOString(),
      lastReviewDate: item.lastReviewDate || new Date().toISOString().split('T')[0],
      notes: item.notes || ''
    };
  });
}

function saveData() {
  try {
    const dir = path.dirname(DATA_FILE);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(DATA_FILE, JSON.stringify(hotspots, null, 2), 'utf8');
  } catch (err) {
    console.error('[HotspotService] Save error:', err);
  }
}

function getAllCheckpoints(filters = {}) {
  let result = [...hotspots];

  if (filters.state) {
    result = result.filter(c => c.state.toLowerCase() === filters.state.toLowerCase());
  }
  if (filters.district) {
    result = result.filter(c => c.district.toLowerCase() === filters.district.toLowerCase());
  }
  if (filters.riskLevel) {
    result = result.filter(c => c.riskLevel.toLowerCase() === filters.riskLevel.toLowerCase());
  }
  if (filters.accessibilityMode) {
    result = result.filter(c => c.accessibilityMode.toLowerCase() === filters.accessibilityMode.toLowerCase());
  }
  if (filters.status) {
    result = result.filter(c => c.status.toLowerCase() === filters.status.toLowerCase());
  }
  if (filters.search) {
    const q = filters.search.toLowerCase().trim();
    result = result.filter(c =>
      c.pincode.includes(q) ||
      c.district.toLowerCase().includes(q) ||
      c.name.toLowerCase().includes(q) ||
      c.state.toLowerCase().includes(q) ||
      c.id.toLowerCase().includes(q)
    );
  }

  return result;
}

function getCheckpointById(id) {
  return hotspots.find(c => c.id === id);
}

function getHotspotByPincode(pincode) {
  return hotspots.find(c =>
    c.pincode === String(pincode) &&
    c.status === 'Active' &&
    c.accessibilityMode === 'Start Monitoring'
  );
}

function getStats() {
  const totalCheckpoints = hotspots.length;
  const riskCheckpoints = hotspots.filter(c => c.type === 'Risk').length;
  const warningCheckpoints = hotspots.filter(c => c.type === 'Warning').length;
  const totalAccountsInHotspots = hotspots.reduce((sum, c) => sum + (c.accountsCount || 0), 0);
  
  const activeCount = hotspots.length || 1;
  const avgScoreVal = hotspots.reduce((sum, c) => sum + (c.riskScore || 0), 0) / activeCount;
  const averageRiskScore = Math.round(avgScoreVal);

  const startMonitoringCount = hotspots.filter(c => c.accessibilityMode === 'Start Monitoring').length;
  const storeOnlyCount = hotspots.filter(c => c.accessibilityMode === 'Store Only').length;

  return {
    totalCheckpoints,
    riskCheckpoints,
    warningCheckpoints,
    totalAccountsInHotspots,
    averageRiskScore,
    startMonitoringCount,
    storeOnlyCount,
    systemStatus: 'ACTIVE & MONITORING'
  };
}

function createCheckpoint(data) {
  const nextNum = hotspots.length > 0
    ? Math.max(...hotspots.map(c => parseInt(c.id.replace(/\D/g, '') || '1000', 10))) + 1
    : 1001;

  const rScore = data.riskScore != null ? parseInt(data.riskScore, 10) : (data.score != null ? Math.round(data.score * 100) : 50);

  const newCheckpoint = {
    id: `CHK-${nextNum}`,
    name: data.name || `${data.district || 'Checkpoint'} Area`,
    state: data.state || 'Delhi',
    district: data.district || 'New Delhi',
    pincode: String(data.pincode || '110001'),
    latitude: data.latitude != null ? parseFloat(data.latitude) : 28.6139,
    longitude: data.longitude != null ? parseFloat(data.longitude) : 77.2090,
    type: data.type || (rScore >= 35 ? 'Risk' : 'Warning'),
    riskLevel: data.riskLevel || 'Medium',
    score: rScore / 100,
    riskScore: rScore,
    accessibilityMode: data.accessibilityMode || 'Start Monitoring',
    status: data.status || 'Active',
    fraudCases: data.fraudCases != null ? parseInt(data.fraudCases, 10) : 0,
    accountsCount: data.accountsCount != null ? parseInt(data.accountsCount, 10) : 100,
    lastUpdated: new Date().toISOString(),
    lastReviewDate: data.lastReviewDate || new Date().toISOString().split('T')[0],
    notes: data.notes || ''
  };

  hotspots.push(newCheckpoint);
  saveData();

  addActivity(`Added new checkpoint "${newCheckpoint.name}" (${newCheckpoint.pincode})`);
  return newCheckpoint;
}

function updateCheckpoint(id, updates) {
  const index = hotspots.findIndex(c => c.id === id);
  if (index === -1) return null;

  const current = hotspots[index];
  const rScore = updates.riskScore != null ? parseInt(updates.riskScore, 10) : (updates.score != null ? Math.round(updates.score * 100) : current.riskScore);

  const updated = {
    ...current,
    ...updates,
    id: current.id,
    pincode: updates.pincode != null ? String(updates.pincode) : current.pincode,
    score: rScore / 100,
    riskScore: rScore,
    type: updates.type || (rScore >= 35 ? 'Risk' : 'Warning'),
    latitude: updates.latitude != null ? parseFloat(updates.latitude) : current.latitude,
    longitude: updates.longitude != null ? parseFloat(updates.longitude) : current.longitude,
    lastUpdated: new Date().toISOString()
  };

  hotspots[index] = updated;
  saveData();

  addActivity(`Updated checkpoint "${updated.name}" (${updated.id})`);
  return updated;
}

function deleteCheckpoint(id) {
  const index = hotspots.findIndex(c => c.id === id);
  if (index === -1) return false;

  const removed = hotspots.splice(index, 1)[0];
  saveData();

  addActivity(`Deleted checkpoint "${removed.name}" (${removed.id})`);
  return true;
}

function toggleAccessibilityMode(id, newMode) {
  const checkpoint = getCheckpointById(id);
  if (!checkpoint) return null;

  const targetMode = newMode || (checkpoint.accessibilityMode === 'Start Monitoring' ? 'Store Only' : 'Start Monitoring');
  checkpoint.accessibilityMode = targetMode;
  checkpoint.lastUpdated = new Date().toISOString();

  saveData();

  addActivity(`Changed accessibility mode of ${checkpoint.name} to "${targetMode}"`);
  return checkpoint;
}

function importHotspots(items) {
  if (!Array.isArray(items)) return { count: 0 };

  const normalized = normalizeCheckpoints(items);
  hotspots = normalized;
  saveData();

  addActivity(`Imported ${hotspots.length} hotspots into control database`);
  return { count: hotspots.length };
}

function refreshDatabase() {
  init();
  addActivity('Refreshed hotspot database and recomputed analytics');
  return getStats();
}

function addActivity(text) {
  recentActivity.unshift({
    id: `ACT-${Date.now()}`,
    text,
    timestamp: new Date().toISOString()
  });
  if (recentActivity.length > 20) recentActivity.pop();
}

function getActivitiesAndAlerts() {
  return {
    recentActivity,
    recentAlerts
  };
}

init();

module.exports = {
  getAllCheckpoints,
  getCheckpointById,
  getHotspotByPincode,
  getStats,
  createCheckpoint,
  updateCheckpoint,
  deleteCheckpoint,
  toggleAccessibilityMode,
  importHotspots,
  refreshDatabase,
  getActivitiesAndAlerts
};
