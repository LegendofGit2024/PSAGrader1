import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/card.dart';
import '../../models/collection_item.dart';
import '../../providers/collection_provider.dart';
import '../../services/firestore_service.dart';
import '../theme/app_theme.dart';

/// "Generate Showcase" — animates the user's top-5 cards in a luxury reveal
/// and provides a share sheet to post to TikTok/Instagram.
///
/// Note: Full 15-second video export requires a native render pipeline
/// (e.g. `video_player` + `ffmpeg_kit_flutter`) — scaffolded here as a
/// live animated Flutter view that can be screen-recorded, with a share
/// button that invokes the OS share sheet.
class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotateCtrl;
  late AnimationController _smokeCtrl;
  late AnimationController _revealCtrl;

  List<({CollectionItem item, CardDocument card})> _top5 = [];
  bool _loading = true;
  int _spotlightIndex = 0;

  @override
  void initState() {
    super.initState();

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _smokeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _loadTopCards();
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _smokeCtrl.dispose();
    _revealCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTopCards() async {
    final items = await ref.read(collectionProvider.future);
    final fs = ref.read(firestoreServiceProvider);

    final resolved = <({CollectionItem item, CardDocument card, double value})>[];
    for (final item in items) {
      final card = await fs.getCard(item.cardRef.id);
      if (card == null) continue;
      final value = itemMarketValue(item, card) ?? item.acquisition.costBasis;
      resolved.add((item: item, card: card, value: value));
    }

    resolved.sort((a, b) => b.value.compareTo(a.value));
    final top5 = resolved
        .take(5)
        .map((e) => (item: e.item, card: e.card))
        .toList();

    if (mounted) {
      setState(() {
        _top5 = top5;
        _loading = false;
      });
      _revealCtrl.forward();
      // Cycle spotlight every 3 seconds
      _startSpotlightCycle();
    }
  }

  void _startSpotlightCycle() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _spotlightIndex = (_spotlightIndex + 1) % _top5.length);
      _startSpotlightCycle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white70,
        title: const Text('Showcase',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3)),
        actions: [
          if (!_loading)
            TextButton.icon(
              onPressed: _share,
              icon: const Icon(Icons.share_rounded,
                  color: AppColors.accent, size: 18),
              label: const Text('Share',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              fit: StackFit.expand,
              children: [
                // Animated smoke background
                _SmokeBackground(ctrl: _smokeCtrl),
                // Card fan
                _CardFan(
                  cards: _top5,
                  rotateCtrl: _rotateCtrl,
                  spotlightIndex: _spotlightIndex,
                  revealCtrl: _revealCtrl,
                ),
                // Total value overlay
                _ValueOverlay(top5: _top5),
                // Bottom CTA
                _BottomCTA(onShare: _share),
              ],
            ),
    );
  }

  Future<void> _share() async {
    final valuation = await ref.read(portfolioValuationProvider.future);
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    await Share.share(
      '🏆 My Pokémon TCG Vault is worth ${fmt.format(valuation.totalMarketValue)}!\n\n'
      'Top cards: ${_top5.take(3).map((e) => e.card.meta.name).join(', ')}\n\n'
      '#PokémonTCG #SlabStack #PokémonCards',
      subject: 'My Slab Stack Vault',
    );
  }
}

// ---------------------------------------------------------------------------
// Smoke background — slow drifting gradient blobs
// ---------------------------------------------------------------------------

class _SmokeBackground extends StatelessWidget {
  const _SmokeBackground({required this.ctrl});
  final AnimationController ctrl;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => CustomPaint(
        painter: _SmokePainter(t: ctrl.value),
      ),
    );
  }
}

