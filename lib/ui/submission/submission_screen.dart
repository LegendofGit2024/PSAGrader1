import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/submission_provider.dart';
import '../../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'widgets/fee_breakdown_sheet.dart';
import 'widgets/gem_rate_widget.dart';
import 'widgets/grade_roi_chart.dart';
import 'widgets/grade_selector_row.dart';
import 'widgets/profit_matrix_table.dart';
import 'widgets/verdict_badge.dart';

/// Submission Estimator V2 — full layout:
///
///  1. AppBar
///  2. Two-track card selector (Scan / Search)
///  3. Grade selector (8 / 9 / 10) + Calculate-for-9
///  4. Cost basis input
///  5. Gem Rate widget  (when card loaded)
///  6. Fee Breakdown (expandable)
///  7. RESULT: Verdict + Matrix Table + Grade ROI Chart + Save button
class SubmissionScreen extends ConsumerWidget {
  const SubmissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pre-fill from deep-link query params: /submission?cardId=X&costBasis=Y
    final state = GoRouterState.of(context);
    final preCardId = state.uri.queryParameters['cardId'];
    final preCostBasis =
        double.tryParse(state.uri.queryParameters['costBasis'] ?? '');

    if (preCardId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notifier =
            ref.read(estimatorInputProvider.notifier);
        notifier.setCard(preCardId);
        if (preCostBasis != null) notifier.setCostBasis(preCostBasis);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          const _AppBar(),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(child: _CardSelector()),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(child: _InputSection()),
          ),
          const _ResultSection(),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// App bar
// ---------------------------------------------------------------------------

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      title: const Text(
        'Submission Estimator',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card selector — scan QR / search by name
// ---------------------------------------------------------------------------

class _CardSelector extends ConsumerStatefulWidget {
  const _CardSelector();

  @override
  ConsumerState<_CardSelector> createState() => _CardSelectorState();
}

class _CardSelectorState extends ConsumerState<_CardSelector>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final input = ref.watch(estimatorInputProvider);
    final cardAsync = ref.watch(estimatorCardProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        _SectionLabel(icon: Icons.style_rounded, label: 'Card'),
        const SizedBox(height: 10),

        // Mode tabs
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tab,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            labelStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500),
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Search'),
              Tab(text: 'Scan QR'),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Tab views
        SizedBox(
          height: 52,
          child: TabBarView(
            controller: _tab,
            children: [
              // Search
              _SearchField(
                ctrl: _searchCtrl,
                onCardSelected: (cardId) {
                  ref
                      .read(estimatorInputProvider.notifier)
                      .setCard(cardId);
                  _searchCtrl.clear();
                },
              ),
              // Scan placeholder
              _ScanPlaceholder(
                onScanned: (cardId) => ref
                    .read(estimatorInputProvider.notifier)
                    .setCard(cardId),
              ),
            ],
          ),
        ),

        // Selected card preview
        if (input.cardId != null) ...[
          const SizedBox(height: 12),
          cardAsync.when(
            loading: () => const _CardPreviewShimmer(),
            error: (_, __) => const SizedBox.shrink(),
            data: (card) => card == null
                ? const SizedBox.shrink()
                : _SelectedCardPreview(
                    card: card,
                    onClear: () => ref
                        .read(estimatorInputProvider.notifier)
                        .setCard(''),
                  ),
          ),
        ],
      ],
    );
  }
}

class _SearchField extends ConsumerStatefulWidget {
  const _SearchField({required this.ctrl, required this.onCardSelected});
  final TextEditingController ctrl;
  final ValueChanged<String> onCardSelected;

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  List<dynamic> _results = [];

