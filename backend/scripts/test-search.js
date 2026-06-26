const { searchKnowledgeBase } = require('../src/services/retrievalService');

const QUERY = 'What is a velocity attack?';

async function testSearch() {
  console.log(`[SearchTest] Starting search test for query: "${QUERY}"`);

  try {
    // 1. Perform search using the improved retrieval service
    const results = await searchKnowledgeBase(QUERY, 5);

    console.log('\n=========================================');
    console.log(`Top 5 Results for: "${QUERY}"`);
    console.log('=========================================');

    if (results.length === 0) {
      console.log('No results found.');
      return;
    }

    results.forEach((result, idx) => {
      const score = result.score;
      const source = result.source;
      const text = result.text;

      console.log(`\nResult #${idx + 1}`);
      console.log(`Similarity Score: ${(score * 100).toFixed(2)}% (${score})`);
      console.log(`Source File: ${source}`);
      console.log(`-----------------------------------------`);
      console.log(text);
      console.log('=========================================');
    });

  } catch (error) {
    console.error('[SearchTest] Error during search test:', error.message || error);
    process.exit(1);
  }
}

// Execute test search
testSearch();
