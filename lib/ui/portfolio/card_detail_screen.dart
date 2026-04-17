import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/card.dart';
import '../../models/collection_item.dart';
import '../../providers/collection_provider.dart';
import '../../services/price_link_utility.dart';
import '../theme/app_theme.dart';
import 'widgets/slab_card_tile.dart';

class CardDetailScreen extends ConsumerWidget {
  const CardDetailScreen({super.key, required this.itemId});
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(collectionItemProvider(itemId));

    return itemAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: Center(
            child: Text('Error: $e',
                style: const TextStyle(color: AppColors.danger))),
      ),
      data: (item) {
        if (item == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(),
            body: const Center(
                child: Text('Card not found',
                    style: TextStyle(color: AppColors.textSecondary))),
          );
        }
        return _DetailBody(item: item);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Main detail body
// ---------------------------------------------------------------------------

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.item});
  final CollectionItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardAsync = ref.watch(resolvedCardProvider(item.cardRef.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: cardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: AppColors.danger))),
        data: (card) {
          if (card == null) {
            return const Center(
                child: Text('Card data unavailable',
                    style: TextStyle(color: AppColors.textSecondary)));
          }
          return CustomScrollView(
            slivers: [
              _HeroAppBar(item: item, card: card),
              _CardBody(item: item, card: card),
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          );
        },
      ),
      floatingActionButton: _ActionBar(item: item),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero image app bar
// ---------------------------------------------------------------------------

