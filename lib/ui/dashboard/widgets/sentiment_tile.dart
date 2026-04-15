import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../providers/dashboard_provider.dart';
import '../../theme/app_theme.dart';

String _str(dynamic v, [String fallback = '']) {
  if (v == null) return fallback;
  if (v is String) return v.isEmpty ? fallback : v;
  return '$v';
}

/// 1×1 bento tile: Community Sentiment.
/// Card image fills the tile; text overlaid in a frosted box at the bottom.
class SentimentTile extends ConsumerWidget {
  const SentimentTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentAsync = ref.watch(communitySentimentProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite ? constraints.maxWidth : 160.0;
        final h = constraints.maxHeight.isFinite ? constraints.maxHeight : 160.0;

        return SizedBox(
          width: w,
          height: h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Background card image ──
                sentAsync.maybeWhen(
                  data: (sent) {
                    final url = _str(sent?.imageUrl);
                    if (url.isEmpty) return Container(color: AppColors.surface);
                    return CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: AppColors.surface,
                        highlightColor: AppColors.surfaceVariant,
                        child: Container(color: AppColors.surface),
                      ),
                      errorWidget: (_, __, ___) =>
                          Container(color: AppColors.surface),
                    );
                  },
                  orElse: () => Shimmer.fromColors(
                    baseColor: AppColors.surface,
                    highlightColor: AppColors.surfaceVariant,
                    child: Container(color: AppColors.surface),
                  ),
                ),

                // ── Gradient ──
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.45),
                        Colors.black.withOpacity(0.88),
                      ],
                      stops: const [0.3, 0.6, 1.0],
                    ),
                  ),
                ),

                // ── Text overlay ──
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: sentAsync.maybeWhen(
                    data: (sent) {
                      if (sent == null) return const SizedBox.shrink();
                      try {
                        return _SentimentOverlay(sentiment: sent);
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
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _SentimentOverlay extends StatelessWidget {
  const _SentimentOverlay({required this.sentiment});
  final CommunitySentiment sentiment;

  @override
  Widget build(BuildContext context) {
    final isBullish = sentiment.isBullish;
    final color  = isBullish ? AppColors.success : AppColors.danger;
    final dir    = _str(sentiment.direction, 'Bullish');
    final topic  = _str(sentiment.topic);
    final source = _str(sentiment.source, 'Reddit');
    final pct    = (sentiment.pct as num?)?.toDouble() ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'SENTIMENT',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Colors.white54,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),

        Row(
          children: [
            Text(
              isBullish ? '📈' : '📉',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 6),
            Text(
              dir,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

        const SizedBox(height: 4),

        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.22),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Text(
                '+${pct.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                topic.isNotEmpty ? '$topic · $source' : source,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white.withOpacity(0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
