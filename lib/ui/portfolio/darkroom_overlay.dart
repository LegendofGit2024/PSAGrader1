import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../models/card.dart';
import '../../models/collection_item.dart';
import '../../ui/theme/app_theme.dart';
import 'widgets/swipeable_card_tile.dart';

/// "Darkroom Effect" — tapping a card fades the entire screen to pure black,
/// then illuminates the card with a spotlight so the art colours pop.
///
/// Usage:
///   DarkroomOverlay.show(context, item: item, card: card);
class DarkroomOverlay {
  static void show(
    BuildContext context, {
    required CollectionItem item,
    required CardDocument card,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, animation, __) => _DarkroomPage(
          item: item,
          card: card,
          animation: animation,
        ),
      ),
    );
  }
}

class _DarkroomPage extends StatelessWidget {
  const _DarkroomPage({
    required this.item,
    required this.card,
    required this.animation,
  });

  final CollectionItem item;
  final CardDocument card;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final slab = item.condition.slab;

    return FadeTransition(
      opacity: animation,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Radial spotlight — centred on the card
              Center(
                child: Container(
                  width: 340,
                  height: 480,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.07),
                        Colors.transparent,
                      ],
                      radius: 0.8,
                    ),
                  ),
                ),
              ),

              // Card — centred, with slab acrylic border if graded
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SpotlightCard(item: item, card: card)
                        .animate(delay: 150.ms)
                        .fadeIn(duration: 400.ms)
                        .scale(
                          begin: const Offset(0.88, 0.88),
                          end: const Offset(1, 1),
                          curve: Curves.easeOutCubic,
                        ),

                    const SizedBox(height: 24),

                    // Card info
                    Text(
                      card.meta.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 6),

                    if (slab != null)
                      Text(
                        '${slab.grader.name.toUpperCase()} ${slab.grade}  ·  #${slab.certNumber}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.55),
                        ),
                      ).animate(delay: 380.ms).fadeIn(),

                    const SizedBox(height: 28),

                    // Action row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DarkroomAction(
                          icon: Icons.open_in_full_rounded,
                          label: 'Full Detail',
                          onTap: () {
                            Navigator.of(context).pop();
                            context.push('/portfolio/card/${item.id}');
                          },
                        ),
                        const SizedBox(width: 16),
                        _DarkroomAction(
                          icon: Icons.close_rounded,
                          label: 'Close',
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ).animate(delay: 450.ms).fadeIn(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The spotlit card — acrylic slab shadow if graded
// ---------------------------------------------------------------------------

class _SpotlightCard extends StatelessWidget {
  const _SpotlightCard({required this.item, required this.card});
  final CollectionItem item;
  final CardDocument card;

  bool get _isSlab => item.condition.type == ConditionType.slab;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 336,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_isSlab ? 10 : 14),
        // Acrylic slab shadow — mimics PSA/BGS case edges
        boxShadow: _isSlab
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.06),
                  blurRadius: 0,
                  spreadRadius: 3,
                  offset: const Offset(0, 0),
                ),
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 40,
                  spreadRadius: -4,
                  offset: const Offset(0, 16),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 12),
                ),
              ],
        // Acrylic border for slabs
        border: _isSlab
            ? Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 2.5,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_isSlab ? 8 : 12),
        child: CachedNetworkImage(
          imageUrl: card.meta.imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Darkroom action button
// ---------------------------------------------------------------------------

class _DarkroomAction extends StatelessWidget {
  const _DarkroomAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border:
              Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white70),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
