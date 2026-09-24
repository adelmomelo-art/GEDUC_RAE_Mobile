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

class EscalaPeriodoConsulta {
  EscalaPeriodoConsulta({
    required DateTime inicio,
    required DateTime fim,
    required Iterable<EscalaDiaConsulta> dias,
  })  : inicio = somenteData(inicio),
        fim = somenteData(fim),
        dias = List<EscalaDiaConsulta>.unmodifiable(dias) {
    validarPeriodo(inicio: this.inicio, fim: this.fim);
  }

  static const int maximoDias = 366;

  final DateTime inicio;
  final DateTime fim;
  final List<EscalaDiaConsulta> dias;

  bool get vazio => dias.isEmpty;

  static void validarPeriodo({
    required DateTime inicio,
    required DateTime fim,
  }) {
    final dataInicio = somenteData(inicio);
    final dataFim = somenteData(fim);
    if (dataFim.isBefore(dataInicio)) {
      throw ArgumentError.value(
        fim,
        'fim',
        'O fim do período não pode ser anterior ao início.',
      );
    }

    final quantidadeDias = dataFim.difference(dataInicio).inDays + 1;
    if (quantidadeDias > maximoDias) {
      throw ArgumentError.value(
        quantidadeDias,
        'periodo',
        'A consulta histórica aceita no máximo $maximoDias dias.',
      );
    }
  }

  static DateTime somenteData(DateTime data) =>
      DateTime(data.year, data.month, data.day);
}

abstract class EscalaRepository {
  Future<EscalaDiaConsulta> carregarDia(DateTime data);

  Future<EscalaPeriodoConsulta> carregarPeriodo({
    required DateTime inicio,
    required DateTime fim,
  });

  Future<void> salvarHorasRealizadas({
    required String alocacaoId,
    required String usuarioId,
    required String horaInicioReal,
    required String horaFimReal,
    required int minutosRealizados,
    required String observacao,
    required DateTime atualizadoEm,
  });
}
