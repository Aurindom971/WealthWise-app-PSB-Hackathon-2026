const axios = require('axios');
require('dotenv').config();

const OLLAMA_URL = process.env.OLLAMA_URL || 'http://localhost:11434';
const EMBEDDING_MODEL = 'nomic-embed-text';

/**
 * Generates an embedding vector for a given text using local Ollama model.
 * Implements exponential backoff retries.
 * 
 * @param {string} text The input text to embed.
 * @param {number} retries Number of retry attempts.
 * @param {number} delay Initial delay in milliseconds for backoff.
 * @returns {Promise<number[]>} The embedding vector.
 */
async function getEmbedding(text, retries = 3, delay = 1000) {
  if (!text || typeof text !== 'string') {
    throw new Error('Input text must be a non-empty string');
  }

  const endpoint = `${OLLAMA_URL}/api/embeddings`;

  for (let attempt = 1; attempt <= retries + 1; attempt++) {
    try {
      const response = await axios.post(
        endpoint,
        {
          model: EMBEDDING_MODEL,
          prompt: text,
        },
        {
          timeout: 15000, // 15 seconds timeout
        }
      );

      if (response.data && response.data.embedding) {
        return response.data.embedding;
      } else {
        throw new Error('Ollama response did not contain "embedding" field');
      }
    } catch (error) {
      const isLastAttempt = attempt === retries + 1;
      const errorMessage = error.response
        ? `Status ${error.response.status}: ${JSON.stringify(error.response.data)}`
        : error.message;

      console.error(
        `[EmbeddingService] Attempt ${attempt} failed: ${errorMessage}`
      );

      if (isLastAttempt) {
        throw new Error(
          `Failed to get embedding after ${retries + 1} attempts. Error: ${errorMessage}`
        );
      }

      console.log(`[EmbeddingService] Retrying in ${delay}ms...`);
      await new Promise((resolve) => setTimeout(resolve, delay));
      delay *= 2; // Exponential backoff
    }
  }
}

module.exports = {
  getEmbedding,
};
