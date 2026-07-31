const { client } = require('../config/qdrant');
const { getEmbedding } = require('./embeddingService');

const COLLECTION_NAME = 'banking_knowledge';

/**
 * Extracts keywords from a query string for keyword-overlap scoring.
 * Strips common stopwords and returns lowercase tokens.
 * @param {string} text
 * @returns {string[]}
 */
function extractKeywords(text) {
  const stopwords = new Set([
    'a', 'an', 'the', 'is', 'are', 'was', 'were', 'be', 'been', 'being',
    'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'shall',
    'should', 'may', 'might', 'must', 'can', 'could', 'of', 'in', 'to',
    'for', 'with', 'on', 'at', 'from', 'by', 'about', 'as', 'into',
    'through', 'during', 'before', 'after', 'above', 'below', 'between',
    'and', 'but', 'or', 'nor', 'not', 'so', 'yet', 'both', 'either',
    'neither', 'each', 'every', 'all', 'any', 'few', 'more', 'most',
    'other', 'some', 'such', 'no', 'only', 'own', 'same', 'than', 'too',
    'very', 'just', 'because', 'if', 'when', 'where', 'how', 'what',
    'which', 'who', 'whom', 'this', 'that', 'these', 'those', 'i', 'me',
    'my', 'we', 'our', 'you', 'your', 'he', 'him', 'his', 'she', 'her',
    'it', 'its', 'they', 'them', 'their', 'why', 'does'
  ]);
  return text
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, ' ')
    .split(/\s+/)
    .filter(w => w.length > 2 && !stopwords.has(w));
}

/**
 * Calculates keyword overlap ratio between query keywords and chunk text.
 * @param {string[]} queryKeywords
 * @param {string} chunkText
 * @returns {number} A value between 0 and 1.
 */
function keywordOverlapScore(queryKeywords, chunkText) {
  if (queryKeywords.length === 0) return 0;
  const chunkLower = chunkText.toLowerCase();
  let matchCount = 0;
  for (const kw of queryKeywords) {
    if (chunkLower.includes(kw)) matchCount++;
  }
  return matchCount / queryKeywords.length;
}

/**
 * Checks if a chunk contains a markdown heading (## or ###) that includes
 * any of the query keywords. Returns a bonus score.
 * @param {string[]} queryKeywords
 * @param {string} chunkText
 * @returns {number} Heading match bonus (0 or 0.1).
 */
function headingMatchBonus(queryKeywords, chunkText) {
  // Extract markdown headings from the chunk
  const headingRegex = /^#{1,4}\s+(.+)$/gm;
  let match;
  const headings = [];
  while ((match = headingRegex.exec(chunkText)) !== null) {
    headings.push(match[1].toLowerCase());
  }
  if (headings.length === 0) return 0;

  for (const heading of headings) {
    for (const kw of queryKeywords) {
      if (heading.includes(kw)) return 0.1; // Bonus for heading match
    }
  }
  return 0;
}

/**
 * Searches the Qdrant knowledge base with enhanced reranking.
 *
 * Pipeline:
 *   1. Fetch 30 candidates from Qdrant (semantic search)
 *   2. Deduplicate near-identical chunks
 *   3. Re-rank using: semantic score + keyword overlap + heading match bonus
 *   4. Apply diversity penalty to avoid source monopoly
 *   5. Return top 5 results
 *
 * @param {string} query The search query.
 * @param {number} limit The number of final results to return (default: 5).
 * @returns {Promise<Array<{score: number, source: string, chunk_index: number, text: string}>>}
 */
