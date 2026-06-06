const axios = require('axios');
const Groq = require('groq-sdk');
require('dotenv').config();

const OLLAMA_URL = process.env.OLLAMA_URL || 'http://localhost:11434';
const LLM_PROVIDER = (process.env.LLM_PROVIDER || 'groq').toLowerCase();
const GROQ_API_KEY = process.env.GROQ_API_KEY;

// Initialize Groq if selected
let groq = null;
if (LLM_PROVIDER === 'groq') {
  if (!GROQ_API_KEY) {
    console.warn('[LLM Service] Warning: LLM_PROVIDER is set to "groq" but GROQ_API_KEY is not defined.');
  }
  groq = new Groq({ apiKey: GROQ_API_KEY });
}

/**
 * Generates a response from the selected LLM provider.
 * 
 * @param {string} prompt The input prompt.
 * @returns {Promise<string>} The generated text response.
 */
async function generateResponse(prompt) {
  const startTime = Date.now();
  
  if (!prompt || typeof prompt !== 'string') {
    throw new Error('Prompt must be a non-empty string');
  }

  let responseText = '';
  
  try {
    if (LLM_PROVIDER === 'groq') {
      console.log(`[LLM Service] Using Groq (llama-3.3-70b-versatile)...`);
      if (!groq) {
        throw new Error('Groq SDK is not initialized. Check your GROQ_API_KEY.');
      }
      
      const completion = await groq.chat.completions.create({
        messages: [{ role: 'user', content: prompt }],
        model: 'llama-3.3-70b-versatile',
      });
      
      if (completion.choices && completion.choices[0] && completion.choices[0].message) {
        responseText = completion.choices[0].message.content;
      } else {
        throw new Error('Invalid or empty response from Groq API');
      }
    } else {
      console.log(`[LLM Service] Using Ollama (llama3) at ${OLLAMA_URL}...`);
      const response = await axios.post(
        `${OLLAMA_URL}/api/generate`,
        {
          model: 'llama3',
          prompt: prompt,
          stream: false
        },
        {
          timeout: 60000 // 60 seconds timeout
        }
      );
      
      if (response.data && response.data.response) {
        responseText = response.data.response;
      } else {
        throw new Error('Invalid or empty response from local Ollama');
      }
    }

    const latency = Date.now() - startTime;
    console.log(`[LLM Service] Provider: ${LLM_PROVIDER} | Prompt Length: ${prompt.length} | Response Length: ${responseText.length} | Latency: ${latency}ms`);
    
    return responseText.trim();
  } catch (error) {
    console.error(`[LLM Service] Error generating response:`, error.message);
    throw error;
  }
}

module.exports = {
  generateResponse,
};
