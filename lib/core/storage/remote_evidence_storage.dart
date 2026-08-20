import 'remote_evidence_models.dart';

abstract interface class RemoteEvidenceStorage {
  bool get enabled;

  Future<RemoteEvidenceUploadResult> upload(
    RemoteEvidenceUploadRequest request,
  );

  Future<Uri> createReadUri({
    required String acaoId,
    required String evidenciaId,
  });

  Future<void> delete({
    required String acaoId,
    required String evidenciaId,
  });
}