async function searchKnowledgeBase(query, limit = 5) {
  if (!query || typeof query !== 'string') {
    throw new Error('Search query must be a non-empty string');
  }

  const queryKeywords = extractKeywords(query);
  console.log(`[RetrievalService] Query keywords: [${queryKeywords.join(', ')}]`);

  // 1. Generate query embedding
  const queryVector = await getEmbedding(query);

  // 2. Fetch 30 candidates (10 desired × 3 for dedup/diversity headroom)
  const fetchLimit = 30;
  console.log(`[RetrievalService] Fetching top ${fetchLimit} candidate points from Qdrant...`);

  if (!client) {
    console.warn('[RetrievalService] Qdrant client is not initialized. Skipping vector search.');
    return [];
  }

  const rawResults = await client.search(COLLECTION_NAME, {
    vector: queryVector,
    limit: fetchLimit,
    with_payload: true,
  });

  console.log(`[RetrievalService] Received ${rawResults.length} raw results. Processing...`);

  // Log raw similarity scores
  rawResults.forEach((res, i) => {
    const src = res.payload ? res.payload.source : 'unknown';
    console.log(`  Raw #${i + 1}: Semantic = ${(res.score * 100).toFixed(2)}% | Source = ${src}`);
  });

  // 3. Deduplicate exact and near-exact chunk texts
  const uniqueCandidates = [];
  const seenTexts = new Set();

  for (const item of rawResults) {
    if (!item.payload || !item.payload.text) continue;

    const normalizedText = item.payload.text.toLowerCase().replace(/\s+/g, ' ').trim();

    if (seenTexts.has(normalizedText)) {
      console.log(`[RetrievalService] Filtered duplicate from: ${item.payload.source}`);
      continue;
    }

    seenTexts.add(normalizedText);

    // 4. Calculate composite reranked score
    const semanticScore = item.score;
    const kwOverlap = keywordOverlapScore(queryKeywords, item.payload.text);
    const headingBonus = headingMatchBonus(queryKeywords, item.payload.text);

    // Weighted composite: 60% semantic + 30% keyword overlap + 10% heading bonus
    const compositeScore = (semanticScore * 0.6) + (kwOverlap * 0.3) + headingBonus;

    uniqueCandidates.push({
      score: item.score,
      compositeScore,
      kwOverlap,
      headingBonus,
      source: item.payload.source || 'Unknown',
      chunk_index: item.payload.chunk_index !== undefined ? item.payload.chunk_index : 0,
      text: item.payload.text
    });
  }

  // Log reranked candidates (top 10)
  uniqueCandidates.sort((a, b) => b.compositeScore - a.compositeScore);
  console.log(`[RetrievalService] ${uniqueCandidates.length} unique candidates after dedup. Top 10 reranked:`);
  uniqueCandidates.slice(0, 10).forEach((c, i) => {
    console.log(`  Reranked #${i + 1}: Composite = ${(c.compositeScore * 100).toFixed(2)}% | Semantic = ${(c.score * 100).toFixed(2)}% | KW = ${(c.kwOverlap * 100).toFixed(0)}% | Heading = ${c.headingBonus > 0 ? 'YES' : 'no'} | Source = ${c.source}`);
  });

  // 5. Diversification: pick best 5 with diversity penalty
  const selectedResults = [];
  const sourceSelectionCount = {};
  const diversityPenalty = 0.06;
  const remaining = [...uniqueCandidates];

  while (selectedResults.length < limit && remaining.length > 0) {
    let bestIndex = -1;
    let bestEffectiveScore = -Infinity;

    for (let i = 0; i < remaining.length; i++) {
      const candidate = remaining[i];
      const selectedCount = sourceSelectionCount[candidate.source] || 0;
      const effectiveScore = candidate.compositeScore - (selectedCount * diversityPenalty);

      if (effectiveScore > bestEffectiveScore) {
        bestEffectiveScore = effectiveScore;
        bestIndex = i;
      }
    }

    if (bestIndex === -1) break;

    const chosen = remaining.splice(bestIndex, 1)[0];
    sourceSelectionCount[chosen.source] = (sourceSelectionCount[chosen.source] || 0) + 1;

    // Return clean result without internal fields
    selectedResults.push({
      score: chosen.score,
      source: chosen.source,
      chunk_index: chosen.chunk_index,
      text: chosen.text
    });
  }

  // Log final selection
  console.log(`[RetrievalService] Final selection: ${selectedResults.length} chunks:`);
  selectedResults.forEach((res, i) => {
    console.log(`  Selected #${i + 1}: Score = ${(res.score * 100).toFixed(2)}% | Source = ${res.source}`);
  });

  return selectedResults;
}

module.exports = {
  searchKnowledgeBase,
};
