const express = require('express');
const cors = require('cors');
const axios = require('axios');
const cheerio = require('cheerio');
const Anthropic = require('@anthropic-ai/sdk');

const app = express();
app.use(cors());
app.use(express.json());

const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

// ─── eBay UK sold listings scraper ────────────────────────────────────────
async function scrapeEbaySold(cardName, set, num, gradeLabel) {
  const query = `pokemon ${cardName} ${set || ''} ${num || ''} ${gradeLabel}`.trim();
  const encoded = encodeURIComponent(query);
  const url = `https://www.ebay.co.uk/sch/i.html?_nkw=${encoded}&LH_Sold=1&LH_Complete=1&_sop=13`;

  try {
    const { data } = await axios.get(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
        'Accept-Language': 'en-GB,en;q=0.9',
      },
      timeout: 10000,
    });

    const $ = cheerio.load(data);
    const prices = [];

    $('.s-item').each((_, el) => {
      const priceText = $(el).find('.s-item__price').first().text().trim();
      const match = priceText.match(/£([\d,]+\.?\d*)/);
      if (match) {
        const price = parseFloat(match[1].replace(',', ''));
        if (price > 0) prices.push(price);
      }
    });

    if (prices.length === 0) return null;

    prices.sort((a, b) => a - b);
    const mid = Math.floor(prices.length / 2);
    const median = prices.length % 2 === 0
      ? (prices[mid - 1] + prices[mid]) / 2
      : prices[mid];

    return {
      median: Math.round(median),
      min: Math.round(prices[0]),
      max: Math.round(prices[prices.length - 1]),
      count: prices.length,
      recentSales: prices.slice(-5).reverse(),
    };
  } catch (err) {
    console.error(`eBay scrape failed for "${gradeLabel}":`, err.message);
    return null;
  }
}

// ─── PSA Pop Report fetcher ────────────────────────────────────────────────
async function fetchPSAPop(cardName, set) {
  const query = encodeURIComponent(`${cardName} ${set || ''}`);
  const url = `https://www.psacard.com/pop/trading-card-games/pokemon/${query}`;

  try {
    const { data } = await axios.get(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'text/html',
      },
      timeout: 8000,
    });

    const $ = cheerio.load(data);
    const pop = {};
    $('table tr').each((_, row) => {
      const cells = $(row).find('td');
      if (cells.length >= 2) {
        const grade = $(cells[0]).text().trim();
        const count = parseInt($(cells[1]).text().trim().replace(',', ''));
        if (!isNaN(count) && grade) pop[grade] = count;
      }
    });

    const total = Object.values(pop).reduce((s, v) => s + v, 0);
    const psa10Count = pop['10'] || pop['PSA 10'] || 0;
    const gemRate = total > 0 ? Math.round((psa10Count / total) * 100) : null;

    return { pop, total, psa10Count, gemRate };
  } catch (err) {
    console.error('PSA pop fetch failed:', err.message);
    return null;
  }
}

