const axios = require('axios');
const NodeCache = require('node-cache');

// Cache mutual fund data for 30 minutes (NAV updates once daily)
const cache = new NodeCache({ stdTTL: 1800 });

// Popular Indian mutual fund scheme codes from MFAPI
const FUND_SCHEMES = [
  { code: '120503', category: 'Small Cap' },     // Quant Small Cap Fund
  { code: '120505', category: 'Large Cap' },      // Quant Active Fund
  { code: '119551', category: 'Flexi Cap' },      // Parag Parikh Flexi Cap Fund
  { code: '118989', category: 'Mid Cap' },         // PGIM India Midcap Opportunities Fund
  { code: '135781', category: 'Large & Mid Cap' }, // Mirae Asset Large & Midcap Fund
  { code: '122639', category: 'ELSS' },            // Quant Tax Plan
  { code: '100356', category: 'Index Fund' },      // UTI Nifty 50 Index Fund
  { code: '119598', category: 'Multi Cap' },       // Nippon India Multi Cap Fund
];

const BASE_URL = 'https://api.mfapi.in/mf';

/**
 * Fetches latest NAV data for popular mutual fund schemes.
 * Uses the free MFAPI (api.mfapi.in).
 * @returns {Promise<Array<{schemeName: string, category: string, nav: number, date: string, schemeCode: string}>>}
 */
async function getMutualFunds() {
  const cacheKey = 'mutual_funds_data';
  const cached = cache.get(cacheKey);
  if (cached) {
    console.log('[MutualFundService] Returning cached fund data');
    return cached;
  }

  console.log('[MutualFundService] Fetching live mutual fund data from MFAPI...');
  const results = [];

  for (const fund of FUND_SCHEMES) {
    try {
      const response = await axios.get(`${BASE_URL}/${fund.code}`, {
        timeout: 10000
      });

      const data = response.data;
      const latestNav = data.data && data.data[0];

      results.push({
        schemeCode: fund.code,
        schemeName: data.meta?.scheme_name || `Fund ${fund.code}`,
        category: fund.category,
        nav: latestNav ? parseFloat(latestNav.nav) : 0,
        date: latestNav ? latestNav.date : 'N/A'
      });
    } catch (err) {
      console.warn(`[MutualFundService] Failed to fetch fund ${fund.code}:`, err.message);
      results.push({
        schemeCode: fund.code,
        schemeName: `Fund ${fund.code}`,
        category: fund.category,
        nav: 0,
        date: 'N/A'
      });
    }
  }

  cache.set(cacheKey, results);
  return results;
}

module.exports = { getMutualFunds };
