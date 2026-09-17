import '../models/escala_models.dart';

class EscalaDiaConsulta {
  const EscalaDiaConsulta({
    required this.data,
    required this.escala,
    required this.atividades,
    required this.alocacoes,
    required this.indisponibilidades,
  });

  final DateTime data;
  final EscalaModel? escala;
  final List<EscalaAtividadeModel> atividades;
  final List<EscalaAlocacaoModel> alocacoes;
  final List<EscalaIndisponibilidadeModel> indisponibilidades;

  bool get encontrada => escala != null;
  bool get publicada => escala?.status == EscalaCodigos.statusPublicada;

  factory EscalaDiaConsulta.vazia(DateTime data) {
    final dia = DateTime(data.year, data.month, data.day);
    return EscalaDiaConsulta(
      data: dia,
      escala: null,
      atividades: const <EscalaAtividadeModel>[],
      alocacoes: const <EscalaAlocacaoModel>[],
      indisponibilidades: const <EscalaIndisponibilidadeModel>[],
    );
  }
}

abstract class EscalaRepository {
  Future<EscalaDiaConsulta> carregarDia(DateTime data);
}
