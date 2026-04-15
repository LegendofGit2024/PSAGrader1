import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/collection_item.dart';
import '../../../providers/collection_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

/// Wraps any card tile with swipe-to-action gestures.
///
///  Swipe LEFT  → "List for Sale"   (sets flags.forSale = true)
///  Swipe RIGHT → "Submission Pool" (sets flags.submissionPending = true,
///                                   navigates to Submission Estimator)
class SwipeableCardTile extends ConsumerWidget {
  const SwipeableCardTile({
    super.key,
    required this.item,
    required this.child,
  });

  final CollectionItem item;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onLongPress: () => _showDeleteSheet(context, ref),
      child: Dismissible(
        key: ValueKey('swipe_${item.id}'),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            await _listForSale(context, ref);
          } else {
            await _sendToSubmission(context, ref);
          }
          return false;
        },
        background: _SwipeBackground(
          alignment: Alignment.centerLeft,
          color: AppColors.accentSoft.withOpacity(0.15),
          icon: Icons.calculate_rounded,
          label: 'Submit',
          iconColor: AppColors.accentSoft,
        ),
        secondaryBackground: _SwipeBackground(
          alignment: Alignment.centerRight,
          color: AppColors.success.withOpacity(0.15),
          icon: Icons.sell_rounded,
          label: 'List',
          iconColor: AppColors.success,
        ),
        child: child,
      ),
    );
  }

  Future<void> _showDeleteSheet(BuildContext context, WidgetRef ref) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // drag handle
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.danger),
                title: const Text('Remove from Vault',
                    style: TextStyle(
                        color: AppColors.danger, fontWeight: FontWeight.w600)),
                subtitle: const Text('This cannot be undone.',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                onTap: () => Navigator.of(context).pop(true),
              ),
              ListTile(
                leading: const Icon(Icons.close_rounded,
                    color: AppColors.textSecondary),
                title: const Text('Cancel',
                    style: TextStyle(color: AppColors.textPrimary)),
                onTap: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final fs = ref.read(firestoreServiceProvider);
    final uid = ref.read(currentUidProvider);
    try {
      await fs.deleteItem(uid, item.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from Vault'),
            backgroundColor: AppColors.danger,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
              backgroundColor: AppColors.danger),
        );
      }
    }
  }

  Future<void> _listForSale(BuildContext context, WidgetRef ref) async {
    if (item.flags.forSale) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Already listed for sale'),
          backgroundColor: AppColors.surfaceVariant,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    await ref.read(collectionMutationsProvider.notifier).updateItem(
          item.copyWith(flags: item.flags.copyWith(forSale: true)),
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Listed for sale'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () => ref
                .read(collectionMutationsProvider.notifier)
                .updateItem(item.copyWith(
                    flags: item.flags.copyWith(forSale: false))),
          ),
        ),
      );
    }
  }

  Future<void> _sendToSubmission(BuildContext context, WidgetRef ref) async {
    await ref.read(collectionMutationsProvider.notifier).updateItem(
          item.copyWith(
              flags: item.flags.copyWith(submissionPending: true)),
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to Submission Pool'),
          backgroundColor: AppColors.accentSoft,
          duration: Duration(seconds: 2),
        ),
      );
      // Navigate to estimator with card pre-filled
      context.push(
          '/submission?cardId=${item.cardRef.id}&costBasis=${item.acquisition.costBasis}');
    }
  }
}

// ---------------------------------------------------------------------------
// Swipe background — shown behind the tile during drag
// ---------------------------------------------------------------------------

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Condition dot — replaces "NM" / "LP" text in inventory list mode
// ---------------------------------------------------------------------------

class ConditionDot extends StatelessWidget {
  const ConditionDot({super.key, required this.item});
  final CollectionItem item;

  Color get _color {
    if (item.condition.type == ConditionType.slab) {
      final grade = item.condition.slab?.grade ?? 0;
      if (grade >= 10) return const Color(0xFFFFD700);    // Gold  — PSA 10
      if (grade >= 9.5) return const Color(0xFFC0C0C0);  // Silver — PSA 9.5
      if (grade >= 9)   return const Color(0xFFCD7F32);  // Bronze — PSA 9
      if (grade >= 8)   return AppColors.accentSoft;
      return AppColors.textDisabled;
    }
    return switch (item.condition.rawCondition) {
      RawCondition.nm  => AppColors.success,
      RawCondition.lp  => const Color(0xFF84CC16),
      RawCondition.mp  => AppColors.warning,
      RawCondition.hp  => AppColors.danger,
      RawCondition.dmg => AppColors.textDisabled,
      null             => AppColors.textDisabled,
    };
  }

  String get _tooltip {
    if (item.condition.type == ConditionType.slab && item.condition.slab != null) {
      return '${item.condition.slab!.grader.name.toUpperCase()} ${item.condition.slab!.grade}';
    }
    return item.condition.rawCondition?.name.toUpperCase() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _tooltip,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: _color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: _color.withOpacity(0.5), blurRadius: 4),
          ],
        ),
      ),
    );
  }
}
