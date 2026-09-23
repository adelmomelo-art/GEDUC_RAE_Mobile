import '../data/escala_repository.dart';
import '../models/escala_models.dart';
import 'escala_horas_service.dart';

class EscalaSaldoBancoPessoa {
  const EscalaSaldoBancoPessoa({
    required this.chavePessoa,
    required this.usuarioId,
    required this.membroEquipeId,
    required this.nome,
    required this.minutosCredito,
    required this.minutosCompensados,
    required this.creditosPendentes,
    required this.compensacoesPendentes,
  });

  final String chavePessoa;
  final String usuarioId;
  final String membroEquipeId;
  final String nome;
  final int minutosCredito;
  final int minutosCompensados;
  final int creditosPendentes;
  final int compensacoesPendentes;

  int get saldoMinutos => minutosCredito - minutosCompensados;
  bool get saldoNegativo => saldoMinutos < 0;
  bool get possuiPendencia =>
      creditosPendentes > 0 || compensacoesPendentes > 0;
}

class EscalaIndicadoresHistoricosResumo {
  EscalaIndicadoresHistoricosResumo({
    required this.inicio,
    required this.fim,
    required this.diasPublicados,
    required this.totalAlocacoes,
    required this.alocacoesComHorasRealizadas,
    required this.alocacoesSemHorasRealizadas,
    required this.alocacoesHorasInvalidas,
    required this.minutosPlanejados,
    required this.minutosRealizadosNormal,
    required this.minutosRealizadosHoraExtra,
    required this.minutosCreditoBanco,
    required this.minutosCompensadosBanco,
    required this.compensacoesComHoras,
    required this.compensacoesSemHoras,
    required this.compensacoesInvalidas,
    required this.registrosSemIdentidade,
    required Iterable<EscalaSaldoBancoPessoa> pessoas,
  }) : pessoas = List<EscalaSaldoBancoPessoa>.unmodifiable(pessoas);

  final DateTime inicio;
  final DateTime fim;
  final int diasPublicados;
  final int totalAlocacoes;
  final int alocacoesComHorasRealizadas;
  final int alocacoesSemHorasRealizadas;
  final int alocacoesHorasInvalidas;
  final int minutosPlanejados;
  final int minutosRealizadosNormal;
  final int minutosRealizadosHoraExtra;
  final int minutosCreditoBanco;
  final int minutosCompensadosBanco;
  final int compensacoesComHoras;
  final int compensacoesSemHoras;
  final int compensacoesInvalidas;
  final int registrosSemIdentidade;
  final List<EscalaSaldoBancoPessoa> pessoas;

  int get totalMinutosRealizados =>
      minutosRealizadosNormal +
      minutosRealizadosHoraExtra +
      minutosCreditoBanco;

  int get saldoBancoMinutos => minutosCreditoBanco - minutosCompensadosBanco;

  bool get possuiPendencias =>
      alocacoesSemHorasRealizadas > 0 ||
      alocacoesHorasInvalidas > 0 ||
      compensacoesSemHoras > 0 ||
      compensacoesInvalidas > 0 ||
      registrosSemIdentidade > 0;
}

