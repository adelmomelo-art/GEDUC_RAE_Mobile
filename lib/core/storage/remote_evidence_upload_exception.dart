enum RemoteEvidenceUploadFailure {
  invalidRequest,
  invalidGrant,
  missingContentType,
  contentTypeMismatch,
  httpRejected,
  transportFailure,
}

class RemoteEvidenceUploadException implements Exception {
  const RemoteEvidenceUploadException({
    required this.failure,
    required this.message,
    this.statusCode,
    this.cause,
  });

  final RemoteEvidenceUploadFailure failure;
  final String message;
  final int? statusCode;
  final Object? cause;

  /// Indica apenas se a natureza da falha pode admitir nova tentativa.
  ///
  /// A camada de transporte nunca executa retry automaticamente. A decisao
  /// pertence ao orquestrador de sincronizacao, que deve revalidar ou renovar
  /// o grant antes de uma nova chamada.
  bool get retryCandidate {
    if (failure == RemoteEvidenceUploadFailure.transportFailure) {
      return true;
    }

    if (failure != RemoteEvidenceUploadFailure.httpRejected) {
      return false;
    }

    final status = statusCode;
    if (status == null) {
      return false;
    }

    return status == 408 ||
        status == 425 ||
        status == 429 ||
        (status >= 500 && status <= 599);
  }

  @override
  String toString() {
    final status = statusCode == null ? '' : ' (HTTP $statusCode)';
    return 'RemoteEvidenceUploadException: $message$status';
  }
}
