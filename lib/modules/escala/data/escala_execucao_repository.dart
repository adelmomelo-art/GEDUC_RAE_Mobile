import '../../../data/models/membro_equipe_model.dart';
import '../models/escala_models.dart';

class EscalaExecucaoContexto {
  const EscalaExecucaoContexto({
    required this.atividade,
    required this.escala,
    required this.equipe,
    required this.executor,
    required this.execucao,
  });

  final EscalaAtividadeModel atividade;
  final EscalaModel escala;
  final List<EscalaAlocacaoModel> equipe;
  final MembroEquipeModel executor;
  final ExecucaoMissaoModel? execucao;

  bool get escalaPublicada => escala.status == EscalaCodigos.statusPublicada;

  bool get atividadeAdministrativa =>
      atividade.naturezaAtividade == EscalaCodigos.naturezaAdministrativa &&
      atividade.geraRae == false;

  bool participante(String usuarioId) =>
      atividade.participanteUsuarioIds.contains(usuarioId.trim());

  bool coordenador(String usuarioId) =>
      atividade.coordenadorUsuarioId.trim() == usuarioId.trim();

  bool elegivelParaExecucao(String usuarioId) {
    final uid = usuarioId.trim();
    return uid.isNotEmpty &&
        executor.ativo &&
        executor.usuarioId.trim() == uid &&
        escalaPublicada &&
        atividadeAdministrativa &&
        (participante(uid) || coordenador(uid));
  }

  EscalaExecucaoContexto comExecucao(ExecucaoMissaoModel valor) {
    return EscalaExecucaoContexto(
      atividade: atividade,
      escala: escala,
      equipe: equipe,
      executor: executor,
      execucao: valor,
    );
  }
}

abstract class EscalaExecucaoRepository {
  String idExecucao({
    required String atividadeId,
    required String usuarioId,
  });

  Future<EscalaExecucaoContexto> carregarContexto({
    required String atividadeId,
    required String usuarioId,
  });

  Future<ExecucaoMissaoModel> iniciarExecucao(
    ExecucaoMissaoModel execucao,
  );

  Future<void> atualizarExecucao(
    ExecucaoMissaoModel execucao,
  );
}
