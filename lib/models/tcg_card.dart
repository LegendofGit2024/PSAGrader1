/// Lightweight model for cards returned by the Pokémon TCG API v2.
/// Only carries what the search UI needs — full card data lives in Firestore.
class TcgCard {
  const TcgCard({
    required this.id,
    required this.name,
    required this.number,
    required this.setId,
    required this.setName,
    required this.smallImageUrl,
    this.largeImageUrl,
    this.rarity,
    this.subtypes = const [],
  });

  /// TCG API card id, e.g. "base1-4". Used as the Firestore /cards/{id} doc id.
  final String id;
  final String name;

  /// Card number within the set, e.g. "4".
  final String number;
  final String setId;
  final String setName;
  final String smallImageUrl;
  final String? largeImageUrl;
  final String? rarity;

  /// TCG API subtypes e.g. ["VMAX", "Ultra Beast"], used to hint the variant.
  final List<String> subtypes;

  factory TcgCard.fromJson(Map<String, dynamic> json) {
    final set = (json['set'] as Map<String, dynamic>?) ?? {};
    final images = (json['images'] as Map<String, dynamic>?) ?? {};
    final rawSubtypes = json['subtypes'];
    final subtypes = rawSubtypes is List
        ? List<String>.from(rawSubtypes.whereType<String>())
        : <String>[];
    return TcgCard(
      id: json['id'] as String,
      name: json['name'] as String,
      number: json['number'] as String? ?? '',
      setId: set['id'] as String? ?? '',
      setName: set['name'] as String? ?? '',
      smallImageUrl: images['small'] as String? ?? '',
      largeImageUrl: images['large'] as String?,
      rarity: json['rarity'] as String?,
      subtypes: subtypes,
    );
  }

  /// Human-readable one-liner shown in search results and selected-card chips.
  String get displayLabel => '$name · $setName · #$number';
}
