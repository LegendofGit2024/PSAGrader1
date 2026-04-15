import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

import '../../../models/collection_item.dart';
import '../../../ui/theme/app_theme.dart';

/// 3D-tilt slab card tile.
class SlabCardTile extends StatefulWidget {
  const SlabCardTile({
    super.key,
    required this.imageUrl,
    required this.cardName,
    required this.slab,
    this.currentValue,
    this.costBasis,
    this.onTap,
  });

  final String imageUrl;
  final String cardName;
  final SlabCondition slab;
  final double? currentValue;
  final double? costBasis;
  final VoidCallback? onTap;

  @override
  State<SlabCardTile> createState() => _SlabCardTileState();
}

class _SlabCardTileState extends State<SlabCardTile>
    with SingleTickerProviderStateMixin {
  static const _maxTilt = 0.21;
  static const _perspective = 0.001;

  double _tiltX = 0;
  double _tiltY = 0;
  bool _isHovered = false;

  late AnimationController _snapBack;
  late Animation<double> _snapTiltX;
  late Animation<double> _snapTiltY;

  @override
  void initState() {
    super.initState();
    _snapBack = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _snapBack.dispose();
    super.dispose();
  }

  void _onPointerMove(PointerMoveEvent event, Size size) {
    final dx = event.localPosition.dx;
    final dy = event.localPosition.dy;
    setState(() {
      _tiltY = _maxTilt * ((dx / size.width) * 2 - 1);
      _tiltX = -_maxTilt * ((dy / size.height) * 2 - 1);
    });
  }

  void _onPointerExit() {
    _snapTiltX = Tween<double>(begin: _tiltX, end: 0).animate(
      CurvedAnimation(parent: _snapBack, curve: Curves.easeOutCubic),
    );
    _snapTiltY = Tween<double>(begin: _tiltY, end: 0).animate(
      CurvedAnimation(parent: _snapBack, curve: Curves.easeOutCubic),
    );
    _snapBack
      ..reset()
      ..forward().then((_) {
        if (mounted) setState(() { _tiltX = 0; _tiltY = 0; });
      });
    setState(() => _isHovered = false);
  }

  Color get _graderColor {
    switch (widget.slab.grader) {
      case Grader.psa: return const Color(0xFF2563EB);
      case Grader.bgs: return const Color(0xFF9333EA);
      case Grader.cgc: return const Color(0xFFD97706);
      case Grader.tag: return const Color(0xFF059669);
      case Grader.ace: return _aceColor;
      case Grader.ark: return const Color(0xFFDC2626);
      case Grader.egc: return const Color(0xFF0891B2);
    }
  }

  Color get _aceColor {
    final raw = widget.slab.labelColor;
    if (raw != null) {
      try {
        return Color(int.parse(raw.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }
    return const Color(0xFF334155);
  }

  String get _gradeDisplay {
    final g = widget.slab.grade;
    return g == g.truncateToDouble() ? g.toInt().toString() : g.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => _onPointerExit(),
        child: Listener(
          onPointerMove: (e) {
            final box = context.findRenderObject() as RenderBox?;
            if (box != null) _onPointerMove(e, box.size);
          },
          child: AnimatedBuilder(
            animation: _snapBack,
            builder: (context, child) {
              final tX = _snapBack.isAnimating ? _snapTiltX.value : _tiltX;
              final tY = _snapBack.isAnimating ? _snapTiltY.value : _tiltY;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, _perspective)
                  ..rotateX(tX)
                  ..rotateY(tY),
                child: child,
              );
            },
            child: _CardBody(
              imageUrl: widget.imageUrl,
              cardName: widget.cardName,
              slab: widget.slab,
              graderColor: _graderColor,
              gradeDisplay: _gradeDisplay,
              currentValue: widget.currentValue,
              costBasis: widget.costBasis,
              isHovered: _isHovered,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.06, end: 0);
  }
}

// ---------------------------------------------------------------------------
// Card body
// ---------------------------------------------------------------------------

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.imageUrl,
    required this.cardName,
    required this.slab,
    required this.graderColor,
    required this.gradeDisplay,
    this.currentValue,
    this.costBasis,
    this.isHovered = false,
  });

  final String imageUrl;
  final String cardName;
  final SlabCondition slab;
  final Color graderColor;
  final String gradeDisplay;
  final double? currentValue;
  final double? costBasis;
  final bool isHovered;

  @override
  Widget build(BuildContext context) {
    final pnl = (currentValue != null && costBasis != null)
        ? currentValue! - costBasis!
        : null;
    final isProfitable = pnl != null && pnl >= 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHovered ? graderColor.withOpacity(0.6) : AppColors.border,
          width: isHovered ? 1.5 : 1.0,
        ),
        boxShadow: isHovered
            ? [BoxShadow(color: graderColor.withOpacity(0.25), blurRadius: 20, spreadRadius: 2)]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Card image — BoxFit.contain so the full card is always visible ──
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => Shimmer.fromColors(
                      baseColor: AppColors.surface,
                      highlightColor: AppColors.surfaceVariant,
                      child: Container(color: AppColors.surface),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.surface,
                      child: const Icon(Icons.broken_image_rounded,
                          color: AppColors.textDisabled),
                    ),
                  ),
                  Positioned(
                    top: 8, left: 8,
                    child: _GraderBadge(grader: slab.grader, color: graderColor),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: _GradePill(grade: gradeDisplay, color: graderColor),
                  ),
                ],
              ),
            ),

            // ── Info footer ──
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cardName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (slab.certNumber.isNotEmpty)
                        Text('#${slab.certNumber}',
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textSecondary)),
                      if (pnl != null)
                        Text(
                          '${isProfitable ? '+' : ''}\$${pnl.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isProfitable ? AppColors.success : AppColors.danger,
                          ),
                        ),
                    ],
                  ),
                  if (slab.subgrades != null) ...[
                    const SizedBox(height: 6),
                    _SubgradeBar(subgrades: slab.subgrades!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _GraderBadge extends StatelessWidget {
  const _GraderBadge({required this.grader, required this.color});
  final Grader grader;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        grader.name.toUpperCase(),
        style: const TextStyle(
          fontSize: 9, fontWeight: FontWeight.w800,
          color: Colors.white, letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _GradePill extends StatelessWidget {
  const _GradePill({required this.grade, required this.color});
  final String grade;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(grade,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w800, color: color)),
    );
  }
}

class _SubgradeBar extends StatelessWidget {
  const _SubgradeBar({required this.subgrades});
  final subgrades;

  @override
  Widget build(BuildContext context) {
    final values = [
      ('C', subgrades.centering),
      ('Co', subgrades.corners),
      ('E', subgrades.edges),
      ('S', subgrades.surface),
    ];
    return Row(
      children: values
          .map((v) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Column(
                    children: [
                      Text(v.$1,
                          style: const TextStyle(
                              fontSize: 8, color: AppColors.textDisabled)),
                      Text(v.$2.toString(),
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Raw card tile
// ---------------------------------------------------------------------------

class RawCardTile extends StatelessWidget {
  const RawCardTile({
    super.key,
    required this.imageUrl,
    required this.cardName,
    required this.condition,
    this.currentValue,
    this.costBasis,
    this.onTap,
  });

  final String imageUrl;
  final String cardName;
  final RawCondition condition;
  final double? currentValue;
  final double? costBasis;
  final VoidCallback? onTap;

  Color get _conditionColor {
    switch (condition) {
      case RawCondition.nm:  return AppColors.success;
      case RawCondition.lp:  return const Color(0xFF84CC16);
      case RawCondition.mp:  return AppColors.warning;
      case RawCondition.hp:  return const Color(0xFFEF4444);
      case RawCondition.dmg: return AppColors.textDisabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: AppColors.surface,
                        highlightColor: AppColors.surfaceVariant,
                        child: Container(color: AppColors.surface),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surface,
                        child: const Icon(Icons.broken_image_rounded,
                            color: AppColors.textDisabled),
                      ),
                    ),
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: _conditionColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          condition.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9, fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cardName,
                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (currentValue != null && costBasis != null) ...[
                      const SizedBox(height: 2),
                      Builder(builder: (context) {
                        final pnl = currentValue! - costBasis!;
                        final isUp = pnl >= 0;
                        return Text(
                          '${isUp ? '+' : ''}\$${pnl.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isUp ? AppColors.success : AppColors.danger,
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.06, end: 0);
  }
}
