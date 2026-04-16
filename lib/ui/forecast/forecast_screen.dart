import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/card.dart';
import '../../models/tcg_card.dart';
import '../../providers/forecast_provider.dart';
import '../../services/firestore_service.dart';
import '../shared/tcg_search_field.dart';
import '../theme/app_theme.dart';
import 'widgets/heat_index_tile.dart';
import 'widgets/projection_tile.dart';
import 'widgets/signal_card.dart';
import 'widgets/sp500_compare_tile.dart';
import 'widgets/unified_price_chart.dart';

/// Crystal Ball — the Forecast Engine screen.
///
/// Three states:
///  1. No card selected → Portfolio-wide forecast list (top 10 by value)
///  2. Search active   → Search results list
///  3. Card selected   → Full per-card detail view
class ForecastScreen extends ConsumerStatefulWidget {
  const ForecastScreen({super.key});

  @override
  ConsumerState<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends ConsumerState<ForecastScreen> {
  TcgCard? _selectedTcgCard;
  String? _selectedCardId;
  bool _searching = false; // true while the search field is active / populated

  void _onCardSelected(TcgCard card) async {
    // Upsert into Firestore so cardForecastProvider can resolve it.
    final db = ref.read(firestoreServiceProvider);
    final cardDoc = CardDocument(
      id: card.id,
      meta: CardMeta(
        name: card.name,
        setId: card.setId,
        setNumber: card.number,
        language: CardLanguage.en,
        variant: '',
        imageUrl: card.largeImageUrl ?? '',
      ),
      pricing: const CardPricing(),
    );
    await db.upsertCard(cardDoc);

    if (!mounted) return;
    setState(() {
      _selectedTcgCard = card;
      _selectedCardId = card.id;
      _searching = false;
    });
  }

  void _onCardCleared() {
    setState(() {
      _selectedTcgCard = null;
      _selectedCardId = null;
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              onBack: _selectedCardId != null ? _onCardCleared : null,
            ),

            // ── TCG live-search field ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TcgSearchField(
                selectedCard: _selectedTcgCard,
                onSelected: _onCardSelected,
                onCleared: _onCardCleared,
                hintText: 'Search any card to forecast…',
                label: 'Search card',
              ),
            ),

            Expanded(
              child: _selectedCardId != null
                  ? _CardDetailPanel(cardId: _selectedCardId!)
                  : _PortfolioForecastPanel(
                      onSelect: (cardId) =>
                          setState(() => _selectedCardId = cardId),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({this.onBack});
  final VoidCallback? onBack;

  void _showExplainer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ForecastExplainerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          if (onBack != null) ...[
            GestureDetector(
              onTap: onBack,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 10),
          ],
          const Text('🔮', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CRYSTAL BALL',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDisabled,
                  letterSpacing: 1.4,
                ),
              ),
              const Text(
                'Forecast Engine',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const Spacer(),
          Semantics(
            label: 'How the forecast works',
            button: true,
            child: GestureDetector(
              onTap: () => _showExplainer(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Forecast explainer bottom sheet
// ---------------------------------------------------------------------------

class _ForecastExplainerSheet extends StatelessWidget {
  const _ForecastExplainerSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Row(
                  children: [
                    const Text('🔮', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How the Forecast Works',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'A plain-English guide to every metric',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textDisabled,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Semantics(
                      label: 'Close',
                      button: true,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.close_rounded,
                            color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.border, height: 1),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  children: const [

                    _SectionHeader(emoji: '📈', title: '30-Day Price Trend'),
                    _ExplainerCard(
                      body:
                          'This chart shows the card\'s real sale prices over the last 30 days. '
                          'Each point is an actual eBay transaction. '
                          'The colour of the line matches the overall signal — '
                          'green means the model thinks it\'s a good time to buy, '
                          'amber means hold, red means consider selling. '
                          'The badge in the top-right shows the total % change over that period.',
                    ),

                    SizedBox(height: 20),
                    _SectionHeader(emoji: '🎯', title: '12-Month Price Projection'),
                    _ExplainerCard(
                      body:
                          'This is the app\'s best estimate of where the price will be in '
                          '12 months. It is not a guarantee — it is a model based on four '
                          'factors shown as chips below the chart. '
                          'Green chips are pushing the forecast higher. '
                          'Amber chips are a slight drag. '
                          'Grey chips are neutral.',
                    ),
                    SizedBox(height: 10),

                    _FactorRow(
                      emoji: '💎',
                      label: 'Scarcity',
                      color: AppColors.success,
                      body:
                          'Measures how hard it is to find a PSA 10 copy. '
                          'If only a tiny fraction of all graded copies ever received a perfect 10, '
                          'the card is rare and the forecast is boosted. '
                          'A card where half of all copies are PSA 10 gets no boost.',
                      range: '1.0× (common) → 1.5× (very rare)',
                    ),
                    _FactorRow(
                      emoji: '⚡',
                      label: 'Velocity',
                      color: AppColors.accent,
                      body:
                          'Measures how actively the card is being bought and sold on eBay '
                          'right now, based on the last 7 days of sales. '
                          'High activity means the price is real and liquid — people actually '
                          'want this card. Low or no recent sales gets a slight penalty '
                          'because the price may be stale.',
                      range: '0.9× (illiquid) → 1.2× (50+ sales/week)',
                    ),
                    _FactorRow(
                      emoji: '📅',
                      label: 'Age Lift',
                      color: AppColors.warning,
                      body:
                          'Vintage sets that are out of print — like Base Set, Jungle, Fossil, '
                          'Neo, EX era, and early Diamond & Pearl — get a long-term growth bonus. '
                          'No new copies can ever enter the market, so supply can only shrink over time. '
                          'Modern sets (Scarlet & Violet, Sword & Shield) get no boost.',
                      range: '1.0× (modern) or 1.15× (vintage / out of print)',
                    ),
                    _FactorRow(
                      emoji: '📊',
                      label: 'Sentiment',
                      color: AppColors.accentSoft,
                      body:
                          'Reflects the current mood of the collector community, '
                          'sourced from social data in the app\'s database. '
                          'When the community is excited and bullish, this pushes the '
                          'forecast higher. When sentiment is cautious or bearish, it pulls it down.',
                      range: '0.5× (very bearish) → 1.5× (very bullish)',
                    ),

                    SizedBox(height: 20),
                    _SectionHeader(emoji: '🟢', title: 'BUY / HOLD / SELL Signal'),
                    _ExplainerCard(
                      body:
                          'A single verdict — Buy, Hold, or Sell — with a confidence score '
                          'and a one-sentence reason. It is calculated by weighing five market signals:',
                    ),
                    SizedBox(height: 8),
                    _BulletRow(
                      emoji: '📉',
                      label: 'Low Supply',
                      body: 'Active listings dropped 20%+ week-over-week. '
                            'Fewer cards for sale usually means prices rise soon.',
                    ),
                    _BulletRow(
                      emoji: '🧱',
                      label: 'Pop Plateau',
                      body: 'The number of PSA 10s being created is growing very slowly (under 1%). '
                            'The ceiling on supply is effectively set.',
                    ),
                    _BulletRow(
                      emoji: '🔥',
                      label: 'High Velocity',
                      body: 'The card is selling faster than its 30-day average — '
                            'strong demand signal.',
                    ),
                    _BulletRow(
                      emoji: '⚠️',
                      label: 'Overheating',
                      body: 'Price jumped 30%+ in the last 14 days. '
                            'Rapid pumps often correct — the model leans toward Sell.',
                    ),
                    _BulletRow(
                      emoji: '🔄',
                      label: 'Flipper Influx',
                      body: 'More than 35% of listings come from accounts under 90 days old. '
                            'This suggests short-term speculators, which often precedes a sell-off.',
                    ),

                    SizedBox(height: 20),
                    _SectionHeader(emoji: '🌡️', title: 'Heat Index'),
                    _ExplainerCard(
                      body:
                          'A score that tells you how "hot" the card is right now — '
                          'not where it\'s going, just how much activity is happening today.\n\n'
                          '🔥 Above 1.5 = Heating Up — strong sales momentum\n'
                          '〰 0.5 to 1.5 = Stable — normal trading activity\n'
                          '❄️ Below 0.5 = Cooling Down — low interest\n\n'
                          'It combines two things: how much faster the card is selling '
                          'compared to its 30-day average (60% weight), '
                          'and how much the price moved in the last 7 days (40% weight).',
                    ),

                    SizedBox(height: 20),
                    _SectionHeader(emoji: '📊', title: 'S&P 500 Comparison'),
                    _ExplainerCard(
                      body:
                          'Compares the card\'s projected 1-year return against the stock market\'s '
                          'historical average of about 10.5% per year.\n\n'
                          'If the card is projected to return more than that, it shows '
                          '"Beats the Market" in green — meaning holding this card could '
                          'outperform a standard index fund investment.\n\n'
                          'If it\'s below that, it shows the gap in red. '
                          'This helps you decide if the card is actually a smart investment '
                          'compared to alternatives.',
                    ),

                    SizedBox(height: 20),
                    _DisclaimerBox(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Explainer sheet sub-widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.emoji, required this.title});
  final String emoji;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplainerCard extends StatelessWidget {
  const _ExplainerCard({required this.body});
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        body,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          height: 1.55,
        ),
      ),
    );
  }
}

class _FactorRow extends StatelessWidget {
  const _FactorRow({
    required this.emoji,
    required this.label,
    required this.color,
    required this.body,
    required this.range,
  });
  final String emoji;
  final String label;
  final Color color;
  final String body;
  final String range;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label factor: $body Range: $range',
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji,
                          style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 5),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Range: $range',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textDisabled,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({
    required this.emoji,
    required this.label,
    required this.body,
  });
  final String emoji;
  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $body',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$label  ',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: body,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisclaimerBox extends StatelessWidget {
  const _DisclaimerBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Forecasts are estimates, not financial advice. '
              'Card markets are volatile and past trends do not guarantee future prices. '
              'Always do your own research before buying or selling.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// (Search bar and results panel replaced by TcgSearchField in the state class)

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.style_rounded,
            size: 16, color: AppColors.textDisabled),
      );
}

// ---------------------------------------------------------------------------
// Portfolio-wide forecast panel
// ---------------------------------------------------------------------------

class _PortfolioForecastPanel extends ConsumerWidget {
  const _PortfolioForecastPanel({required this.onSelect});
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecasts = ref.watch(portfolioForecastsProvider);

    return forecasts.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (e, _) => _EmptyState(message: 'Could not load forecasts'),
      data: (list) {
        if (list.isEmpty) {
          return _EmptyState(
            message: 'Add cards to your vault to see forecasts',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: list.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'YOUR VAULT — TOP ${list.length}',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDisabled,
                    letterSpacing: 1.2,
                  ),
                ),
              );
            }
            final f = list[i - 1];
            return _ForecastListRow(
              forecast: f,
              onTap: () => onSelect(f.card.id),
            )
                .animate(delay: (i * 50).ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.05, end: 0);
          },
        );
      },
    );
  }
}

