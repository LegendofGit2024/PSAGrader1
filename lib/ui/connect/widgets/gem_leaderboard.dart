import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/auth_service.dart';
import '../../../providers/connect_provider.dart';
import '../../theme/app_theme.dart';

/// "Gem King" — friend gem-accuracy leaderboard + log-a-result button.
class GemLeaderboardTab extends ConsumerWidget {
  const GemLeaderboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderAsync = ref.watch(gemLeaderboardProvider);
    final currentUid = ref.watch(currentUidProvider);

    return leaderAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
      data: (entries) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        children: [
          // Explanation card
          _ExplainerCard(),
          const SizedBox(height: 14),

          // Leaderboard
          if (entries.isEmpty)
            _EmptyLeader()
          else
            ...entries.asMap().entries.map((e) => _LeaderRow(
                  entry: e.value,
                  rank: e.key + 1,
                  isSelf: e.value.uid == currentUid,
                  delay: Duration(milliseconds: (60 * e.key).toInt()),
                )),

          const SizedBox(height: 16),

          // Log a result button
          _LogResultButton(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Explainer card
// ---------------------------------------------------------------------------

class _ExplainerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Text('💎', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gem Accuracy',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Predict a PSA 10 and it comes back a 10? Perfect score. '
                  'Log your returned grades to climb the leaderboard.',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary, height: 1.4),
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
// Leaderboard row
// ---------------------------------------------------------------------------

class _LeaderRow extends StatelessWidget {
  const _LeaderRow({
    required this.entry,
    required this.rank,
    required this.isSelf,
    required this.delay,
  });
  final GemLeaderEntry entry;
  final int rank;
  final bool isSelf;
  final Duration delay;

  Color _rankColor(int r) {
    if (r == 1) return const Color(0xFFFFD700); // gold
    if (r == 2) return const Color(0xFFC0C0C0); // silver
    if (r == 3) return const Color(0xFFCD7F32); // bronze
    return AppColors.textDisabled;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (entry.accuracyPct * 100).toStringAsFixed(1);
    final rankColor = _rankColor(rank);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isSelf
            ? AppColors.accent.withOpacity(0.06)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelf
              ? AppColors.accent.withOpacity(0.25)
              : AppColors.border,
          width: isSelf ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 32,
            child: Text(
              rank <= 3 ? _medalEmoji(rank) : '#$rank',
              style: TextStyle(
                fontSize: rank <= 3 ? 20 : 13,
                fontWeight: FontWeight.w800,
                color: rankColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),

          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.accentSoft.withOpacity(0.15),
            backgroundImage: entry.avatarUrl != null &&
                    entry.avatarUrl!.isNotEmpty
                ? NetworkImage(entry.avatarUrl!)
                : null,
            child: entry.avatarUrl == null || entry.avatarUrl!.isEmpty
                ? Text(
                    entry.displayName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accentSoft,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),

          // Name + prediction count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isSelf ? 'You' : entry.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelf
                            ? AppColors.accent
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (isSelf) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${entry.correct}/${entry.predictions} correct',
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textDisabled),
                ),
              ],
            ),
          ),

          // Accuracy bar + pct
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: rankColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: entry.accuracyPct,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation(rankColor),
                    minHeight: 4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: delay).fadeIn(duration: 300.ms).slideX(begin: -0.02, end: 0);
  }

  String _medalEmoji(int r) {
    if (r == 1) return '🥇';
    if (r == 2) return '🥈';
    return '🥉';
  }
}

// ---------------------------------------------------------------------------
// Log a result button → bottom sheet
// ---------------------------------------------------------------------------

class _LogResultButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () => _showLogSheet(context, ref),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.accent),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.add_rounded, size: 16),
        label: const Text(
          'Log a Returned Grade',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _showLogSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UncontrolledProviderScope(
        container: ProviderScope.containerOf(context),
        child: const _LogGradeSheet(),
      ),
    );
  }
}

class _LogGradeSheet extends ConsumerStatefulWidget {
  const _LogGradeSheet();

  @override
  ConsumerState<_LogGradeSheet> createState() => _LogGradeSheetState();
}

class _LogGradeSheetState extends ConsumerState<_LogGradeSheet> {
  final _nameCtrl = TextEditingController();
  double _predicted = 10;
  double _actual = 10;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(logGemResultProvider).isLoading;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Log Returned Grade',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Card name
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDec('Card Name'),
          ),
          const SizedBox(height: 12),

          // Predicted grade
          _GradeSelector(
            label: 'Predicted Grade',
            value: _predicted,
            onChanged: (v) => setState(() => _predicted = v),
          ),
          const SizedBox(height: 12),

          // Actual grade
          _GradeSelector(
            label: 'Actual Grade (returned)',
            value: _actual,
            onChanged: (v) => setState(() => _actual = v),
          ),
          const SizedBox(height: 20),

          // Submit
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (_nameCtrl.text.trim().isEmpty) return;
                      await ref
                          .read(logGemResultProvider.notifier)
                          .log(
                            cardName: _nameCtrl.text.trim(),
                            predictedGrade: _predicted,
                            actualGrade: _actual,
                          );
                      if (context.mounted) Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.background),
                    )
                  : const Text(
                      'Save Result',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppColors.textDisabled, fontSize: 14),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      );
}

class _GradeSelector extends StatelessWidget {
  const _GradeSelector({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  static const _grades = [8.0, 8.5, 9.0, 9.5, 10.0];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Row(
          children: _grades.map((g) {
            final sel = value == g;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(g),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 6),
                  height: 38,
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.accent.withOpacity(0.15)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel
                          ? AppColors.accent
                          : AppColors.border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      g == g.truncateToDouble()
                          ? g.toInt().toString()
                          : g.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color:
                            sel ? AppColors.accent : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _EmptyLeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'No predictions logged yet.\nTap "Log a Returned Grade" to start.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textDisabled),
        ),
      ),
    );
  }
}
