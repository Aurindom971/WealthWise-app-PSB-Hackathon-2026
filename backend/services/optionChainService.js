const axios = require('axios');
const NodeCache = require('node-cache');

// Cache option chain data for 3 minutes
const cache = new NodeCache({ stdTTL: 180 });

const NSE_OPTION_CHAIN_URL = 'https://www.nseindia.com/api/option-chain-indices';

// NSE requires specific headers to avoid being blocked
const NSE_HEADERS = {
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  'Accept': 'application/json, text/plain, */*',
  'Accept-Language': 'en-US,en;q=0.9',
  'Accept-Encoding': 'gzip, deflate, br',
  'Referer': 'https://www.nseindia.com/option-chain',
  'Connection': 'keep-alive'
};

/**
 * Get NSE cookies by visiting the main page first (required for API access).
 * @returns {Promise<string>} Cookie string
 */
async function getNSECookies() {
  try {
    const response = await axios.get('https://www.nseindia.com/option-chain', {
      headers: NSE_HEADERS,
      timeout: 10000,
      maxRedirects: 5
    });
    const cookies = response.headers['set-cookie'];
    if (cookies) {
      return cookies.map(c => c.split(';')[0]).join('; ');
    }
    return '';
  } catch (err) {
    console.warn('[OptionChainService] Cookie fetch failed:', err.message);
    return '';
  }
}

/**
 * Fetch option chain data from NSE for a given index.
 * @param {string} symbol - Index symbol (NIFTY or BANKNIFTY)
 * @returns {Promise<Array>} Parsed option chain records
 */
async function fetchOptionChain(symbol) {
  const cacheKey = `option_chain_${symbol}`;
  const cached = cache.get(cacheKey);
  if (cached) {
    console.log(`[OptionChainService] Returning cached data for ${symbol}`);
    return cached;
  }

  console.log(`[OptionChainService] Fetching option chain for ${symbol} from NSE...`);

  try {
    // First get cookies
    const cookies = await getNSECookies();

    const response = await axios.get(NSE_OPTION_CHAIN_URL, {
      params: { symbol },
      headers: {
        ...NSE_HEADERS,
        'Cookie': cookies
      },
      timeout: 15000
    });

    const data = response.data;
    if (!data || !data.records || !data.records.data) {
      console.warn(`[OptionChainService] No data received for ${symbol}`);
      return getFallbackOptionData(symbol);
    }

    // Parse and extract the most relevant strike prices (near ATM)
    const spotPrice = data.records.underlyingValue || 0;
    const expiryDates = data.records.expiryDates || [];
    const nearestExpiry = expiryDates[0] || '';
    const allData = data.records.data;

    // Filter for nearest expiry and take 5 strikes around ATM
    const nearExpiryData = allData.filter(d => d.expiryDate === nearestExpiry);
    const sorted = nearExpiryData.sort((a, b) =>
      Math.abs(a.strikePrice - spotPrice) - Math.abs(b.strikePrice - spotPrice)
    );

    const top5 = sorted.slice(0, 5).map(record => ({
      strikePrice: record.strikePrice,
      expiryDate: record.expiryDate,
      ce: record.CE ? {
        openInterest: record.CE.openInterest || 0,
        changeinOpenInterest: record.CE.changeinOpenInterest || 0,
        lastPrice: record.CE.lastPrice || 0,
        impliedVolatility: record.CE.impliedVolatility || 0,
        volume: record.CE.totalTradedVolume || 0
      } : null,
      pe: record.PE ? {
        openInterest: record.PE.openInterest || 0,
        changeinOpenInterest: record.PE.changeinOpenInterest || 0,
        lastPrice: record.PE.lastPrice || 0,
        impliedVolatility: record.PE.impliedVolatility || 0,
        volume: record.PE.totalTradedVolume || 0
      } : null
    }));

    const result = {
      spotPrice,
      expiryDate: nearestExpiry,
      data: top5
    };

    cache.set(cacheKey, result);
    return result;

  } catch (err) {
    console.warn(`[OptionChainService] NSE API error for ${symbol}:`, err.message);
    return getFallbackOptionData(symbol);
  }
}

/**
 * Returns fallback option chain data when NSE API is unavailable.
 */
function getFallbackOptionData(symbol) {
  const spotPrices = { NIFTY: 23500, BANKNIFTY: 51000 };
  const spot = spotPrices[symbol] || 20000;
  const stepSize = symbol === 'BANKNIFTY' ? 500 : 100;

  const today = new Date();
  const nextThursday = new Date(today);
  nextThursday.setDate(today.getDate() + ((4 - today.getDay() + 7) % 7 || 7));
  const expiryDate = nextThursday.toLocaleDateString('en-GB', {
    day: '2-digit', month: 'short', year: 'numeric'
  }).replace(/ /g, '-');

  const data = [];
  for (let i = -2; i <= 2; i++) {
    const strike = spot + (i * stepSize);
    data.push({
      strikePrice: strike,
      expiryDate,
      ce: {
        openInterest: Math.floor(Math.random() * 50000) + 10000,
        changeinOpenInterest: Math.floor(Math.random() * 5000) - 2500,
        lastPrice: parseFloat((Math.max(0, spot - strike) + Math.random() * 200).toFixed(2)),
        impliedVolatility: parseFloat((10 + Math.random() * 15).toFixed(2)),
        volume: Math.floor(Math.random() * 100000) + 5000
      },
      pe: {
        openInterest: Math.floor(Math.random() * 50000) + 10000,
        changeinOpenInterest: Math.floor(Math.random() * 5000) - 2500,
        lastPrice: parseFloat((Math.max(0, strike - spot) + Math.random() * 200).toFixed(2)),
        impliedVolatility: parseFloat((10 + Math.random() * 15).toFixed(2)),
        volume: Math.floor(Math.random() * 100000) + 5000
      }
    });
  }

  return {
    spotPrice: spot,
    expiryDate,
    data,
    isFallback: true
  };
}

/**
 * Get option chains for both NIFTY and BANKNIFTY.
 * @returns {Promise<{nifty: Object, banknifty: Object}>}
 */
async function getOptionChains() {
  const [nifty, banknifty] = await Promise.all([
    fetchOptionChain('NIFTY'),
    fetchOptionChain('BANKNIFTY')
  ]);

  return { nifty, banknifty };
}

module.exports = { getOptionChains, fetchOptionChain };
