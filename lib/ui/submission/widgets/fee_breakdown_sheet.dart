import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/collection_item.dart';
import '../../../providers/submission_provider.dart';
import '../../theme/app_theme.dart';

/// Expandable "Hidden Costs" panel that breaks down every line item
/// contributing to the total outlay for a submission.
///
/// Also surfaces grader toggles (PSA Club, TAG Digital, ACE Label Upgrade,
/// CGC Pristine mode) that affect the fee calculation.
class FeeBreakdownSheet extends ConsumerStatefulWidget {
  const FeeBreakdownSheet({super.key});

  @override
  ConsumerState<FeeBreakdownSheet> createState() => _FeeBreakdownSheetState();
}

class _FeeBreakdownSheetState extends ConsumerState<FeeBreakdownSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandCtrl;
  late Animation<double> _expandAnim;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _expandCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _expandAnim =
        CurvedAnimation(parent: _expandCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _expandCtrl.forward() : _expandCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final input = ref.watch(estimatorInputProvider);
    final notifier = ref.read(estimatorInputProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header / toggle
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_rounded,
                      size: 16, color: AppColors.accent),
                  const SizedBox(width: 8),
                  const Text(
                    'Fee Breakdown',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _expanded ? 'Hide' : 'Show',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textDisabled),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 18, color: AppColors.textDisabled),
                  ),
                ],
              ),
            ),
          ),

          // Expandable body
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Column(
              children: [
                const Divider(color: AppColors.border, height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Grader toggles section
                      const _SubHeader('Grader Options'),
                      const SizedBox(height: 8),
                      _GraderToggle(
                        icon: Icons.card_membership_rounded,
                        label: 'PSA Collectors Club',
                        subtitle: 'Reduces PSA fee by \$5/card',
                        value: input.psaClubMember,
                        onChanged: (_) => notifier.togglePsaClub(),
                      ),
                      const SizedBox(height: 8),
                      _GraderToggle(
                        icon: Icons.qr_code_scanner_rounded,
                        label: 'TAG Digital Report',
                        subtitle: 'Adds \$5 to TAG fee for digital cert',
                        value: input.tagDigitalReport,
                        onChanged: (_) => notifier.toggleTagReport(),
                      ),
                      const SizedBox(height: 8),
                      _GraderToggle(
                        icon: Icons.star_rounded,
                        label: 'CGC Pristine Mode',
                        subtitle: 'Uses Pristine 10 market value (+10%)',
                        value: input.cgcPristineMode,
                        onChanged: (_) => notifier.toggleCgcPristine(),
                      ),
                      const SizedBox(height: 14),

                      // ACE Label Upgrade
                      const _SubHeader('ACE Label Upgrade'),
                      const SizedBox(height: 8),
                      _AceLabelSelector(
                        value: input.aceColorMatchLabel,
                        onChanged: (v) => notifier.setAceLabel(v),
                      ),
                      const SizedBox(height: 14),

                      // Currency mode
                      const _SubHeader('Display Currency'),
                      const SizedBox(height: 8),
                      _CurrencyToggle(
                        showUk: input.showUkPrices,
                        onChanged: (_) => notifier.toggleUkPrices(),
                      ),
                      const SizedBox(height: 14),

                      // Fee reference table (read-only)
                      const _SubHeader('Grader Fee Reference'),
                      const SizedBox(height: 8),
                      const _FeeReferenceTable(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-section header
// ---------------------------------------------------------------------------

class _SubHeader extends StatelessWidget {
  const _SubHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: AppColors.textDisabled,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Toggle row
// ---------------------------------------------------------------------------

class _GraderToggle extends StatelessWidget {
  const _GraderToggle({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Icon(icon,
              size: 14,
              color: value ? AppColors.accent : AppColors.textDisabled),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        value ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textDisabled),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ACE Label upgrade selector
// ---------------------------------------------------------------------------

class _AceLabelSelector extends StatelessWidget {
  const _AceLabelSelector({required this.value, required this.onChanged});

  final AceLabelUpgrade value;
  final ValueChanged<AceLabelUpgrade> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = [
      (label: 'None', value: AceLabelUpgrade.none, cost: ''),
      (label: 'Color Match', value: AceLabelUpgrade.colorMatch, cost: '+£1'),
      (label: 'ACE Label', value: AceLabelUpgrade.aceLabel, cost: '+£3'),
    ];

    return Row(
      children: options.map((opt) {
        final selected = value == opt.value;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(opt.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFEC4899).withOpacity(0.15)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFEC4899).withOpacity(0.5)
                      : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    opt.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? const Color(0xFFEC4899)
                          : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (opt.cost.isNotEmpty)
                    Text(
                      opt.cost,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textDisabled,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Currency toggle (USD / GBP)
// ---------------------------------------------------------------------------

class _CurrencyToggle extends StatelessWidget {
  const _CurrencyToggle({required this.showUk, required this.onChanged});
  final bool showUk;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CurrencyChip(
          label: 'USD',
          flag: '\u{1F1FA}\u{1F1F8}',
          selected: !showUk,
          onTap: () => onChanged(false),
        ),
        const SizedBox(width: 8),
        _CurrencyChip(
          label: 'GBP',
          flag: '\u{1F1EC}\u{1F1E7}',
          selected: showUk,
          onTap: () => onChanged(true),
        ),
        const SizedBox(width: 10),
        const Text(
          'Affects ACE pricing row',
          style: TextStyle(fontSize: 10, color: AppColors.textDisabled),
        ),
      ],
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  const _CurrencyChip({
    required this.label,
    required this.flag,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final String flag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withOpacity(0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? AppColors.accent.withOpacity(0.5)
                : AppColors.border,
          ),
        ),
        child: Text(
          '$flag $label',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grader fee reference table (static info)
// ---------------------------------------------------------------------------

class _FeeReferenceTable extends StatelessWidget {
  const _FeeReferenceTable();

  static const _rows = [
    (grader: 'PSA', tiers: 'Value \$20 · Economy \$25 · Regular \$50', ship: '\$30'),
    (grader: 'BGS', tiers: 'Standard \$30 · Express \$75', ship: '\$30'),
    (grader: 'CGC', tiers: 'Standard \$25 · Express \$65', ship: '\$30'),
    (grader: 'TAG', tiers: 'Standard \$20 · Express \$50', ship: '\$15'),
    (grader: 'ACE', tiers: 'Standard £15 · Express £35', ship: '£12'),
    (grader: 'ARK', tiers: 'Standard \$18 · Express \$45', ship: '\$20'),
    (grader: 'EGC', tiers: 'Standard \$15 · Express \$40', ship: '\$15'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: _rows.asMap().entries.map((e) {
          final row = e.value;
          final isLast = e.key == _rows.length - 1;
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    row.grader,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    row.tiers,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary),
                  ),
                ),
                Text(
                  'Ship ${row.ship}',
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textDisabled),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