  Future<void> _search(String query) async {
    if (query.length < 2) {
      setState(() => _results = []);
      return;
    }
    final fs = ref.read(firestoreServiceProvider);
    final cards = await fs.searchCards(nameQuery: query);
    if (mounted) setState(() => _results = cards);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        TextField(
          controller: widget.ctrl,
          onChanged: _search,
          style: const TextStyle(
              fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search card name or set…',
            hintStyle: const TextStyle(
                fontSize: 13, color: AppColors.textDisabled),
            prefixIcon: const Icon(Icons.search_rounded,
                size: 18, color: AppColors.textDisabled),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
          ),
        ),
        if (_results.isNotEmpty)
          Positioned(
            top: 52,
            left: 0,
            right: 0,
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              elevation: 8,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: _results.length,
                  itemBuilder: (_, i) {
                    final c = _results[i];
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 0),
                      title: Text(
                        c.meta.name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        '${c.meta.setId}  ·  ${c.meta.setNumber}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary),
                      ),
                      onTap: () {
                        widget.onCardSelected(c.id);
                        setState(() => _results = []);
                        widget.ctrl.clear();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ScanPlaceholder extends StatelessWidget {
  const _ScanPlaceholder({required this.onScanned});
  final ValueChanged<String> onScanned;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.accent.withOpacity(0.3),
            style: BorderStyle.solid),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner_rounded,
              size: 18, color: AppColors.accent),
          SizedBox(width: 8),
          Text(
            'Tap to scan PSA cert / card barcode',
            style: TextStyle(fontSize: 13, color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

class _SelectedCardPreview extends StatelessWidget {
  const _SelectedCardPreview({required this.card, required this.onClear});
  final dynamic card;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: card.meta.imageUrl,
              width: 44,
              height: 62,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.meta.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${card.meta.setId}  ·  ${card.meta.setNumber}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
                if (card.pricing.ebayUs?.lastSoldNm != null)
                  Text(
                    'eBay NM: \$${card.pricing.ebayUs!.lastSoldNm!.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.accent),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded,
                size: 16, color: AppColors.textDisabled),
            onPressed: onClear,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }
}

class _CardPreviewShimmer extends StatelessWidget {
  const _CardPreviewShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Input section — grade selector + cost basis
// ---------------------------------------------------------------------------

class _InputSection extends ConsumerWidget {
  const _InputSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final input = ref.watch(estimatorInputProvider);
    final notifier = ref.read(estimatorInputProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grade target
        _SectionLabel(icon: Icons.grade_rounded, label: 'Target Grade'),
        const SizedBox(height: 10),
        const GradeSelectorRow(),
        const SizedBox(height: 20),

        // Cost basis
        _SectionLabel(
            icon: Icons.attach_money_rounded, label: 'Cost Basis (USD)'),
        const SizedBox(height: 10),
        _CostBasisField(
          initialValue: input.costBasis,
          onChanged: notifier.setCostBasis,
        ),
        const SizedBox(height: 16),

        // Fee breakdown
        const FeeBreakdownSheet(),
      ],
    );
  }
}

class _CostBasisField extends StatefulWidget {
  const _CostBasisField({
    required this.initialValue,
    required this.onChanged,
  });
  final double initialValue;
  final ValueChanged<double> onChanged;

  @override
  State<_CostBasisField> createState() => _CostBasisFieldState();
}

class _CostBasisFieldState extends State<_CostBasisField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.initialValue > 0
          ? widget.initialValue.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      onChanged: (v) => widget.onChanged(double.tryParse(v) ?? 0),
      style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: '0.00',
        hintStyle: const TextStyle(
            fontSize: 15, color: AppColors.textDisabled),
        prefixText: '\$  ',
        prefixStyle: const TextStyle(
            fontSize: 15, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Result section — shown when matrix is ready
// ---------------------------------------------------------------------------

class _ResultSection extends ConsumerWidget {
  const _ResultSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matrixAsync = ref.watch(submissionMatrixProvider);
    final input = ref.watch(estimatorInputProvider);

    return matrixAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, __) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Error: $e',
              style: const TextStyle(color: AppColors.danger)),
        ),
      ),
      data: (matrix) {
        if (matrix == null || input.cardId == null) {
          return const SliverToBoxAdapter(
            child: _EmptyResultPlaceholder(),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Divider
              const _SectionDivider(label: 'RESULT'),
              const SizedBox(height: 16),

              // PSA Pop / Gem Rate
              GemRateWidget(card: matrix.card),
              const SizedBox(height: 14),

              // Verdict badge
              VerdictBadge(matrix: matrix),
              const SizedBox(height: 14),

              // Profit matrix table
              ProfitMatrixTable(
                rows: matrix.rows,
                targetGrade: input.targetGrade,
                calculateForNine: input.calculateForNine,
                bestGrader: matrix.bestGrader?.grader,
              ),
              const SizedBox(height: 14),

              // Grade ROI chart for best grader
              if (matrix.bestGrader != null)
                GradeRoiChart(
                  profitByGrade: matrix.bestGrader!.profitByGrade,
                  projectedGrade: input.targetGrade,
                ),
              const SizedBox(height: 20),

              // Save button
              _SaveButton(matrix: matrix),
            ]),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyResultPlaceholder extends StatelessWidget {
  const _EmptyResultPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
      child: Column(
        children: [
          const Icon(Icons.calculate_rounded,
              size: 48, color: AppColors.border),
          const SizedBox(height: 12),
          const Text(
            'Search a card to see ROI estimates\nacross all graders',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: AppColors.textDisabled, height: 1.5),
          ),
        ],
      ).animate().fadeIn(delay: 200.ms),
    );
  }
}

// ---------------------------------------------------------------------------
// Save button
// ---------------------------------------------------------------------------

class _SaveButton extends ConsumerWidget {
  const _SaveButton({required this.matrix});
  final MatrixResult matrix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saveAsync = ref.watch(saveEstimateProvider);

    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: saveAsync.isLoading
            ? null
            : () => ref
                .read(saveEstimateProvider.notifier)
                .save(matrix),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.background,
          disabledBackgroundColor: AppColors.surfaceVariant,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        icon: saveAsync.isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.background),
              )
            : const Icon(Icons.save_rounded, size: 18),
        label: Text(
          saveAsync.isLoading ? 'Saving…' : 'Save Estimate',
          style: const TextStyle(
              fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
    ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0);
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.accent),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textDisabled,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.border)),
      ],
    );
  }
}
