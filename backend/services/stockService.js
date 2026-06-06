const YahooFinance = require('yahoo-finance2').default;
const yahooFinance = new YahooFinance();
const NodeCache = require('node-cache');

// Cache stock data for 5 minutes to avoid hitting rate limits
const cache = new NodeCache({ stdTTL: 300 });

const SYMBOLS = ['RELIANCE.NS', 'INFY.NS', 'TCS.NS', 'HDFCBANK.NS', 'WIPRO.NS'];

const SYMBOL_NAMES = {
  'RELIANCE.NS': 'Reliance Industries',
  'INFY.NS': 'Infosys',
  'TCS.NS': 'Tata Consultancy Services',
  'HDFCBANK.NS': 'HDFC Bank',
  'WIPRO.NS': 'Wipro'
};

/**
 * Fetches live stock quotes from Yahoo Finance for Indian NSE stocks.
 * Results are cached for 5 minutes.
 * @returns {Promise<Array<{symbol: string, name: string, price: number, changePercent: number}>>}
 */
async function getStocks() {
  const cacheKey = 'stocks_data';
  const cached = cache.get(cacheKey);
  if (cached) {
    console.log('[StockService] Returning cached stock data');
    return cached;
  }

  console.log('[StockService] Fetching live stock data from Yahoo Finance...');
  const results = [];

  for (const symbol of SYMBOLS) {
    try {
      const quote = await yahooFinance.quote(symbol);
      results.push({
        symbol: symbol.replace('.NS', ''),
        name: SYMBOL_NAMES[symbol] || quote.shortName || symbol,
        price: parseFloat((quote.regularMarketPrice || 0).toFixed(2)),
        changePercent: parseFloat((quote.regularMarketChangePercent || 0).toFixed(2))
      });
    } catch (err) {
      console.warn(`[StockService] Failed to fetch ${symbol}:`, err.message);
      // Return fallback data for this symbol
      results.push({
        symbol: symbol.replace('.NS', ''),
        name: SYMBOL_NAMES[symbol] || symbol,
        price: 0,
        changePercent: 0
      });
    }
  }

  cache.set(cacheKey, results);
  return results;
}

module.exports = { getStocks };
