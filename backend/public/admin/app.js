// Admin Hotspot Control Center - Client Controller JS

let allCheckpoints = [];
let leafletMap = null;
let mapMarkers = [];

document.addEventListener('DOMContentLoaded', () => {
  initDashboard();
});

async function initDashboard() {
  await fetchStats();
  await fetchCheckpoints();
  await fetchActivitiesAndAlerts();
  initIndiaMap();
}

// 1. Fetch Stats & Populate KPI Cards
async function fetchStats() {
  try {
    const res = await fetch('/api/hotspots/stats');
    const json = await res.json();
    if (json.success) {
      const stats = json.data;
      document.getElementById('kpiTotalCheckpoints').innerText = stats.totalCheckpoints;
      document.getElementById('kpiRiskCheckpoints').innerText = stats.riskCheckpoints;
      document.getElementById('kpiWarningCheckpoints').innerText = stats.warningCheckpoints;
      document.getElementById('kpiTotalAccounts').innerText = (stats.totalAccountsInHotspots || 0).toLocaleString();
      document.getElementById('kpiAvgRiskScore').innerText = `${stats.averageRiskScore}%`;
      document.getElementById('systemStatusText').innerText = stats.systemStatus || 'ACTIVE & MONITORING';
    }
  } catch (err) {
    console.error('Error fetching stats:', err);
  }
}

// 2. Fetch Checkpoints
async function fetchCheckpoints() {
  try {
    const res = await fetch('/api/hotspots');
    const json = await res.json();
    if (json.success) {
      allCheckpoints = json.data;
      populateFilterDropdowns(allCheckpoints);
      renderTable(allCheckpoints);
      updateMapMarkers(allCheckpoints);
    }
  } catch (err) {
    console.error('Error fetching checkpoints:', err);
  }
}

// 3. Fetch Audit Trail & Alerts
async function fetchActivitiesAndAlerts() {
  try {
    const res = await fetch('/api/hotspots/activity');
    const json = await res.json();
    if (json.success) {
      renderActivities(json.data.recentActivity || []);
      renderAlerts(json.data.recentAlerts || []);
    }
  } catch (err) {
    console.error('Error fetching activities:', err);
  }
}

// Populate State & District Filter Options dynamically
function populateFilterDropdowns(list) {
  const stateSelect = document.getElementById('stateFilter');
  const districtSelect = document.getElementById('districtFilter');

  const selectedState = stateSelect.value;
  const selectedDistrict = districtSelect.value;

  const states = [...new Set(list.map(c => c.state))].sort();
  const districts = [...new Set(list.map(c => c.district))].sort();

  stateSelect.innerHTML = '<option value="">All States</option>' +
    states.map(s => `<option value="${s}" ${s === selectedState ? 'selected' : ''}>${s}</option>`).join('');

  districtSelect.innerHTML = '<option value="">All Districts</option>' +
    districts.map(d => `<option value="${d}" ${d === selectedDistrict ? 'selected' : ''}>${d}</option>`).join('');
}

