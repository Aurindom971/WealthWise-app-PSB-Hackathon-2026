const { QdrantClient } = require('@qdrant/js-client-rest');
require('dotenv').config();

const qdrantUrl = process.env.QDRANT_URL;
const qdrantApiKey = process.env.QDRANT_API_KEY;

if (!qdrantUrl) {
  console.warn('[QdrantConfig] WARNING: QDRANT_URL is not defined in the environment variables.');
}

// Initialize the Qdrant Client
const client = new QdrantClient({
  url: qdrantUrl,
  apiKey: qdrantApiKey,
});

/**
 * Checks if the "banking_knowledge" collection exists in Qdrant.
 * If the collection is missing, creates it with the proper configuration:
 * - Vector size: 768 (Ollama nomic-embed-text embedding size)
 * - Distance metric: Cosine
 * @returns {Promise<boolean>} Resolves to true if the collection exists or was successfully created.
 */
async function ensureCollection() {
  const collectionName = 'banking_knowledge';
  console.log(`[QdrantConfig] Verifying collection: "${collectionName}"...`);

  try {
    // Retrieve list of all collections
    const result = await client.getCollections();
    const collectionExists = result.collections.some(
      (c) => c.name === collectionName
    );

    if (collectionExists) {
      console.log(`[QdrantConfig] Collection "${collectionName}" already exists.`);
      return true;
    }

    console.log(`[QdrantConfig] Collection "${collectionName}" missing. Creating new collection...`);

    // Create the collection
    await client.createCollection(collectionName, {
      vectors: {
        size: 768,
        distance: 'Cosine',
      },
    });

    console.log(`[QdrantConfig] Collection "${collectionName}" successfully created.`);
    return true;
  } catch (error) {
    console.error(`[QdrantConfig] Error in ensureCollection:`, error.message || error);
    throw error;
  }
}

module.exports = {
  client,
  ensureCollection,
};
