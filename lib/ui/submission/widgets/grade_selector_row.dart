import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/submission_provider.dart';
import '../../theme/app_theme.dart';

/// Row of [8] [9] [10] grade target buttons + "Calculate for the 9" toggle.
///
/// Tapping a grade button updates [estimatorInputProvider].targetGrade.
/// The toggle sets [estimatorInputProvider].calculateForNine.
class GradeSelectorRow extends ConsumerWidget {
  const GradeSelectorRow({super.key});

  static const _grades = [8.0, 9.0, 10.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final input = ref.watch(estimatorInputProvider);
    final notifier = ref.read(estimatorInputProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grade buttons
        Row(
          children: [
            for (int i = 0; i < _grades.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _GradeButton(
                  grade: _grades[i],
                  selected: input.targetGrade == _grades[i],
                  onTap: () => notifier.setTargetGrade(_grades[i]),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),

        // Calculate for the 9 toggle
        _ForNineToggle(
          enabled: input.calculateForNine,
          onChanged: (_) => notifier.toggleCalculateForNine(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Grade button
// ---------------------------------------------------------------------------

class _GradeButton extends StatelessWidget {
  const _GradeButton({
    required this.grade,
    required this.selected,
    required this.onTap,
  });
  final double grade;
  final bool selected;
  final VoidCallback onTap;

  Color _gradeColor(double g) {
    if (g == 10) return AppColors.accent;
    if (g == 9) return AppColors.accentSoft;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final color = _gradeColor(grade);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 44,
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.18) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            grade.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: selected ? color : AppColors.textSecondary,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// "Calculate for the 9" toggle
// ---------------------------------------------------------------------------

class _ForNineToggle extends StatelessWidget {
  const _ForNineToggle({required this.enabled, required this.onChanged});
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!enabled),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.accentSoft.withOpacity(0.12)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled
                ? AppColors.accentSoft.withOpacity(0.5)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                enabled
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                key: ValueKey(enabled),
                size: 16,
                color: enabled ? AppColors.accentSoft : AppColors.textDisabled,
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Calculate for the 9',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Text(
              'Show PSA 9 profit alongside target',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