class _HeroAppBar extends StatelessWidget {
  const _HeroAppBar({required this.item, required this.card});
  final CollectionItem item;
  final CardDocument card;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        color: AppColors.textPrimary,
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_rounded, color: AppColors.textSecondary),
          onPressed: () => context.push('/portfolio/card/${ item.id}/edit'),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Blurred background tint
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.surface,
                    AppColors.background,
                  ],
                ),
              ),
            ),
            // Card image — centered, with Museum-style breathing room
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 60, 40, 20),
              child: CachedNetworkImage(
                imageUrl: card.meta.imageUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: AppColors.surface,
                  highlightColor: AppColors.surfaceVariant,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail content body
// ---------------------------------------------------------------------------

class _CardBody extends StatelessWidget {
  const _CardBody({required this.item, required this.card});
  final CollectionItem item;
  final CardDocument card;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card name + set
            Text(
              card.meta.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ).animate().fadeIn(delay: 50.ms),
            const SizedBox(height: 4),
            Text(
              '${card.meta.setId}  ·  ${card.meta.setNumber}  ·  ${card.meta.language.name.toUpperCase()}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(delay: 80.ms),
            const SizedBox(height: 20),

            // Condition badge
            _ConditionBadge(item: item),
            const SizedBox(height: 20),

            // Financial summary
            _FinancialCard(item: item, card: card),
            const SizedBox(height: 12),

            // Live Price Check button
            _LivePriceCheckButton(card: card),
            const SizedBox(height: 20),

            // eBay Raw vs Graded split pricing
            if (card.pricing.ebayUs?.raw != null ||
                card.pricing.ebayUs?.graded != null) ...[
              _SectionHeader(title: 'eBay Market Data'),
              const SizedBox(height: 10),
              _EbayMarketSection(pricing: card.pricing),
              const SizedBox(height: 20),
            ],

            // Regional pricing (TCGplayer / Cardmarket / Yuyutei)
            if (card.pricing.tcgplayerUs != null ||
                card.pricing.cardmarketEu != null ||
                card.pricing.yuyuteiJp != null) ...[
              _SectionHeader(title: 'Market Prices'),
              const SizedBox(height: 10),
              _PricingGrid(pricing: card.pricing),
              const SizedBox(height: 20),
            ],

            // Slab-specific details
            if (item.condition.type == ConditionType.slab &&
                item.condition.slab != null) ...[
              _SectionHeader(title: 'Slab Details'),
              const SizedBox(height: 10),
              _SlabDetails(slab: item.condition.slab!),
              const SizedBox(height: 20),
            ],

            // PSA Population
            if (card.psaPop != null) ...[
              _SectionHeader(title: 'PSA Population'),
              const SizedBox(height: 10),
              _PopReport(pop: card.psaPop!),
              const SizedBox(height: 20),
            ],

            // Location
            _SectionHeader(title: 'Location'),
            const SizedBox(height: 10),
            _LocationChip(location: item.location),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Condition badge
// ---------------------------------------------------------------------------

class _ConditionBadge extends StatelessWidget {
  const _ConditionBadge({required this.item});
  final CollectionItem item;

  @override
  Widget build(BuildContext context) {
    if (item.condition.type == ConditionType.slab &&
        item.condition.slab != null) {
      final slab = item.condition.slab!;
      return Row(
        children: [
          _Badge(
            label: slab.grader.name.toUpperCase(),
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(width: 8),
          _Badge(
            label: 'Grade ${slab.grade}',
            color: AppColors.accent,
            textColor: AppColors.background,
          ),
          if (slab.certNumber.isNotEmpty) ...[
            const SizedBox(width: 8),
            _Badge(label: '#${slab.certNumber}', color: AppColors.surface),
          ],
        ],
      );
    }

    final cond = item.condition.rawCondition ?? RawCondition.nm;
    final colors = {
      RawCondition.nm: AppColors.success,
      RawCondition.lp: const Color(0xFF84CC16),
      RawCondition.mp: AppColors.warning,
      RawCondition.hp: AppColors.danger,
      RawCondition.dmg: AppColors.textDisabled,
    };
    return _Badge(label: cond.name.toUpperCase(), color: colors[cond]!);
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    this.textColor = Colors.white,
  });
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color == AppColors.surface ? AppColors.textPrimary : color,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Financial summary card
// ---------------------------------------------------------------------------

class _FinancialCard extends StatelessWidget {
  const _FinancialCard({required this.item, required this.card});
  final CollectionItem item;
  final CardDocument card;

  double? get _marketValue {
    if (item.condition.type == ConditionType.slab) {
      return card.pricing.ebayUs?.lastSoldNm;
    }
    final cond = item.condition.rawCondition;
    final p = card.pricing.tcgplayerUs;
    if (p == null || cond == null) return null;
    return switch (cond) {
      RawCondition.nm => p.marketNm,
      RawCondition.lp => p.marketLp,
      RawCondition.mp => p.marketMp,
      RawCondition.hp => p.marketHp,
      RawCondition.dmg => p.marketDmg,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cost = item.acquisition.costBasis;
    final market = _marketValue;
    final pnl = market != null ? market - cost : null;
    final roi = (market != null && cost > 0)
        ? ((market - cost) / cost * 100)
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _FinStat(
            label: 'Cost Basis',
            value: '\$${cost.toStringAsFixed(2)}',
          ),
          _VertDivider(),
          _FinStat(
            label: 'Market Value',
            value: market != null
                ? '\$${market.toStringAsFixed(2)}'
                : '—',
            subLabel: market != null ? 'eBay / TCGplayer' : null,
          ),
          _VertDivider(),
          _FinStat(
            label: 'P&L',
            value: pnl != null
                ? '${pnl >= 0 ? '+' : ''}\$${pnl.toStringAsFixed(2)}'
                : '—',
            valueColor: pnl == null
                ? AppColors.textSecondary
                : pnl >= 0
                    ? AppColors.success
                    : AppColors.danger,
            subLabel: roi != null
                ? '${roi >= 0 ? '+' : ''}${roi.toStringAsFixed(1)}%'
                : null,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.04, end: 0);
  }
}

class _FinStat extends StatelessWidget {
  const _FinStat({
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
    this.subLabel,
  });
  final String label;
  final String value;
  final Color valueColor;
  final String? subLabel;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: valueColor)),
          if (subLabel != null) ...[
            const SizedBox(height: 2),
            Text(subLabel!,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textDisabled)),
          ],
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: AppColors.border);
  }
}

// ---------------------------------------------------------------------------
// eBay Raw / Graded toggle section
// ---------------------------------------------------------------------------