// ─── Claude AI gem rate + analysis ────────────────────────────────────────
async function getAIAnalysis({ cardName, set, num, buyPrice, totalCost, platFee, ebayPrices, psaPop }) {
  const popContext = psaPop
    ? `PSA Population: ${psaPop.total} total graded, ${psaPop.psa10Count} PSA 10s, real gem rate: ${psaPop.gemRate ?? 'unknown'}%`
    : 'PSA population data unavailable';

  const priceContext = ebayPrices
    ? Object.entries(ebayPrices)
        .filter(([, v]) => v)
        .map(([grade, data]) => `${grade}: median £${data.median} (${data.count} sales)`)
        .join(', ')
    : 'No live price data available';

  const prompt = `You are a Pokemon TCG grading expert. Analyze this card for PSA grading profitability using the real data provided.

Card: ${cardName}${set ? ' - ' + set : ''}${num ? ' #' + num : ''}
Raw buy price: £${buyPrice}
Total all-in cost: £${totalCost}
Platform fee: ${(platFee * 100).toFixed(0)}%

REAL DATA:
${popContext}
Live eBay UK sold prices: ${priceContext}

Based on this real data, reply ONLY with valid JSON:
{
  "gemRate": {"pct": <number>, "label": "<Low/Average/Good/Excellent>", "reason": "<based on real pop data>", "rating": "<hot|warm|cold>"},
  "gradingTip": "<specific actionable tip>",
  "probs": {"p10":<num>,"p9":<num>,"p8":<num>,"p7":<num>,"p6":<num>,"pLow":<num>},
  "salePrices": {"p10":<£>,"p9":<£>,"p8":<£>,"p7":<£>,"p6":<£>,"pLow":<£>},
  "keyFactors": ["<factor1>","<factor2>","<factor3>"],
  "verdict": {"decision":"<GRADE|SKIP|RISKY>","headline":"<short line>","analysis":"<2-3 sentences>"},
  "dataQuality": "<real|estimated>"
}

Probabilities must sum to 100. Use real eBay prices where available, estimate gaps intelligently.`;

  const response = await anthropic.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 1000,
    messages: [{ role: 'user', content: prompt }],
  });

  const text = response.content.map(b => b.text || '').join('');
  return JSON.parse(text.replace(/```json|```/g, '').trim());
}

// ─── Main analyze endpoint ────────────────────────────────────────────────
app.post('/analyze', async (req, res) => {
  const { cardName, set, num, buyPrice, gradeFee, shipping, platFee } = req.body;

  if (!cardName) return res.status(400).json({ error: 'cardName required' });

  const totalCost = (buyPrice || 0) + (gradeFee || 25) + (shipping || 13);

  try {
    // Run eBay scrapes + PSA pop in parallel
    const [psa10Data, psa9Data, psa8Data, rawData, psaPop] = await Promise.allSettled([
      scrapeEbaySold(cardName, set, num, 'PSA 10'),
      scrapeEbaySold(cardName, set, num, 'PSA 9'),
      scrapeEbaySold(cardName, set, num, 'PSA 8'),
      scrapeEbaySold(cardName, set, num, 'raw'),
      fetchPSAPop(cardName, set),
    ]);

    const ebayPrices = {
      'PSA 10': psa10Data.status === 'fulfilled' ? psa10Data.value : null,
      'PSA 9': psa9Data.status === 'fulfilled' ? psa9Data.value : null,
      'PSA 8': psa8Data.status === 'fulfilled' ? psa8Data.value : null,
      'Raw': rawData.status === 'fulfilled' ? rawData.value : null,
    };

    const popData = psaPop.status === 'fulfilled' ? psaPop.value : null;

    const analysis = await getAIAnalysis({
      cardName, set, num, buyPrice, totalCost, platFee: platFee || 0.13,
      ebayPrices, psaPop: popData,
    });

    res.json({
      success: true,
      analysis,
      rawData: { ebayPrices, psaPop: popData, totalCost },
    });
  } catch (err) {
    console.error('Analyze error:', err);
    res.status(500).json({ error: err.message });
  }
});

// ─── Portfolio price refresh ──────────────────────────────────────────────
app.post('/refresh-prices', async (req, res) => {
  const { cardName, set, num } = req.body;
  if (!cardName) return res.status(400).json({ error: 'cardName required' });

  const [psa10, psa9, psa8] = await Promise.allSettled([
    scrapeEbaySold(cardName, set, num, 'PSA 10'),
    scrapeEbaySold(cardName, set, num, 'PSA 9'),
    scrapeEbaySold(cardName, set, num, 'PSA 8'),
  ]);

  res.json({
    'PSA 10': psa10.status === 'fulfilled' ? psa10.value : null,
    'PSA 9': psa9.status === 'fulfilled' ? psa9.value : null,
    'PSA 8': psa8.status === 'fulfilled' ? psa8.value : null,
  });
});

app.get('/health', (_, res) => res.json({ status: 'ok' }));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`PSA Grader backend running on port ${PORT}`));
