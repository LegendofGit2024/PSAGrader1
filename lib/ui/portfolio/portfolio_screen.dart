import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/binder.dart';
import '../../models/card.dart';
import '../../models/collection_item.dart';
import '../../providers/collection_provider.dart';
import '../../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'darkroom_overlay.dart';
import 'fund_manager_sheet.dart';
import 'widgets/net_worth_pulse.dart';
import 'widgets/portfolio_bento_grid.dart';
import 'widgets/slab_card_tile.dart';
import 'widgets/swipeable_card_tile.dart';

// ---------------------------------------------------------------------------
// View mode + filter state
// ---------------------------------------------------------------------------

enum _ViewMode { all, byBinder }

// ---------------------------------------------------------------------------
// Notifier-based local state (Riverpod 3.x — StateProvider removed)
// ---------------------------------------------------------------------------

final _viewModeProvider =
    NotifierProvider<_ViewModeNotifier, _ViewMode>(_ViewModeNotifier.new);

class _ViewModeNotifier extends Notifier<_ViewMode> {
  @override
  _ViewMode build() => _ViewMode.all;
  void set(_ViewMode mode) => state = mode;
}

final _selectedBinderProvider =
    NotifierProvider<_SelectedBinderNotifier, String?>(_SelectedBinderNotifier.new);

class _SelectedBinderNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? id) => state = id;
}

final _filterTypeProvider =
    NotifierProvider<_FilterTypeNotifier, ConditionType?>(_FilterTypeNotifier.new);

class _FilterTypeNotifier extends Notifier<ConditionType?> {
  @override
  ConditionType? build() => null;
  void set(ConditionType? type) => state = type;
}

// ---------------------------------------------------------------------------
// Portfolio Screen
// ---------------------------------------------------------------------------

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(_viewModeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _PortfolioAppBar(viewMode: viewMode),

          // ── Net Worth Pulse ──────────────────────────────────────────────
          const SliverToBoxAdapter(child: NetWorthPulse()),

          // ── Bento Grid ───────────────────────────────────────────────────
          const SliverToBoxAdapter(child: PortfolioBentoGrid()),

          // ── Deep Dive + Showcase buttons ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.analytics_rounded,
                      label: 'Deep Dive',
                      color: AppColors.accent,
                      onTap: () => FundManagerSheet.show(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Generate Showcase',
                      color: AppColors.accentSoft,
                      onTap: () => context.push('/portfolio/showcase'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Section divider ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  const Text(
                    'VAULT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDisabled,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                      child: Divider(color: AppColors.border, height: 1)),
                ],
              ),
            ),
          ),

          // ── Filter chips ──────────────────────────────────────────────────
          _FilterChips(),

          // ── Stats bar ─────────────────────────────────────────────────────
          _StatsBar(),

          // ── Grid / Binder view ────────────────────────────────────────────
          if (viewMode == _ViewMode.all)
            _AllCardsGrid()
          else ...[
            _BinderSelector(),
            _BinderCardsGrid(),
          ],

          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/portfolio/add'),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Card',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action buttons row
// ---------------------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// App bar
// ---------------------------------------------------------------------------

class _PortfolioAppBar extends ConsumerWidget {
  const _PortfolioAppBar({required this.viewMode});
  final _ViewMode viewMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      title: const Text('The Vault'),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _ModeTab(
                label: 'All',
                active: viewMode == _ViewMode.all,
                onTap: () => ref.read(_viewModeProvider.notifier).set(_ViewMode.all),
              ),
              _ModeTab(
                label: 'Binders',
                active: viewMode == _ViewMode.byBinder,
                onTap: () => ref.read(_viewModeProvider.notifier).set(_ViewMode.byBinder),
              ),
            ],
          ),
        ),
        IconButton(
          icon:
              const Icon(Icons.search_rounded, color: AppColors.textSecondary),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab(
      {required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.background : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats bar
// ---------------------------------------------------------------------------

class _StatsBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(portfolioStatsProvider);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: stats.when(
          loading: () => const SizedBox(height: 28),
          error: (_, __) => const SizedBox.shrink(),
          data: (s) => Row(
            children: [
              _StatChip(label: 'Total', value: '${s.totalItems}'),
              const SizedBox(width: 8),
              _StatChip(label: 'Slabs', value: '${s.slabCount}'),
              const SizedBox(width: 8),
              _StatChip(label: 'Raw', value: '${s.rawCount}'),
              const Spacer(),
              _StatChip(
                label: 'Cost',
                value: '\$${s.totalCostBasis.toStringAsFixed(0)}',
                highlight: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.label, required this.value, this.highlight = false});
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.accent.withOpacity(0.12)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlight
              ? AppColors.accent.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
              text: '$label ',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          TextSpan(
              text: value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: highlight ? AppColors.accent : AppColors.textPrimary)),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chips
// ---------------------------------------------------------------------------

class _FilterChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(_filterTypeProvider);
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 36,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          children: [
            _Chip(
                label: 'All',
                active: current == null,
                onTap: () =>
                    ref.read(_filterTypeProvider.notifier).set(null)),
            _Chip(
                label: 'Slabs',
                active: current == ConditionType.slab,
                onTap: () => ref.read(_filterTypeProvider.notifier).set(ConditionType.slab)),
            _Chip(
                label: 'Raw',
                active: current == ConditionType.raw,
                onTap: () => ref.read(_filterTypeProvider.notifier).set(ConditionType.raw)),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(
      {required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? AppColors.accent : AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color:
                  active ? AppColors.background : AppColors.textSecondary,
            )),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// All-cards grid — with swipe actions + darkroom tap + condition dots
// ---------------------------------------------------------------------------

class _AllCardsGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(collectionProvider);
    final typeFilter = ref.watch(_filterTypeProvider);

    return async.when(
      loading: () => SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
              (_, __) => _CardSkeleton(),
              childCount: 6),
          gridDelegate: _gridDelegate,
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Center(
            child: Text('Error: $e',
                style: const TextStyle(color: AppColors.danger))),
      ),
      data: (items) {
        final filtered = typeFilter == null
            ? items
            : items.where((i) => i.condition.type == typeFilter).toList();
        if (filtered.isEmpty) {
          return const SliverToBoxAdapter(child: _EmptyState());
        }
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _CollectionItemTile(item: filtered[i]),
              childCount: filtered.length,
            ),
            gridDelegate: _gridDelegate,
          ),
        );
      },
    );
  }

  // MaxCrossAxisExtent auto-scales columns: ~2 on phone, ~4 on tablet, ~6 on laptop.
  static const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 195,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 0.62,
  );
}