class _EbayMarketSection extends StatefulWidget {
  const _EbayMarketSection({required this.pricing});
  final CardPricing pricing;

  @override
  State<_EbayMarketSection> createState() => _EbayMarketSectionState();
}

class _EbayMarketSectionState extends State<_EbayMarketSection> {
  bool _showGraded = false;

  @override
  Widget build(BuildContext context) {
    final ebay   = widget.pricing.ebayUs;
    final raw    = ebay?.raw;
    final graded = ebay?.graded;
    final hasRaw    = raw?.lastSold != null;
    final hasGraded = graded?.psa10 != null || graded?.psa9 != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle pill
        if (hasRaw && hasGraded)
          _ConditionToggle(
            showGraded: _showGraded,
            onChanged: (v) => setState(() => _showGraded = v),
          ),
        if (hasRaw && hasGraded) const SizedBox(height: 12),

        // Price panel
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _showGraded
              ? _GradedPanel(graded: graded!, key: const ValueKey('graded'))
              : _RawPanel(raw: raw, key: const ValueKey('raw')),
        ),

        // Grading Alpha — only visible when both datasets exist
        if (hasRaw && hasGraded && graded!.psa10 != null) ...[
          const SizedBox(height: 10),
          _GradingAlphaCard(
            rawPrice:  raw!.lastSold!,
            psa10:     graded.psa10!,
            psa9:      graded.psa9,
          ),
        ],
      ],
    );
  }
}

class _ConditionToggle extends StatelessWidget {
  const _ConditionToggle({
    required this.showGraded,
    required this.onChanged,
  });
  final bool showGraded;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _ToggleBtn(
            label: 'Raw',
            icon: Icons.style_outlined,
            active: !showGraded,
            onTap: () => onChanged(false),
          ),
          _ToggleBtn(
            label: 'Graded',
            icon: Icons.workspace_premium_rounded,
            active: showGraded,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });
  final String   label;
  final IconData icon;
  final bool     active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: active ? AppColors.accent.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: active
                ? Border.all(color: AppColors.accent.withOpacity(0.5))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 13,
                  color: active ? AppColors.accent : AppColors.textSecondary),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: active ? AppColors.accent : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RawPanel extends StatelessWidget {
  const _RawPanel({super.key, required this.raw});
  final EbayRawPrice? raw;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.style_outlined, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Raw (Ungraded)',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 3),
              Text(
                raw?.lastSold != null
                    ? '\$${raw!.lastSold!.toStringAsFixed(2)}'
                    : '—',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text('eBay median · last 5 sales',
              style: TextStyle(fontSize: 10, color: AppColors.textDisabled)),
        ],
      ),
    );
  }
}

