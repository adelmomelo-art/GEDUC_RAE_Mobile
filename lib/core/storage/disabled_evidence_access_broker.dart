import 'evidence_access_broker.dart';
import 'evidence_access_models.dart';

class DisabledEvidenceAccessBroker implements EvidenceAccessBroker {
  const DisabledEvidenceAccessBroker();

  static const String _message =
      'Autorizacao de acesso remoto a evidencias nao esta habilitada.';

  @override
  bool get enabled => false;

  @override
  Future<EvidenceAccessGrant> requestReadAccess(
    EvidenceReadAccessRequest request,
  ) {
    return Future<EvidenceAccessGrant>.error(StateError(_message));
  }

  @override
  Future<EvidenceAccessGrant> requestUploadAccess(
    EvidenceUploadAccessRequest request,
  ) {
    return Future<EvidenceAccessGrant>.error(StateError(_message));
  }
}
