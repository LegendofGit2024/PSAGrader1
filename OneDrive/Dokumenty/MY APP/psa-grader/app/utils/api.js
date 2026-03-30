import AsyncStorage from '@react-native-async-storage/async-storage';

const DEFAULT_URL = 'http://localhost:3000';

export async function getBackendUrl() {
  const stored = await AsyncStorage.getItem('backendUrl');
  return stored || DEFAULT_URL;
}

export async function analyzeCard(params) {
  const url = await getBackendUrl();
  const res = await fetch(`${url}/analyze`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(params),
  });
  if (!res.ok) throw new Error(`Server error: ${res.status}`);
  return res.json();
}

export async function refreshPrices(params) {
  const url = await getBackendUrl();
  const res = await fetch(`${url}/refresh-prices`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(params),
  });
  if (!res.ok) throw new Error(`Server error: ${res.status}`);
  return res.json();
}

export async function checkHealth() {
  const url = await getBackendUrl();
  const res = await fetch(`${url}/health`, { timeout: 5000 });
  return res.ok;
}