class _GradedPanel extends StatelessWidget {
  const _GradedPanel({super.key, required this.graded});
  final EbayGradedPrice graded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded,
                  size: 16, color: AppColors.accent),
              const SizedBox(width: 6),
              const Text('Graded',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary)),
              const Spacer(),
              const Text('eBay median · last 5 sales',
                  style: TextStyle(fontSize: 10, color: AppColors.textDisabled)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _GradeStat(
                label: 'PSA / CGC 10',
                value: graded.psa10,
                highlight: true,
              ),
              const SizedBox(width: 12),
              _GradeStat(label: 'PSA 9', value: graded.psa9),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradeStat extends StatelessWidget {
  const _GradeStat({
    required this.label,
    required this.value,
    this.highlight = false,
  });
  final String  label;
  final double? value;
  final bool    highlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: highlight
              ? AppColors.accent.withOpacity(0.08)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: highlight
              ? Border.all(color: AppColors.accent.withOpacity(0.3))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(
              value != null ? '\$${value!.toStringAsFixed(2)}' : '—',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: highlight ? AppColors.accent : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grading Alpha — the price gap between raw and PSA 10.
/// This is the core "is it worth grading?" signal.
class _GradingAlphaCard extends StatelessWidget {
  const _GradingAlphaCard({
    required this.rawPrice,
    required this.psa10,
    this.psa9,
  });
  final double  rawPrice;
  final double  psa10;
  final double? psa9;

  @override
  Widget build(BuildContext context) {
    final alpha     = psa10 - rawPrice;
    final alphaSign = alpha >= 0 ? '+' : '';
    final roiPct    = rawPrice > 0 ? (alpha / rawPrice * 100) : 0.0;
    final isWorth   = alpha > 25;          // rough rule: only worth if >$25 upside

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isWorth
            ? AppColors.success.withOpacity(0.06)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWorth
              ? AppColors.success.withOpacity(0.35)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isWorth
                    ? Icons.trending_up_rounded
                    : Icons.trending_flat_rounded,
                size: 14,
                color: isWorth ? AppColors.success : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Grading Alpha',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isWorth ? AppColors.success : AppColors.textSecondary,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isWorth
                      ? AppColors.success.withOpacity(0.15)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isWorth ? 'Worth Grading' : 'Marginal',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color:
                        isWorth ? AppColors.success : AppColors.textDisabled,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _AlphaStat('Raw', '\$${rawPrice.toStringAsFixed(2)}'),
              const _Arrow(),
              _AlphaStat('PSA 10', '\$${psa10.toStringAsFixed(2)}',
                  accent: true),
              const SizedBox(width: 16),
              _AlphaStat(
                'Upside',
                '$alphaSign\$${alpha.toStringAsFixed(2)}',
                sub: '${alphaSign}${roiPct.toStringAsFixed(0)}% ROI',
                accent: isWorth,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}

class _AlphaStat extends StatelessWidget {
  const _AlphaStat(this.label, this.value,
      {this.sub, this.accent = false});
  final String  label;
  final String  value;
  final String? sub;
  final bool    accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: accent ? AppColors.success : AppColors.textPrimary,
          ),
        ),
        if (sub != null)
          Text(sub!,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textDisabled)),
      ],
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Icon(Icons.arrow_forward_rounded,
          size: 14, color: AppColors.textDisabled),
    );
  }
}

// ---------------------------------------------------------------------------
// Regional pricing grid
// ---------------------------------------------------------------------------

class _PricingGrid extends StatelessWidget {
  const _PricingGrid({required this.pricing});
  final CardPricing pricing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (pricing.tcgplayerUs != null) ...[
          _PricingSource(
            source: 'TCGplayer US',
            flag: '🇺🇸',
            rows: [
              if (pricing.tcgplayerUs!.marketNm != null)
                _PriceRow('NM', pricing.tcgplayerUs!.marketNm!),
              if (pricing.tcgplayerUs!.marketLp != null)
                _PriceRow('LP', pricing.tcgplayerUs!.marketLp!),
              if (pricing.tcgplayerUs!.marketMp != null)
                _PriceRow('MP', pricing.tcgplayerUs!.marketMp!),
            ],
            currency: 'USD',
          ),
          const SizedBox(height: 8),
        ],
        if (pricing.cardmarketEu != null) ...[
          _PricingSource(
            source: 'Cardmarket EU',
            flag: '🇪🇺',
            rows: [
              if (pricing.cardmarketEu!.trendPrice != null)
                _PriceRow('Trend', pricing.cardmarketEu!.trendPrice!),
              if (pricing.cardmarketEu!.avgSell1d != null)
                _PriceRow('Avg 1d', pricing.cardmarketEu!.avgSell1d!),
            ],
            currency: 'EUR',
          ),
          const SizedBox(height: 8),
        ],
        if (pricing.yuyuteiJp != null && pricing.yuyuteiJp!.buyPrice != null)
          _PricingSource(
            source: 'Yuyutei JP',
            flag: '🇯🇵',
            rows: [_PriceRow('Buy', pricing.yuyuteiJp!.buyPrice!)],
            currency: 'JPY',
          ),
      ],
    );
  }
}

class _PriceRow {
  const _PriceRow(this.label, this.price);
  final String label;
  final double price;
}

