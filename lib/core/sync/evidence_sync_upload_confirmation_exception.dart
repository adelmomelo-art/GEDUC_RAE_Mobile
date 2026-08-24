enum EvidenceSyncConfirmationFailure {
  objectKeyMismatch,
  sizeMismatch,
  jobMissing,
  jobChanged,
  invalidSyncedState,
  persistenceFailure,
}

class EvidenceSyncConfirmationException implements Exception {
  const EvidenceSyncConfirmationException({
    required this.failure,
    required this.message,
    required this.trustedObjectKey,
    this.cause,
  });

  final EvidenceSyncConfirmationFailure failure;
  final String message;
  final String trustedObjectKey;
  final Object? cause;

  bool get retryCandidate =>
      failure == EvidenceSyncConfirmationFailure.persistenceFailure;

  bool get concurrentStateConflict =>
      failure == EvidenceSyncConfirmationFailure.jobMissing ||
      failure == EvidenceSyncConfirmationFailure.jobChanged;

  @override
  String toString() =>
      'EvidenceSyncConfirmationException: $message';
}
