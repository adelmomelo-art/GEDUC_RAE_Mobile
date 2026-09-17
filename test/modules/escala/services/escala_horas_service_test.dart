import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';
import 'package:geduc_rae_mobile/modules/escala/services/escala_horas_service.dart';

void main() {
  final data = DateTime.utc(2026, 9, 17);
  final agora = DateTime.utc(2026, 9, 17, 12);

  EscalaAlocacaoModel alocacao({
    required String id,
    String usuarioId = 'agente-1',
    String membroEquipeId = 'membro-1',
    String tipoJornada = EscalaCodigos.jornadaNormal,
    String inicio = '06:00',
    String fim = '12:00',
    int minutosPrevistos = 360,
  }) {
    return EscalaAlocacaoModel(
      id: id,
      escalaId: '2026-09-17',
      atividadeId: 'atividade-1',
      data: data,
      membroEquipeId: membroEquipeId,
      usuarioId: usuarioId,
      nomeSnapshot: usuarioId.isEmpty ? membroEquipeId : usuarioId,
      vinculoSnapshot: 'agente',
      setorSnapshot: 'GEDUC',
      cargaHorariaSnapshot: '180H',
      funcaoNaAtividade: 'apoio',
      turnoId: 'manha',
      horaInicio: inicio,
      horaFim: fim,
      tipoJornada: tipoJornada,
      horaInicioReal: '',
      horaFimReal: '',
      minutosPrevistos: minutosPrevistos,
      minutosRealizados: null,
      motivoJornadaComplementar: tipoJornada == EscalaCodigos.jornadaNormal
          ? ''
          : 'Reforco',
      classificadoPor: tipoJornada == EscalaCodigos.jornadaNormal
          ? ''
          : 'responsavel',
      classificadoEm: tipoJornada == EscalaCodigos.jornadaNormal ? null : agora,
      observacao: '',
      criadoPor: 'responsavel',
      criadoEm: agora,
      atualizadoPor: 'responsavel',
      atualizadoEm: agora,
    );
  }

  group('EscalaHorasService', () {
    test('converte HH:mm e rejeita horario invalido', () {
      expect(EscalaHorasService.horarioParaMinutos('06:30'), 390);
      expect(EscalaHorasService.horarioParaMinutos('23:59'), 1439);
      expect(EscalaHorasService.horarioParaMinutos('24:00'), isNull);
      expect(EscalaHorasService.horarioParaMinutos('6:30'), isNull);
    });

    test('calcula intervalos comuns e virada de dia', () {
      expect(
        EscalaHorasService.calcularDuracaoMinutos(
          inicio: '06:00',
          fim: '12:00',
        ),
        360,
      );
      expect(
        EscalaHorasService.calcularDuracaoMinutos(
          inicio: '18:00',
          fim: '22:00',
        ),
        240,
      );
      expect(
        EscalaHorasService.calcularDuracaoMinutos(
          inicio: '22:00',
          fim: '02:00',
        ),
        240,
      );
      expect(
        EscalaHorasService.calcularDuracaoMinutos(
          inicio: '08:00',
          fim: '08:00',
        ),
        0,
      );
    });

    test('resume normal, hora extra e banco sem componente financeiro', () {
      final resumo = EscalaHorasService.resumir([
        alocacao(id: 'normal'),
        alocacao(
          id: 'extra',
          tipoJornada: EscalaCodigos.jornadaHoraExtra,
          inicio: '18:00',
          fim: '22:00',
          minutosPrevistos: 240,
        ),
        alocacao(
          id: 'banco',
          usuarioId: 'agente-2',
          membroEquipeId: 'membro-2',
          tipoJornada: EscalaCodigos.jornadaBancoHoras,
          inicio: '18:00',
          fim: '22:00',
          minutosPrevistos: 240,
        ),
      ]);

      expect(resumo.totalAlocacoes, 3);
      expect(resumo.totalAgentesUnicos, 2);
      expect(resumo.minutosNormal, 360);
      expect(resumo.minutosHoraExtra, 240);
      expect(resumo.minutosBancoHoras, 240);
      expect(resumo.totalMinutosProgramados, 840);
      expect(resumo.agentesNormal, 1);
      expect(resumo.agentesHoraExtra, 1);
      expect(resumo.agentesBancoHoras, 1);
      expect(resumo.possuiJornadaComplementar, isTrue);
    });

    test('prefere calculo do horario e detecta divergencia persistida', () {
      final item = alocacao(
        id: 'divergente',
        inicio: '06:00',
        fim: '12:00',
        minutosPrevistos: 300,
      );

      expect(EscalaHorasService.minutosProgramados(item), 360);
      expect(EscalaHorasService.minutosPrevistosCoerentes(item), isFalse);
    });

    test('usa minutos persistidos quando horario e invalido', () {
      final item = alocacao(
        id: 'fallback',
        inicio: '',
        fim: '',
        minutosPrevistos: 180,
      );

      expect(EscalaHorasService.minutosProgramados(item), 180);
      expect(EscalaHorasService.minutosPrevistosCoerentes(item), isTrue);
    });

    test('formata minutos sem decimal de horas', () {
      expect(EscalaHorasService.formatarMinutos(0), '0h');
      expect(EscalaHorasService.formatarMinutos(360), '6h');
      expect(EscalaHorasService.formatarMinutos(390), '6h30');
      expect(EscalaHorasService.formatarMinutos(30), '0h30');
    });

    test('fallback de identidade usa membro quando uid esta ausente', () {
      final item = alocacao(
        id: 'legado',
        usuarioId: '',
        membroEquipeId: 'membro-legado',
      );

      expect(EscalaHorasService.chavePessoa(item), 'membro:membro-legado');
    });
  });
}
