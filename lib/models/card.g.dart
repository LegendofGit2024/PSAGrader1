// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EbayRawPrice _$EbayRawPriceFromJson(Map<String, dynamic> json) =>
    _EbayRawPrice(
      lastSold: (json['last_sold'] as num?)?.toDouble(),
      lastUpdated: const TimestampConverter().fromJson(json['last_updated']),
    );

Map<String, dynamic> _$EbayRawPriceToJson(_EbayRawPrice instance) =>
    <String, dynamic>{
      'last_sold': instance.lastSold,
      'last_updated': const TimestampConverter().toJson(instance.lastUpdated),
    };

_EbayGradedPrice _$EbayGradedPriceFromJson(Map<String, dynamic> json) =>
    _EbayGradedPrice(
      psa10: (json['psa10'] as num?)?.toDouble(),
      psa9: (json['psa9'] as num?)?.toDouble(),
      psa8: (json['psa8'] as num?)?.toDouble(),
      lastUpdated: const TimestampConverter().fromJson(json['last_updated']),
    );

Map<String, dynamic> _$EbayGradedPriceToJson(_EbayGradedPrice instance) =>
    <String, dynamic>{
      'psa10': instance.psa10,
      'psa9': instance.psa9,
      'psa8': instance.psa8,
      'last_updated': const TimestampConverter().toJson(instance.lastUpdated),
    };

_EbayUsPricing _$EbayUsPricingFromJson(Map<String, dynamic> json) =>
    _EbayUsPricing(
      raw: json['raw'] == null
          ? null
          : EbayRawPrice.fromJson(json['raw'] as Map<String, dynamic>),
      graded: json['graded'] == null
          ? null
          : EbayGradedPrice.fromJson(json['graded'] as Map<String, dynamic>),
      lastSoldNm: (json['last_sold_nm'] as num?)?.toDouble(),
      lastSoldLp: (json['last_sold_lp'] as num?)?.toDouble(),
      volume7d: (json['volume_7d'] as num?)?.toInt(),
      updatedAt: const TimestampConverter().fromJson(json['updated_at']),
    );

Map<String, dynamic> _$EbayUsPricingToJson(_EbayUsPricing instance) =>
    <String, dynamic>{
      'raw': instance.raw,
      'graded': instance.graded,
      'last_sold_nm': instance.lastSoldNm,
      'last_sold_lp': instance.lastSoldLp,
      'volume_7d': instance.volume7d,
      'updated_at': const TimestampConverter().toJson(instance.updatedAt),
    };

_TcgplayerUsPricing _$TcgplayerUsPricingFromJson(Map<String, dynamic> json) =>
    _TcgplayerUsPricing(
      marketNm: (json['market_nm'] as num?)?.toDouble(),
      marketLp: (json['market_lp'] as num?)?.toDouble(),
      marketMp: (json['market_mp'] as num?)?.toDouble(),
      marketHp: (json['market_hp'] as num?)?.toDouble(),
      marketDmg: (json['market_dmg'] as num?)?.toDouble(),
      updatedAt: const TimestampConverter().fromJson(json['updated_at']),
    );

Map<String, dynamic> _$TcgplayerUsPricingToJson(_TcgplayerUsPricing instance) =>
    <String, dynamic>{
      'market_nm': instance.marketNm,
      'market_lp': instance.marketLp,
      'market_mp': instance.marketMp,
      'market_hp': instance.marketHp,
      'market_dmg': instance.marketDmg,
      'updated_at': const TimestampConverter().toJson(instance.updatedAt),
    };

_CardmarketEuPricing _$CardmarketEuPricingFromJson(Map<String, dynamic> json) =>
    _CardmarketEuPricing(
      trendPrice: (json['trend_price'] as num?)?.toDouble(),
      avgSell1d: (json['avg_sell_1d'] as num?)?.toDouble(),
      updatedAt: const TimestampConverter().fromJson(json['updated_at']),
    );

Map<String, dynamic> _$CardmarketEuPricingToJson(
  _CardmarketEuPricing instance,
) => <String, dynamic>{
  'trend_price': instance.trendPrice,
  'avg_sell_1d': instance.avgSell1d,
  'updated_at': const TimestampConverter().toJson(instance.updatedAt),
};

