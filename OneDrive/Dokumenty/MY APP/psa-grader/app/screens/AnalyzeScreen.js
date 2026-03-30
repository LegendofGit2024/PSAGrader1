import React, { useState } from 'react';
import {
  View, Text, TextInput, TouchableOpacity, ScrollView,
  StyleSheet, ActivityIndicator, Alert, Linking,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { COLORS, GRADE_STYLES } from '../utils/theme';
import { analyzeCard } from '../utils/api';
import { addToPortfolio } from '../utils/portfolio';

const GRADES = [
  { key: 'p10', label: 'PSA 10' },
  { key: 'p9',  label: 'PSA 9' },
  { key: 'p8',  label: 'PSA 8' },
  { key: 'p7',  label: 'PSA 7' },
  { key: 'p6',  label: 'PSA 6' },
  { key: 'pLow',label: 'PSA 5↓' },
];

export default function AnalyzeScreen() {
  const [form, setForm] = useState({
    cardName: '', set: '', num: '',
    buyPrice: '', gradeFee: '25', shipping: '13', platFee: '13',
  });
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState(null);
  const [rawData, setRawData] = useState(null);
  const [saved, setSaved] = useState(false);

  const set = (key, val) => setForm(f => ({ ...f, [key]: val }));

  async function handleAnalyze() {
    if (!form.cardName.trim()) { Alert.alert('Missing', 'Please enter a card name'); return; }
    setLoading(true);
    setResult(null);
    setSaved(false);
    try {
      const res = await analyzeCard({
        cardName: form.cardName.trim(),
        set: form.set.trim(),
        num: form.num.trim(),
        buyPrice: parseFloat(form.buyPrice) || 0,
        gradeFee: parseFloat(form.gradeFee) || 25,
        shipping: parseFloat(form.shipping) || 13,
        platFee: (parseFloat(form.platFee) || 13) / 100,
      });
      setResult(res.analysis);
      setRawData(res.rawData);
    } catch (e) {
      Alert.alert('Error', e.message || 'Could not connect to backend. Check Settings.');
    } finally {
      setLoading(false);
    }
  }

  async function handleSave() {
    if (!result) return;
    const totalCost = rawData?.totalCost || 0;
    const platFee = (parseFloat(form.platFee) || 13) / 100;
    let expRev = 0;
    GRADES.forEach(g => {
      const prob = (result.probs?.[g.key] || 0) / 100;
      const sale = result.salePrices?.[g.key] || 0;
      expRev += prob * sale * (1 - platFee);
    });
    await addToPortfolio({
      cardName: form.cardName.trim(),
      set: form.set.trim(),
      num: form.num.trim(),
      buyPrice: parseFloat(form.buyPrice) || 0,
      totalCost,
      expectedRevenue: expRev,
      expectedProfit: expRev - totalCost,
      gemRate: result.gemRate?.pct,
      verdict: result.verdict?.decision,
      analysis: result,
    });
    setSaved(true);
    Alert.alert('Saved', `${form.cardName} added to your portfolio`);
  }

  function openEbay(gradeLabel) {
    const q = encodeURIComponent(`pokemon ${form.cardName} ${form.set} ${form.num} ${gradeLabel}`);
    Linking.openURL(`https://www.ebay.co.uk/sch/i.html?_nkw=${q}&LH_Sold=1&LH_Complete=1`);
  }

  const totalCost = (parseFloat(form.buyPrice) || 0) + (parseFloat(form.gradeFee) || 25) + (parseFloat(form.shipping) || 13);
  const platFee = (parseFloat(form.platFee) || 13) / 100;

  let expRev = 0, expProfit = 0, roi = 0;
  if (result) {
    GRADES.forEach(g => {
      expRev += ((result.probs?.[g.key] || 0) / 100) * (result.salePrices?.[g.key] || 0) * (1 - platFee);
    });
    expProfit = expRev - totalCost;
    roi = totalCost > 0 ? (expProfit / totalCost) * 100 : 0;
  }

  return (
    <SafeAreaView style={s.safe}>
      <ScrollView style={s.scroll} keyboardShouldPersistTaps="handled">
        {/* Header */}
        <View style={s.header}>
          <Text style={s.headerTitle}>⬡ PSA Analyzer</Text>
          <Text style={s.headerSub}>AI-powered grading intelligence</Text>
        </View>

        {/* Input Card */}
        <View style={s.card}>
          <Text style={s.cardLabel}>CARD DETAILS</Text>
          <View style={s.row3}>
            <View style={s.flex2}>
              <Text style={s.label}>Card Name</Text>
              <TextInput style={s.input} placeholder="Charizard" placeholderTextColor={COLORS.muted}
                value={form.cardName} onChangeText={v => set('cardName', v)} />
            </View>
            <View style={s.flex1}>
              <Text style={s.label}>Card #</Text>
              <TextInput style={s.input} placeholder="4/102" placeholderTextColor={COLORS.muted}
                value={form.num} onChangeText={v => set('num', v)} />
            </View>
          </View>
          <View style={{ marginBottom: 10 }}>
            <Text style={s.label}>Set Name</Text>
            <TextInput style={s.input} placeholder="Base Set" placeholderTextColor={COLORS.muted}
              value={form.set} onChangeText={v => set('set', v)} />
          </View>
          <View style={s.row4}>
            {[
              { key: 'buyPrice', label: 'Buy Price (£)', placeholder: '0.00' },
              { key: 'gradeFee', label: 'Grade Fee (£)', placeholder: '25' },
              { key: 'shipping', label: 'Shipping (£)', placeholder: '13' },
              { key: 'platFee', label: 'Platform %', placeholder: '13' },
            ].map(f => (
              <View key={f.key} style={s.flex1}>
                <Text style={s.label}>{f.label}</Text>
                <TextInput style={s.input} placeholder={f.placeholder} placeholderTextColor={COLORS.muted}
                  keyboardType="decimal-pad" value={form[f.key]} onChangeText={v => set(f.key, v)} />
              </View>
            ))}
          </View>
          <View style={s.totalRow}>
            <Text style={s.totalLabel}>Total Cost</Text>
            <Text style={s.totalVal}>£{totalCost.toFixed(2)}</Text>
          </View>
          <TouchableOpacity style={[s.btn, loading && s.btnDisabled]} onPress={handleAnalyze} disabled={loading}>
            {loading
              ? <ActivityIndicator color="#000" />
              : <Text style={s.btnText}>⚡ Analyze Card</Text>}
          </TouchableOpacity>
        </View>

        {/* Results */}
        {result && (
          <>
            {/* Gem Rate Banner */}
            <View style={[s.gemBanner, result.gemRate?.rating === 'hot' ? s.gemHot : result.gemRate?.rating === 'warm' ? s.gemWarm : s.gemCold]}>
              <Text style={s.gemIcon}>{result.gemRate?.rating === 'hot' ? '💎' : result.gemRate?.rating === 'warm' ? '🟢' : '❄️'}</Text>
              <View style={{ flex: 1 }}>
                <Text style={[s.gemLabel, result.gemRate?.rating === 'hot' ? { color: '#fcd34d' } : result.gemRate?.rating === 'warm' ? { color: '#86efac' } : { color: '#fca5a5' }]}>
                  {result.gemRate?.label} Gem Rate
                </Text>
                <Text style={s.gemReason}>{result.gemRate?.reason}</Text>
                {result.gradingTip && <Text style={s.gemTip}>💡 {result.gradingTip}</Text>}
              </View>
              <Text style={[s.gemPct, result.gemRate?.rating === 'hot' ? { color: '#fcd34d' } : result.gemRate?.rating === 'warm' ? { color: '#86efac' } : { color: '#fca5a5' }]}>
                {result.gemRate?.pct}%
              </Text>
            </View>

            {/* Metrics */}
            <View style={s.metricsGrid}>
              {[
                { label: 'TOTAL COST', val: `£${totalCost.toFixed(0)}`, color: COLORS.accent },
                { label: 'EXP. REVENUE', val: `£${expRev.toFixed(0)}`, color: COLORS.blue },
                { label: 'EXP. PROFIT', val: `£${expProfit.toFixed(0)}`, color: expProfit >= 0 ? COLORS.green : COLORS.red },
                { label: 'ROI', val: `${roi.toFixed(1)}%`, color: roi >= 0 ? COLORS.green : COLORS.red },
              ].map(m => (
                <View key={m.label} style={s.metric}>
                  <Text style={s.metricLabel}>{m.label}</Text>
                  <Text style={[s.metricVal, { color: m.color }]}>{m.val}</Text>
                </View>
              ))}
            </View>

            {/* Grade Table */}
            <View style={s.card}>
              <Text style={s.cardLabel}>GRADE BREAKDOWN</Text>
              <View style={s.tableHeader}>
                <Text style={[s.th, { flex: 1 }]}>Grade</Text>
                <Text style={[s.th, { flex: 1 }]}>Sale</Text>
                <Text style={[s.th, { flex: 1 }]}>Net</Text>
                <Text style={[s.th, { flex: 1 }]}>Profit</Text>
                <Text style={[s.th, { width: 45 }]}>Prob</Text>
              </View>
              {GRADES.map(g => {
                const sale = result.salePrices?.[g.key] || 0;
                const net = sale * (1 - platFee);
                const profit = net - totalCost;
                const prob = result.probs?.[g.key] || 0;
                const gs = GRADE_STYLES[g.label] || GRADE_STYLES['PSA 6'];
                return (
                  <View key={g.key} style={s.tableRow}>
                    <View style={[s.gradeBadge, { backgroundColor: gs.bg, borderColor: gs.border, flex: 1 }]}>
                      <Text style={[s.gradeBadgeText, { color: gs.color }]}>{g.label}</Text>
                    </View>
                    <Text style={[s.td, { flex: 1 }]}>£{sale.toFixed(0)}</Text>
                    <Text style={[s.td, { flex: 1 }]}>£{net.toFixed(0)}</Text>
                    <Text style={[s.td, { flex: 1, color: profit >= 0 ? COLORS.green : COLORS.red }]}>
                      {profit >= 0 ? '+' : ''}£{profit.toFixed(0)}
                    </Text>
                    <View style={{ width: 45 }}>
                      <Text style={[s.td, { textAlign: 'right' }]}>{prob}%</Text>
                      <View style={s.probBg}>
                        <View style={[s.probFill, { width: `${prob}%` }]} />
                      </View>
                    </View>
                  </View>
                );
              })}
            </View>

            {/* PSA Pop Data */}
            {rawData?.psaPop && (
              <View style={s.card}>
                <Text style={s.cardLabel}>PSA POPULATION DATA</Text>
                <View style={s.row2}>
                  <View style={s.statBox}>
                    <Text style={s.statVal}>{rawData.psaPop.total?.toLocaleString() || '—'}</Text>
                    <Text style={s.statLabel}>Total Graded</Text>
                  </View>
                  <View style={s.statBox}>
                    <Text style={[s.statVal, { color: COLORS.accent }]}>{rawData.psaPop.psa10Count?.toLocaleString() || '—'}</Text>
                    <Text style={s.statLabel}>PSA 10s</Text>
                  </View>
                  <View style={s.statBox}>
                    <Text style={[s.statVal, { color: rawData.psaPop.gemRate > 20 ? COLORS.green : COLORS.red }]}>
                      {rawData.psaPop.gemRate != null ? `${rawData.psaPop.gemRate}%` : '—'}
                    </Text>
                    <Text style={s.statLabel}>Real Gem Rate</Text>
                  </View>
                </View>
              </View>
            )}

            {/* eBay Live Prices */}
            {rawData?.ebayPrices && (
              <View style={s.card}>
                <Text style={s.cardLabel}>LIVE eBay SOLD PRICES</Text>
                {Object.entries(rawData.ebayPrices).map(([grade, data]) => (
                  <TouchableOpacity key={grade} style={s.ebayRow} onPress={() => openEbay(grade)}>
                    <Text style={s.ebayGrade}>{grade}</Text>
                    {data ? (
                      <View style={{ flex: 1, alignItems: 'flex-end' }}>
                        <Text style={s.ebayMedian}>£{data.median} median</Text>
                        <Text style={s.ebaySub}>£{data.min}–£{data.max} · {data.count} sales</Text>
                      </View>
                    ) : (
                      <Text style={s.ebayNone}>No data</Text>
                    )}
                    <Text style={{ color: COLORS.muted, marginLeft: 6 }}>›</Text>
                  </TouchableOpacity>
                ))}
              </View>
            )}

            {/* Verdict */}
            {result.verdict && (
              <View style={[s.verdict,
                result.verdict.decision === 'GRADE' ? s.verdictGo :
                result.verdict.decision === 'SKIP' ? s.verdictStop : s.verdictCaution
              ]}>
                <Text style={[s.verdictTitle,
                  result.verdict.decision === 'GRADE' ? { color: '#86efac' } :
                  result.verdict.decision === 'SKIP' ? { color: '#fca5a5' } : { color: '#fcd34d' }
                ]}>
                  {result.verdict.decision === 'GRADE' ? '✅ GRADE IT' : result.verdict.decision === 'SKIP' ? '❌ SKIP IT' : '⚠️ RISKY'} — {result.verdict.headline}
                </Text>
                <Text style={s.verdictBody}>{result.verdict.analysis}</Text>
                {result.keyFactors?.length > 0 && (
                  <View style={s.factors}>
                    {result.keyFactors.map(f => (
                      <View key={f} style={s.factorPill}>
                        <Text style={s.factorText}>{f}</Text>
                      </View>
                    ))}
                  </View>
                )}
              </View>
            )}

            {/* Save to Portfolio */}
            <TouchableOpacity style={[s.saveBtn, saved && s.saveBtnDone]} onPress={handleSave} disabled={saved}>
              <Text style={s.saveBtnText}>{saved ? '✓ Saved to Portfolio' : '＋ Add to Portfolio'}</Text>
            </TouchableOpacity>
          </>
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
  headerTitle: { fontSize: 22, fontWeight: '700', color: COLORS.accent },
  headerSub: { fontSize: 12, color: COLORS.muted, marginTop: 2 },
  card: { backgroundColor: COLORS.surface, borderRadius: 14, borderWidth: 1, borderColor: COLORS.border, padding: 14, marginBottom: 12 },
  cardLabel: { fontSize: 10, color: COLORS.muted, letterSpacing: 2, textTransform: 'uppercase', marginBottom: 12, fontFamily: 'Courier' },
  row3: { flexDirection: 'row', gap: 8, marginBottom: 10 },
  row4: { flexDirection: 'row', gap: 6, marginBottom: 10 },
  row2: { flexDirection: 'row', gap: 8 },
  flex1: { flex: 1 },
  flex2: { flex: 2 },
  label: { fontSize: 10, color: COLORS.muted, textTransform: 'uppercase', letterSpacing: 1, marginBottom: 4 },
  input: { backgroundColor: '#0d1424', borderWidth: 1, borderColor: '#2a3a55', borderRadius: 8, padding: 10, color: COLORS.text, fontSize: 14 },
  totalRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 8, marginBottom: 10, borderTopWidth: 1, borderTopColor: COLORS.border },
  totalLabel: { fontSize: 12, color: COLORS.muted },
  totalVal: { fontSize: 16, fontWeight: '700', color: COLORS.accent, fontFamily: 'Courier' },
  btn: { backgroundColor: COLORS.accent, borderRadius: 10, padding: 14, alignItems: 'center' },
  btnDisabled: { opacity: 0.5 },
  btnText: { color: '#000', fontWeight: '700', fontSize: 15 },
  gemBanner: { borderRadius: 12, padding: 14, marginBottom: 12, flexDirection: 'row', alignItems: 'center', gap: 12, borderWidth: 1 },
  gemHot: { backgroundColor: '#1a1505', borderColor: '#854d0e' },
  gemWarm: { backgroundColor: '#0d1f0e', borderColor: '#166534' },
  gemCold: { backgroundColor: '#1a0a0a', borderColor: '#7f1d1d' },
  gemIcon: { fontSize: 28 },
  gemLabel: { fontSize: 15, fontWeight: '600', marginBottom: 2 },
  gemReason: { fontSize: 12, color: '#94a3b8', lineHeight: 16 },
  gemTip: { fontSize: 11, color: COLORS.accent, marginTop: 6, lineHeight: 15 },
  gemPct: { fontSize: 26, fontWeight: '700', fontFamily: 'Courier' },
  metricsGrid: { flexDirection: 'row', gap: 8, marginBottom: 12 },
  metric: { flex: 1, backgroundColor: COLORS.surface, borderRadius: 10, borderWidth: 1, borderColor: COLORS.border, padding: 10, alignItems: 'center' },
  metricLabel: { fontSize: 8, color: COLORS.muted, textTransform: 'uppercase', letterSpacing: 1, marginBottom: 4 },
  metricVal: { fontSize: 16, fontWeight: '700', fontFamily: 'Courier' },
  tableHeader: { flexDirection: 'row', paddingBottom: 8, borderBottomWidth: 1, borderBottomColor: COLORS.border, marginBottom: 4 },
  th: { fontSize: 9, color: COLORS.muted, textTransform: 'uppercase', letterSpacing: 1 },
  tableRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: 8, borderBottomWidth: 1, borderBottomColor: COLORS.border, gap: 4 },
  gradeBadge: { borderRadius: 5, borderWidth: 1, paddingHorizontal: 6, paddingVertical: 2, alignSelf: 'flex-start' },
  gradeBadgeText: { fontSize: 10, fontWeight: '700', fontFamily: 'Courier' },
  td: { fontSize: 12, color: COLORS.text, fontFamily: 'Courier' },
  probBg: { backgroundColor: COLORS.surface2, borderRadius: 2, height: 3, marginTop: 3 },
  probFill: { height: 3, backgroundColor: COLORS.accent, borderRadius: 2 },
  statBox: { flex: 1, backgroundColor: COLORS.surface2, borderRadius: 8, padding: 10, alignItems: 'center' },
  statVal: { fontSize: 18, fontWeight: '700', color: COLORS.text, fontFamily: 'Courier' },
  statLabel: { fontSize: 10, color: COLORS.muted, marginTop: 3 },
  ebayRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: 10, borderBottomWidth: 1, borderBottomColor: COLORS.border },
  ebayGrade: { width: 55, fontSize: 12, fontWeight: '600', color: COLORS.text },
  ebayMedian: { fontSize: 13, fontWeight: '700', color: COLORS.accent, fontFamily: 'Courier' },
  ebaySub: { fontSize: 10, color: COLORS.muted, marginTop: 1 },
  ebayNone: { flex: 1, fontSize: 12, color: COLORS.muted, textAlign: 'right' },
  verdict: { borderRadius: 12, padding: 14, marginBottom: 12, borderWidth: 1 },
  verdictGo: { backgroundColor: '#0d1f0e', borderColor: '#166534' },
  verdictStop: { backgroundColor: '#1a0a0a', borderColor: '#7f1d1d' },
  verdictCaution: { backgroundColor: '#1a1505', borderColor: '#854d0e' },
  verdictTitle: { fontSize: 14, fontWeight: '700', marginBottom: 6 },
  verdictBody: { fontSize: 13, color: '#94a3b8', lineHeight: 19 },
  factors: { flexDirection: 'row', flexWrap: 'wrap', gap: 6, marginTop: 10 },
  factorPill: { backgroundColor: COLORS.surface2, borderWidth: 1, borderColor: COLORS.border, borderRadius: 4, paddingHorizontal: 8, paddingVertical: 3 },
  factorText: { fontSize: 11, color: COLORS.muted },
  saveBtn: { backgroundColor: COLORS.surface2, borderWidth: 1, borderColor: COLORS.accent, borderRadius: 10, padding: 14, alignItems: 'center', marginBottom: 12 },
  saveBtnDone: { borderColor: COLORS.green },
  saveBtnText: { color: COLORS.text, fontWeight: '600', fontSize: 14 },
});
