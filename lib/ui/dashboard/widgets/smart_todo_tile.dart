import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/dashboard_provider.dart';
import '../../theme/app_theme.dart';

/// Full-width bento tile: Smart To-Do — actionable insights computed from
/// the user's collection (grading opportunities, rebalance prompts, etc.).
class SmartTodoTile extends ConsumerWidget {
  const SmartTodoTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(smartTodosProvider);

    return _BentoTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist_rounded,
                  size: 14, color: AppColors.accent),
              const SizedBox(width: 6),
              const Text(
                'SMART TO-DO',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDisabled,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          todosAsync.when(
            loading: () => const _ShimmerBlock(height: 56),
            error: (_, __) => const SizedBox.shrink(),
            data: (todos) {
              if (todos.isEmpty) {
                return const _EmptyTodos();
              }
              return Column(
                children: todos
                    .asMap()
                    .entries
                    .map((e) => _TodoRow(
                          todo: e.value,
                          delay: Duration(milliseconds: (80 * e.key).toInt()),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TodoRow extends StatelessWidget {
  const _TodoRow({required this.todo, required this.delay});
  final SmartTodo todo;
  final Duration delay;

  IconData _icon() => switch (todo.type) {
        SmartTodoType.gradingAlert   => Icons.grade_rounded,
        SmartTodoType.rebalance      => Icons.balance_rounded,
        SmartTodoType.priceSpike     => Icons.trending_up_rounded,
        SmartTodoType.wishlistMatch  => Icons.people_rounded,
      };

  Color _color() => switch (todo.type) {
        SmartTodoType.gradingAlert   => AppColors.accent,
        SmartTodoType.rebalance      => AppColors.warning,
        SmartTodoType.priceSpike     => AppColors.success,
        SmartTodoType.wishlistMatch  => AppColors.accentSoft,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color();

    return GestureDetector(
      onTap: todo.actionRoute != null
          ? () => context.push(todo.actionRoute!)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_icon(), size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    todo.subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (todo.actionRoute != null)
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: AppColors.textDisabled),
          ],
        ),
      ),
    ).animate(delay: delay).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}

class _EmptyTodos extends StatelessWidget {
  const _EmptyTodos();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline_rounded,
            size: 16, color: AppColors.success),
        const SizedBox(width: 8),
        const Text(
          'All clear — no action items right now.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _BentoTile extends StatelessWidget {
  const _BentoTile({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
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
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
