class RemoteEvidenceUploadRequest {
  const RemoteEvidenceUploadRequest({
    required this.acaoId,
    required this.evidenciaId,
    required this.localFilePath,
    required this.contentType,
  });

  final String acaoId;
  final String evidenciaId;
  final String localFilePath;
  final String contentType;

  bool get valido =>
      acaoId.trim().isNotEmpty &&
      evidenciaId.trim().isNotEmpty &&
      localFilePath.trim().isNotEmpty &&
      contentType.trim().isNotEmpty;
}

class RemoteEvidenceUploadResult {
  const RemoteEvidenceUploadResult({
    required this.objectKey,
    required this.syncedAt,
    this.etag,
    this.sizeBytes,
  });

  final String objectKey;
  final DateTime syncedAt;
  final String? etag;
  final int? sizeBytes;
}
