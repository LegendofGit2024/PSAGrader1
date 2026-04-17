// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cardForecast)
final cardForecastProvider = CardForecastFamily._();

final class CardForecastProvider
    extends
        $FunctionalProvider<
          AsyncValue<CardForecast>,
          CardForecast,
          FutureOr<CardForecast>
        >
    with $FutureModifier<CardForecast>, $FutureProvider<CardForecast> {
  CardForecastProvider._({
    required CardForecastFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cardForecastProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cardForecastHash();

  @override
  String toString() {
    return r'cardForecastProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CardForecast> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CardForecast> create(Ref ref) {
    final argument = this.argument as String;
    return cardForecast(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CardForecastProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cardForecastHash() => r'9b42fedc2b89fad13354486af129fa4bca657272';

final class CardForecastFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CardForecast>, String> {
  CardForecastFamily._()
    : super(
        retry: null,
        name: r'cardForecastProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CardForecastProvider call(String cardId) =>
      CardForecastProvider._(argument: cardId, from: this);

  @override
  String toString() => r'cardForecastProvider';
}

@ProviderFor(portfolioForecasts)
final portfolioForecastsProvider = PortfolioForecastsProvider._();

final class PortfolioForecastsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CardForecast>>,
          List<CardForecast>,
          FutureOr<List<CardForecast>>
        >
    with
        $FutureModifier<List<CardForecast>>,
        $FutureProvider<List<CardForecast>> {
  PortfolioForecastsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'portfolioForecastsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$portfolioForecastsHash();

  @$internal
  @override
  $FutureProviderElement<List<CardForecast>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CardForecast>> create(Ref ref) {
    return portfolioForecasts(ref);
  }
}

String _$portfolioForecastsHash() =>
    r'8b12a6249eeeb782731a6b474cdb66f6e30c9576';

@ProviderFor(ForecastSearchQuery)
final forecastSearchQueryProvider = ForecastSearchQueryProvider._();

final class ForecastSearchQueryProvider
    extends $NotifierProvider<ForecastSearchQuery, String> {
  ForecastSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forecastSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forecastSearchQueryHash();

  @$internal
  @override
  ForecastSearchQuery create() => ForecastSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$forecastSearchQueryHash() =>
    r'b6529ef82206c2dc5e50b4310c1282e5eb113cee';

abstract class _$ForecastSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(forecastSearchResults)
final forecastSearchResultsProvider = ForecastSearchResultsProvider._();

final class ForecastSearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CardDocument>>,
          List<CardDocument>,
          FutureOr<List<CardDocument>>
        >
    with
        $FutureModifier<List<CardDocument>>,
        $FutureProvider<List<CardDocument>> {
  ForecastSearchResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forecastSearchResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forecastSearchResultsHash();

  @$internal
  @override
  $FutureProviderElement<List<CardDocument>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CardDocument>> create(Ref ref) {
    return forecastSearchResults(ref);
  }
}

String _$forecastSearchResultsHash() =>
    r'a50293672c0c3451c027b2225ac07266aa3f41db';

/// Per-card variant selection state: cardId → [BaseSetVariant].
/// Defaults to [BaseSetVariant.unlimited] when not set.

@ProviderFor(SelectedVariant)
final selectedVariantProvider = SelectedVariantProvider._();

/// Per-card variant selection state: cardId → [BaseSetVariant].
/// Defaults to [BaseSetVariant.unlimited] when not set.
final class SelectedVariantProvider
    extends $NotifierProvider<SelectedVariant, Map<String, BaseSetVariant>> {
  /// Per-card variant selection state: cardId → [BaseSetVariant].
  /// Defaults to [BaseSetVariant.unlimited] when not set.
  SelectedVariantProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedVariantProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedVariantHash();

  @$internal
  @override
  SelectedVariant create() => SelectedVariant();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, BaseSetVariant> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, BaseSetVariant>>(value),
    );
  }
}

String _$selectedVariantHash() => r'b4bbe04e78ddb78f63881bb5356fce88a0fbb291';

/// Per-card variant selection state: cardId → [BaseSetVariant].
/// Defaults to [BaseSetVariant.unlimited] when not set.

abstract class _$SelectedVariant
    extends $Notifier<Map<String, BaseSetVariant>> {
  Map<String, BaseSetVariant> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<Map<String, BaseSetVariant>, Map<String, BaseSetVariant>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, BaseSetVariant>,
                Map<String, BaseSetVariant>
              >,
              Map<String, BaseSetVariant>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ManualCardPrice)
final manualCardPriceProvider = ManualCardPriceProvider._();

final class ManualCardPriceProvider
    extends $NotifierProvider<ManualCardPrice, Map<String, double>> {
  ManualCardPriceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'manualCardPriceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$manualCardPriceHash();

  @$internal
  @override
  ManualCardPrice create() => ManualCardPrice();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, double> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, double>>(value),
    );
  }
}

String _$manualCardPriceHash() => r'237da715e1f9084cd42ab422a1ef0e65456d3b1b';

abstract class _$ManualCardPrice extends $Notifier<Map<String, double>> {
  Map<String, double> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, double>, Map<String, double>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, double>, Map<String, double>>,
              Map<String, double>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
