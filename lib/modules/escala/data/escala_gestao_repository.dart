import '../../../data/models/membro_equipe_model.dart';
import '../models/escala_models.dart';
import 'escala_repository.dart';

class EscalaGestaoDados {
  const EscalaGestaoDados({
    required this.dia,
    required this.configuracao,
    required this.membrosEquipe,
    required this.perfisOperacionais,
  });

  final EscalaDiaConsulta dia;
  final EscalaConfiguracaoModel? configuracao;
  final List<MembroEquipeModel> membrosEquipe;
  final List<EscalaPerfilOperacionalModel> perfisOperacionais;
}

class EscalaAtividadePersistencia {
  const EscalaAtividadePersistencia({
    required this.atividade,
    required this.alocacoes,
    required this.removerAlocacaoIds,
  });

  final EscalaAtividadeModel atividade;
  final List<EscalaAlocacaoModel> alocacoes;
  final Set<String> removerAlocacaoIds;
}

abstract class EscalaGestaoRepository {
  Future<EscalaConfiguracaoModel?> carregarConfiguracao();
  Future<EscalaGestaoDados> carregarGestao(DateTime data);
  Future<void> criarRascunho(EscalaModel escala);
  Future<void> salvarAtividadeComEquipe(
    EscalaAtividadePersistencia persistencia,
  );
  String novoIdAtividade();
  String novoIdAlocacao();
}
