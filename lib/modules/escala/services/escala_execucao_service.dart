import '../models/escala_models.dart';

class EscalaExecucaoValidacao {
  const EscalaExecucaoValidacao(this.erros);

  final List<String> erros;

  bool get valida => erros.isEmpty;
}

abstract final class EscalaExecucaoService {
  static const Set<String> tiposEvidencia = <String>{
    EscalaCodigos.evidenciaFoto,
    EscalaCodigos.evidenciaDocumento,
    EscalaCodigos.evidenciaArquivo,
    EscalaCodigos.evidenciaLink,
    EscalaCodigos.evidenciaObservacao,
    EscalaCodigos.evidenciaOutro,
  };

  static const Set<String> statusExecucao = <String>{
    EscalaCodigos.execucaoEmExecucao,
    EscalaCodigos.execucaoConcluida,
    EscalaCodigos.execucaoCancelada,
  };

  static bool transicaoStatusValida({
    required String statusAtual,
    required String proximoStatus,
  }) {
    if (!statusExecucao.contains(statusAtual) ||
        !statusExecucao.contains(proximoStatus)) {
      return false;
    }

    if (statusAtual == EscalaCodigos.execucaoEmExecucao) {
      return true;
    }

    return false;
  }

  static bool evidenciaValida(
    MissaoEvidenciaModel evidencia, {
    required String executorUsuarioId,
  }) {
    final uid = executorUsuarioId.trim();

    return evidencia.id.trim().isNotEmpty &&
        tiposEvidencia.contains(evidencia.tipo.trim()) &&
        (evidencia.descricao.trim().isNotEmpty ||
            evidencia.referencia.trim().isNotEmpty) &&
        uid.isNotEmpty &&
        evidencia.criadoPor.trim() == uid;
  }

  static EscalaExecucaoValidacao validar(ExecucaoMissaoModel execucao) {
    final erros = <String>[];
    final executorUid = execucao.executadoPorUsuarioId.trim();

    if (execucao.escalaAtividadeId.trim().isEmpty) {
      erros.add('Atividade da escala é obrigatória.');
    }
    if (execucao.escalaId.trim().isEmpty) {
      erros.add('Escala é obrigatória.');
    }
    if (!statusExecucao.contains(execucao.status.trim())) {
      erros.add('Status de execução inválido.');
    }
    if (executorUid.isEmpty ||
        execucao.executadoPorMembroEquipeId.trim().isEmpty ||
        execucao.executadoPorNomeSnapshot.trim().isEmpty) {
      erros.add('Executor canônico é obrigatório.');
    }
    if (execucao.evidencias.length > 20) {
      erros.add('A execução aceita no máximo 20 evidências.');
    }
    if (execucao.evidencias.any(
      (item) => !evidenciaValida(
        item,
        executorUsuarioId: executorUid,
      ),
    )) {
      erros.add('Existe evidência inválida ou atribuída a outro executor.');
    }

    if (execucao.status == EscalaCodigos.execucaoConcluida) {
      if (execucao.resultadoResumo.trim().isEmpty) {
        erros.add('Conclusão exige resultado/entrega.');
      }
      if (execucao.concluidoEm == null) {
        erros.add('Conclusão exige data/hora de conclusão.');
      }
    }

    return EscalaExecucaoValidacao(
      List<String>.unmodifiable(erros),
    );
  }
}
