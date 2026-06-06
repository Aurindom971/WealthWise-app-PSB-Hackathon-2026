const { searchKnowledgeBase } = require('./retrievalService');

/**
 * Retrieves relevant knowledge chunks for a query from the vector database.
 * Logs query parameters, match counts, and retrieval latency.
 * Handles failure cases gracefully by returning an empty list.
 * 
 * @param {string} query The user's query text.
 * @returns {Promise<Array<{score: number, source: string, text: string}>>} Relevant deduplicated chunks.
 */
async function getSageKnowledge(query) {
  const startTime = Date.now();
  console.log(`[RAG Service] Processing retrieval query: "${query}"`);

  try {
    const results = await searchKnowledgeBase(query, 5);
    const latency = Date.now() - startTime;
    console.log(`[RAG Service] Success: Retrieved ${results.length} chunks. Latency: ${latency}ms`);
    return results;
  } catch (error) {
    const latency = Date.now() - startTime;
    console.error(
      `[RAG Service] Error: Retrieval failed. Latency: ${latency}ms. Details:`,
      error.message || error
    );
    // Graceful degradation: Return empty array so application doesn't crash
    return [];
  }
}

module.exports = {
  getSageKnowledge,
  search: getSageKnowledge,
};
