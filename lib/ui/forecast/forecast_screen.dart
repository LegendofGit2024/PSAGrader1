import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/card.dart';
import '../../providers/forecast_provider.dart';
import '../theme/app_theme.dart';
import 'widgets/heat_index_tile.dart';
import 'widgets/projection_tile.dart';
import 'widgets/signal_card.dart';
import 'widgets/sp500_compare_tile.dart';
import 'widgets/trend_chart.dart';

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
  final _searchCtrl = TextEditingController();
  String? _selectedCardId;
  bool _searchFocused = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _selectCard(String cardId) {
    _searchCtrl.clear();
    ref.read(forecastSearchQueryProvider.notifier).set('');
    setState(() {
      _selectedCardId = cardId;
      _searchFocused = false;
    });
  }

  void _clearSelection() => setState(() => _selectedCardId = null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              onBack: _selectedCardId != null ? _clearSelection : null,
            ),
            _SearchBar(
              controller: _searchCtrl,
              onChanged: (q) {
                ref.read(forecastSearchQueryProvider.notifier).set(q);
                setState(() => _searchFocused = q.isNotEmpty);
              },
              onClear: () {
                _searchCtrl.clear();
                ref.read(forecastSearchQueryProvider.notifier).set('');
                setState(() => _searchFocused = false);
              },
            ),
            Expanded(
              child: _searchFocused
                  ? _SearchResultsPanel(onSelect: _selectCard)
                  : _selectedCardId != null
                      ? _CardDetailPanel(cardId: _selectedCardId!)
                      : _PortfolioForecastPanel(onSelect: _selectCard),
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
          const Text(
            '🔮',
            style: TextStyle(fontSize: 22),
          ),
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
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search bar
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search any card to forecast…',
            hintStyle: const TextStyle(
                fontSize: 13, color: AppColors.textDisabled),
            prefixIcon: const Icon(Icons.search_rounded,
                size: 18, color: AppColors.textDisabled),
            suffixIcon: controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: onClear,
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: AppColors.textDisabled),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search results panel
// ---------------------------------------------------------------------------

class _SearchResultsPanel extends ConsumerWidget {
  const _SearchResultsPanel({required this.onSelect});
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(forecastSearchResultsProvider);

    return results.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (_, __) => const Center(
        child: Text('Search failed',
            style: TextStyle(color: AppColors.textDisabled)),
      ),
      data: (cards) {
        if (cards.isEmpty) {
          return const Center(
            child: Text(
              'No cards found',
              style: TextStyle(fontSize: 13, color: AppColors.textDisabled),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          itemCount: cards.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (_, i) => _SearchResultRow(
            card: cards[i],
            onTap: () => onSelect(cards[i].id),
          ),
        );
      },
    );
  }
}

class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({required this.card, required this.onTap});
  final CardDocument card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final price = card.pricing.ebayUs?.lastSoldNm;
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Card image thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: card.meta.imageUrl.isNotEmpty
                  ? Image.network(
                      card.meta.imageUrl,
                      width: 36,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _ImagePlaceholder(),
                    )
                  : _ImagePlaceholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.meta.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    card.meta.setId,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textDisabled),
                  ),
                ],
              ),
            ),
            if (price != null)
              Text(
                fmt.format(price),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}

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

        // 30-day trend chart
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: TrendChart(
            history: forecast.priceHistory,
            signal: forecast.signal.signal,
          ),
        ),
        const SizedBox(height: 12),

        // BUY / HOLD / SELL signal card
        SignalCard(signal: forecast.signal),
        const SizedBox(height: 12),

        // Heat index gauge
        HeatIndexTile(heat: forecast.heat),
        const SizedBox(height: 12),

        // 1-Year projection
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
