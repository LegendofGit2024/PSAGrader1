import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/collection_provider.dart';
import '../../ui/theme/app_theme.dart';

/// "Fund Manager Mode" — full deep-dive analytics overlay.
///
/// Opened via the "Deep Dive" button on the Portfolio screen.
/// Contains:
///   • Unrealized Gains breakdown
///   • Market Correlation (Vintage vs Modern)
///   • Missing Piece alerts
class FundManagerSheet extends ConsumerWidget {
  const FundManagerSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FundManagerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  const Icon(Icons.analytics_rounded,
                      color: AppColors.accent, size: 20),
                  const SizedBox(width: 10),
                  const Text(
                    'Fund Manager',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            // Content
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: const [
                  _UnrealizedGainsSection(),
                  SizedBox(height: 24),
                  _MarketCorrelationSection(),
                  SizedBox(height: 24),
                  _MissingPieceSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section: Unrealized Gains
// ---------------------------------------------------------------------------

class _UnrealizedGainsSection extends ConsumerWidget {
  const _UnrealizedGainsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valAsync = ref.watch(portfolioValuationProvider);
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
            icon: Icons.show_chart_rounded, title: 'Unrealized Gains'),
        const SizedBox(height: 12),
        valAsync.when(
          loading: () => const _ShimmerBlock(height: 100),
          error: (_, __) => const SizedBox.shrink(),
          data: (val) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _FinRow(
                  label: 'Total Cost Basis',
                  value: fmt.format(val.totalCostBasis),
                ),
                _FinRow(
                  label: 'Total Market Value',
                  value: fmt.format(val.totalMarketValue),
                  valueColor: AppColors.textPrimary,
                ),
                const Divider(color: AppColors.border, height: 20),
                _FinRow(
                  label: 'Unrealized Gain/Loss',
                  value:
                      '${val.unrealizedGains >= 0 ? '+' : ''}${fmt.format(val.unrealizedGains)}',
                  bold: true,
                  valueColor: val.unrealizedGains >= 0
                      ? AppColors.success
                      : AppColors.danger,
                ),
                _FinRow(
                  label: 'Return on Investment',
                  value:
                      '${val.roiPct >= 0 ? '+' : ''}${val.roiPct.toStringAsFixed(2)}%',
                  valueColor: val.roiPct >= 0
                      ? AppColors.success
                      : AppColors.danger,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section: Market Correlation
// ---------------------------------------------------------------------------

class _MarketCorrelationSection extends ConsumerWidget {
  const _MarketCorrelationSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final corrAsync = ref.watch(marketCorrelationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
            icon: Icons.device_hub_rounded,
            title: 'Market Correlation'),
        const SizedBox(height: 4),
        const Text(
          'How your portfolio moves relative to Vintage and Modern markets.',
          style: TextStyle(fontSize: 12, color: AppColors.textDisabled),
        ),
        const SizedBox(height: 12),
        corrAsync.when(
          loading: () => const _ShimmerBlock(height: 80),
          error: (_, __) => const SizedBox.shrink(),
          data: (corr) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.history_rounded,
                        size: 14, color: AppColors.accent),
                    const SizedBox(width: 6),
                    const Text('Vintage',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                    const Spacer(),
                    Text(
                      '${(corr.vintagePct * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: corr.vintagePct,
                    backgroundColor: AppColors.surface,
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.flash_on_rounded,
                        size: 14, color: AppColors.accentSoft),
                    const SizedBox(width: 6),
                    const Text('Modern',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                    const Spacer(),
                    Text(
                      '${(corr.modernPct * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentSoft,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: corr.modernPct,
                    backgroundColor: AppColors.surface,
                    valueColor: const AlwaysStoppedAnimation(AppColors.accentSoft),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 14, color: AppColors.textDisabled),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Dominant exposure: ${corr.dominantMarket} market. '
                          '${corr.dominantMarket == 'Vintage' ? 'More sensitive to Base Set / Neo era trends.' : 'More sensitive to current set release cycles.'}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section: Missing Piece
// ---------------------------------------------------------------------------

class _MissingPieceSection extends ConsumerWidget {
  const _MissingPieceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(missingPieceAlertsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
            icon: Icons.extension_rounded, title: 'Missing Piece'),
        const SizedBox(height: 4),
        const Text(
          'Sets where you own all but one card.',
          style: TextStyle(fontSize: 12, color: AppColors.textDisabled),
        ),
        const SizedBox(height: 12),
        alertsAsync.when(
          loading: () => const _ShimmerBlock(height: 80),
          error: (_, __) => const SizedBox.shrink(),
          data: (alerts) {
            if (alerts.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.success, size: 20),
                    SizedBox(width: 10),
                    Text('No sets at N-1 completion',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14)),
                  ],
                ),
              );
            }
            return Column(
              children: alerts.map((a) => _MissingPieceCard(alert: a)).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _MissingPieceCard extends StatelessWidget {
  const _MissingPieceCard({required this.alert});
  final MissingPieceAlert alert;

  @override
  Widget build(BuildContext context) {
    final nmPrice =
        alert.missingCard.pricing.tcgplayerUs?.marketNm;
    final ebayPrice =
        alert.missingCard.pricing.ebayUs?.lastSoldNm;
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Card image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: alert.missingCard.meta.imageUrl,
              width: 48,
              height: 67,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 12, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      '${alert.ownedCount}/${alert.totalCount} complete',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  alert.missingCard.meta.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${alert.missingCard.meta.setId}  ·  ${alert.missingCard.meta.setNumber}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (nmPrice != null)
                      _PriceTag(
                          label: 'TCG', value: fmt.format(nmPrice)),
                    if (nmPrice != null && ebayPrice != null)
                      const SizedBox(width: 8),
                    if (ebayPrice != null)
                      _PriceTag(
                          label: 'eBay', value: fmt.format(ebayPrice)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}

class _PriceTag extends StatelessWidget {
  const _PriceTag({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textDisabled),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _FinRow extends StatelessWidget {
  const _FinRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor = AppColors.textPrimary,
  });
  final String label;
  final String value;
  final bool bold;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          Text(value,
              style: TextStyle(
                fontSize: bold ? 15 : 13,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: valueColor,
              )),
        ],
      ),
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
