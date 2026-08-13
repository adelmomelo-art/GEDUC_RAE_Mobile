import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/acao_model.dart';
import 'package:geduc_rae_mobile/modules/dashboard/services/dashboard_cio_bridge.dart';
import 'package:geduc_rae_mobile/modules/dashboard/models/cio_dashboard_filters.dart';

void main() {
  const bridge = DashboardCIOBridge();

  test('produz inteligência e ranking a partir do mesmo conjunto', () {
    final resultado = bridge.processar([
      _acao('1', 'Regional Norte', pessoas: 100, metaAtingida: true),
      _acao('2', 'Regional Norte', pessoas: 50, metaAtingida: true),
      _acao('3', 'Regional Sul', pessoas: 10, metaAtingida: false),
    ]);

    expect(resultado.indicadores.totalAcoes, 3);
    expect(resultado.metricasOficiais.totalRecords, 3);
    expect(resultado.indicadoresEstrategicos, hasLength(5));
    expect(resultado.rankingRegionais, hasLength(2));
    expect(resultado.rankingRegionais.first.nome, 'Regional Norte');
    expect(resultado.rankingRegionais.first.posicao, 1);
    expect(resultado.rankingRegionais.first.percentualMetasAtingidas, 100);
    expect(resultado.rankingRegionais.last.percentualMetasAtingidas, 0);
    expect(resultado.insights, isNotEmpty);
    expect(resultado.recomendacoes, isNotEmpty);
  });

  test('conjunto vazio gera resultado institucional seguro', () {
    final resultado = bridge.processar(const <AcaoModel>[]);

    expect(resultado.indicadores.totalAcoes, 0);
    expect(resultado.rankingRegionais, isEmpty);
    expect(resultado.indicadoresEstrategicos, hasLength(5));
    expect(resultado.alertas, isNotEmpty);
    expect(resultado.qualidadeDados.totalRecords, 0);
  });

  test('expõe série contínua e qualidade pelo mesmo resultado', () {
    final resultado = bridge.processar(
      [_acao('1', 'Regional Norte', pessoas: 100, metaAtingida: true)],
      intervalo: DateTimeRangeCio(
        DateTime(2026, 8, 11),
        DateTime(2026, 8, 13),
      ),
    );

    expect(resultado.serieHistorica, isNotNull);
    expect(resultado.serieHistorica!.buckets, hasLength(3));
    expect(
      resultado.serieHistorica!.buckets.map((item) => item.actions),
      [0, 1, 0],
    );
    expect(resultado.qualidadeDados.totalRecords, 1);
    expect(resultado.territorios, hasLength(1));
  });
}

AcaoModel _acao(
  String id,
  String regional, {
  required int pessoas,
  required bool metaAtingida,
}) {
  return AcaoModel.fromMap({
    'id': id,
    'dataAcao': '2026-08-12T10:00:00.000',
    'regional': regional,
    'tipoAcao': 'Oficina',
    'status': 'concluido',
    'coordenadorNome': 'Maria',
    'pessoasAlcancadas': pessoas,
    'publicoMinimo': 50,
    'veiculosAbordados': pessoas ~/ 2,
    'credenciaisEmitidas': pessoas ~/ 4,
    'metaAtingida': metaAtingida,
    'agentesTransito': 2,
    'equipeTerceirizada': 1,
    'sincronizado': true,
  });
}
