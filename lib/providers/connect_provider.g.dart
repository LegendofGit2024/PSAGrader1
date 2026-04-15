// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connect_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(activityFeed)
final activityFeedProvider = ActivityFeedProvider._();

final class ActivityFeedProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ActivityEvent>>,
          List<ActivityEvent>,
          Stream<List<ActivityEvent>>
        >
    with
        $FutureModifier<List<ActivityEvent>>,
        $StreamProvider<List<ActivityEvent>> {
  ActivityFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activityFeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activityFeedHash();

  @$internal
  @override
  $StreamProviderElement<List<ActivityEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ActivityEvent>> create(Ref ref) {
    return activityFeed(ref);
  }
}

String _$activityFeedHash() => r'd8b9ecca101cf10cb8d14552eed663870dc03617';

@ProviderFor(ReactToEvent)
final reactToEventProvider = ReactToEventProvider._();

final class ReactToEventProvider
    extends $NotifierProvider<ReactToEvent, AsyncValue<void>> {
  ReactToEventProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reactToEventProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reactToEventHash();

  @$internal
  @override
  ReactToEvent create() => ReactToEvent();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$reactToEventHash() => r'b62532b219fad02c3849e84f53e282fb4a865b16';

abstract class _$ReactToEvent extends $Notifier<AsyncValue<void>> {
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

@ProviderFor(friends)
final friendsProvider = FriendsProvider._();

final class FriendsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FriendProfile>>,
          List<FriendProfile>,
          FutureOr<List<FriendProfile>>
        >
    with
        $FutureModifier<List<FriendProfile>>,
        $FutureProvider<List<FriendProfile>> {
  FriendsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'friendsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$friendsHash();

  @$internal
  @override
  $FutureProviderElement<List<FriendProfile>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FriendProfile>> create(Ref ref) {
    return friends(ref);
  }
}

String _$friendsHash() => r'94985ced576b128f597236f2682d761bcb081f97';

@ProviderFor(gemLeaderboard)
final gemLeaderboardProvider = GemLeaderboardProvider._();

final class GemLeaderboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GemLeaderEntry>>,
          List<GemLeaderEntry>,
          FutureOr<List<GemLeaderEntry>>
        >
    with
        $FutureModifier<List<GemLeaderEntry>>,
        $FutureProvider<List<GemLeaderEntry>> {
  GemLeaderboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gemLeaderboardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gemLeaderboardHash();

  @$internal
  @override
  $FutureProviderElement<List<GemLeaderEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GemLeaderEntry>> create(Ref ref) {
    return gemLeaderboard(ref);
  }
}

String _$gemLeaderboardHash() => r'2da55119857727bebd18615edb67233c49076842';

@ProviderFor(tradeMatches)
final tradeMatchesProvider = TradeMatchesProvider._();

final class TradeMatchesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TradeMatch>>,
          List<TradeMatch>,
          FutureOr<List<TradeMatch>>
        >
    with $FutureModifier<List<TradeMatch>>, $FutureProvider<List<TradeMatch>> {
  TradeMatchesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tradeMatchesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tradeMatchesHash();

  @$internal
  @override
  $FutureProviderElement<List<TradeMatch>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TradeMatch>> create(Ref ref) {
    return tradeMatches(ref);
  }
}

String _$tradeMatchesHash() => r'b4d71df71ac1ea379883561d1791df8131a6655b';

@ProviderFor(portfolioDna)
final portfolioDnaProvider = PortfolioDnaFamily._();

final class PortfolioDnaProvider
    extends
        $FunctionalProvider<
          AsyncValue<PortfolioDna?>,
          PortfolioDna?,
          FutureOr<PortfolioDna?>
        >
    with $FutureModifier<PortfolioDna?>, $FutureProvider<PortfolioDna?> {
  PortfolioDnaProvider._({
    required PortfolioDnaFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'portfolioDnaProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$portfolioDnaHash();

  @override
  String toString() {
    return r'portfolioDnaProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PortfolioDna?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PortfolioDna?> create(Ref ref) {
    final argument = this.argument as String;
    return portfolioDna(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PortfolioDnaProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$portfolioDnaHash() => r'd6901b46b3c42af33646b50f69ebbd67ed198aa4';

final class PortfolioDnaFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PortfolioDna?>, String> {
  PortfolioDnaFamily._()
    : super(
        retry: null,
        name: r'portfolioDnaProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PortfolioDnaProvider call(String friendUid) =>
      PortfolioDnaProvider._(argument: friendUid, from: this);

  @override
  String toString() => r'portfolioDnaProvider';
}

@ProviderFor(LogGemResult)
final logGemResultProvider = LogGemResultProvider._();

final class LogGemResultProvider
    extends $NotifierProvider<LogGemResult, AsyncValue<void>> {
  LogGemResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logGemResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logGemResultHash();

  @$internal
  @override
  LogGemResult create() => LogGemResult();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$logGemResultHash() => r'65d6f9d005fdfbdecc8ece27da289be031196ecc';

abstract class _$LogGemResult extends $Notifier<AsyncValue<void>> {
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
