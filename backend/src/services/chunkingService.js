/**
 * Chunks a given markdown content into pieces of 500-800 characters
 * with a 100-character overlap.
 * 
 * Uses a sliding window approach with natural boundary awareness (paragraph, line, sentence, space).
 * 
 * @param {string} content The raw text or markdown content.
 * @returns {string[]} An array of text chunks.
 */
function chunkMarkdown(content) {
  if (!content || typeof content !== 'string') {
    return [];
  }

  // Normalize line endings
  const normalized = content.replace(/\r\n/g, '\n').trim();
  if (normalized.length <= 800) {
    return [normalized];
  }

  const chunks = [];
  const minSize = 500;
  const maxSize = 800;
  const overlap = 100;
  
  let start = 0;
  const len = normalized.length;

  while (start < len) {
    // If remaining content is less than or equal to maxSize, take it all and finish
    if (len - start <= maxSize) {
      const remainingChunk = normalized.substring(start).trim();
      if (remainingChunk.length > 0) {
        chunks.push(remainingChunk);
      }
      break;
    }

    // Define the window within which we want to find a split point
    const windowStart = start + minSize;
    const windowEnd = start + maxSize;
    const searchSpace = normalized.substring(windowStart, windowEnd);

    let splitIndex = -1;

    // 1. Try to split at a paragraph boundary (\n\n) within the search window
    const lastParagraph = searchSpace.lastIndexOf('\n\n');
    if (lastParagraph !== -1) {
      splitIndex = windowStart + lastParagraph + 2; // Split after the newlines
    }

    // 2. Try to split at a line boundary (\n)
    if (splitIndex === -1) {
      const lastLine = searchSpace.lastIndexOf('\n');
      if (lastLine !== -1) {
        splitIndex = windowStart + lastLine + 1; // Split after the newline
      }
    }

    // 3. Try to split at a sentence boundary (. , ? , ! )
    if (splitIndex === -1) {
      // Find sentence endings (. or ? or ! followed by space)
      let sentenceEnd = -1;
      const regex = /[.!?]\s/g;
      let match;
      while ((match = regex.exec(searchSpace)) !== null) {
        sentenceEnd = match.index;
      }
      if (sentenceEnd !== -1) {
        splitIndex = windowStart + sentenceEnd + 2; // Split after the punctuation and space
      }
    }

    // 4. Try to split at a word boundary (space)
    if (splitIndex === -1) {
      const lastSpace = searchSpace.lastIndexOf(' ');
      if (lastSpace !== -1) {
        splitIndex = windowStart + lastSpace + 1; // Split after the space
      }
    }

    // 5. Fallback: split exactly at the maximum size boundary
    if (splitIndex === -1) {
      splitIndex = windowEnd;
    }

    // Extract chunk and add to list
    const chunkText = normalized.substring(start, splitIndex).trim();
    if (chunkText.length > 0) {
      chunks.push(chunkText);
    }

    // Advance start position accounting for the overlap
    start = splitIndex - overlap;
    
    // Safety check to ensure we always make progress and avoid infinite loop
    if (start <= windowStart - minSize) {
      start = splitIndex;
    }
  }

  return chunks;
}

module.exports = {
  chunkMarkdown,
};