// Render Table
function renderTable(list) {
  const tableBody = document.getElementById('tableBody');
  document.getElementById('tableResultCount').innerText = list.length;

  if (list.length === 0) {
    tableBody.innerHTML = `<tr><td colspan="7" style="text-align: center; color: var(--text-dim); padding: 30px;">No checkpoints found matching filters.</td></tr>`;
    return;
  }

  tableBody.innerHTML = list.map(item => {
    const isRisk = item.type === 'Risk';

    let scoreClass = 'fill-medium';
    if (item.riskScore >= 85) scoreClass = 'fill-critical';
    else if (item.riskScore >= 65) scoreClass = 'fill-high';
    else if (item.riskScore < 35) scoreClass = 'fill-low';

    return `
      <tr>
        <td style="font-weight: 700; color: var(--accent-blue);">${item.id}</td>
        <td>
          <div style="font-weight: 600;">${escapeHtml(item.name)}</div>
          <div style="font-size: 11px; color: var(--text-muted);">${escapeHtml(item.district)}, ${escapeHtml(item.state)} (${item.pincode})</div>
        </td>
        <td>
          <span class="type-badge ${isRisk ? 'type-risk' : 'type-warning'}">
            <i class="fa-solid ${isRisk ? 'fa-triangle-exclamation' : 'fa-bell'}"></i>
            ${item.type}
          </span>
        </td>
        <td>
          <div class="risk-score-bar">
            <span style="font-weight: 700; width: 36px;">${item.riskScore}%</span>
            <div class="score-progress">
              <div class="score-fill ${scoreClass}" style="width: ${item.riskScore}%;"></div>
            </div>
          </div>
          <div style="font-size: 10px; color: var(--text-dim); margin-top: 2px;">Level: ${item.riskLevel}</div>
        </td>
        <td>
          <span style="color: ${item.status === 'Active' ? 'var(--accent-emerald)' : 'var(--text-dim)'}; font-weight: 600;">
            ● ${item.status}
          </span>
        </td>
        <td style="font-weight: 600;">${item.fraudCases || 0}</td>
        <td>
          <div class="action-btns">
            <button class="icon-btn" title="Edit Checkpoint" onclick="openEditModal('${item.id}')">
              <i class="fa-solid fa-pen-to-square"></i>
            </button>
            <button class="icon-btn icon-btn-danger" title="Delete Checkpoint" onclick="handleDeleteCheckpoint('${item.id}')">
              <i class="fa-solid fa-trash-can"></i>
            </button>
          </div>
        </td>
      </tr>
    `;
  }).join('');
}

// Search & Filter Handler
function handleSearchFilter() {
  const search = document.getElementById('searchInput').value.toLowerCase().trim();
  const state = document.getElementById('stateFilter').value;
  const district = document.getElementById('districtFilter').value;
  const riskLevel = document.getElementById('riskLevelFilter').value;
  const status = document.getElementById('statusFilter').value;

  let filtered = allCheckpoints.filter(item => {
    if (state && item.state !== state) return false;
    if (district && item.district !== district) return false;
    if (riskLevel && item.riskLevel.toLowerCase() !== riskLevel.toLowerCase()) return false;
    if (status && item.status !== status) return false;

    if (search) {
      const matchSearch =
        item.pincode.includes(search) ||
        item.name.toLowerCase().includes(search) ||
        item.district.toLowerCase().includes(search) ||
        item.state.toLowerCase().includes(search) ||
        item.id.toLowerCase().includes(search);
      if (!matchSearch) return false;
    }
    return true;
  });

  renderTable(filtered);
  updateMapMarkers(filtered);
}

// Interactive India Map Setup
function initIndiaMap() {
  if (leafletMap) return;

  // Center over India
  leafletMap = L.map('indiaMap').setView([22.5937, 78.9629], 4.5);

  L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
    attribution: '&copy; OpenStreetMap &copy; CARTO',
    maxZoom: 18
  }).addTo(leafletMap);

  updateMapMarkers(allCheckpoints);
}

function updateMapMarkers(checkpoints) {
  if (!leafletMap) return;

  // Clear existing markers
  mapMarkers.forEach(m => leafletMap.removeLayer(m));
  mapMarkers = [];

  checkpoints.forEach(item => {
    if (item.latitude && item.longitude) {
      const isRisk = item.type === 'Risk';
      const color = isRisk ? '#ef4444' : '#f59e0b';

      const circleMarker = L.circleMarker([item.latitude, item.longitude], {
        radius: isRisk ? 8 : 6,
        fillColor: color,
        color: '#ffffff',
        weight: 1.5,
        opacity: 0.9,
        fillOpacity: 0.8
      }).addTo(leafletMap);

      const popupHtml = `
        <div style="font-family: var(--font-family); color: #000; padding: 4px;">
          <h4 style="margin: 0 0 4px 0; font-size: 14px; color: #1e293b;">${escapeHtml(item.name)}</h4>
          <div style="font-size: 12px; color: #475569;">
            <b>ID:</b> ${item.id}<br/>
            <b>Location:</b> ${escapeHtml(item.district)}, ${escapeHtml(item.state)} (${item.pincode})<br/>
            <b>Type:</b> <span style="color:${color}; font-weight:700;">${item.type}</span> (${item.riskLevel} - ${item.riskScore}%)<br/>
            <b>Mode:</b> ${item.accessibilityMode}<br/>
            <b>Cases:</b> ${item.fraudCases || 0}
          </div>
        </div>
      `;

      circleMarker.bindPopup(popupHtml);
      mapMarkers.push(circleMarker);
    }
  });
}

