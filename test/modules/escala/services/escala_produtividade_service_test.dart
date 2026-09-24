import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/services/escala_indicadores_historicos_service.dart';
import 'package:geduc_rae_mobile/modules/escala/services/escala_produtividade_service.dart';

void main() {
  group('EscalaProdutividadeService ESC-001H.4', () {
    test('mede cobertura e aderência sem criar nota ou ranking', () {
      final resultado = EscalaProdutividadeService.analisar(
        _historico(total: 4, concluidos: 4, planejados: 240, realizados: 240),
      );

      expect(resultado.coberturaRegistroPercentual, 100);
      expect(resultado.aderenciaPercentual, 100);
      expect(
        resultado.faixaAderencia,
        EscalaFaixaAderencia.compativelComPlanejado,
      );
      expect(resultado.orientacaoFaixita, contains('compatíveis'));
    });

    test('pendências impedem interpretação conclusiva pela Faixita', () {
      final resultado = EscalaProdutividadeService.analisar(
        _historico(
          total: 4,
          concluidos: 2,
          semHoras: 1,
          invalidos: 1,
          planejados: 240,
          realizados: 120,
        ),
      );

      expect(resultado.coberturaRegistroPercentual, 50);
      expect(resultado.registrosPendentes, 2);
      expect(resultado.possuiPendencias, isTrue);
      expect(resultado.orientacaoFaixita, contains('antes de interpretar'));
    });

    test(
      'classifica aderência abaixo e acima com faixa neutra de 90 a 110',
      () {
        final abaixo = EscalaProdutividadeService.analisar(
          _historico(total: 1, concluidos: 1, planejados: 100, realizados: 89),
        );
        final limiteInferior = EscalaProdutividadeService.analisar(
          _historico(total: 1, concluidos: 1, planejados: 100, realizados: 90),
        );
        final limiteSuperior = EscalaProdutividadeService.analisar(
          _historico(total: 1, concluidos: 1, planejados: 100, realizados: 110),
        );
        final acima = EscalaProdutividadeService.analisar(
          _historico(total: 1, concluidos: 1, planejados: 100, realizados: 111),
        );

        expect(abaixo.faixaAderencia, EscalaFaixaAderencia.abaixoDoPlanejado);
        expect(
          limiteInferior.faixaAderencia,
          EscalaFaixaAderencia.compativelComPlanejado,
        );
        expect(
          limiteSuperior.faixaAderencia,
          EscalaFaixaAderencia.compativelComPlanejado,
        );
        expect(acima.faixaAderencia, EscalaFaixaAderencia.acimaDoPlanejado);
      },
    );

    test('sem alocações ou planejamento permanece sem base', () {
      final vazio = EscalaProdutividadeService.analisar(_historico());
      final semPlanejado = EscalaProdutividadeService.analisar(
        _historico(total: 1, concluidos: 1, realizados: 60),
      );

      expect(vazio.coberturaRegistroPercentual, isNull);
      expect(vazio.aderenciaPercentual, isNull);
      expect(vazio.faixaAderencia, EscalaFaixaAderencia.semBase);
      expect(semPlanejado.aderenciaPercentual, isNull);
      expect(
        semPlanejado.orientacaoFaixita,
        contains('não há horas planejadas'),
      );
    });
  });
}

EscalaIndicadoresHistoricosResumo _historico({
  int total = 0,
  int concluidos = 0,
  int semHoras = 0,
  int invalidos = 0,
  int planejados = 0,
  int realizados = 0,
}) {
  return EscalaIndicadoresHistoricosResumo(
    inicio: DateTime(2026, 9, 1),
    fim: DateTime(2026, 9, 30),
    diasPublicados: total == 0 ? 0 : 1,
    totalAlocacoes: total,
    alocacoesComHorasRealizadas: concluidos,
    alocacoesSemHorasRealizadas: semHoras,
    alocacoesHorasInvalidas: invalidos,
    minutosPlanejados: planejados,
    minutosRealizadosNormal: realizados,
    minutosRealizadosHoraExtra: 0,
    minutosCreditoBanco: 0,
    minutosCompensadosBanco: 0,
    compensacoesComHoras: 0,
    compensacoesSemHoras: 0,
    compensacoesInvalidas: 0,
    registrosSemIdentidade: 0,
    pessoas: const [],
  );
}
