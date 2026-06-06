const axios = require('axios');

async function test() {
  const queries = [
    { message: "What is my account balance?", cus_id: "CUST1" },
    { message: "Why was my transaction flagged as fraudulent?", cus_id: "CUST1" },
    { message: "What security measures are in place for velocity attacks?", cus_id: "CUST1" }
  ];

  for (const q of queries) {
    console.log(`\n>>> Sending: "${q.message}"`);
    try {
      const res = await axios.post('http://localhost:3000/ai-chat', q);
      console.log(`<<< Response:`, res.data);
    } catch (err) {
      console.error(`<<< Error:`, err.response ? err.response.data : err.message);
    }
  }
}

test();
