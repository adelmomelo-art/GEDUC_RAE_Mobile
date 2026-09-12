import '../storage/evidence_access_broker.dart';
import '../storage/evidence_access_models.dart';
import 'evidence_sync_job.dart';
import 'evidence_sync_orchestrator.dart';

class EvidenceSyncGrantPreparation {
  const EvidenceSyncGrantPreparation({
    required this.job,
    required this.grant,
  });

  final EvidenceSyncJob job;
  final EvidenceAccessGrant grant;
}

class EvidenceSyncGrantCoordinator {
  EvidenceSyncGrantCoordinator({
    required EvidenceSyncOrchestrator orchestrator,
    required EvidenceAccessBroker broker,
    DateTime Function()? clock,
  })  : _orchestrator = orchestrator,
        _broker = broker,
        _clock = clock ?? DateTime.now;

  final EvidenceSyncOrchestrator _orchestrator;
  final EvidenceAccessBroker _broker;
  final DateTime Function() _clock;

  Future<EvidenceSyncGrantPreparation?> prepararProximaTentativa() async {
    final job = await _orchestrator.proximoCandidato();
    if (job == null) {
      return null;
    }

    if (!_broker.enabled) {
      throw StateError('Broker de acesso remoto a evidencias esta desabilitado.');
    }

    if (!job.valido) {
      throw StateError(
        'Candidato de sincronizacao invalido antes da solicitacao de grant.',
      );
    }

    final request = EvidenceUploadAccessRequest(
      acaoId: job.acaoId,
      evidenciaId: job.evidenciaId,
      autorUserId: job.autorUserId,
      contentType: job.contentType,
      tamanhoBytes: job.tamanhoBytes,
      sha256: job.sha256,
    );

    if (!request.valido) {
      throw StateError(
        'Snapshot da evidencia nao produz requisicao de upload valida.',
      );
    }

    final grant = await _broker.requestUploadAccess(request);
    final agora = _clock().toUtc();

    if (!grant.validoUploadPara(
      identity: request.identity,
      instante: agora,
    )) {
      throw StateError(
        'Broker retornou grant sem binding valido para o snapshot solicitado.',
      );
    }

    return EvidenceSyncGrantPreparation(job: job, grant: grant);
  }
}
