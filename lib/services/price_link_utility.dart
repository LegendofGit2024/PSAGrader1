import 'package:url_launcher/url_launcher.dart';

import '../models/card.dart';
import '../models/tcg_card.dart';

/// Generates PriceCharting.com deep-link search URLs and launches them.
///
/// URL pattern: https://www.pricecharting.com/search-products?q={setName}+{cardName}+{variant}
class PriceLinkUtility {
  PriceLinkUtility._();

  /// Build a PriceCharting search URL from a [CardDocument].
  static Uri buildUri(CardDocument card) {
    final parts = <String>[
      card.meta.setId,
      card.meta.name,
      if (card.meta.variant.isNotEmpty) card.meta.variant,
    ];
    final query = parts
        .join(' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
    return Uri.https(
      'www.pricecharting.com',
      '/search-products',
      {'q': query},
    );
  }

  /// Build a URL from a [TcgCard] (used before the card is in Firestore).
  static Uri buildUriFromTcgCard(TcgCard card, {String variant = ''}) {
    final parts = <String>[
      card.setName,
      card.name,
      if (variant.isNotEmpty) variant,
    ];
    final query = parts.join(' ').trim().replaceAll(RegExp(r'\s+'), ' ');
    return Uri.https(
      'www.pricecharting.com',
      '/search-products',
      {'q': query},
    );
  }

  /// Launch the PriceCharting search page in the user's browser.
  /// Returns true if the URL was launched, false otherwise.
  static Future<bool> launchPriceCheck(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Convenience: build + launch from a [CardDocument].
  static Future<bool> checkCard(CardDocument card) =>
      launchPriceCheck(buildUri(card));
}
