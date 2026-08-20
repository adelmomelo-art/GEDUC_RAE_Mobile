import 'remote_evidence_models.dart';
import 'remote_evidence_storage.dart';

class DisabledRemoteEvidenceStorage implements RemoteEvidenceStorage {
  const DisabledRemoteEvidenceStorage();

  static const String _message =
      'Armazenamento remoto de evidências não está habilitado.';

  @override
  bool get enabled => false;

  @override
  Future<RemoteEvidenceUploadResult> upload(
    RemoteEvidenceUploadRequest request,
  ) {
    return Future<RemoteEvidenceUploadResult>.error(
      StateError(_message),
    );
  }

  @override
  Future<Uri> createReadUri({
    required String acaoId,
    required String evidenciaId,
  }) {
    return Future<Uri>.error(
      StateError(_message),
    );
  }

  @override
  Future<void> delete({
    required String acaoId,
    required String evidenciaId,
  }) {
    return Future<void>.error(
      StateError(_message),
    );
  }
}
