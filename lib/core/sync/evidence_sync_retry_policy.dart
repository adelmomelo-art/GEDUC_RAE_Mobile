class EvidenceSyncRetryPolicy {
  EvidenceSyncRetryPolicy({
    this.baseDelay = const Duration(seconds: 30),
    this.maxDelay = const Duration(minutes: 30),
    this.maxAttempts = 6,
  })  : assert(maxAttempts > 0),
        assert(baseDelay > Duration.zero),
        assert(maxDelay >= baseDelay);

  final Duration baseDelay;
  final Duration maxDelay;
  final int maxAttempts;

  bool podeAgendarAposFalha(int attemptCountAfterFailure) =>
      attemptCountAfterFailure < maxAttempts;

  Duration delayForAttempt(int attemptCountAfterFailure) {
    if (attemptCountAfterFailure <= 0) {
      throw ArgumentError.value(
        attemptCountAfterFailure,
        'attemptCountAfterFailure',
        'Deve ser maior que zero.',
      );
    }

    var delayMicros = baseDelay.inMicroseconds;

    for (var i = 1; i < attemptCountAfterFailure; i++) {
      if (delayMicros >= maxDelay.inMicroseconds) {
        return maxDelay;
      }

      delayMicros *= 2;
      if (delayMicros >= maxDelay.inMicroseconds) {
        return maxDelay;
      }
    }

    return Duration(microseconds: delayMicros);
  }
}