class _PricingSource extends StatelessWidget {
  const _PricingSource({
    required this.source,
    required this.flag,
    required this.rows,
    required this.currency,
  });
  final String source;
  final String flag;
  final List<_PriceRow> rows;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(source,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const Spacer(),
              Text(currency,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textDisabled)),
            ],
          ),
          const SizedBox(height: 10),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.label,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                    Text(
                      currency == 'JPY'
                          ? '¥${r.price.toStringAsFixed(0)}'
                          : currency == 'EUR'
                              ? '€${r.price.toStringAsFixed(2)}'
                              : '\$${r.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slab details
// ---------------------------------------------------------------------------

class _SlabDetails extends StatelessWidget {
  const _SlabDetails({required this.slab});
  final SlabCondition slab;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _DetailRow('Grader', slab.grader.name.toUpperCase()),
          _DetailRow('Cert #', slab.certNumber),
          _DetailRow('Grade', slab.grade.toString()),
          if (slab.labelColor != null)
            _DetailRow('Label Color', slab.labelColor!),
          if (slab.subgrades != null) ...[
            const Divider(color: AppColors.border, height: 24),
            const Text('Subgrades',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textDisabled,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)),
            const SizedBox(height: 8),
            _SubgradesRow(slab.subgrades!),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _SubgradesRow extends StatelessWidget {
  const _SubgradesRow(this.subgrades);
  final subgrades;

  @override
  Widget build(BuildContext context) {
    final values = [
      ('Centering', subgrades.centering),
      ('Corners', subgrades.corners),
      ('Edges', subgrades.edges),
      ('Surface', subgrades.surface),
    ];
    return Row(
      children: values
          .map((v) => Expanded(
                child: Column(
                  children: [
                    Text(v.$1,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textDisabled)),
                    const SizedBox(height: 4),
                    Text(v.$2.toString(),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// PSA population
// ---------------------------------------------------------------------------

class _PopReport extends StatelessWidget {
  const _PopReport({required this.pop});
  final PsaPop pop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _PopStat('Total', '${pop.totalPop ?? '—'}'),
          _VertDivider(),
          _PopStat('PSA 10', '${pop.pop10 ?? '—'}'),
          _VertDivider(),
          _PopStat('PSA 9', '${pop.pop9 ?? '—'}'),
        ],
      ),
    );
  }
}

class _PopStat extends StatelessWidget {
  const _PopStat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Location
// ---------------------------------------------------------------------------

class _LocationChip extends StatelessWidget {
  const _LocationChip({required this.location});
  final ItemLocation location;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded,
              size: 16, color: AppColors.accentSoft),
          const SizedBox(width: 8),
          Text(
            location.locationTag,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.textDisabled,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Live Price Check button
// ---------------------------------------------------------------------------

class _LivePriceCheckButton extends StatelessWidget {
  const _LivePriceCheckButton({required this.card});
  final CardDocument card;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final launched = await PriceLinkUtility.checkCard(card);
        if (!launched && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open browser'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent.withOpacity(0.4)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.open_in_browser_rounded,
                size: 16, color: AppColors.accent),
            SizedBox(width: 8),
            Text(
              'Live Price Check  ·  PriceCharting.com',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Floating action bar (Edit / Delete / For Sale toggle)
// ---------------------------------------------------------------------------

class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.item});
  final CollectionItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              item.flags.forSale
                  ? Icons.sell_rounded
                  : Icons.sell_outlined,
              color: item.flags.forSale
                  ? AppColors.accent
                  : AppColors.textSecondary,
            ),
            tooltip: item.flags.forSale ? 'Listed for sale' : 'Mark for sale',
            onPressed: () async {
              await ref
                  .read(collectionMutationsProvider.notifier)
                  .updateItem(item.copyWith(
                    flags: item.flags.copyWith(forSale: !item.flags.forSale),
                  ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.textSecondary),
            tooltip: 'Remove from collection',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: const Text('Remove Card?',
                      style: TextStyle(color: AppColors.textPrimary)),
                  content: const Text(
                    'This will permanently remove the card from your collection.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Remove',
                          style: TextStyle(color: AppColors.danger)),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await ref
                    .read(collectionMutationsProvider.notifier)
                    .deleteItem(item.id);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
