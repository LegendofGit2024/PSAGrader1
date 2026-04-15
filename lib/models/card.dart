import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'card.freezed.dart';
part 'card.g.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum CardLanguage { en, jp, kr, zh }

// ---------------------------------------------------------------------------
// Regional pricing sub-models
// ---------------------------------------------------------------------------

@freezed
abstract class EbayUsPricing with _$EbayUsPricing {
  const factory EbayUsPricing({
    @JsonKey(name: 'last_sold_nm') double? lastSoldNm,
    @JsonKey(name: 'last_sold_lp') double? lastSoldLp,
    @JsonKey(name: 'volume_7d') int? volume7d,
    @JsonKey(name: 'updated_at') @TimestampConverter() DateTime? updatedAt,
  }) = _EbayUsPricing;

  factory EbayUsPricing.fromJson(Map<String, dynamic> json) =>
      _$EbayUsPricingFromJson(json);
}

@freezed
abstract class TcgplayerUsPricing with _$TcgplayerUsPricing {
  const factory TcgplayerUsPricing({
    @JsonKey(name: 'market_nm') double? marketNm,
    @JsonKey(name: 'market_lp') double? marketLp,
    @JsonKey(name: 'market_mp') double? marketMp,
    @JsonKey(name: 'market_hp') double? marketHp,
    @JsonKey(name: 'market_dmg') double? marketDmg,
    @JsonKey(name: 'updated_at') @TimestampConverter() DateTime? updatedAt,
  }) = _TcgplayerUsPricing;

  factory TcgplayerUsPricing.fromJson(Map<String, dynamic> json) =>
      _$TcgplayerUsPricingFromJson(json);
}

@freezed
abstract class CardmarketEuPricing with _$CardmarketEuPricing {
  const factory CardmarketEuPricing({
    @JsonKey(name: 'trend_price') double? trendPrice,
    @JsonKey(name: 'avg_sell_1d') double? avgSell1d,
    @JsonKey(name: 'updated_at') @TimestampConverter() DateTime? updatedAt,
  }) = _CardmarketEuPricing;

  factory CardmarketEuPricing.fromJson(Map<String, dynamic> json) =>
      _$CardmarketEuPricingFromJson(json);
}

@freezed
abstract class YuyuteiJpPricing with _$YuyuteiJpPricing {
  const factory YuyuteiJpPricing({
    @JsonKey(name: 'buy_price') double? buyPrice,
    @JsonKey(name: 'updated_at') @TimestampConverter() DateTime? updatedAt,
  }) = _YuyuteiJpPricing;

  factory YuyuteiJpPricing.fromJson(Map<String, dynamic> json) =>
      _$YuyuteiJpPricingFromJson(json);
}

@freezed
abstract class CardPricing with _$CardPricing {
  const factory CardPricing({
    @JsonKey(name: 'ebay_us') EbayUsPricing? ebayUs,
    @JsonKey(name: 'tcgplayer_us') TcgplayerUsPricing? tcgplayerUs,
    @JsonKey(name: 'cardmarket_eu') CardmarketEuPricing? cardmarketEu,
    @JsonKey(name: 'yuyutei_jp') YuyuteiJpPricing? yuyuteiJp,
  }) = _CardPricing;

  factory CardPricing.fromJson(Map<String, dynamic> json) =>
      _$CardPricingFromJson(json);
}

// ---------------------------------------------------------------------------
// PSA Population
// ---------------------------------------------------------------------------

@freezed
abstract class PsaPop with _$PsaPop {
  const factory PsaPop({
    @JsonKey(name: 'total_pop') int? totalPop,
    @JsonKey(name: 'pop_10') int? pop10,
    @JsonKey(name: 'pop_9') int? pop9,
    @JsonKey(name: 'updated_at') @TimestampConverter() DateTime? updatedAt,
  }) = _PsaPop;

