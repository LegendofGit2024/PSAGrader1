// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(collection)
final collectionProvider = CollectionProvider._();

final class CollectionProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CollectionItem>>,
          List<CollectionItem>,
          Stream<List<CollectionItem>>
        >
    with
        $FutureModifier<List<CollectionItem>>,
        $StreamProvider<List<CollectionItem>> {
  CollectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionHash();

  @$internal
  @override
  $StreamProviderElement<List<CollectionItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CollectionItem>> create(Ref ref) {
    return collection(ref);
  }
}

String _$collectionHash() => r'6280b5fc21db820c45ddabe499317f08b012397e';

@ProviderFor(collectionItem)
final collectionItemProvider = CollectionItemFamily._();

final class CollectionItemProvider
    extends
        $FunctionalProvider<
          AsyncValue<CollectionItem?>,
          CollectionItem?,
          FutureOr<CollectionItem?>
        >
    with $FutureModifier<CollectionItem?>, $FutureProvider<CollectionItem?> {
  CollectionItemProvider._({
    required CollectionItemFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'collectionItemProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$collectionItemHash();

  @override
  String toString() {
    return r'collectionItemProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CollectionItem?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CollectionItem?> create(Ref ref) {
    final argument = this.argument as String;
    return collectionItem(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionItemProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$collectionItemHash() => r'9687bda059606f3ae2c3c01d42abbd7e6b5a2a9d';

final class CollectionItemFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CollectionItem?>, String> {
  CollectionItemFamily._()
    : super(
        retry: null,
        name: r'collectionItemProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CollectionItemProvider call(String itemId) =>
      CollectionItemProvider._(argument: itemId, from: this);

  @override
  String toString() => r'collectionItemProvider';
}

@ProviderFor(binders)
final bindersProvider = BindersProvider._();

final class BindersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Binder>>,
          List<Binder>,
          Stream<List<Binder>>
        >
    with $FutureModifier<List<Binder>>, $StreamProvider<List<Binder>> {
  BindersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bindersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bindersHash();

  @$internal
  @override
  $StreamProviderElement<List<Binder>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Binder>> create(Ref ref) {
    return binders(ref);
  }
}

String _$bindersHash() => r'ac2ce6fe13e3a5f2c473687832c797cf1f1f92a5';

@ProviderFor(binderItems)
final binderItemsProvider = BinderItemsFamily._();

final class BinderItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CollectionItem>>,
          AsyncValue<List<CollectionItem>>,
          AsyncValue<List<CollectionItem>>
        >
    with $Provider<AsyncValue<List<CollectionItem>>> {
  BinderItemsProvider._({
    required BinderItemsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'binderItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$binderItemsHash();

  @override
  String toString() {
    return r'binderItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<CollectionItem>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<CollectionItem>> create(Ref ref) {
    final argument = this.argument as String;
    return binderItems(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<CollectionItem>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<CollectionItem>>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BinderItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$binderItemsHash() => r'f7acb24bb75b957507cc6432868db6e2319169de';

final class BinderItemsFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<List<CollectionItem>>, String> {
  BinderItemsFamily._()
    : super(
        retry: null,
        name: r'binderItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BinderItemsProvider call(String binderId) =>
      BinderItemsProvider._(argument: binderId, from: this);

  @override
  String toString() => r'binderItemsProvider';
}

@ProviderFor(resolvedCard)
final resolvedCardProvider = ResolvedCardFamily._();

final class ResolvedCardProvider
    extends
        $FunctionalProvider<
          AsyncValue<CardDocument?>,
          CardDocument?,
          FutureOr<CardDocument?>
        >
    with $FutureModifier<CardDocument?>, $FutureProvider<CardDocument?> {
  ResolvedCardProvider._({
    required ResolvedCardFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'resolvedCardProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$resolvedCardHash();

  @override
  String toString() {
    return r'resolvedCardProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CardDocument?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CardDocument?> create(Ref ref) {
    final argument = this.argument as String;
    return resolvedCard(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ResolvedCardProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$resolvedCardHash() => r'579dc793cba0acb2f65b6468810dfbc6910fcb7a';

final class ResolvedCardFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CardDocument?>, String> {
  ResolvedCardFamily._()
    : super(
        retry: null,
        name: r'resolvedCardProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ResolvedCardProvider call(String cardId) =>
      ResolvedCardProvider._(argument: cardId, from: this);

  @override
  String toString() => r'resolvedCardProvider';
}

@ProviderFor(portfolioStats)
final portfolioStatsProvider = PortfolioStatsProvider._();

final class PortfolioStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PortfolioStats>,
          AsyncValue<PortfolioStats>,
          AsyncValue<PortfolioStats>
        >
    with $Provider<AsyncValue<PortfolioStats>> {
  PortfolioStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'portfolioStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$portfolioStatsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<PortfolioStats>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<PortfolioStats> create(Ref ref) {
    return portfolioStats(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<PortfolioStats> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<PortfolioStats>>(value),
    );
  }
}

String _$portfolioStatsHash() => r'20dafe60b5bb2c316670a09e50d7b197e65ec84e';

@ProviderFor(portfolioValuation)
final portfolioValuationProvider = PortfolioValuationProvider._();

final class PortfolioValuationProvider
    extends
        $FunctionalProvider<
          AsyncValue<PortfolioValuation>,
          PortfolioValuation,
          FutureOr<PortfolioValuation>
        >
    with
        $FutureModifier<PortfolioValuation>,
        $FutureProvider<PortfolioValuation> {
  PortfolioValuationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'portfolioValuationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$portfolioValuationHash();

  @$internal
  @override
  $FutureProviderElement<PortfolioValuation> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PortfolioValuation> create(Ref ref) {
    return portfolioValuation(ref);
  }
}

String _$portfolioValuationHash() =>
    r'64d1bfb2dc213f1a22f2992866dc0b96ba79a433';

@ProviderFor(allTimeHigh)
final allTimeHighProvider = AllTimeHighProvider._();

final class AllTimeHighProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  AllTimeHighProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allTimeHighProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allTimeHighHash();

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    return allTimeHigh(ref);
  }
}

String _$allTimeHighHash() => r'd14ce4d996b4d8c190124e1178538c51427df5cf';

@ProviderFor(missingPieceAlerts)
final missingPieceAlertsProvider = MissingPieceAlertsProvider._();

final class MissingPieceAlertsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MissingPieceAlert>>,
          List<MissingPieceAlert>,
          FutureOr<List<MissingPieceAlert>>
        >
    with
        $FutureModifier<List<MissingPieceAlert>>,
        $FutureProvider<List<MissingPieceAlert>> {
  MissingPieceAlertsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'missingPieceAlertsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$missingPieceAlertsHash();

  @$internal
  @override
  $FutureProviderElement<List<MissingPieceAlert>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MissingPieceAlert>> create(Ref ref) {
    return missingPieceAlerts(ref);
  }
}

String _$missingPieceAlertsHash() =>
    r'9a51c5db72c1cf771978217ad079b2f711ecdf86';

@ProviderFor(marketCorrelation)
final marketCorrelationProvider = MarketCorrelationProvider._();

final class MarketCorrelationProvider
    extends
        $FunctionalProvider<
          AsyncValue<MarketCorrelation>,
          MarketCorrelation,
          FutureOr<MarketCorrelation>
        >
    with
        $FutureModifier<MarketCorrelation>,
        $FutureProvider<MarketCorrelation> {
  MarketCorrelationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'marketCorrelationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$marketCorrelationHash();

  @$internal
  @override
  $FutureProviderElement<MarketCorrelation> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MarketCorrelation> create(Ref ref) {
    return marketCorrelation(ref);
  }
}

String _$marketCorrelationHash() => r'd64e01069def0331d5cd1cc2755a0283693b9210';

@ProviderFor(CollectionMutations)
final collectionMutationsProvider = CollectionMutationsProvider._();

final class CollectionMutationsProvider
    extends $NotifierProvider<CollectionMutations, AsyncValue<void>> {
  CollectionMutationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionMutationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionMutationsHash();

  @$internal
  @override
  CollectionMutations create() => CollectionMutations();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$collectionMutationsHash() =>
    r'0ce0a0af02ec8354b4ef0524c75ad1a8591a4b44';

abstract class _$CollectionMutations extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(BinderMutations)
final binderMutationsProvider = BinderMutationsProvider._();

final class BinderMutationsProvider
    extends $NotifierProvider<BinderMutations, AsyncValue<void>> {
  BinderMutationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'binderMutationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$binderMutationsHash();

  @$internal
  @override
  BinderMutations create() => BinderMutations();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$binderMutationsHash() => r'f5d1dd3b0b94327dce944c38061e7f04d139b870';

abstract class _$BinderMutations extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
