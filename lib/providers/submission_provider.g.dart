// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EstimatorInputNotifier)
final estimatorInputProvider = EstimatorInputNotifierProvider._();

final class EstimatorInputNotifierProvider
    extends $NotifierProvider<EstimatorInputNotifier, EstimatorInput> {
  EstimatorInputNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'estimatorInputProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$estimatorInputNotifierHash();

  @$internal
  @override
  EstimatorInputNotifier create() => EstimatorInputNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EstimatorInput value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EstimatorInput>(value),
    );
  }
}

String _$estimatorInputNotifierHash() =>
    r'e6483f3bc640f1f7cb981768ea73257ff9f50cfe';

abstract class _$EstimatorInputNotifier extends $Notifier<EstimatorInput> {
  EstimatorInput build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<EstimatorInput, EstimatorInput>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EstimatorInput, EstimatorInput>,
              EstimatorInput,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(estimatorCard)
final estimatorCardProvider = EstimatorCardProvider._();

final class EstimatorCardProvider
    extends
        $FunctionalProvider<
          AsyncValue<CardDocument?>,
          CardDocument?,
          FutureOr<CardDocument?>
        >
    with $FutureModifier<CardDocument?>, $FutureProvider<CardDocument?> {
  EstimatorCardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'estimatorCardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$estimatorCardHash();

  @$internal
  @override
  $FutureProviderElement<CardDocument?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CardDocument?> create(Ref ref) {
    return estimatorCard(ref);
  }
}

String _$estimatorCardHash() => r'ed97f26487d2ce12e567ca7d3e93566d5afa4e57';

@ProviderFor(submissionMatrix)
final submissionMatrixProvider = SubmissionMatrixProvider._();

final class SubmissionMatrixProvider
    extends
        $FunctionalProvider<
          AsyncValue<MatrixResult?>,
          MatrixResult?,
          FutureOr<MatrixResult?>
        >
    with $FutureModifier<MatrixResult?>, $FutureProvider<MatrixResult?> {
  SubmissionMatrixProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'submissionMatrixProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$submissionMatrixHash();

  @$internal
  @override
  $FutureProviderElement<MatrixResult?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MatrixResult?> create(Ref ref) {
    return submissionMatrix(ref);
  }
}

String _$submissionMatrixHash() => r'79561c9efe07e2199a2bd9e3c8c3c83ad6d2ef05';

@ProviderFor(SaveEstimate)
final saveEstimateProvider = SaveEstimateProvider._();

final class SaveEstimateProvider
    extends $NotifierProvider<SaveEstimate, AsyncValue<void>> {
  SaveEstimateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveEstimateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveEstimateHash();

  @$internal
  @override
  SaveEstimate create() => SaveEstimate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$saveEstimateHash() => r'9966156a0c112874d0115df069be91fc4921b3b3';

abstract class _$SaveEstimate extends $Notifier<AsyncValue<void>> {
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