// ---------------------------------------------------------------------------
// Single tile — resolves card, wraps in swipe + darkroom
// ---------------------------------------------------------------------------

class _CollectionItemTile extends ConsumerWidget {
  const _CollectionItemTile({required this.item});
  final CollectionItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardAsync = ref.watch(resolvedCardProvider(item.cardRef.id));

    return cardAsync.when(
      loading: () => _CardSkeleton(),
      error: (_, __) => _CardSkeleton(),
      data: (card) {
        if (card == null) return _CardSkeleton();

        final marketValue = itemMarketValue(item, card);
        final isSlab = item.condition.type == ConditionType.slab;
        final tile = isSlab && item.condition.slab != null
            ? SlabCardTile(
                imageUrl: card.meta.imageUrl,
                cardName: card.meta.name,
                slab: item.condition.slab!,
                currentValue: marketValue,
                costBasis: item.acquisition.costBasis,
                onTap: () =>
                    DarkroomOverlay.show(context, item: item, card: card),
              )
            : RawCardTile(
                imageUrl: card.meta.imageUrl,
                cardName: card.meta.name,
                condition:
                    item.condition.rawCondition ?? RawCondition.nm,
                currentValue: marketValue,
                costBasis: item.acquisition.costBasis,
                onTap: () =>
                    DarkroomOverlay.show(context, item: item, card: card),
              );

        return SwipeableCardTile(item: item, child: tile);
      },
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceVariant,
      child: Container(
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16))),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
      child: Column(
        children: [
          const Icon(Icons.style_outlined,
              size: 56, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          const Text('Your Vault is empty',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Tap + Add Card to start building your collection.',
              style: TextStyle(
                  fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Binder selector
// ---------------------------------------------------------------------------

class _BinderSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bindersAsync = ref.watch(bindersProvider);
    final selected = ref.watch(_selectedBinderProvider);
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 80,
        child: bindersAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
          data: (binders) => ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: binders.length + 1,
            itemBuilder: (context, i) {
              if (i == binders.length) return _NewBinderChip();
              final b = binders[i];
              return _BinderChip(
                binder: b,
                active: selected == b.id,
                onTap: () => ref
                    .read(_selectedBinderProvider.notifier)
                    .set(selected == b.id ? null : b.id),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BinderChip extends StatelessWidget {
  const _BinderChip(
      {required this.binder, required this.active, required this.onTap});
  final Binder binder;
  final bool active;
  final VoidCallback onTap;

  IconData get _icon => switch (binder.type) {
        BinderType.binder  => Icons.menu_book_rounded,
        BinderType.box     => Icons.inventory_2_rounded,
        BinderType.case_   => Icons.cases_rounded,
        BinderType.display => Icons.view_module_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active
              ? AppColors.accent.withOpacity(0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: active ? AppColors.accent : AppColors.border,
              width: active ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(_icon,
                size: 16,
                color:
                    active ? AppColors.accent : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(binder.name,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? AppColors.accent
                        : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _NewBinderChip extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showNewBinderDialog(context, ref),
      child: Container(
        margin: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.add_rounded, size: 16, color: AppColors.textSecondary),
            SizedBox(width: 6),
            Text('New',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Future<void> _showNewBinderDialog(
      BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    var type = BinderType.binder;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('New Container',
              style: TextStyle(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Name',
                  hintStyle: TextStyle(color: AppColors.textDisabled),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.border)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.accent)),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: BinderType.values
                    .map((t) => ChoiceChip(
                          label: Text(t.name),
                          selected: type == t,
                          onSelected: (_) => setState(() => type = t),
                          selectedColor: AppColors.accent,
                          backgroundColor: AppColors.surfaceVariant,
                          labelStyle: TextStyle(
                              color: type == t
                                  ? AppColors.background
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel',
                    style: TextStyle(color: AppColors.textSecondary))),
            TextButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                await ref.read(binderMutationsProvider.notifier).addBinder(
                    Binder(
                        id: '',
                        ownerUid: '',
                        name: nameCtrl.text.trim(),
                        type: type,
                        createdAt: DateTime.now()));
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Create',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Binder cards grid
// ---------------------------------------------------------------------------

class _BinderCardsGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final binderId = ref.watch(_selectedBinderProvider);
    if (binderId == null) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('Select a binder above',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ),
        ),
      );
    }
    final async = ref.watch(binderItemsProvider(binderId));
    return async.when(
      loading: () => const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator())),
      error: (e, _) => SliverToBoxAdapter(
          child: Text('Error: $e',
              style: const TextStyle(color: AppColors.danger))),
      data: (items) {
        if (items.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                  child: Text('No cards in this binder yet',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14))),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _CollectionItemTile(item: items[i]),
              childCount: items.length,
            ),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 195,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
          ),
        );
      },
    );
  }
}
