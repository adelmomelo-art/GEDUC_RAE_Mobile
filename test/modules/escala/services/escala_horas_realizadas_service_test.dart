import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';
import 'package:geduc_rae_mobile/modules/escala/services/escala_horas_service.dart';

void main() {
  final data = DateTime.utc(2026, 9, 18);
  final agora = DateTime.utc(2026, 9, 18, 18);

  EscalaAlocacaoModel alocacao({
    required String id,
    String tipo = EscalaCodigos.jornadaNormal,
    String inicioReal = '',
    String fimReal = '',
    int? minutosRealizados,
  }) {
    return EscalaAlocacaoModel(
      id: id,
      escalaId: 'escala-publicada',
      atividadeId: 'atividade-admin',
      data: data,
      membroEquipeId: 'membro-$id',
      usuarioId: 'uid-$id',
      nomeSnapshot: id,
      vinculoSnapshot: 'agente',
      setorSnapshot: 'GEDUC',
      cargaHorariaSnapshot: '180H',
      funcaoNaAtividade: 'execucao',
      turnoId: 'tarde',
      horaInicio: '12:00',
      horaFim: '18:00',
      tipoJornada: tipo,
      horaInicioReal: inicioReal,
      horaFimReal: fimReal,
      minutosPrevistos: 360,
      minutosRealizados: minutosRealizados,
      motivoJornadaComplementar:
          tipo == EscalaCodigos.jornadaNormal ? '' : 'Reforço operacional',
      classificadoPor: tipo == EscalaCodigos.jornadaNormal ? '' : 'responsavel',
      classificadoEm: tipo == EscalaCodigos.jornadaNormal ? null : agora,
      observacao: '',
      criadoPor: 'responsavel',
      criadoEm: agora,
      atualizadoPor: 'uid-$id',
      atualizadoEm: agora,
    );
  }

  group('EscalaHorasService horas realizadas ESC-001E.1', () {
    test('registro vazio é coerente e ainda não realizado', () {
      final item = alocacao(id: 'a');

      expect(EscalaHorasService.horasRealizadasCoerentes(item), isTrue);
      expect(EscalaHorasService.possuiHorasRealizadas(item), isFalse);
      expect(EscalaHorasService.minutosRealizadosCalculados(item), isNull);
    });

    test('calcula e valida intervalo real', () {
      final item = alocacao(
        id: 'a',
        inicioReal: '12:10',
        fimReal: '16:40',
        minutosRealizados: 270,
      );

      expect(EscalaHorasService.possuiHorasRealizadas(item), isTrue);
      expect(EscalaHorasService.minutosRealizadosCalculados(item), 270);
      expect(EscalaHorasService.horasRealizadasCoerentes(item), isTrue);
    });

    test('detecta minuto persistido divergente do horário real', () {
      final item = alocacao(
        id: 'a',
        inicioReal: '12:10',
        fimReal: '16:40',
        minutosRealizados: 200,
      );

      expect(EscalaHorasService.horasRealizadasCoerentes(item), isFalse);
    });

    test('resume horas realizadas por natureza sem financeiro', () {
      final resumo = EscalaHorasService.resumirRealizadas([
        alocacao(
          id: 'normal',
          inicioReal: '12:00',
          fimReal: '16:00',
          minutosRealizados: 240,
        ),
        alocacao(
          id: 'extra',
          tipo: EscalaCodigos.jornadaHoraExtra,
          inicioReal: '18:00',
          fimReal: '22:00',
          minutosRealizados: 240,
        ),
        alocacao(
          id: 'banco',
          tipo: EscalaCodigos.jornadaBancoHoras,
        ),
      ]);

      expect(resumo.totalAlocacoes, 3);
      expect(resumo.alocacoesComRegistro, 2);
      expect(resumo.alocacoesSemRegistro, 1);
      expect(resumo.alocacoesInvalidas, 0);
      expect(resumo.totalMinutosRealizados, 480);
      expect(resumo.minutosNormal, 240);
      expect(resumo.minutosHoraExtra, 240);
      expect(resumo.minutosBancoHoras, 0);
    });
  });
}