class _SmokePainter extends CustomPainter {
  const _SmokePainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final blobs = [
      (
        cx: size.width * 0.3 + math.sin(t * math.pi * 2) * 40,
        cy: size.height * 0.4 + math.cos(t * math.pi) * 30,
        r: 200.0,
        color: AppColors.accent.withOpacity(0.05),
      ),
      (
        cx: size.width * 0.7 + math.cos(t * math.pi * 1.5) * 50,
        cy: size.height * 0.6 + math.sin(t * math.pi * 2) * 40,
        r: 180.0,
        color: AppColors.accentSoft.withOpacity(0.04),
      ),
      (
        cx: size.width * 0.5,
        cy: size.height * 0.5 + math.sin(t * math.pi) * 20,
        r: 240.0,
        color: Colors.white.withOpacity(0.02),
      ),
    ];

    for (final b in blobs) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [b.color, Colors.transparent],
        ).createShader(Rect.fromCircle(
            center: Offset(b.cx, b.cy), radius: b.r));
      canvas.drawCircle(Offset(b.cx, b.cy), b.r, paint);
    }
  }

  @override
  bool shouldRepaint(_SmokePainter old) => old.t != t;
}

// ---------------------------------------------------------------------------
// Card fan — top 5 cards arranged in an arc, spotlight cycles through them
// ---------------------------------------------------------------------------

class _CardFan extends StatelessWidget {
  const _CardFan({
    required this.cards,
    required this.rotateCtrl,
    required this.spotlightIndex,
    required this.revealCtrl,
  });

  final List<({CollectionItem item, CardDocument card})> cards;
  final AnimationController rotateCtrl;
  final int spotlightIndex;
  final AnimationController revealCtrl;

  @override
  Widget build(BuildContext context) {
    final count = cards.length;
    return Center(
      child: SizedBox(
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: List.generate(count, (i) {
            final isSpotlit = i == spotlightIndex;
            // Fan angle: spread ±40° across all cards
            final spread = count > 1 ? 40.0 : 0.0;
            final angle = count > 1
                ? (i / (count - 1) - 0.5) * 2 * spread * (math.pi / 180)
                : 0.0;
            final xOffset = math.sin(angle) * 120.0;
            final yOffset = -math.cos(angle.abs()) * 20.0;

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              left: MediaQuery.of(context).size.width / 2 +
                  xOffset -
                  (isSpotlit ? 75 : 60),
              top: 50 + yOffset - (isSpotlit ? 20 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                width: isSpotlit ? 150 : 120,
                height: isSpotlit ? 210 : 168,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: isSpotlit
                          ? AppColors.accent.withOpacity(0.4)
                          : Colors.black.withOpacity(0.6),
                      blurRadius: isSpotlit ? 30 : 15,
                      spreadRadius: isSpotlit ? 4 : 0,
                    ),
                  ],
                ),
                child: Transform.rotate(
                  angle: angle,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: cards[i].card.meta.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
                  .animate(
                      delay: Duration(milliseconds: 150 * i),
                      controller: revealCtrl)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.3, end: 0),
            );
          }),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Total value overlay
// ---------------------------------------------------------------------------

class _ValueOverlay extends ConsumerWidget {
  const _ValueOverlay({required this.top5});
  final List<({CollectionItem item, CardDocument card})> top5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valAsync = ref.watch(portfolioValuationProvider);
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Positioned(
      bottom: 120,
      left: 0,
      right: 0,
      child: Column(
        children: [
          const Text(
            'MY VAULT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white38,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 6),
          valAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (val) => Text(
              fmt.format(val.totalMarketValue),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -2,
                height: 1,
                shadows: [
                  Shadow(color: AppColors.accent, blurRadius: 20),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom CTA
// ---------------------------------------------------------------------------

class _BottomCTA extends StatelessWidget {
  const _BottomCTA({required this.onShare});
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 40,
      right: 40,
      child: SizedBox(
        height: 52,
        child: ElevatedButton.icon(
          onPressed: onShare,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          icon: const Icon(Icons.share_rounded, size: 18),
          label: const Text(
            'Share to TikTok / Instagram',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
      ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.2, end: 0),
    );
  }
}
