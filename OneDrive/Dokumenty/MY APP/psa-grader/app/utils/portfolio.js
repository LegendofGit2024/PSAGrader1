import AsyncStorage from '@react-native-async-storage/async-storage';

const PORTFOLIO_KEY = 'psa_portfolio';

export async function getPortfolio() {
  const data = await AsyncStorage.getItem(PORTFOLIO_KEY);
  return data ? JSON.parse(data) : [];
}

export async function addToPortfolio(card) {
  const portfolio = await getPortfolio();
  const newCard = {
    ...card,
    id: Date.now().toString(),
    addedAt: new Date().toISOString(),
  };
  portfolio.unshift(newCard);
  await AsyncStorage.setItem(PORTFOLIO_KEY, JSON.stringify(portfolio));
  return newCard;
}

export async function updatePortfolioCard(id, updates) {
  const portfolio = await getPortfolio();
  const idx = portfolio.findIndex(c => c.id === id);
  if (idx !== -1) {
    portfolio[idx] = { ...portfolio[idx], ...updates, updatedAt: new Date().toISOString() };
    await AsyncStorage.setItem(PORTFOLIO_KEY, JSON.stringify(portfolio));
  }
  return portfolio;
}

export async function removeFromPortfolio(id) {
  const portfolio = await getPortfolio();
  const filtered = portfolio.filter(c => c.id !== id);
  await AsyncStorage.setItem(PORTFOLIO_KEY, JSON.stringify(filtered));
  return filtered;
}

export function calcPortfolioStats(portfolio) {
  const totalInvested = portfolio.reduce((s, c) => s + (c.totalCost || 0), 0);
  const totalExpectedRev = portfolio.reduce((s, c) => s + (c.expectedRevenue || 0), 0);
  const totalExpectedProfit = totalExpectedRev - totalInvested;
  const roi = totalInvested > 0 ? (totalExpectedProfit / totalInvested) * 100 : 0;
  return { totalInvested, totalExpectedRev, totalExpectedProfit, roi };
}
