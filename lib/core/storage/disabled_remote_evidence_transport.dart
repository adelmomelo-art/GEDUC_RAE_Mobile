import 'evidence_access_models.dart';
import 'remote_evidence_models.dart';
import 'remote_evidence_transport.dart';

class DisabledRemoteEvidenceTransport implements RemoteEvidenceTransport {
  const DisabledRemoteEvidenceTransport();

  static const String _message =
      'Transporte remoto de evidencias nao esta habilitado.';

  @override
  bool get enabled => false;

  @override
  Future<RemoteEvidenceUploadResult> upload({
    required EvidenceAccessGrant grant,
    required RemoteEvidenceUploadRequest request,
  }) {
    return Future<RemoteEvidenceUploadResult>.error(
      StateError(_message),
    );
  }
}
