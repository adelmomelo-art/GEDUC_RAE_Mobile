import '../models/escala_models.dart';

class EscalaHorasResumo {
  const EscalaHorasResumo({
    required this.totalMinutosProgramados,
    required this.minutosNormal,
    required this.minutosHoraExtra,
    required this.minutosBancoHoras,
    required this.totalAlocacoes,
    required this.totalAgentesUnicos,
    required this.agentesNormal,
    required this.agentesHoraExtra,
    required this.agentesBancoHoras,
  });

  final int totalMinutosProgramados;
  final int minutosNormal;
  final int minutosHoraExtra;
  final int minutosBancoHoras;
  final int totalAlocacoes;
  final int totalAgentesUnicos;
  final int agentesNormal;
  final int agentesHoraExtra;
  final int agentesBancoHoras;

  bool get possuiJornadaComplementar =>
      minutosHoraExtra > 0 || minutosBancoHoras > 0;
}

abstract final class EscalaHorasService {
  static final RegExp _horarioValido = RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$');

  static int? horarioParaMinutos(String valor) {
    final horario = valor.trim();
    if (!_horarioValido.hasMatch(horario)) return null;

    final partes = horario.split(':');
    final horas = int.parse(partes[0]);
    final minutos = int.parse(partes[1]);
    return (horas * 60) + minutos;
  }

  static int? calcularDuracaoMinutos({
    required String inicio,
    required String fim,
  }) {
    final inicioMinutos = horarioParaMinutos(inicio);
    final fimMinutosBase = horarioParaMinutos(fim);
    if (inicioMinutos == null || fimMinutosBase == null) return null;

    var fimMinutos = fimMinutosBase;
    if (fimMinutos < inicioMinutos) {
      fimMinutos += 24 * 60;
    }

    return fimMinutos - inicioMinutos;
  }

  static int minutosProgramados(EscalaAlocacaoModel alocacao) {
    final calculado = calcularDuracaoMinutos(
      inicio: alocacao.horaInicio,
      fim: alocacao.horaFim,
    );
    if (calculado != null) return calculado;

    final persistido = alocacao.minutosPrevistos;
    if (persistido < 0 || persistido > 1440) return 0;
    return persistido;
  }

  static bool minutosPrevistosCoerentes(EscalaAlocacaoModel alocacao) {
    final calculado = calcularDuracaoMinutos(
      inicio: alocacao.horaInicio,
      fim: alocacao.horaFim,
    );
    if (calculado == null) {
      return alocacao.minutosPrevistos >= 0 &&
          alocacao.minutosPrevistos <= 1440;
    }
    return calculado == alocacao.minutosPrevistos;
  }

  static String chavePessoa(EscalaAlocacaoModel alocacao) {
    final uid = alocacao.usuarioId.trim();
    if (uid.isNotEmpty) return 'uid:$uid';

    final membroId = alocacao.membroEquipeId.trim();
    if (membroId.isNotEmpty) return 'membro:$membroId';

    return 'alocacao:${alocacao.id}';
  }

  static EscalaHorasResumo resumir(Iterable<EscalaAlocacaoModel> alocacoes) {
    var normal = 0;
    var extra = 0;
    var banco = 0;
    var total = 0;
    var quantidade = 0;

    final agentes = <String>{};
    final agentesNormal = <String>{};
    final agentesExtra = <String>{};
    final agentesBanco = <String>{};

    for (final alocacao in alocacoes) {
      final minutos = minutosProgramados(alocacao);
      final chave = chavePessoa(alocacao);

      quantidade++;
      total += minutos;
      agentes.add(chave);

      switch (alocacao.tipoJornada) {
        case EscalaCodigos.jornadaHoraExtra:
          extra += minutos;
          agentesExtra.add(chave);
          break;
        case EscalaCodigos.jornadaBancoHoras:
          banco += minutos;
          agentesBanco.add(chave);
          break;
        default:
          normal += minutos;
          agentesNormal.add(chave);
      }
    }

    return EscalaHorasResumo(
      totalMinutosProgramados: total,
      minutosNormal: normal,
      minutosHoraExtra: extra,
      minutosBancoHoras: banco,
      totalAlocacoes: quantidade,
      totalAgentesUnicos: agentes.length,
      agentesNormal: agentesNormal.length,
      agentesHoraExtra: agentesExtra.length,
      agentesBancoHoras: agentesBanco.length,
    );
  }

  static String formatarMinutos(int valor) {
    final minutos = valor < 0 ? 0 : valor;
    final horas = minutos ~/ 60;
    final resto = minutos % 60;
    if (resto == 0) return '${horas}h';
    return '${horas}h${resto.toString().padLeft(2, '0')}';
  }
}