abstract final class EscalaIndicadoresHistoricosService {
  static EscalaIndicadoresHistoricosResumo consolidar({
    required DateTime inicio,
    required DateTime fim,
    required Iterable<EscalaDiaConsulta> dias,
  }) {
    final periodoInicio = _somenteData(inicio);
    final periodoFim = _somenteData(fim);
    if (periodoFim.isBefore(periodoInicio)) {
      throw ArgumentError.value(
        fim,
        'fim',
        'O fim do periodo nao pode ser anterior ao inicio.',
      );
    }

    final datasProcessadas = <String>{};
    final pessoas = <String, _SaldoPessoaAcumulado>{};
    var diasPublicados = 0;
    var totalAlocacoes = 0;
    var alocacoesComHoras = 0;
    var alocacoesSemHoras = 0;
    var alocacoesInvalidas = 0;
    var minutosPlanejados = 0;
    var minutosNormal = 0;
    var minutosHoraExtra = 0;
    var minutosCreditoBanco = 0;
    var minutosCompensados = 0;
    var compensacoesComHoras = 0;
    var compensacoesSemHoras = 0;
    var compensacoesInvalidas = 0;
    var registrosSemIdentidade = 0;

    for (final dia in dias) {
      final data = _somenteData(dia.data);
      if (data.isBefore(periodoInicio) || data.isAfter(periodoFim)) continue;
      if (!dia.publicada) continue;

      final chaveData = _chaveData(data);
      if (!datasProcessadas.add(chaveData)) {
        throw StateError('Existe mais de um registro para o dia $chaveData.');
      }
      diasPublicados++;

      for (final alocacao in dia.alocacoes) {
        totalAlocacoes++;
        minutosPlanejados += EscalaHorasService.minutosProgramados(alocacao);

        if (!EscalaHorasService.horasRealizadasCoerentes(alocacao)) {
          alocacoesInvalidas++;
          if (alocacao.tipoJornada == EscalaCodigos.jornadaBancoHoras) {
            final pessoa = _pessoaDaAlocacao(alocacao, pessoas);
            if (pessoa == null) {
              registrosSemIdentidade++;
            } else {
              pessoa.creditosPendentes++;
            }
          }
          continue;
        }

        if (!EscalaHorasService.possuiHorasRealizadas(alocacao)) {
          alocacoesSemHoras++;
          if (alocacao.tipoJornada == EscalaCodigos.jornadaBancoHoras) {
            final pessoa = _pessoaDaAlocacao(alocacao, pessoas);
            if (pessoa == null) {
              registrosSemIdentidade++;
            } else {
              pessoa.creditosPendentes++;
            }
          }
          continue;
        }

        final minutos = alocacao.minutosRealizados!;
        alocacoesComHoras++;
        switch (alocacao.tipoJornada) {
          case EscalaCodigos.jornadaHoraExtra:
            minutosHoraExtra += minutos;
            break;
          case EscalaCodigos.jornadaBancoHoras:
            final pessoa = _pessoaDaAlocacao(alocacao, pessoas);
            if (pessoa == null) {
              registrosSemIdentidade++;
              break;
            }
            minutosCreditoBanco += minutos;
            pessoa.minutosCredito += minutos;
            break;
          default:
            minutosNormal += minutos;
        }
      }

      for (final indisponibilidade in dia.indisponibilidades) {
        if (indisponibilidade.tipoId.trim().toLowerCase() != 'compensacao') {
          continue;
        }

        final pessoa = _pessoaDaIndisponibilidade(
          indisponibilidade,
          pessoas,
        );
        if (pessoa == null) {
          registrosSemIdentidade++;
          compensacoesInvalidas++;
          continue;
        }

        final inicioCompensacao = indisponibilidade.horaInicio.trim();
        final fimCompensacao = indisponibilidade.horaFim.trim();
        if (inicioCompensacao.isEmpty && fimCompensacao.isEmpty) {
          compensacoesSemHoras++;
          pessoa.compensacoesPendentes++;
          continue;
        }

        final minutos = EscalaHorasService.calcularDuracaoMinutos(
          inicio: inicioCompensacao,
          fim: fimCompensacao,
        );
        if (minutos == null || minutos <= 0 || minutos > 1440) {
          compensacoesInvalidas++;
          pessoa.compensacoesPendentes++;
          continue;
        }

        compensacoesComHoras++;
        minutosCompensados += minutos;
        pessoa.minutosCompensados += minutos;
      }
    }

    final saldos = pessoas.values.map((item) => item.concluir()).toList()
      ..sort((a, b) {
        final porNome = a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        if (porNome != 0) return porNome;
        return a.chavePessoa.compareTo(b.chavePessoa);
      });

    return EscalaIndicadoresHistoricosResumo(
      inicio: periodoInicio,
      fim: periodoFim,
      diasPublicados: diasPublicados,
      totalAlocacoes: totalAlocacoes,
      alocacoesComHorasRealizadas: alocacoesComHoras,
      alocacoesSemHorasRealizadas: alocacoesSemHoras,
      alocacoesHorasInvalidas: alocacoesInvalidas,
      minutosPlanejados: minutosPlanejados,
      minutosRealizadosNormal: minutosNormal,
      minutosRealizadosHoraExtra: minutosHoraExtra,
      minutosCreditoBanco: minutosCreditoBanco,
      minutosCompensadosBanco: minutosCompensados,
      compensacoesComHoras: compensacoesComHoras,
      compensacoesSemHoras: compensacoesSemHoras,
      compensacoesInvalidas: compensacoesInvalidas,
      registrosSemIdentidade: registrosSemIdentidade,
      pessoas: saldos,
    );
  }