class _ForecastListRow extends StatelessWidget {
  const _ForecastListRow({required this.forecast, required this.onTap});
  final CardForecast forecast;
  final VoidCallback onTap;

  Color _signalColor() => switch (forecast.signal.signal) {
        ForecastSignal.buy  => AppColors.success,
        ForecastSignal.hold => AppColors.warning,
        ForecastSignal.sell => AppColors.danger,
      };

  String _signalLabel() => switch (forecast.signal.signal) {
        ForecastSignal.buy  => 'BUY',
        ForecastSignal.hold => 'HOLD',
        ForecastSignal.sell => 'SELL',
      };

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final color = _signalColor();
    final returnPct = forecast.projection.returnPct;
    final sign = returnPct >= 0 ? '+' : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            // Signal indicator strip
            Container(
              width: 3,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            // Card thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: forecast.card.meta.imageUrl.isNotEmpty
                  ? Image.network(
                      forecast.card.meta.imageUrl,
                      width: 30,
                      height: 42,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _ImagePlaceholder(),
                    )
                  : _ImagePlaceholder(),
            ),
            const SizedBox(width: 12),

            // Name + set
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    forecast.card.meta.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        forecast.card.meta.setId,
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.textDisabled),
                      ),
                      const SizedBox(width: 6),
                      _HeatDot(heat: forecast.heat),
                    ],
                  ),
                ],
              ),
            ),

            // Right side: signal + 1Y return
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _signalLabel(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$sign${returnPct.toStringAsFixed(1)}% 1Y',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: returnPct >= 0
                        ? AppColors.success
                        : AppColors.danger,
                  ),
                ),
                Text(
                  fmt.format(forecast.projection.projectedPrice1Y),
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textDisabled),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}

