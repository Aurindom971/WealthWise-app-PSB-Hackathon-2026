const axios = require('axios');

const BASE_URL = 'http://localhost:3000';
const CUS_ID = 'CUST1';

async function testEndpoints() {
  console.log('=== STARTING ENDPOINT TESTS ===');
  
  const endpoints = [
    { name: 'Health Check', path: '/health', method: 'GET', data: {} },
    { name: 'Financial Insights', path: '/financial-insights', method: 'POST', data: { cus_id: CUS_ID } },
    { name: 'Financial Health', path: '/financial-health', method: 'POST', data: { cus_id: CUS_ID } },
    { name: 'Suspicious Transactions', path: '/suspicious-transactions', method: 'POST', data: { cus_id: CUS_ID } },
    { name: 'Expense Analysis', path: '/expense-analysis', method: 'POST', data: { cus_id: CUS_ID } },
    { name: 'Savings Advice', path: '/savings-advice', method: 'POST', data: { cus_id: CUS_ID } }
  ];

  for (const ep of endpoints) {
    console.log(`\n>>> Testing [${ep.name}] - ${ep.method} ${ep.path}`);
    try {
      let res;
      if (ep.method === 'POST') {
        res = await axios.post(`${BASE_URL}${ep.path}`, ep.data);
      } else {
        res = await axios.get(`${BASE_URL}${ep.path}`);
      }
      console.log(`<<< Response:`, JSON.stringify(res.data, null, 2).substring(0, 300) + '...');
    } catch (err) {
      console.error(`<<< Error [${ep.name}]:`, err.response ? err.response.data : err.message);
    }
  }
}

async function testChatQueries() {
  console.log('\n=== STARTING CHAT QUERIES TESTS ===');

  const queries = [
    'How much did I spend this week?',
    'What are my highest expenses?',
    'Show suspicious transactions.',
    'Give me savings advice.',
    'How healthy are my finances?'
  ];

  for (const query of queries) {
    console.log(`\n>>> SAGE QUERY: "${query}"`);
    try {
      const res = await axios.post(`${BASE_URL}/ai-chat`, {
        message: query,
        cus_id: CUS_ID
      });
      console.log(`<<< SAGE Reply:\n`, res.data.reply);
    } catch (err) {
      console.error(`<<< Error query "${query}":`, err.response ? err.response.data : err.message);
    }
  }
}

async function run() {
  await testEndpoints();
  await testChatQueries();
}

run();
