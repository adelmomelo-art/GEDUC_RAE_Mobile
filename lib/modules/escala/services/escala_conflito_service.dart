import '../models/escala_models.dart';
import 'escala_horas_service.dart';

class EscalaConflitoHorario {
  const EscalaConflitoHorario({
    required this.chavePessoa,
    required this.nome,
    required this.primeiraAlocacaoId,
    required this.segundaAlocacaoId,
    required this.data,
  });

  final String chavePessoa;
  final String nome;
  final String primeiraAlocacaoId;
  final String segundaAlocacaoId;
  final DateTime data;
}

class EscalaMultiplaAlocacao {
  const EscalaMultiplaAlocacao({
    required this.chavePessoa,
    required this.nome,
    required this.quantidadeAlocacoes,
  });

  final String chavePessoa;
  final String nome;
  final int quantidadeAlocacoes;
}

abstract final class EscalaConflitoService {
  static List<EscalaConflitoHorario> detectarSobreposicoes(
    Iterable<EscalaAlocacaoModel> alocacoes,
  ) {
    final grupos = <String, List<EscalaAlocacaoModel>>{};

    for (final alocacao in alocacoes) {
      final chave = _chaveDia(alocacao);
      grupos.putIfAbsent(chave, () => <EscalaAlocacaoModel>[]).add(alocacao);
    }

    final conflitos = <EscalaConflitoHorario>[];

    for (final grupo in grupos.values) {
      for (var i = 0; i < grupo.length; i++) {
        for (var j = i + 1; j < grupo.length; j++) {
          final primeira = grupo[i];
          final segunda = grupo[j];

          if (!_intervalosSobrepostos(primeira, segunda)) continue;

          conflitos.add(
            EscalaConflitoHorario(
              chavePessoa: EscalaHorasService.chavePessoa(primeira),
              nome: primeira.nomeSnapshot.trim().isNotEmpty
                  ? primeira.nomeSnapshot.trim()
                  : segunda.nomeSnapshot.trim(),
              primeiraAlocacaoId: primeira.id,
              segundaAlocacaoId: segunda.id,
              data: _somenteData(primeira.data),
            ),
          );
        }
      }
    }

    return List<EscalaConflitoHorario>.unmodifiable(conflitos);
  }

  static List<EscalaMultiplaAlocacao> detectarMultiplasAlocacoes(
    Iterable<EscalaAlocacaoModel> alocacoes,
  ) {
    final grupos = <String, List<EscalaAlocacaoModel>>{};

    for (final alocacao in alocacoes) {
      grupos
          .putIfAbsent(_chaveDia(alocacao), () => <EscalaAlocacaoModel>[])
          .add(alocacao);
    }

    final resultado = <EscalaMultiplaAlocacao>[];

    for (final grupo in grupos.values) {
      if (grupo.length < 2) continue;
      final primeira = grupo.first;
      resultado.add(
        EscalaMultiplaAlocacao(
          chavePessoa: EscalaHorasService.chavePessoa(primeira),
          nome: primeira.nomeSnapshot.trim(),
          quantidadeAlocacoes: grupo.length,
        ),
      );
    }

    resultado.sort((a, b) => a.nome.compareTo(b.nome));
    return List<EscalaMultiplaAlocacao>.unmodifiable(resultado);
  }

  static bool possuiOutraAlocacaoNoDia({
    required EscalaAlocacaoModel candidata,
    required Iterable<EscalaAlocacaoModel> existentes,
  }) {
    final chavePessoa = EscalaHorasService.chavePessoa(candidata);
    final data = _somenteData(candidata.data);

    return existentes.any((item) {
      if (item.id == candidata.id) return false;
      if (EscalaHorasService.chavePessoa(item) != chavePessoa) return false;
      return _somenteData(item.data) == data;
    });
  }

  static String _chaveDia(EscalaAlocacaoModel alocacao) {
    final data = _somenteData(alocacao.data);
    return '${EscalaHorasService.chavePessoa(alocacao)}|'
        '${data.year.toString().padLeft(4, '0')}-'
        '${data.month.toString().padLeft(2, '0')}-'
        '${data.day.toString().padLeft(2, '0')}';
  }

  static DateTime _somenteData(DateTime data) =>
      DateTime(data.year, data.month, data.day);

  static bool _intervalosSobrepostos(
    EscalaAlocacaoModel primeira,
    EscalaAlocacaoModel segunda,
  ) {
    final aInicio = EscalaHorasService.horarioParaMinutos(primeira.horaInicio);
    final aFimBase = EscalaHorasService.horarioParaMinutos(primeira.horaFim);
    final bInicio = EscalaHorasService.horarioParaMinutos(segunda.horaInicio);
    final bFimBase = EscalaHorasService.horarioParaMinutos(segunda.horaFim);

    if (aInicio == null ||
        aFimBase == null ||
        bInicio == null ||
        bFimBase == null) {
      return false;
    }

    var aFim = aFimBase;
    var bFim = bFimBase;

    if (aFim < aInicio) aFim += 1440;
    if (bFim < bInicio) bFim += 1440;

    bool cruza(int inicioA, int fimA, int inicioB, int fimB) {
      if (fimA <= inicioA || fimB <= inicioB) return false;
      return inicioA < fimB && inicioB < fimA;
    }

    if (cruza(aInicio, aFim, bInicio, bFim)) return true;

    if (aFim > 1440 && cruza(aInicio, aFim, bInicio + 1440, bFim + 1440)) {
      return true;
    }

    if (bFim > 1440 && cruza(aInicio + 1440, aFim + 1440, bInicio, bFim)) {
      return true;
    }

    return false;
  }
}
