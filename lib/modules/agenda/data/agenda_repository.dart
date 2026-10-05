import '../../../data/models/projeto_model.dart';
import '../../../data/models/regional_model.dart';
import '../../escala/models/escala_models.dart';
import '../models/agenda_compromisso.dart';

class AgendaMes {
  const AgendaMes({
    required this.compromissos,
    required this.escalas,
    required this.atividades,
  });
  final List<AgendaCompromisso> compromissos;
  final Map<String, EscalaModel> escalas;
  final Map<String, EscalaAtividadeModel> atividades;
}

abstract class AgendaRepository {
  Future<EscalaConfiguracaoModel?> configuracao();
  Future<AgendaMes> carregarMes(DateTime mes);
  Future<List<ProjetoModel>> projetos();
  Future<List<RegionalModel>> regionais();
  String novoId();
  Future<void> salvar(
    AgendaCompromisso item, {
    required int revisaoEsperada,
    required String usuarioId,
  });
  Future<void> cancelar(
    AgendaCompromisso item, {
    required String motivo,
    required String usuarioId,
  });
  Future<void> montarEscala(
    AgendaCompromisso item, {
    required String usuarioId,
  });
  Future<List<AgendaHistorico>> historico(String id);
}
