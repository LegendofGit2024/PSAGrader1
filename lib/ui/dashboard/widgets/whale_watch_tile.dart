import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../providers/dashboard_provider.dart';
import '../../theme/app_theme.dart';

// Safe string extraction — works even when a non-nullable Dart field
// holds JS null/undefined at runtime on Flutter web.
String _str(dynamic v, [String fallback = '']) {
  if (v == null) return fallback;
  if (v is String) return v.isEmpty ? fallback : v;
  return '$v';
}

/// Whale Watch bento tile.
/// Card image fills the cell; price + name overlaid at the bottom.
class WhaleWatchTile extends ConsumerStatefulWidget {
  const WhaleWatchTile({super.key});

  @override
  ConsumerState<WhaleWatchTile> createState() => _WhaleWatchTileState();
}

class _WhaleWatchTileState extends ConsumerState<WhaleWatchTile> {
  int _index = 0;
  // Track when the user last manually swiped so auto-cycle waits
  DateTime _lastInteraction = DateTime.now().subtract(const Duration(seconds: 60));

  static const _autoCycleInterval = Duration(seconds: 10);
  static const _pauseAfterInteraction = Duration(seconds: 12);

  @override
  void initState() {
    super.initState();
    _cycle();
  }

  void _cycle() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final elapsed = DateTime.now().difference(_lastInteraction);
      if (elapsed >= _pauseAfterInteraction) {
        final sales = ref.read(whaleSalesProvider).asData?.value ?? [];
        if (sales.isNotEmpty) {
          final timeSinceCycle = DateTime.now().difference(_lastInteraction);
          if (timeSinceCycle >= _autoCycleInterval) {
            setState(() => _index = (_index + 1) % sales.length);
            _lastInteraction = DateTime.now().subtract(_pauseAfterInteraction);
          }
        }
      }
      _cycle();
    });
  }

  void _prev(List<WhaleSale> sales) {
    if (sales.isEmpty) return;
    setState(() => _index = (_index - 1 + sales.length) % sales.length);
    _lastInteraction = DateTime.now();
  }

  void _next(List<WhaleSale> sales) {
    if (sales.isEmpty) return;
    setState(() => _index = (_index + 1) % sales.length);
    _lastInteraction = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(whaleSalesProvider);
    final sales = salesAsync.asData?.value ?? [];

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite ? constraints.maxWidth : 160.0;
        final h = constraints.maxHeight.isFinite ? constraints.maxHeight : 200.0;

        return SizedBox(
          width: w,
          height: h,
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity == null) return;
              if (details.primaryVelocity! < -100) _next(sales);
              if (details.primaryVelocity! > 100)  _prev(sales);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ── Background ──
                  _Background(salesAsync: salesAsync, index: _index),

                  // ── Dark gradient ──
                  const _Gradient(),

                  // ── Tap zones: left half = prev, right half = next ──
                  if (sales.length > 1) ...[
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: w * 0.4,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => _prev(sales),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: w * 0.4,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => _next(sales),
                      ),
                    ),
                  ],

                  // ── Header badge ──
                  const Positioned(
                    top: 12,
                    left: 12,
                    child: _HeaderBadge(),
                  ),

                  // ── Dot indicators ──
                  if (sales.length > 1)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _DotIndicator(
                        count: sales.length,
                        current: _index % sales.length,
                      ),
                    ),

                  // ── Sale info ──
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: salesAsync.maybeWhen(
                      data: (sales) {
                        if (sales.isEmpty) return const SizedBox.shrink();
                        try {
                          final sale = sales[_index % sales.length];
                          return _SaleOverlay(sale: sale);
                        } catch (_) {
                          return const SizedBox.shrink();
                        }
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _Background extends StatelessWidget {
  const _Background({required this.salesAsync, required this.index});
  final AsyncValue<List<WhaleSale>> salesAsync;
  final int index;

  @override
  Widget build(BuildContext context) {
    final url = salesAsync.maybeWhen(
      data: (sales) {
        if (sales.isEmpty) return '';
        try {
          return _str(sales[index % sales.length].imageUrl);
        } catch (_) {
          return '';
        }
      },
      orElse: () => '',
    );

    if (url.isEmpty) {
      return Shimmer.fromColors(
        baseColor: AppColors.surface,
        highlightColor: AppColors.surfaceVariant,
        child: Container(color: AppColors.surface),
      );
    }

    return CachedNetworkImage(
      key: ValueKey(url),
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.surface,
        highlightColor: AppColors.surfaceVariant,
        child: Container(color: AppColors.surface),
      ),
      errorWidget: (_, __, ___) => Container(color: AppColors.surface),
    );
  }
}

class _Gradient extends StatelessWidget {
  const _Gradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.45),
            Colors.black.withOpacity(0.88),
          ],
          stops: const [0.3, 0.62, 1.0],
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'WHALE WATCH',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 4),
          _LiveDot(),
        ],
      ),
    );
  }
}

class _SaleOverlay extends StatelessWidget {
  const _SaleOverlay({required this.sale});
  final WhaleSale sale;

  @override
  Widget build(BuildContext context) {
    // Extract every value through _str / null-safe coercions
    // so no runtime JS null can propagate into a widget.
    final cardName = _str(sale.cardName, '—');
    final grader   = _str(sale.graderLabel, 'PSA');
    final house    = _str(sale.auctionHouse, 'Auction');
    final grade    = _safeDouble(sale.grade, 10).toStringAsFixed(0);
    final price    = _safeDouble(sale.price, 0);
    final soldAt   = sale.soldAt; // DateTime — handled by _timeAgo

    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          fmt.format(price),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.accent,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        )
            .animate(key: ValueKey(cardName))
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.2, end: 0),
        const SizedBox(height: 2),
        Text(
          '$grader $grade · $cardName',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '$house · ${_timeAgo(soldAt)}',
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  double _safeDouble(dynamic v, double fallback) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return fallback;
  }

  String _timeAgo(dynamic dt) {
    if (dt == null) return '';
    if (dt is! DateTime) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ---------------------------------------------------------------------------
// Dot progress indicator
// ---------------------------------------------------------------------------

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(left: 4),
          width: active ? 14 : 5,
          height: 5,
          decoration: BoxDecoration(
            color: active
                ? Colors.white.withOpacity(0.9)
                : Colors.white.withOpacity(0.35),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------

class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.success.withOpacity(0.5 + _ctrl.value * 0.5),
        ),
      ),
    );
  }
}
