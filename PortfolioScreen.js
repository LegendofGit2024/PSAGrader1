import React, { useState, useCallback } from 'react';
import {
  View, Text, ScrollView, TouchableOpacity, StyleSheet,
  Alert, RefreshControl,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useFocusEffect } from '@react-navigation/native';
import { COLORS } from '../utils/theme';
import { getPortfolio, removeFromPortfolio, calcPortfolioStats, updatePortfolioCard } from '../utils/portfolio';
import { refreshPrices } from '../utils/api';

export default function PortfolioScreen() {
  const [portfolio, setPortfolio] = useState([]);
  const [stats, setStats] = useState({});
  const [refreshing, setRefreshing] = useState(false);
  const [refreshingId, setRefreshingId] = useState(null);

  useFocusEffect(useCallback(() => { loadPortfolio(); }, []));

  async function loadPortfolio() {
    const p = await getPortfolio();
    setPortfolio(p);
    setStats(calcPortfolioStats(p));
  }

  async function handleDelete(id, name) {
    Alert.alert('Remove Card', `Remove ${name} from portfolio?`, [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Remove', style: 'destructive',
        onPress: async () => {
          const updated = await removeFromPortfolio(id);
          setPortfolio(updated);
          setStats(calcPortfolioStats(updated));
        },
      },
    ]);
  }

  async function handleRefreshPrices(card) {
    setRefreshingId(card.id);
    try {
      const prices = await refreshPrices({ cardName: card.cardName, set: card.set, num: card.num });
      const platFee = 0.13;
      const p9Price = prices['PSA 9']?.median;
      const p10Price = prices['PSA 10']?.median;
      await updatePortfolioCard(card.id, { latestPrices: prices, lastRefreshed: new Date().toISOString() });
      await loadPortfolio();
      Alert.alert('Prices Updated', `PSA 9: ${p9Price ? '£' + p9Price : 'N/A'} · PSA 10: ${p10Price ? '£' + p10Price : 'N/A'}`);
    } catch (e) {
      Alert.alert('Error', 'Could not refresh prices. Check your backend connection.');
    } finally {
      setRefreshingId(null);
    }
  }

  const verdictColor = v => v === 'GRADE' ? COLORS.green : v === 'SKIP' ? COLORS.red : COLORS.accent;
  const verdictIcon = v => v === 'GRADE' ? '✅' : v === 'SKIP' ? '❌' : '⚠️';

  return (
    <SafeAreaView style={s.safe}>
      <ScrollView
        style={s.scroll}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={loadPortfolio} tintColor={COLORS.accent} />}
      >
        <View style={s.header}>
          <Text style={s.headerTitle}>📁 Portfolio</Text>
          <Text style={s.headerSub}>{portfolio.length} card{portfolio.length !== 1 ? 's' : ''} tracked</Text>
        </View>

        {/* Stats */}
        {portfolio.length > 0 && (
          <View style={s.statsGrid}>
            {[
              { label: 'INVESTED', val: `£${stats.totalInvested?.toFixed(0) || 0}`, color: COLORS.accent },
              { label: 'EXP. RETURN', val: `£${stats.totalExpectedRev?.toFixed(0) || 0}`, color: COLORS.blue },
              { label: 'EXP. PROFIT', val: `£${stats.totalExpectedProfit?.toFixed(0) || 0}`, color: stats.totalExpectedProfit >= 0 ? COLORS.green : COLORS.red },
              { label: 'PORT. ROI', val: `${stats.roi?.toFixed(1) || 0}%`, color: stats.roi >= 0 ? COLORS.green : COLORS.red },
            ].map(m => (
              <View key={m.label} style={s.stat}>
                <Text style={s.statLabel}>{m.label}</Text>
                <Text style={[s.statVal, { color: m.color }]}>{m.val}</Text>
              </View>
            ))}
          </View>
        )}

        {/* Card List */}
        {portfolio.length === 0 ? (
          <View style={s.empty}>
            <Text style={s.emptyIcon}>🃏</Text>
            <Text style={s.emptyTitle}>No cards yet</Text>
            <Text style={s.emptySub}>Analyze a card and save it to build your portfolio</Text>
          </View>
        ) : (
          portfolio.map(card => (
            <View key={card.id} style={s.cardItem}>
              <View style={s.cardTop}>
                <View style={{ flex: 1 }}>
                  <Text style={s.cardName}>{card.cardName}</Text>
                  <Text style={s.cardSet}>{[card.set, card.num].filter(Boolean).join(' · ')}</Text>
                </View>
                {card.verdict && (
                  <View style={[s.verdictBadge, { borderColor: verdictColor(card.verdict) }]}>
                    <Text style={[s.verdictText, { color: verdictColor(card.verdict) }]}>
                      {verdictIcon(card.verdict)} {card.verdict}
                    </Text>
                  </View>
                )}
              </View>

              <View style={s.cardStats}>
                <View style={s.cardStat}>
                  <Text style={s.cardStatLabel}>Cost</Text>
                  <Text style={[s.cardStatVal, { color: COLORS.accent }]}>£{(card.totalCost || 0).toFixed(0)}</Text>
                </View>
                <View style={s.cardStat}>
                  <Text style={s.cardStatLabel}>Exp. Profit</Text>
                  <Text style={[s.cardStatVal, { color: card.expectedProfit >= 0 ? COLORS.green : COLORS.red }]}>
                    {card.expectedProfit >= 0 ? '+' : ''}£{(card.expectedProfit || 0).toFixed(0)}
                  </Text>
                </View>
                {card.gemRate && (
                  <View style={s.cardStat}>
                    <Text style={s.cardStatLabel}>Gem Rate</Text>
                    <Text style={[s.cardStatVal, { color: COLORS.purple }]}>{card.gemRate}%</Text>
                  </View>
                )}
                {card.latestPrices?.['PSA 9'] && (
                  <View style={s.cardStat}>
                    <Text style={s.cardStatLabel}>PSA 9 Now</Text>
                    <Text style={[s.cardStatVal, { color: COLORS.blue }]}>£{card.latestPrices['PSA 9'].median}</Text>
                  </View>
                )}
              </View>

              {card.lastRefreshed && (
                <Text style={s.refreshedAt}>Updated {new Date(card.lastRefreshed).toLocaleDateString()}</Text>
              )}

              <View style={s.cardActions}>
                <TouchableOpacity
                  style={[s.actionBtn, s.refreshBtn]}
                  onPress={() => handleRefreshPrices(card)}
                  disabled={refreshingId === card.id}
                >
                  <Text style={s.actionBtnText}>{refreshingId === card.id ? '⏳ Updating...' : '↻ Refresh Prices'}</Text>
                </TouchableOpacity>
                <TouchableOpacity style={[s.actionBtn, s.deleteBtn]} onPress={() => handleDelete(card.id, card.cardName)}>
                  <Text style={[s.actionBtnText, { color: COLORS.red }]}>✕ Remove</Text>
                </TouchableOpacity>
              </View>
            </View>
          ))
        )}
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
  headerSub: { fontSize: 12, color: COLORS.muted, marginTop: 2 },
  statsGrid: { flexDirection: 'row', gap: 8, marginBottom: 14, flexWrap: 'wrap' },
  stat: { flex: 1, minWidth: '45%', backgroundColor: COLORS.surface, borderRadius: 10, borderWidth: 1, borderColor: COLORS.border, padding: 10 },
  statLabel: { fontSize: 8, color: COLORS.muted, textTransform: 'uppercase', letterSpacing: 1, marginBottom: 4 },
  statVal: { fontSize: 18, fontWeight: '700', fontFamily: 'Courier' },
  empty: { alignItems: 'center', paddingTop: 80 },
  emptyIcon: { fontSize: 48, marginBottom: 12 },
  emptyTitle: { fontSize: 18, fontWeight: '600', color: COLORS.text, marginBottom: 6 },
  emptySub: { fontSize: 13, color: COLORS.muted, textAlign: 'center', lineHeight: 18 },
  cardItem: { backgroundColor: COLORS.surface, borderRadius: 14, borderWidth: 1, borderColor: COLORS.border, padding: 14, marginBottom: 10 },
  cardTop: { flexDirection: 'row', alignItems: 'flex-start', marginBottom: 12 },
  cardName: { fontSize: 16, fontWeight: '700', color: COLORS.text, textTransform: 'capitalize' },
  cardSet: { fontSize: 12, color: COLORS.muted, marginTop: 2 },
  verdictBadge: { borderWidth: 1, borderRadius: 6, paddingHorizontal: 8, paddingVertical: 3 },
  verdictText: { fontSize: 11, fontWeight: '700' },
  cardStats: { flexDirection: 'row', gap: 8, marginBottom: 10 },
  cardStat: { flex: 1, backgroundColor: COLORS.surface2, borderRadius: 8, padding: 8 },
  cardStatLabel: { fontSize: 9, color: COLORS.muted, textTransform: 'uppercase', letterSpacing: 1, marginBottom: 3 },
  cardStatVal: { fontSize: 14, fontWeight: '700', fontFamily: 'Courier' },
  refreshedAt: { fontSize: 10, color: COLORS.muted, marginBottom: 8 },
  cardActions: { flexDirection: 'row', gap: 8 },
  actionBtn: { flex: 1, borderRadius: 8, borderWidth: 1, padding: 9, alignItems: 'center' },
  refreshBtn: { borderColor: COLORS.border, backgroundColor: COLORS.surface2 },
  deleteBtn: { borderColor: COLORS.redDim },
  actionBtnText: { fontSize: 13, color: COLORS.text, fontWeight: '500' },
});
