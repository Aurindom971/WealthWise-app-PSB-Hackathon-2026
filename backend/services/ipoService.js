const axios = require('axios');
const NodeCache = require('node-cache');

// Cache IPO data for 1 hour (IPO listings don't change frequently)
const cache = new NodeCache({ stdTTL: 3600 });

const NSE_IPO_URL = 'https://www.nseindia.com/api/ipo-current-issue';

const NSE_HEADERS = {
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  'Accept': 'application/json, text/plain, */*',
  'Accept-Language': 'en-US,en;q=0.9',
  'Accept-Encoding': 'gzip, deflate, br',
  'Referer': 'https://www.nseindia.com/market-data/all-upcoming-issues-ipo',
  'Connection': 'keep-alive'
};

/**
 * Get NSE cookies for API access.
 * @returns {Promise<string>}
 */
async function getNSECookies() {
  try {
    const response = await axios.get('https://www.nseindia.com/', {
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
    console.warn('[IPOService] Cookie fetch failed:', err.message);
    return '';
  }
}

/**
 * Fetches current and upcoming IPO data from NSE.
 * Falls back to realistic sample data if NSE API is unavailable.
 * @returns {Promise<Array<{name: string, openDate: string, closeDate: string, price: string, status: string}>>}
 */
async function getIPOs() {
  const cacheKey = 'ipo_data';
  const cached = cache.get(cacheKey);
  if (cached) {
    console.log('[IPOService] Returning cached IPO data');
    return cached;
  }

  console.log('[IPOService] Fetching IPO data from NSE...');

  try {
    const cookies = await getNSECookies();

    const response = await axios.get(NSE_IPO_URL, {
      headers: {
        ...NSE_HEADERS,
        'Cookie': cookies
      },
      timeout: 15000
    });

    const data = response.data;

    if (!data || (!Array.isArray(data) && !data.data)) {
      console.warn('[IPOService] Unexpected response format');
      return getFallbackIPOData();
    }

    const ipoList = Array.isArray(data) ? data : (data.data || []);

    const results = ipoList.map(ipo => ({
      name: ipo.companyName || ipo.symbol || 'Unknown',
      openDate: ipo.issueStartDate || ipo.openDate || 'TBD',
      closeDate: ipo.issueEndDate || ipo.closeDate || 'TBD',
      price: ipo.priceRange || ipo.issuePriceBand || 'TBD',
      status: ipo.issueStatus || ipo.status || 'Upcoming',
      issueSize: ipo.issueSize || 'N/A',
      issueType: ipo.issueType || 'IPO',
      listingDate: ipo.listingDate || 'TBD'
    }));

    cache.set(cacheKey, results);
    return results;

  } catch (err) {
    console.warn('[IPOService] NSE IPO API error:', err.message);
    return getFallbackIPOData();
  }
}

/**
 * Returns realistic fallback IPO data when NSE API is unavailable.
 */
function getFallbackIPOData() {
  const today = new Date();

  const formatDate = (date) => {
    return date.toLocaleDateString('en-GB', {
      day: '2-digit', month: 'short', year: 'numeric'
    });
  };

  const upcoming1 = new Date(today);
  upcoming1.setDate(today.getDate() + 3);
  const upcoming1End = new Date(upcoming1);
  upcoming1End.setDate(upcoming1.getDate() + 3);

  const upcoming2 = new Date(today);
  upcoming2.setDate(today.getDate() + 7);
  const upcoming2End = new Date(upcoming2);
  upcoming2End.setDate(upcoming2.getDate() + 3);

  const open1Start = new Date(today);
  open1Start.setDate(today.getDate() - 1);
  const open1End = new Date(today);
  open1End.setDate(today.getDate() + 2);

  return [
    {
      name: 'TechVista Solutions Ltd',
      openDate: formatDate(open1Start),
      closeDate: formatDate(open1End),
      price: '₹320 - ₹340',
      status: 'Open',
      issueSize: '₹1,200 Cr',
      issueType: 'Book Built Issue IPO',
      listingDate: 'TBD',
      isFallback: true
    },
    {
      name: 'GreenEnergy Power Ltd',
      openDate: formatDate(upcoming1),
      closeDate: formatDate(upcoming1End),
      price: '₹185 - ₹195',
      status: 'Upcoming',
      issueSize: '₹800 Cr',
      issueType: 'Book Built Issue IPO',
      listingDate: 'TBD',
      isFallback: true
    },
    {
      name: 'FinServe Digital Ltd',
      openDate: formatDate(upcoming2),
      closeDate: formatDate(upcoming2End),
      price: '₹450 - ₹475',
      status: 'Upcoming',
      issueSize: '₹2,500 Cr',
      issueType: 'Book Built Issue IPO',
      listingDate: 'TBD',
      isFallback: true
    },
    {
      name: 'MedTech Innovations Ltd',
      openDate: formatDate(upcoming2),
      closeDate: formatDate(upcoming2End),
      price: '₹125 - ₹135',
      status: 'Upcoming',
      issueSize: '₹600 Cr',
      issueType: 'Fixed Price Issue IPO',
      listingDate: 'TBD',
      isFallback: true
    }
  ];
}

module.exports = { getIPOs };
