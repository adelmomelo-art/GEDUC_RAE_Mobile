import '../models/escala_models.dart';
import 'escala_repository.dart';

abstract final class EscalaPeriodoBuilder {
  static EscalaPeriodoConsulta montar({
    required DateTime inicio,
    required DateTime fim,
    required Iterable<EscalaModel> escalas,
    required Iterable<EscalaAtividadeModel> atividades,
    required Iterable<EscalaAlocacaoModel> alocacoes,
    required Iterable<EscalaIndisponibilidadeModel> indisponibilidades,
  }) {
    final dataInicio = EscalaPeriodoConsulta.somenteData(inicio);
    final dataFim = EscalaPeriodoConsulta.somenteData(fim);
    EscalaPeriodoConsulta.validarPeriodo(inicio: dataInicio, fim: dataFim);

    final escalaPorData = <String, EscalaModel>{};
    for (final escala in escalas) {
      final data = EscalaPeriodoConsulta.somenteData(escala.data);
      if (data.isBefore(dataInicio) || data.isAfter(dataFim)) continue;
      if (escala.status != EscalaCodigos.statusPublicada) continue;

      final chave = _chaveData(data);
      final atual = escalaPorData[chave];
      if (atual == null || _compararPrioridade(escala, atual) < 0) {
        escalaPorData[chave] = escala;
      }
    }

    final atividadesPorEscala = <String, List<EscalaAtividadeModel>>{};
    for (final atividade in atividades) {
      atividadesPorEscala
          .putIfAbsent(atividade.escalaId, () => <EscalaAtividadeModel>[])
          .add(atividade);
    }

    final alocacoesPorEscala = <String, List<EscalaAlocacaoModel>>{};
    for (final alocacao in alocacoes) {
      alocacoesPorEscala
          .putIfAbsent(alocacao.escalaId, () => <EscalaAlocacaoModel>[])
          .add(alocacao);
    }

    final escalasSelecionadas = escalaPorData.values.toList()
      ..sort((a, b) => a.data.compareTo(b.data));
    final dias = <EscalaDiaConsulta>[];

    for (final escala in escalasSelecionadas) {
      final data = EscalaPeriodoConsulta.somenteData(escala.data);
      final atividadesDoDia = (atividadesPorEscala[escala.id] ??
              const <EscalaAtividadeModel>[])
          .where((item) => _mesmoDia(item.data, data))
          .toList()
        ..sort(_compararAtividades);
      final alocacoesDoDia = (alocacoesPorEscala[escala.id] ??
              const <EscalaAlocacaoModel>[])
          .where((item) => _mesmoDia(item.data, data))
          .toList()
        ..sort(_compararAlocacoes);
      final indisponibilidadesDoDia = indisponibilidades
          .where((item) => _abrangeDia(item, data))
          .toList()
        ..sort(_compararIndisponibilidades);

      dias.add(
        EscalaDiaConsulta(
          data: data,
          escala: escala,
          atividades: List<EscalaAtividadeModel>.unmodifiable(atividadesDoDia),
          alocacoes: List<EscalaAlocacaoModel>.unmodifiable(alocacoesDoDia),
          indisponibilidades: List<EscalaIndisponibilidadeModel>.unmodifiable(
            indisponibilidadesDoDia,
          ),
        ),
      );
    }

    return EscalaPeriodoConsulta(inicio: dataInicio, fim: dataFim, dias: dias);
  }

  static int _compararPrioridade(EscalaModel a, EscalaModel b) {
    final porVersao = b.versao.compareTo(a.versao);
    if (porVersao != 0) return porVersao;
    return a.id.compareTo(b.id);
  }

  static int _compararAtividades(
    EscalaAtividadeModel a,
    EscalaAtividadeModel b,
  ) {
    final secao = a.secaoId.compareTo(b.secaoId);
    if (secao != 0) return secao;

    final horarioA = a.horaInicio.trim().isNotEmpty
        ? a.horaInicio.trim()
        : a.qtrHorario.trim();
    final horarioB = b.horaInicio.trim().isNotEmpty
        ? b.horaInicio.trim()
        : b.qtrHorario.trim();
    final horario = horarioA.compareTo(horarioB);
    if (horario != 0) return horario;

    final titulo = a.titulo.compareTo(b.titulo);
    if (titulo != 0) return titulo;
    return a.id.compareTo(b.id);
  }

  static int _compararAlocacoes(EscalaAlocacaoModel a, EscalaAlocacaoModel b) {
    final atividade = a.atividadeId.compareTo(b.atividadeId);
    if (atividade != 0) return atividade;
    final nome = a.nomeSnapshot.compareTo(b.nomeSnapshot);
    if (nome != 0) return nome;
    return a.id.compareTo(b.id);
  }

  static int _compararIndisponibilidades(
    EscalaIndisponibilidadeModel a,
    EscalaIndisponibilidadeModel b,
  ) {
    final nome = a.nomeSnapshot.compareTo(b.nomeSnapshot);
    if (nome != 0) return nome;
    return a.id.compareTo(b.id);
  }

  static bool _abrangeDia(EscalaIndisponibilidadeModel item, DateTime data) {
    final dia = EscalaPeriodoConsulta.somenteData(data);
    final inicio = EscalaPeriodoConsulta.somenteData(item.dataInicio);
    final fim = EscalaPeriodoConsulta.somenteData(item.dataFim);
    if (fim.isBefore(inicio)) return false;
    return !dia.isBefore(inicio) && !dia.isAfter(fim);
  }

  static bool _mesmoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _chaveData(DateTime data) =>
      '${data.year.toString().padLeft(4, '0')}-'
      '${data.month.toString().padLeft(2, '0')}-'
      '${data.day.toString().padLeft(2, '0')}';
}