/// Small coloured dot showing heat level on the list row.
class _HeatDot extends StatelessWidget {
  const _HeatDot({required this.heat});
  final HeatResult heat;

  @override
  Widget build(BuildContext context) {
    final color = heat.isHot
        ? AppColors.danger
        : heat.isCold
            ? AppColors.accentSoft
            : AppColors.warning;
    final label = heat.isHot ? '🔥' : heat.isCold ? '❄' : '〰';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 9)),
        const SizedBox(width: 2),
        Text(
          heat.index.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔮', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textDisabled),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Per-card detail panel
// ---------------------------------------------------------------------------

class _CardDetailPanel extends ConsumerWidget {
  const _CardDetailPanel({required this.cardId});
  final String cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecast = ref.watch(cardForecastProvider(cardId));

    return forecast.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (e, _) => Center(
        child: Text(
          'Failed to load forecast',
          style: const TextStyle(color: AppColors.textDisabled),
        ),
      ),
      data: (f) => _CardDetailContent(forecast: f),
    );
  }
}

class _CardDetailContent extends StatelessWidget {
  const _CardDetailContent({required this.forecast});
  final CardForecast forecast;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        // Card identity header
        _CardIdentityHeader(forecast: forecast),
        const SizedBox(height: 16),

        // Unified chart: historical (30D–5Y) + projected (1Y/5Y/10Y)
        // with Raw / PSA / CGC / BGS / ACE grade toggles
        UnifiedPriceChart(forecast: forecast),
        const SizedBox(height: 12),

        // BUY / HOLD / SELL signal card
        SignalCard(signal: forecast.signal),
        const SizedBox(height: 12),

        // Heat index gauge
        HeatIndexTile(heat: forecast.heat),
        const SizedBox(height: 12),

        // 1-Year projection summary tile
        ProjectionTile(projection: forecast.projection),
        const SizedBox(height: 12),

        // S&P 500 comparison toggle
        Sp500CompareTile(benchmark: forecast.benchmark),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Card identity header (name, set, current price)
// ---------------------------------------------------------------------------

class _CardIdentityHeader extends StatelessWidget {
  const _CardIdentityHeader({required this.forecast});
  final CardForecast forecast;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final price = forecast.card.pricing.ebayUs?.lastSoldNm;

    return Row(
      children: [
        // Card thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: forecast.card.meta.imageUrl.isNotEmpty
              ? Image.network(
                  forecast.card.meta.imageUrl,
                  width: 54,
                  height: 76,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _ImagePlaceholder(),
                )
              : _ImagePlaceholder(),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                forecast.card.meta.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                forecast.card.meta.setId.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDisabled,
                  letterSpacing: 1.2,
                ),
              ),
              if (price != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      fmt.format(price),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'current',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textDisabled),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.05, end: 0);
  }
}
