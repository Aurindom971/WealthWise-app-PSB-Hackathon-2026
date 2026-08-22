const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { client, ensureCollection } = require('../src/config/qdrant');
const { chunkMarkdown } = require('../src/services/chunkingService');
const { getEmbedding } = require('../src/services/embeddingService');

const KNOWLEDGE_BASE_DIR = path.join(__dirname, '../knowledge-base');
const COLLECTION_NAME = 'banking_knowledge';
const BATCH_SIZE = 20; // Size of batches to upsert to Qdrant

async function runIngestion() {
  console.log('[Ingest] Starting WealthWise Knowledge Base Ingestion...');
  
  try {
    // 1. Ensure collection exists with correct config
    await ensureCollection();

    // 2. Read all markdown files
    if (!fs.existsSync(KNOWLEDGE_BASE_DIR)) {
      throw new Error(`Knowledge base directory not found at: ${KNOWLEDGE_BASE_DIR}`);
    }

    const files = fs.readdirSync(KNOWLEDGE_BASE_DIR).filter(
      (file) => file.endsWith('.md')
    );

    if (files.length === 0) {
      console.log('[Ingest] No markdown files found to ingest.');
      return;
    }

    console.log(`[Ingest] Found ${files.length} markdown files for ingestion: ${files.join(', ')}`);

    let totalChunksIngested = 0;

    for (const filename of files) {
      const filePath = path.join(KNOWLEDGE_BASE_DIR, filename);
      console.log(`\n[Ingest] Processing file: ${filename}...`);

      const content = fs.readFileSync(filePath, 'utf-8');
      const chunks = chunkMarkdown(content);
      console.log(`[Ingest] Split into ${chunks.length} chunks.`);

      const points = [];

      for (let i = 0; i < chunks.length; i++) {
        const chunkText = chunks[i];
        console.log(`[Ingest] Generating embedding for chunk ${i + 1}/${chunks.length} of ${filename}...`);
        
        try {
          const vector = await getEmbedding(chunkText);
          
          points.push({
            id: crypto.randomUUID(),
            vector: vector,
            payload: {
              text: chunkText,
              source: filename,
              chunk_index: i
            }
          });
        } catch (embErr) {
          console.error(`[Ingest] Error embedding chunk ${i} of ${filename}:`, embErr.message);
          // Skip this chunk and continue
        }
      }

      // Upload to Qdrant in batches
      for (let offset = 0; offset < points.length; offset += BATCH_SIZE) {
        const batch = points.slice(offset, offset + BATCH_SIZE);
        console.log(`[Ingest] Uploading batch of ${batch.length} points to Qdrant (offset: ${offset})...`);
        
        await client.upsert(COLLECTION_NAME, {
          wait: true,
          points: batch
        });
      }

      totalChunksIngested += points.length;
      console.log(`[Ingest] Completed ingestion for ${filename}. Ingested ${points.length} chunks.`);
    }

    console.log(`\n[Ingest] SUCCESS: Ingestion pipeline finished! Ingested a total of ${totalChunksIngested} chunks across all files.`);
  } catch (error) {
    console.error('\n[Ingest] FATAL ERROR during ingestion:', error.message || error);
    process.exit(1);
  }
}

// Execute Ingestion
runIngestion();