// Toggle Accessibility Mode (Start Monitoring <-> Store Only)
async function toggleMode(id, currentMode) {
  const newMode = currentMode === 'Start Monitoring' ? 'Store Only' : 'Start Monitoring';
  try {
    const res = await fetch(`/api/hotspots/${id}/accessibility`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ accessibilityMode: newMode })
    });
    const json = await res.json();
    if (json.success) {
      await fetchStats();
      await fetchCheckpoints();
      await fetchActivitiesAndAlerts();
    }
  } catch (err) {
    alert('Failed to update accessibility mode');
  }
}

// Add/Edit Modal Handlers
function openAddModal() {
  document.getElementById('modalTitle').innerText = 'Add Hotspot Checkpoint';
  document.getElementById('checkpointForm').reset();
  document.getElementById('formCheckpointId').value = '';
  document.getElementById('formRiskScore').value = 75;
  document.getElementById('formRiskLevel').value = 'High';
  document.getElementById('formStatus').value = 'Active';
  document.getElementById('formLastReviewDate').value = new Date().toISOString().split('T')[0];

  document.getElementById('checkpointModal').classList.add('active');
}

function openEditModal(id) {
  const item = allCheckpoints.find(c => c.id === id);
  if (!item) return;

  document.getElementById('modalTitle').innerText = `Edit Checkpoint ${item.id}`;
  document.getElementById('formCheckpointId').value = item.id;
  document.getElementById('formName').value = item.name;
  document.getElementById('formState').value = item.state;
  document.getElementById('formDistrict').value = item.district;
  document.getElementById('formPincode').value = item.pincode;
  document.getElementById('formRiskLevel').value = item.riskLevel;
  document.getElementById('formRiskScore').value = item.riskScore;
  document.getElementById('formStatus').value = item.status;
  document.getElementById('formFraudCases').value = item.fraudCases || 0;
  document.getElementById('formLatitude').value = item.latitude || '';
  document.getElementById('formLongitude').value = item.longitude || '';
  document.getElementById('formLastReviewDate').value = item.lastReviewDate || new Date().toISOString().split('T')[0];
  document.getElementById('formNotes').value = item.notes || '';

  document.getElementById('checkpointModal').classList.add('active');
}

function syncScoreWithLevel() {
  const level = document.getElementById('formRiskLevel').value;
  const scoreInput = document.getElementById('formRiskScore');
  if (level === 'Critical') scoreInput.value = 92;
  else if (level === 'High') scoreInput.value = 75;
  else if (level === 'Medium') scoreInput.value = 55;
  else if (level === 'Low') scoreInput.value = 25;
}

