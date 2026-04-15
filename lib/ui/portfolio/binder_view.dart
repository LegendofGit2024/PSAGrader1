import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/binder.dart';
import '../../models/collection_item.dart';
import '../../providers/collection_provider.dart';
import '../theme/app_theme.dart';

/// Full-screen "Virtual Binder" — mimics a physical binder page grid.
///
/// Each page holds [_slotsPerPage] cards laid out in a configurable grid.
/// Users can drag cards between slots within the same binder.
class BinderView extends ConsumerStatefulWidget {
  const BinderView({super.key, required this.binderId});
  final String binderId;

  @override
  ConsumerState<BinderView> createState() => _BinderViewState();
}

class _BinderViewState extends ConsumerState<BinderView>
    with SingleTickerProviderStateMixin {
  static const _slotsPerPage = 9; // 3×3 grid per page
  static const _columns = 3;

  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bindersAsync = ref.watch(bindersProvider);
    final itemsAsync = ref.watch(binderItemsProvider(widget.binderId));

    final binder = bindersAsync.asData?.value
        ?.firstWhere((b) => b.id == widget.binderId, orElse: () => _emptyBinder);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(binder?.name ?? 'Binder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.textSecondary),
            onPressed: () {/* edit binder name — inline */},
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: AppColors.danger))),
        data: (items) {
          // Sort by slot_index so the binder layout is deterministic
          final sorted = [...items]
            ..sort((a, b) =>
                (a.location.slotIndex ?? 0)
                    .compareTo(b.location.slotIndex ?? 0));

          final capacity = binder?.capacity ?? _slotsPerPage * 10;
          final pageCount = (capacity / _slotsPerPage).ceil();

          return Column(
            children: [
              // Page indicator
              _PageIndicator(
                currentPage: _currentPage,
                totalPages: pageCount,
              ),
              // Binder pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (p) => setState(() => _currentPage = p),
                  itemCount: pageCount,
                  itemBuilder: (context, pageIndex) {
                    final startSlot = pageIndex * _slotsPerPage;
                    return _BinderPage(
                      pageIndex: pageIndex,
                      startSlot: startSlot,
                      items: sorted,
                      slotsPerPage: _slotsPerPage,
                      columns: _columns,
                      binderId: widget.binderId,
                    );
                  },
                ),
              ),
              _PageNavBar(
                controller: _pageController,
                currentPage: _currentPage,
                totalPages: pageCount,
              ),
            ],
          );
        },
      ),
    );
  }

  static final _emptyBinder = Binder(
    id: '',
    ownerUid: '',
    name: 'Binder',
    type: BinderType.binder,
  );
}

// ---------------------------------------------------------------------------
// Single binder page — 3×3 slot grid
// ---------------------------------------------------------------------------

class _BinderPage extends ConsumerWidget {
  const _BinderPage({
    required this.pageIndex,
    required this.startSlot,
    required this.items,
    required this.slotsPerPage,
    required this.columns,
    required this.binderId,
  });

  final int pageIndex;
  final int startSlot;
  final List<CollectionItem> items;
  final int slotsPerPage;
  final int columns;
  final String binderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Build a slot→item map for O(1) lookup
    final slotMap = {for (final i in items) i.location.slotIndex: i};
    final rows = (slotsPerPage / columns).ceil();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Page label
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Page ${pageIndex + 1}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textDisabled,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            // Slot grid
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.70,
                ),
                itemCount: slotsPerPage,
                itemBuilder: (context, slotOffset) {
                  final slotIndex = startSlot + slotOffset;
                  final item = slotMap[slotIndex];
                  return _BinderSlot(
                    slotIndex: slotIndex,
                    item: item,
                    binderId: binderId,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual slot — filled or empty
// ---------------------------------------------------------------------------

class _BinderSlot extends ConsumerWidget {
  const _BinderSlot({
    required this.slotIndex,
    required this.binderId,
    this.item,
  });

  final int slotIndex;
  final String binderId;
  final CollectionItem? item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (item == null) {
      return _EmptySlot(
        slotIndex: slotIndex,
        onTap: () => context.push('/portfolio/add?binderId=$binderId&slot=$slotIndex'),
      );
    }

    return _FilledSlot(item: item!);
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.slotIndex, this.onTap});
  final int slotIndex;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.add_rounded,
            color: AppColors.textDisabled.withOpacity(0.4),
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _FilledSlot extends ConsumerWidget {
  const _FilledSlot({required this.item});
  final CollectionItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardAsync = ref.watch(resolvedCardProvider(item.cardRef.id));

    return GestureDetector(
      onTap: () => context.push('/portfolio/card/${item.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Card image
              cardAsync.when(
                loading: () => Shimmer.fromColors(
                  baseColor: AppColors.surface,
                  highlightColor: AppColors.surfaceVariant,
                  child: Container(color: AppColors.surface),
                ),
                error: (_, __) => const Icon(Icons.broken_image_rounded,
                    color: AppColors.textDisabled),
                data: (card) => card == null
                    ? const Icon(Icons.broken_image_rounded,
                        color: AppColors.textDisabled)
                    : CachedNetworkImage(
                        imageUrl: card.meta.imageUrl,
                        fit: BoxFit.cover,
                      ),
              ),
              // Slab grade overlay
              if (item.condition.type == ConditionType.slab &&
                  item.condition.slab != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: AppColors.background.withOpacity(0.75),
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '${item.condition.slab!.grader.name.toUpperCase()} ${item.condition.slab!.grade}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 250.ms),
    );
  }
}

// ---------------------------------------------------------------------------
// Navigation chrome
// ---------------------------------------------------------------------------

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.currentPage,
    required this.totalPages,
  });
  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalPages.clamp(0, 10), (i) {
          final active = i == currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active ? AppColors.accent : AppColors.border,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}

class _PageNavBar extends StatelessWidget {
  const _PageNavBar({
    required this.controller,
    required this.currentPage,
    required this.totalPages,
  });
  final PageController controller;
  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: currentPage > 0
                ? () => controller.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut)
                : null,
            icon: const Icon(Icons.chevron_left_rounded),
            label: const Text('Prev'),
            style: TextButton.styleFrom(
              foregroundColor: currentPage > 0
                  ? AppColors.textPrimary
                  : AppColors.textDisabled,
            ),
          ),
          Text(
            '${currentPage + 1} / $totalPages',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextButton.icon(
            onPressed: currentPage < totalPages - 1
                ? () => controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut)
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
            label: const Text('Next'),
            style: TextButton.styleFrom(
              foregroundColor: currentPage < totalPages - 1
                  ? AppColors.textPrimary
                  : AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}