  factory PsaPop.fromJson(Map<String, dynamic> json) =>
      _$PsaPopFromJson(json);
}

// ---------------------------------------------------------------------------
// Card metadata
// ---------------------------------------------------------------------------

@freezed
abstract class CardMeta with _$CardMeta {
  const factory CardMeta({
    required String name,
    @JsonKey(name: 'set_id') required String setId,
    @JsonKey(name: 'set_number') required String setNumber,
    @JsonKey(name: 'language')
    @JsonKey(unknownEnumValue: CardLanguage.en)
    required CardLanguage language,
    required String variant,
    @JsonKey(name: 'image_url') required String imageUrl,
  }) = _CardMeta;

  factory CardMeta.fromJson(Map<String, dynamic> json) =>
      _$CardMetaFromJson(json);
}

// ---------------------------------------------------------------------------
// Root Card document  (/cards/{cardId})
// ---------------------------------------------------------------------------

@freezed
abstract class CardDocument with _$CardDocument {
  const factory CardDocument({
    required String id,
    required CardMeta meta,
    required CardPricing pricing,
    @JsonKey(name: 'psa_pop') PsaPop? psaPop,
  }) = _CardDocument;

  factory CardDocument.fromJson(Map<String, dynamic> json) =>
      _$CardDocumentFromJson(json);

  factory CardDocument.fromFirestore(DocumentSnapshot doc) {
    final raw = doc.data() as Map<String, dynamic>;

    // Normalize the meta sub-map so required String fields are never null.
    final rawMeta = raw['meta'] is Map
        ? Map<String, dynamic>.from(raw['meta'] as Map)
        : <String, dynamic>{};
    rawMeta['name']       ??= '';
    rawMeta['set_id']     ??= '';
    rawMeta['set_number'] ??= '';
    rawMeta['language']   ??= 'en';
    rawMeta['variant']    ??= '';
    rawMeta['image_url']  ??= '';

    final data = <String, dynamic>{
      // Inject the doc ID — toFirestore strips it so it's never in the document.
      'id': doc.id,
      ...raw,
      'meta': rawMeta,
      // Cards upserted via the TCG API only have a 'meta' field; provide an
      // empty pricing map so fromJson doesn't cast null to Map and throw.
      if (!raw.containsKey('pricing')) 'pricing': <String, dynamic>{},
    };
    return CardDocument.fromJson(data);
  }

  static Map<String, dynamic> toFirestore(CardDocument card) =>
      card.toJson()..remove('id');
}

// ---------------------------------------------------------------------------
// Timestamp converter (Firestore Timestamp <-> DateTime)
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// DocumentReference converter (Firestore DocumentReference pass-through)
// ---------------------------------------------------------------------------

/// For required (non-nullable) DocumentReference fields.
class DocumentReferenceConverter
    implements JsonConverter<DocumentReference, Object> {
  const DocumentReferenceConverter();

  @override
  DocumentReference fromJson(Object json) {
    if (json is DocumentReference) return json;
    // Fallback: reconstruct from path string
    return FirebaseFirestore.instance.doc(json as String);
  }

  @override
  Object toJson(DocumentReference ref) => ref;
}

/// For optional (nullable) DocumentReference fields.
class NullableDocumentReferenceConverter
    implements JsonConverter<DocumentReference?, Object?> {
  const NullableDocumentReferenceConverter();

  @override
  DocumentReference? fromJson(Object? json) {
    if (json == null) return null;
    if (json is DocumentReference) return json;
    return FirebaseFirestore.instance.doc(json as String);
  }

  @override
  Object? toJson(DocumentReference? ref) => ref;
}

// ---------------------------------------------------------------------------
// Timestamp converter (Firestore Timestamp <-> DateTime)
// ---------------------------------------------------------------------------

class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.tryParse(json);
    return null;
  }

  @override
  Object? toJson(DateTime? date) =>
      date == null ? null : Timestamp.fromDate(date);
}
