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

String _$cardForecastHash() => r'fe3ad0b544c0c4d1aab547e1341ac630078fcca3';

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