  static _SaldoPessoaAcumulado? _pessoaDaAlocacao(
    EscalaAlocacaoModel alocacao,
    Map<String, _SaldoPessoaAcumulado> pessoas,
  ) {
    return _pessoa(
      usuarioId: alocacao.usuarioId,
      membroEquipeId: alocacao.membroEquipeId,
      nome: alocacao.nomeSnapshot,
      pessoas: pessoas,
    );
  }

  static _SaldoPessoaAcumulado? _pessoaDaIndisponibilidade(
    EscalaIndisponibilidadeModel indisponibilidade,
    Map<String, _SaldoPessoaAcumulado> pessoas,
  ) {
    return _pessoa(
      usuarioId: indisponibilidade.usuarioId,
      membroEquipeId: indisponibilidade.membroEquipeId,
      nome: indisponibilidade.nomeSnapshot,
      pessoas: pessoas,
    );
  }

  static _SaldoPessoaAcumulado? _pessoa({
    required String usuarioId,
    required String membroEquipeId,
    required String nome,
    required Map<String, _SaldoPessoaAcumulado> pessoas,
  }) {
    final uid = usuarioId.trim();
    final membroId = membroEquipeId.trim();
    if (uid.isEmpty && membroId.isEmpty) return null;

    final encontrados = pessoas.values
        .where(
          (item) =>
              (uid.isNotEmpty && item.usuarioId == uid) ||
              (membroId.isNotEmpty && item.membroEquipeId == membroId),
        )
        .toSet()
        .toList();

    if (encontrados.isNotEmpty) {
      final existente = encontrados.first;
      for (final duplicado in encontrados.skip(1)) {
        existente.incorporar(duplicado);
        pessoas.removeWhere((_, item) => identical(item, duplicado));
      }
      existente.atualizarIdentidade(
        usuarioId: uid,
        membroEquipeId: membroId,
        nome: nome,
      );
      return existente;
    }

    final chave = uid.isNotEmpty ? 'uid:$uid' : 'membro:$membroId';
    final criado = _SaldoPessoaAcumulado(
      usuarioId: uid,
      membroEquipeId: membroId,
      nome: nome.trim(),
    );
    pessoas[chave] = criado;
    return criado;
  }

  static DateTime _somenteData(DateTime data) =>
      DateTime(data.year, data.month, data.day);

  static String _chaveData(DateTime data) =>
      '${data.year.toString().padLeft(4, '0')}-'
      '${data.month.toString().padLeft(2, '0')}-'
      '${data.day.toString().padLeft(2, '0')}';
}

class _SaldoPessoaAcumulado {
  _SaldoPessoaAcumulado({
    required this.usuarioId,
    required this.membroEquipeId,
    required this.nome,
  });

  String usuarioId;
  String membroEquipeId;
  String nome;
  int minutosCredito = 0;
  int minutosCompensados = 0;
  int creditosPendentes = 0;
  int compensacoesPendentes = 0;

  void atualizarIdentidade({
    required String usuarioId,
    required String membroEquipeId,
    required String nome,
  }) {
    if (this.usuarioId.isEmpty && usuarioId.isNotEmpty) {
      this.usuarioId = usuarioId;
    }
    if (this.membroEquipeId.isEmpty && membroEquipeId.isNotEmpty) {
      this.membroEquipeId = membroEquipeId;
    }
    if (this.nome.isEmpty && nome.trim().isNotEmpty) {
      this.nome = nome.trim();
    }
  }

  void incorporar(_SaldoPessoaAcumulado outro) {
    atualizarIdentidade(
      usuarioId: outro.usuarioId,
      membroEquipeId: outro.membroEquipeId,
      nome: outro.nome,
    );
    minutosCredito += outro.minutosCredito;
    minutosCompensados += outro.minutosCompensados;
    creditosPendentes += outro.creditosPendentes;
    compensacoesPendentes += outro.compensacoesPendentes;
  }

  EscalaSaldoBancoPessoa concluir() {
    final chavePessoa =
        usuarioId.isNotEmpty ? 'uid:$usuarioId' : 'membro:$membroEquipeId';
    return EscalaSaldoBancoPessoa(
      chavePessoa: chavePessoa,
      usuarioId: usuarioId,
      membroEquipeId: membroEquipeId,
      nome: nome.isEmpty ? 'Nao informado' : nome,
      minutosCredito: minutosCredito,
      minutosCompensados: minutosCompensados,
      creditosPendentes: creditosPendentes,
      compensacoesPendentes: compensacoesPendentes,
    );
  }
}
