import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/card.dart';
import '../services/ebay_search_service.dart';

part 'ebay_search_provider.g.dart';

// ---------------------------------------------------------------------------
// Service singleton
// ---------------------------------------------------------------------------

/// Application-wide [EbaySearchService] instance (rate-limiter state lives here).
@riverpod
EbaySearchService ebaySearchService(Ref ref) => EbaySearchService();

// ---------------------------------------------------------------------------
// Search-active stream
// ---------------------------------------------------------------------------

/// Emits `true` while the Cloud Function is running for [cardId], `false`
/// once the request document has been deleted (job done).
///
/// Safe to watch in a build method — will not cause rebuilds when the card has
/// no in-flight search.
@riverpod
Stream<bool> ebaySearchActive(Ref ref, String cardId) {
  final svc = ref.watch(ebaySearchServiceProvider);
  return svc.searchActiveStream(cardId);
}

// ---------------------------------------------------------------------------
// Search trigger notifier
// ---------------------------------------------------------------------------

/// Holds the result of the most-recent search trigger attempt for [cardId].
sealed class EbaySearchState {
  const EbaySearchState();
}

class EbaySearchIdle extends EbaySearchState {
  const EbaySearchIdle();
}

class EbaySearchPending extends EbaySearchState {
  const EbaySearchPending();
}

class EbaySearchSuccess extends EbaySearchState {
  const EbaySearchSuccess();
}

class EbaySearchError extends EbaySearchState {
  const EbaySearchError(this.message);
  final String message;
}

/// Notifier that drives the "Fetch Live Prices" button.
///
/// Call [trigger(card)] to write a search_request.
/// Watch [ebaySearchActiveProvider(cardId)] for the spinner.
@riverpod
class EbaySearchNotifier extends _$EbaySearchNotifier {
  @override
  EbaySearchState build(String cardId) => const EbaySearchIdle();

  Future<void> trigger(CardDocument card) async {
    state = const EbaySearchPending();
    final svc = ref.read(ebaySearchServiceProvider);
    try {
      await svc.triggerSearch(card);
      state = const EbaySearchSuccess();
    } on SearchRateLimitException catch (e) {
      state = EbaySearchError('Slow down! Try again in ${e.secondsUntilReset}s');
    } on SearchUnauthenticatedException {
      state = const EbaySearchError('Sign in to search eBay');
    } catch (e) {
      state = EbaySearchError(e.toString());
    }
  }
}

// ---------------------------------------------------------------------------
// EbaySearchSection — drop-in widget
// ---------------------------------------------------------------------------
//
// Place this inside a card-detail view.  It shows:
//   • "Fetch Live Prices" button when idle / no in-flight request
//   • "Searching eBay Specialists…" spinner while the Cloud Function runs
//   • Rate-limit / error snackbar on failure
//
// Example:
//   EbaySearchSection(card: forecast.card)
// ---------------------------------------------------------------------------

class EbaySearchSection extends ConsumerWidget {
  const EbaySearchSection({super.key, required this.card});
  final CardDocument card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchActive = ref.watch(ebaySearchActiveProvider(card.id));
    final triggerState = ref.watch(ebaySearchProvider(card.id));
    final svc          = ref.watch(ebaySearchServiceProvider);

    // Show error as a snackbar once
    ref.listen<EbaySearchState>(
      ebaySearchProvider(card.id),
      (_, next) {
        if (next is EbaySearchError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.message),
              backgroundColor: const Color(0xFFF77C7C),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
    );

    return searchActive.when(
      loading: () => const _FetchButton(loading: true),
      error:   (_, __) => const SizedBox.shrink(),
      data: (isActive) {
        if (isActive || triggerState is EbaySearchPending) {
          return const _SearchingSpinner();
        }

        return _FetchButton(
          loading:  false,
          disabled: !svc.canSearch,
          remaining: svc.remainingSearches,
          onTap: () => ref
              .read(ebaySearchProvider(card.id).notifier)
              .trigger(card),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _SearchingSpinner extends StatelessWidget {
  const _SearchingSpinner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        border: Border.all(color: const Color(0xFF2A2A38)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF7C6AF7),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Searching eBay Specialists…',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE8E8F0),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Fetching recent sold listings — usually < 15 s',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8888A8),
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

class _FetchButton extends StatelessWidget {
  const _FetchButton({
    required this.loading,
    this.disabled  = false,
    this.remaining = 5,
    this.onTap,
  });

  final bool          loading;
  final bool          disabled;
  final int           remaining;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = !loading && !disabled;

    return GestureDetector(
      onTap: active ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF7C6AF7).withOpacity(0.15)
              : const Color(0xFF16161E),
          border: Border.all(
            color: active
                ? const Color(0xFF7C6AF7)
                : const Color(0xFF2A2A38),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: 18,
              color: active
                  ? const Color(0xFF7C6AF7)
                  : const Color(0xFF4A4A60),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fetch Live eBay Prices',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: active
                          ? const Color(0xFFE8E8F0)
                          : const Color(0xFF4A4A60),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    disabled
                        ? 'Rate limit reached — wait a moment'
                        : '$remaining search${remaining == 1 ? "" : "es"} left this minute',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8888A8),
                    ),
                  ),
                ],
              ),
            ),
            if (loading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF7C6AF7),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: active
                    ? const Color(0xFF7C6AF7)
                    : const Color(0xFF4A4A60),
              ),
          ],
        ),
      ),
    );
  }
}
