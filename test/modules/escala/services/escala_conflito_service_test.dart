import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';
import 'package:geduc_rae_mobile/modules/escala/services/escala_conflito_service.dart';

void main() {
  final agora = DateTime.utc(2026, 9, 17, 12);

  EscalaAlocacaoModel alocacao({
    required String id,
    String usuarioId = 'agente-1',
    String membroEquipeId = 'membro-1',
    String inicio = '06:00',
    String fim = '12:00',
    DateTime? data,
  }) {
    return EscalaAlocacaoModel(
      id: id,
      escalaId: '2026-09-17',
      atividadeId: 'atividade-$id',
      data: data ?? DateTime.utc(2026, 9, 17),
      membroEquipeId: membroEquipeId,
      usuarioId: usuarioId,
      nomeSnapshot: usuarioId,
      vinculoSnapshot: 'agente',
      setorSnapshot: 'GEDUC',
      cargaHorariaSnapshot: '180H',
      funcaoNaAtividade: 'apoio',
      turnoId: 'turno',
      horaInicio: inicio,
      horaFim: fim,
      tipoJornada: EscalaCodigos.jornadaNormal,
      horaInicioReal: '',
      horaFimReal: '',
      minutosPrevistos: 0,
      minutosRealizados: null,
      motivoJornadaComplementar: '',
      classificadoPor: '',
      classificadoEm: null,
      observacao: '',
      criadoPor: 'responsavel',
      criadoEm: agora,
      atualizadoPor: 'responsavel',
      atualizadoEm: agora,
    );
  }

  group('EscalaConflitoService', () {
    test('intervalos encostados nao sobrepoem', () {
      final conflitos = EscalaConflitoService.detectarSobreposicoes([
        alocacao(id: 'a', inicio: '06:00', fim: '12:00'),
        alocacao(id: 'b', inicio: '12:00', fim: '18:00'),
      ]);

      expect(conflitos, isEmpty);
    });

    test('mesmo agente com horarios cruzados gera alerta', () {
      final conflitos = EscalaConflitoService.detectarSobreposicoes([
        alocacao(id: 'a', inicio: '06:00', fim: '12:00'),
        alocacao(id: 'b', inicio: '11:00', fim: '13:00'),
      ]);

      expect(conflitos, hasLength(1));
      expect(conflitos.single.primeiraAlocacaoId, 'a');
      expect(conflitos.single.segundaAlocacaoId, 'b');
    });

    test('mesmo horario em agentes diferentes nao gera conflito', () {
      final conflitos = EscalaConflitoService.detectarSobreposicoes([
        alocacao(id: 'a', inicio: '06:00', fim: '12:00'),
        alocacao(
          id: 'b',
          usuarioId: 'agente-2',
          membroEquipeId: 'membro-2',
          inicio: '06:00',
          fim: '12:00',
        ),
      ]);

      expect(conflitos, isEmpty);
    });

    test('detecta sobreposicao quando primeira jornada cruza meia-noite', () {
      final conflitos = EscalaConflitoService.detectarSobreposicoes([
        alocacao(id: 'a', inicio: '23:00', fim: '02:00'),
        alocacao(id: 'b', inicio: '01:00', fim: '03:00'),
      ]);

      expect(conflitos, hasLength(1));
    });

    test('multiplas alocacoes sao distintas de sobreposicao', () {
      final itens = [
        alocacao(id: 'a', inicio: '06:00', fim: '12:00'),
        alocacao(id: 'b', inicio: '18:00', fim: '22:00'),
      ];

      final multiplas = EscalaConflitoService.detectarMultiplasAlocacoes(itens);
      final conflitos = EscalaConflitoService.detectarSobreposicoes(itens);

      expect(multiplas, hasLength(1));
      expect(multiplas.single.quantidadeAlocacoes, 2);
      expect(conflitos, isEmpty);
    });

    test('nova alocacao reconhece segunda jornada no mesmo dia', () {
      final primeira = alocacao(id: 'a', inicio: '06:00', fim: '12:00');
      final candidata = alocacao(id: 'b', inicio: '18:00', fim: '22:00');

      expect(
        EscalaConflitoService.possuiOutraAlocacaoNoDia(
          candidata: candidata,
          existentes: [primeira],
        ),
        isTrue,
      );
    });

    test('alocacao do dia seguinte nao caracteriza segunda jornada', () {
      final primeira = alocacao(id: 'a');
      final candidata = alocacao(id: 'b', data: DateTime.utc(2026, 9, 18));

      expect(
        EscalaConflitoService.possuiOutraAlocacaoNoDia(
          candidata: candidata,
          existentes: [primeira],
        ),
        isFalse,
      );
    });
  });
}
