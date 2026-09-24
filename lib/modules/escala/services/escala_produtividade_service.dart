import 'escala_indicadores_historicos_service.dart';

enum EscalaFaixaAderencia {
  semBase,
  abaixoDoPlanejado,
  compativelComPlanejado,
  acimaDoPlanejado,
}

class EscalaProdutividadeResumo {
  const EscalaProdutividadeResumo({
    required this.totalRegistros,
    required this.registrosConcluidos,
    required this.registrosPendentes,
    required this.coberturaRegistroPercentual,
    required this.aderenciaPercentual,
    required this.faixaAderencia,
    required this.orientacaoFaixita,
  });

  final int totalRegistros;
  final int registrosConcluidos;
  final int registrosPendentes;
  final int? coberturaRegistroPercentual;
  final int? aderenciaPercentual;
  final EscalaFaixaAderencia faixaAderencia;
  final String orientacaoFaixita;

  bool get possuiBase => totalRegistros > 0;
  bool get possuiPendencias => registrosPendentes > 0;
}

/// Leitura descritiva da execução da escala.
///
/// Não produz nota, ranking ou avaliação individual. Horas extras e saldo de
/// banco não representam produtividade; permanecem indicadores operacionais.
abstract final class EscalaProdutividadeService {
  static EscalaProdutividadeResumo analisar(
    EscalaIndicadoresHistoricosResumo historico,
  ) {
    final total = historico.totalAlocacoes;
    final concluidos = historico.alocacoesComHorasRealizadas;
    final pendentes = historico.alocacoesSemHorasRealizadas +
        historico.alocacoesHorasInvalidas;
    final cobertura = total == 0 ? null : _percentual(concluidos, total);

    final planejados = historico.minutosPlanejados;
    final realizados = historico.totalMinutosRealizados;
    final aderencia = planejados <= 0
        ? null
        : _percentual(realizados, planejados, limitarEmCem: false);
    final faixa = _faixa(aderencia);

    return EscalaProdutividadeResumo(
      totalRegistros: total,
      registrosConcluidos: concluidos,
      registrosPendentes: pendentes,
      coberturaRegistroPercentual: cobertura,
      aderenciaPercentual: aderencia,
      faixaAderencia: faixa,
      orientacaoFaixita: _orientacao(
        total: total,
        pendentes: pendentes,
        cobertura: cobertura,
        aderencia: aderencia,
        faixa: faixa,
      ),
    );
  }

  static int _percentual(int parte, int total, {bool limitarEmCem = true}) {
    final valor = (parte * 100 / total).round();
    return limitarEmCem ? valor.clamp(0, 100).toInt() : valor;
  }

  static EscalaFaixaAderencia _faixa(int? percentual) {
    if (percentual == null) return EscalaFaixaAderencia.semBase;
    if (percentual < 90) return EscalaFaixaAderencia.abaixoDoPlanejado;
    if (percentual <= 110) {
      return EscalaFaixaAderencia.compativelComPlanejado;
    }
    return EscalaFaixaAderencia.acimaDoPlanejado;
  }

  static String _orientacao({
    required int total,
    required int pendentes,
    required int? cobertura,
    required int? aderencia,
    required EscalaFaixaAderencia faixa,
  }) {
    if (total == 0) {
      return 'Não há alocações publicadas no período para analisar.';
    }
    if (pendentes > 0) {
      return 'Há $pendentes registro(s) de horas pendente(s). '
          'Complete ou corrija os dados antes de interpretar a aderência.';
    }
    if (aderencia == null) {
      return 'Os registros estão completos, mas não há horas planejadas '
          'válidas para calcular a aderência.';
    }

    final coberturaTexto = cobertura == null ? '' : 'Cobertura $cobertura%. ';
    return switch (faixa) {
      EscalaFaixaAderencia.abaixoDoPlanejado =>
        '${coberturaTexto}As horas realizadas ficaram abaixo do intervalo '
            'planejado. Confira o contexto operacional e os registros.',
      EscalaFaixaAderencia.compativelComPlanejado =>
        '${coberturaTexto}As horas realizadas estão compatíveis com o '
            'planejamento do período.',
      EscalaFaixaAderencia.acimaDoPlanejado =>
        '${coberturaTexto}As horas realizadas ficaram acima do intervalo '
            'planejado. Confira horas extras e banco de horas.',
      EscalaFaixaAderencia.semBase =>
        'Não há base suficiente para interpretar a aderência.',
    };
  }
}
