const axios = require('axios');

async function testAIChat() {
  console.log('[Test] Testing /ai-chat endpoint with RAG...');
  try {
    const response = await axios.post('http://localhost:3000/ai-chat', {
      message: 'What is a velocity attack and how does WealthWise prevent it?',
      cus_id: '1' // Using customer ID 1
    });

    console.log('\nResponse from SAGE:');
    console.log(response.data);
  } catch (error) {
    console.error('Error during test:', error.response ? error.response.data : error.message);
  }
}

testAIChat();