_YuyuteiJpPricing _$YuyuteiJpPricingFromJson(Map<String, dynamic> json) =>
    _YuyuteiJpPricing(
      buyPrice: (json['buy_price'] as num?)?.toDouble(),
      updatedAt: const TimestampConverter().fromJson(json['updated_at']),
    );

Map<String, dynamic> _$YuyuteiJpPricingToJson(_YuyuteiJpPricing instance) =>
    <String, dynamic>{
      'buy_price': instance.buyPrice,
      'updated_at': const TimestampConverter().toJson(instance.updatedAt),
    };

_CardPricing _$CardPricingFromJson(Map<String, dynamic> json) => _CardPricing(
  ebayUs: json['ebay_us'] == null
      ? null
      : EbayUsPricing.fromJson(json['ebay_us'] as Map<String, dynamic>),
  tcgplayerUs: json['tcgplayer_us'] == null
      ? null
      : TcgplayerUsPricing.fromJson(
          json['tcgplayer_us'] as Map<String, dynamic>,
        ),
  cardmarketEu: json['cardmarket_eu'] == null
      ? null
      : CardmarketEuPricing.fromJson(
          json['cardmarket_eu'] as Map<String, dynamic>,
        ),
  yuyuteiJp: json['yuyutei_jp'] == null
      ? null
      : YuyuteiJpPricing.fromJson(json['yuyutei_jp'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CardPricingToJson(_CardPricing instance) =>
    <String, dynamic>{
      'ebay_us': instance.ebayUs,
      'tcgplayer_us': instance.tcgplayerUs,
      'cardmarket_eu': instance.cardmarketEu,
      'yuyutei_jp': instance.yuyuteiJp,
    };

_PsaPop _$PsaPopFromJson(Map<String, dynamic> json) => _PsaPop(
  totalPop: (json['total_pop'] as num?)?.toInt(),
  pop10: (json['pop_10'] as num?)?.toInt(),
  pop9: (json['pop_9'] as num?)?.toInt(),
  updatedAt: const TimestampConverter().fromJson(json['updated_at']),
);

Map<String, dynamic> _$PsaPopToJson(_PsaPop instance) => <String, dynamic>{
  'total_pop': instance.totalPop,
  'pop_10': instance.pop10,
  'pop_9': instance.pop9,
  'updated_at': const TimestampConverter().toJson(instance.updatedAt),
};

_CardMeta _$CardMetaFromJson(Map<String, dynamic> json) => _CardMeta(
  name: json['name'] as String,
  setId: json['set_id'] as String,
  setNumber: json['set_number'] as String,
  language: $enumDecode(_$CardLanguageEnumMap, json['language']),
  variant: json['variant'] as String,
  imageUrl: json['image_url'] as String,
  specialtyTags:
      (json['specialty_tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$CardMetaToJson(_CardMeta instance) => <String, dynamic>{
  'name': instance.name,
  'set_id': instance.setId,
  'set_number': instance.setNumber,
  'language': _$CardLanguageEnumMap[instance.language]!,
  'variant': instance.variant,
  'image_url': instance.imageUrl,
  'specialty_tags': instance.specialtyTags,
};

const _$CardLanguageEnumMap = {
  CardLanguage.en: 'en',
  CardLanguage.jp: 'jp',
  CardLanguage.kr: 'kr',
  CardLanguage.zh: 'zh',
};

_CardDocument _$CardDocumentFromJson(Map<String, dynamic> json) =>
    _CardDocument(
      id: json['id'] as String,
      meta: CardMeta.fromJson(json['meta'] as Map<String, dynamic>),
      pricing: CardPricing.fromJson(json['pricing'] as Map<String, dynamic>),
      psaPop: json['psa_pop'] == null
          ? null
          : PsaPop.fromJson(json['psa_pop'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CardDocumentToJson(_CardDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'meta': instance.meta,
      'pricing': instance.pricing,
      'psa_pop': instance.psaPop,
    };
