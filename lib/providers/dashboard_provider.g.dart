// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dailyDelta)
final dailyDeltaProvider = DailyDeltaProvider._();

final class DailyDeltaProvider
    extends
        $FunctionalProvider<
          AsyncValue<DailyDelta>,
          DailyDelta,
          FutureOr<DailyDelta>
        >
    with $FutureModifier<DailyDelta>, $FutureProvider<DailyDelta> {
  DailyDeltaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyDeltaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyDeltaHash();

  @$internal
  @override
  $FutureProviderElement<DailyDelta> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DailyDelta> create(Ref ref) {
    return dailyDelta(ref);
  }
}

String _$dailyDeltaHash() => r'f912e437022f0fcd7c6b8a2af877d3f477fa5947';

@ProviderFor(portfolioHistory)
final portfolioHistoryProvider = PortfolioHistoryProvider._();

final class PortfolioHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PortfolioHistoryPoint>>,
          List<PortfolioHistoryPoint>,
          FutureOr<List<PortfolioHistoryPoint>>
        >
    with
        $FutureModifier<List<PortfolioHistoryPoint>>,
        $FutureProvider<List<PortfolioHistoryPoint>> {
  PortfolioHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'portfolioHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$portfolioHistoryHash();

  @$internal
  @override
  $FutureProviderElement<List<PortfolioHistoryPoint>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PortfolioHistoryPoint>> create(Ref ref) {
    return portfolioHistory(ref);
  }
}

String _$portfolioHistoryHash() => r'8d80eff10082bee0a59f8572252a9d11e16c9d55';

@ProviderFor(hotCards)
final hotCardsProvider = HotCardsProvider._();

final class HotCardsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HotCard>>,
          List<HotCard>,
          FutureOr<List<HotCard>>
        >
    with $FutureModifier<List<HotCard>>, $FutureProvider<List<HotCard>> {
  HotCardsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hotCardsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hotCardsHash();

  @$internal
  @override
  $FutureProviderElement<List<HotCard>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HotCard>> create(Ref ref) {
    return hotCards(ref);
  }
}

String _$hotCardsHash() => r'7a5a90a4e2582fc7858b61b7c0cff18bcf3ecffd';

@ProviderFor(whaleSales)
final whaleSalesProvider = WhaleSalesProvider._();

final class WhaleSalesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WhaleSale>>,
          List<WhaleSale>,
          Stream<List<WhaleSale>>
        >
    with $FutureModifier<List<WhaleSale>>, $StreamProvider<List<WhaleSale>> {
  WhaleSalesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whaleSalesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whaleSalesHash();

  @$internal
  @override
  $StreamProviderElement<List<WhaleSale>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WhaleSale>> create(Ref ref) {
    return whaleSales(ref);
  }
}

String _$whaleSalesHash() => r'f02b345dce57387bd0bc231c74ace884a8b142d6';

@ProviderFor(smartTodos)
final smartTodosProvider = SmartTodosProvider._();

final class SmartTodosProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SmartTodo>>,
          List<SmartTodo>,
          FutureOr<List<SmartTodo>>
        >
    with $FutureModifier<List<SmartTodo>>, $FutureProvider<List<SmartTodo>> {
  SmartTodosProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'smartTodosProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$smartTodosHash();

  @$internal
  @override
  $FutureProviderElement<List<SmartTodo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SmartTodo>> create(Ref ref) {
    return smartTodos(ref);
  }
}

String _$smartTodosHash() => r'1378c09233ef5949323da1971f599a4eac8838ba';

@ProviderFor(communitySentiment)
final communitySentimentProvider = CommunitySentimentProvider._();

final class CommunitySentimentProvider
    extends
        $FunctionalProvider<
          AsyncValue<CommunitySentiment?>,
          CommunitySentiment?,
          FutureOr<CommunitySentiment?>
        >
    with
        $FutureModifier<CommunitySentiment?>,
        $FutureProvider<CommunitySentiment?> {
  CommunitySentimentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'communitySentimentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$communitySentimentHash();

  @$internal
  @override
  $FutureProviderElement<CommunitySentiment?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CommunitySentiment?> create(Ref ref) {
    return communitySentiment(ref);
  }
}

String _$communitySentimentHash() =>
    r'541b6b6b2d18edbaee5ac32788315140f86aeca7';

@ProviderFor(portfolioMovers)
final portfolioMoversProvider = PortfolioMoversProvider._();

final class PortfolioMoversProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PortfolioMover>>,
          List<PortfolioMover>,
          FutureOr<List<PortfolioMover>>
        >
    with
        $FutureModifier<List<PortfolioMover>>,
        $FutureProvider<List<PortfolioMover>> {
  PortfolioMoversProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'portfolioMoversProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$portfolioMoversHash();

  @$internal
  @override
  $FutureProviderElement<List<PortfolioMover>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PortfolioMover>> create(Ref ref) {
    return portfolioMovers(ref);
  }
}

String _$portfolioMoversHash() => r'6455953b0002051b895c2ff5e056da3c5390d53e';