async function handleSaveCheckpoint(event) {
  event.preventDefault();

  const id = document.getElementById('formCheckpointId').value;
  const payload = {
    name: document.getElementById('formName').value.trim(),
    state: document.getElementById('formState').value.trim(),
    district: document.getElementById('formDistrict').value.trim(),
    pincode: document.getElementById('formPincode').value.trim(),
    riskLevel: document.getElementById('formRiskLevel').value,
    riskScore: parseInt(document.getElementById('formRiskScore').value, 10),
    status: document.getElementById('formStatus').value,
    fraudCases: parseInt(document.getElementById('formFraudCases').value, 10) || 0,
    latitude: document.getElementById('formLatitude').value ? parseFloat(document.getElementById('formLatitude').value) : null,
    longitude: document.getElementById('formLongitude').value ? parseFloat(document.getElementById('formLongitude').value) : null,
    lastReviewDate: document.getElementById('formLastReviewDate').value,
    notes: document.getElementById('formNotes').value.trim()
  };

  try {
    const method = id ? 'PUT' : 'POST';
    const url = id ? `/api/hotspots/${id}` : '/api/hotspots';

    const res = await fetch(url, {
      method,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    const json = await res.json();

    if (json.success) {
      closeModal('checkpointModal');
      await fetchStats();
      await fetchCheckpoints();
      await fetchActivitiesAndAlerts();
    } else {
      alert('Error: ' + json.error);
    }
  } catch (err) {
    alert('Failed to save checkpoint');
  }
}

async function handleDeleteCheckpoint(id) {
  if (!confirm(`Are you sure you want to delete checkpoint ${id}?`)) return;

  try {
    const res = await fetch(`/api/hotspots/${id}`, { method: 'DELETE' });
    const json = await res.json();
    if (json.success) {
      await fetchStats();
      await fetchCheckpoints();
      await fetchActivitiesAndAlerts();
    } else {
      alert('Error: ' + json.error);
    }
  } catch (err) {
    alert('Failed to delete checkpoint');
  }
}

// Import Modal
function openImportModal() {
  document.getElementById('importTextarea').value = '';
  document.getElementById('importModal').classList.add('active');
}

async function handleImportSubmit() {
  const raw = document.getElementById('importTextarea').value.trim();
  if (!raw) return;

  try {
    const items = JSON.parse(raw);
    const res = await fetch('/api/hotspots/import', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ items })
    });
    const json = await res.json();
    if (json.success) {
      closeModal('importModal');
      await fetchStats();
      await fetchCheckpoints();
      await fetchActivitiesAndAlerts();
      alert(`Imported ${json.data.count} checkpoints successfully!`);
    } else {
      alert('Import Error: ' + json.error);
    }
  } catch (err) {
    alert('Invalid JSON format: ' + err.message);
  }
}

// Export CSV
function exportData(format = 'csv') {
  window.open(`/api/hotspots/export?format=${format}`, '_blank');
}

// Refresh Database
async function refreshDatabase() {
  try {
    const res = await fetch('/api/hotspots/refresh', { method: 'POST' });
    const json = await res.json();
    if (json.success) {
      await fetchStats();
      await fetchCheckpoints();
      await fetchActivitiesAndAlerts();
      alert('Database refreshed successfully!');
    }
  } catch (err) {
    alert('Refresh failed');
  }
}

function closeModal(id) {
  document.getElementById(id).classList.remove('active');
}

// Render Activities List
function renderActivities(activities) {
  const listEl = document.getElementById('activityList');
  if (activities.length === 0) {
    listEl.innerHTML = '<li class="activity-item"><div class="item-content"><p>No recent activity logs.</p></div></li>';
    return;
  }

  listEl.innerHTML = activities.map(act => `
    <li class="activity-item">
      <div class="item-icon" style="background: rgba(56, 189, 248, 0.1); color: var(--accent-blue);">
        <i class="fa-solid fa-list-check"></i>
      </div>
      <div class="item-content">
        <p>${escapeHtml(act.text)}</p>
        <span class="item-time">${formatDate(act.timestamp)}</span>
      </div>
    </li>
  `).join('');
}

// Render Alerts List
function renderAlerts(alerts) {
  const listEl = document.getElementById('alertsList');
  if (alerts.length === 0) {
    listEl.innerHTML = '<li class="alert-item"><div class="item-content"><p>No active critical alerts.</p></div></li>';
    return;
  }

  listEl.innerHTML = alerts.map(alt => `
    <li class="alert-item">
      <div class="item-icon" style="background: rgba(239, 68, 68, 0.1); color: var(--accent-danger);">
        <i class="fa-solid fa-triangle-exclamation"></i>
      </div>
      <div class="item-content">
        <p><b>${escapeHtml(alt.region)}</b> (${alt.pincode})</p>
        <p style="color: var(--text-muted); margin-top: 2px;">${escapeHtml(alt.text)}</p>
        <span class="item-time">${formatDate(alt.timestamp)}</span>
      </div>
    </li>
  `).join('');
}

function formatDate(isoStr) {
  if (!isoStr) return '';
  const d = new Date(isoStr);
  return d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) + ' - ' + d.toLocaleDateString();
}

function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}
