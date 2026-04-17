// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ebay_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Application-wide [EbaySearchService] instance (rate-limiter state lives here).

@ProviderFor(ebaySearchService)
final ebaySearchServiceProvider = EbaySearchServiceProvider._();

/// Application-wide [EbaySearchService] instance (rate-limiter state lives here).

final class EbaySearchServiceProvider
    extends
        $FunctionalProvider<
          EbaySearchService,
          EbaySearchService,
          EbaySearchService
        >
    with $Provider<EbaySearchService> {
  /// Application-wide [EbaySearchService] instance (rate-limiter state lives here).
  EbaySearchServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ebaySearchServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ebaySearchServiceHash();

  @$internal
  @override
  $ProviderElement<EbaySearchService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EbaySearchService create(Ref ref) {
    return ebaySearchService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EbaySearchService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EbaySearchService>(value),
    );
  }
}

String _$ebaySearchServiceHash() => r'349fee42bbc622fed8ef1fe97f5adae3267a90d9';

/// Emits `true` while the Cloud Function is running for [cardId], `false`
/// once the request document has been deleted (job done).
///
/// Safe to watch in a build method — will not cause rebuilds when the card has
/// no in-flight search.

@ProviderFor(ebaySearchActive)
final ebaySearchActiveProvider = EbaySearchActiveFamily._();

/// Emits `true` while the Cloud Function is running for [cardId], `false`
/// once the request document has been deleted (job done).
///
/// Safe to watch in a build method — will not cause rebuilds when the card has
/// no in-flight search.

final class EbaySearchActiveProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Emits `true` while the Cloud Function is running for [cardId], `false`
  /// once the request document has been deleted (job done).
  ///
  /// Safe to watch in a build method — will not cause rebuilds when the card has
  /// no in-flight search.
  EbaySearchActiveProvider._({
    required EbaySearchActiveFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ebaySearchActiveProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ebaySearchActiveHash();

  @override
  String toString() {
    return r'ebaySearchActiveProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    final argument = this.argument as String;
    return ebaySearchActive(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EbaySearchActiveProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ebaySearchActiveHash() => r'2b3ea527b5a6e2488c2820b261882aa2443295ea';

/// Emits `true` while the Cloud Function is running for [cardId], `false`
/// once the request document has been deleted (job done).
///
/// Safe to watch in a build method — will not cause rebuilds when the card has
/// no in-flight search.

final class EbaySearchActiveFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool>, String> {
  EbaySearchActiveFamily._()
    : super(
        retry: null,
        name: r'ebaySearchActiveProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Emits `true` while the Cloud Function is running for [cardId], `false`
  /// once the request document has been deleted (job done).
  ///
  /// Safe to watch in a build method — will not cause rebuilds when the card has
  /// no in-flight search.

  EbaySearchActiveProvider call(String cardId) =>
      EbaySearchActiveProvider._(argument: cardId, from: this);

  @override
  String toString() => r'ebaySearchActiveProvider';
}

/// Notifier that drives the "Fetch Live Prices" button.
///
/// Call [trigger(card)] to write a search_request.
/// Watch [ebaySearchActiveProvider(cardId)] for the spinner.

@ProviderFor(EbaySearchNotifier)
final ebaySearchProvider = EbaySearchNotifierFamily._();

/// Notifier that drives the "Fetch Live Prices" button.
///
/// Call [trigger(card)] to write a search_request.
/// Watch [ebaySearchActiveProvider(cardId)] for the spinner.
final class EbaySearchNotifierProvider
    extends $NotifierProvider<EbaySearchNotifier, EbaySearchState> {
  /// Notifier that drives the "Fetch Live Prices" button.
  ///
  /// Call [trigger(card)] to write a search_request.
  /// Watch [ebaySearchActiveProvider(cardId)] for the spinner.
  EbaySearchNotifierProvider._({
    required EbaySearchNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ebaySearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ebaySearchNotifierHash();

  @override
  String toString() {
    return r'ebaySearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EbaySearchNotifier create() => EbaySearchNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EbaySearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EbaySearchState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EbaySearchNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ebaySearchNotifierHash() =>
    r'fb2b218dc088a6646b8b2ce400b4abb072f48224';

/// Notifier that drives the "Fetch Live Prices" button.
///
/// Call [trigger(card)] to write a search_request.
/// Watch [ebaySearchActiveProvider(cardId)] for the spinner.

final class EbaySearchNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          EbaySearchNotifier,
          EbaySearchState,
          EbaySearchState,
          EbaySearchState,
          String
        > {
  EbaySearchNotifierFamily._()
    : super(
        retry: null,
        name: r'ebaySearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Notifier that drives the "Fetch Live Prices" button.
  ///
  /// Call [trigger(card)] to write a search_request.
  /// Watch [ebaySearchActiveProvider(cardId)] for the spinner.

  EbaySearchNotifierProvider call(String cardId) =>
      EbaySearchNotifierProvider._(argument: cardId, from: this);

  @override
  String toString() => r'ebaySearchProvider';
}

/// Notifier that drives the "Fetch Live Prices" button.
///
/// Call [trigger(card)] to write a search_request.
/// Watch [ebaySearchActiveProvider(cardId)] for the spinner.

abstract class _$EbaySearchNotifier extends $Notifier<EbaySearchState> {
  late final _$args = ref.$arg as String;
  String get cardId => _$args;

  EbaySearchState build(String cardId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<EbaySearchState, EbaySearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EbaySearchState, EbaySearchState>,
              EbaySearchState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
