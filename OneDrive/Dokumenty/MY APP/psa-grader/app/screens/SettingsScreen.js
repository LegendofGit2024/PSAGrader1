import React, { useState, useEffect } from 'react';
import {
  View, Text, TextInput, TouchableOpacity, ScrollView,
  StyleSheet, Alert, Linking,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { COLORS } from '../utils/theme';
import { checkHealth } from '../utils/api';

export default function SettingsScreen() {
  const [backendUrl, setBackendUrl] = useState('');
  const [status, setStatus] = useState(null);
  const [checking, setChecking] = useState(false);

  useEffect(() => {
    AsyncStorage.getItem('backendUrl').then(v => {
      if (v) setBackendUrl(v);
    });
  }, []);

  async function saveUrl() {
    const url = backendUrl.trim().replace(/\/$/, '');
    await AsyncStorage.setItem('backendUrl', url);
    Alert.alert('Saved', 'Backend URL saved');
  }

  async function testConnection() {
    setChecking(true);
    setStatus(null);
    try {
      const ok = await checkHealth();
      setStatus(ok ? 'connected' : 'failed');
    } catch {
      setStatus('failed');
    } finally {
      setChecking(false);
    }
  }

  return (
    <SafeAreaView style={s.safe}>
      <ScrollView style={s.scroll}>
        <View style={s.header}>
          <Text style={s.headerTitle}>⚙️ Settings</Text>
        </View>

        {/* Backend Config */}
        <View style={s.card}>
          <Text style={s.cardLabel}>BACKEND SERVER</Text>
          <Text style={s.hint}>Your Railway URL — e.g. https://psa-grader.up.railway.app</Text>
          <TextInput
            style={s.input}
            value={backendUrl}
            onChangeText={setBackendUrl}
            placeholder="https://your-app.up.railway.app"
            placeholderTextColor={COLORS.muted}
            autoCapitalize="none"
            keyboardType="url"
          />
          <View style={s.row}>
            <TouchableOpacity style={[s.btn, s.btnPrimary]} onPress={saveUrl}>
              <Text style={s.btnTextPrimary}>Save URL</Text>
            </TouchableOpacity>
            <TouchableOpacity style={[s.btn, s.btnSecondary]} onPress={testConnection} disabled={checking}>
              <Text style={s.btnTextSecondary}>{checking ? 'Checking...' : 'Test Connection'}</Text>
            </TouchableOpacity>
          </View>
          {status && (
            <View style={[s.statusBadge, status === 'connected' ? s.statusOk : s.statusFail]}>
              <Text style={[s.statusText, { color: status === 'connected' ? COLORS.green : COLORS.red }]}>
                {status === 'connected' ? '✓ Connected successfully' : '✗ Connection failed — check URL'}
              </Text>
            </View>
          )}
        </View>

        {/* Setup Guide */}
        <View style={s.card}>
          <Text style={s.cardLabel}>BACKEND SETUP GUIDE</Text>
          {[
            { n: '1', title: 'Deploy to Railway', body: 'Go to railway.app → New Project → Deploy from GitHub. Upload the /backend folder.' },
            { n: '2', title: 'Set environment variable', body: 'In Railway dashboard → Variables → add ANTHROPIC_API_KEY with your API key from console.anthropic.com' },
            { n: '3', title: 'Copy your URL', body: 'Railway gives you a public URL like https://xxx.up.railway.app — paste it above.' },
            { n: '4', title: 'Test it', body: 'Hit "Test Connection" above. If it shows ✓ Connected, you\'re live.' },
          ].map(step => (
            <View key={step.n} style={s.step}>
              <View style={s.stepNum}>
                <Text style={s.stepNumText}>{step.n}</Text>
              </View>
              <View style={{ flex: 1 }}>
                <Text style={s.stepTitle}>{step.title}</Text>
                <Text style={s.stepBody}>{step.body}</Text>
              </View>
            </View>
          ))}
          <TouchableOpacity style={s.linkBtn} onPress={() => Linking.openURL('https://railway.app')}>
            <Text style={s.linkBtnText}>Open Railway.app →</Text>
          </TouchableOpacity>
        </View>

        {/* Anthropic Key */}
        <View style={s.card}>
          <Text style={s.cardLabel}>ANTHROPIC API KEY</Text>
          <Text style={s.hint}>Your API key lives on the backend server as an environment variable — never stored in the app. Get one at:</Text>
          <TouchableOpacity style={s.linkBtn} onPress={() => Linking.openURL('https://console.anthropic.com')}>
            <Text style={s.linkBtnText}>console.anthropic.com →</Text>
          </TouchableOpacity>
        </View>

        {/* About */}
        <View style={s.card}>
          <Text style={s.cardLabel}>ABOUT</Text>
          <Text style={s.hint}>PSA Grading Analyzer v1.0{'\n'}Built with Expo · Express · Claude AI{'\n\n'}Price data scraped from eBay UK sold listings. Pop data from PSA. Always verify before submitting cards.</Text>
        </View>

        <View style={{ height: 40 }} />
      </ScrollView>
    </SafeAreaView>
  );
}

const s = StyleSheet.create({
  safe: { flex: 1, backgroundColor: COLORS.bg },
  scroll: { flex: 1, paddingHorizontal: 16 },
  header: { paddingTop: 16, paddingBottom: 12 },
  headerTitle: { fontSize: 22, fontWeight: '700', color: COLORS.text },
  card: { backgroundColor: COLORS.surface, borderRadius: 14, borderWidth: 1, borderColor: COLORS.border, padding: 14, marginBottom: 12 },
  cardLabel: { fontSize: 10, color: COLORS.muted, letterSpacing: 2, textTransform: 'uppercase', marginBottom: 10 },
  hint: { fontSize: 13, color: COLORS.muted, lineHeight: 18, marginBottom: 10 },
  input: { backgroundColor: '#0d1424', borderWidth: 1, borderColor: '#2a3a55', borderRadius: 8, padding: 10, color: COLORS.text, fontSize: 14, marginBottom: 10 },
  row: { flexDirection: 'row', gap: 8 },
  btn: { flex: 1, borderRadius: 8, padding: 11, alignItems: 'center', borderWidth: 1 },
  btnPrimary: { backgroundColor: COLORS.accent, borderColor: COLORS.accent },
  btnSecondary: { backgroundColor: 'transparent', borderColor: COLORS.border },
  btnTextPrimary: { color: '#000', fontWeight: '700', fontSize: 13 },
  btnTextSecondary: { color: COLORS.text, fontSize: 13 },
  statusBadge: { borderRadius: 8, padding: 10, marginTop: 10, borderWidth: 1 },
  statusOk: { backgroundColor: '#0d1f0e', borderColor: '#166534' },
  statusFail: { backgroundColor: '#1a0a0a', borderColor: '#7f1d1d' },
  statusText: { fontSize: 13, fontWeight: '600' },
  step: { flexDirection: 'row', gap: 12, marginBottom: 14 },
  stepNum: { width: 24, height: 24, borderRadius: 12, backgroundColor: COLORS.accent, alignItems: 'center', justifyContent: 'center', flexShrink: 0, marginTop: 1 },
  stepNumText: { fontSize: 12, fontWeight: '700', color: '#000' },
  stepTitle: { fontSize: 13, fontWeight: '600', color: COLORS.text, marginBottom: 2 },
  stepBody: { fontSize: 12, color: COLORS.muted, lineHeight: 17 },
  linkBtn: { backgroundColor: COLORS.surface2, borderWidth: 1, borderColor: COLORS.border, borderRadius: 8, padding: 11, alignItems: 'center', marginTop: 4 },
  linkBtnText: { color: COLORS.accent, fontSize: 13, fontWeight: '600' },
});
