import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/data/escala_periodo_builder.dart';
import 'package:geduc_rae_mobile/modules/escala/data/escala_repository.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';

void main() {
  group('EscalaPeriodoBuilder ESC-001H.2', () {
    test('seleciona somente a versão publicada mais recente de cada dia', () {
      final periodo = EscalaPeriodoBuilder.montar(
        inicio: DateTime(2026, 9, 1, 18),
        fim: DateTime(2026, 9, 30, 6),
        escalas: [
          _escala('publicada-v1', DateTime(2026, 9, 10), versao: 1),
          _escala('publicada-v2', DateTime(2026, 9, 10), versao: 2),
          _escala(
            'rascunho-v3',
            DateTime(2026, 9, 10),
            versao: 3,
            status: EscalaCodigos.statusRascunho,
          ),
          _escala('fora-periodo', DateTime(2026, 10, 1), versao: 1),
        ],
        atividades: const [],
        alocacoes: [
          _alocacao('antiga', 'publicada-v1', DateTime(2026, 9, 10)),
          _alocacao('atual', 'publicada-v2', DateTime(2026, 9, 10)),
          _alocacao('rascunho', 'rascunho-v3', DateTime(2026, 9, 10)),
        ],
        indisponibilidades: const [],
      );

      expect(periodo.inicio, DateTime(2026, 9, 1));
      expect(periodo.fim, DateTime(2026, 9, 30));
      expect(periodo.dias, hasLength(1));
      expect(periodo.dias.single.escala?.id, 'publicada-v2');
      expect(periodo.dias.single.alocacoes.map((item) => item.id), ['atual']);
    });

    test('repete indisponibilidade abrangente em cada dia publicado', () {
      final periodo = EscalaPeriodoBuilder.montar(
        inicio: DateTime(2026, 9, 10),
        fim: DateTime(2026, 9, 12),
        escalas: [
          _escala('dia-10', DateTime(2026, 9, 10)),
          _escala('dia-11', DateTime(2026, 9, 11)),
        ],
        atividades: const [],
        alocacoes: const [],
        indisponibilidades: [
          _indisponibilidade(
            'compensacao',
            DateTime(2026, 9, 10),
            DateTime(2026, 9, 11),
          ),
          _indisponibilidade(
            'fora',
            DateTime(2026, 9, 12),
            DateTime(2026, 9, 12),
          ),
        ],
      );

      expect(periodo.dias, hasLength(2));
      expect(periodo.dias[0].indisponibilidades.single.id, 'compensacao');
      expect(periodo.dias[1].indisponibilidades.single.id, 'compensacao');
      expect(
        () => periodo.dias.add(periodo.dias.first),
        throwsUnsupportedError,
      );
    });

    test('bloqueia período invertido ou superior a 366 dias', () {
      expect(
        () => EscalaPeriodoConsulta.validarPeriodo(
          inicio: DateTime(2026, 9, 2),
          fim: DateTime(2026, 9, 1),
        ),
        throwsArgumentError,
      );
      expect(
        () => EscalaPeriodoConsulta.validarPeriodo(
          inicio: DateTime(2026, 1, 1),
          fim: DateTime(2027, 1, 2),
        ),
        throwsArgumentError,
      );
    });
  });
}

EscalaModel _escala(
  String id,
  DateTime data, {
  int versao = 1,
  String status = EscalaCodigos.statusPublicada,
}) {
  return EscalaModel(
    id: id,
    data: data,
    status: status,
    versao: versao,
    observacaoGeral: '',
    motivoRevisao: '',
    criadoPor: 'responsavel',
    criadoEm: data,
    atualizadoPor: 'responsavel',
    atualizadoEm: data,
    publicadoPor: status == EscalaCodigos.statusPublicada ? 'responsavel' : '',
    publicadoEm: status == EscalaCodigos.statusPublicada ? data : null,
  );
}

EscalaAlocacaoModel _alocacao(String id, String escalaId, DateTime data) {
  return EscalaAlocacaoModel(
    id: id,
    escalaId: escalaId,
    atividadeId: 'atividade-$id',
    data: data,
    membroEquipeId: 'membro-$id',
    usuarioId: 'uid-$id',
    nomeSnapshot: 'Agente $id',
    vinculoSnapshot: 'agente',
    setorSnapshot: 'GEDUC',
    cargaHorariaSnapshot: '40H',
    funcaoNaAtividade: 'participante',
    turnoId: 'manha',
    horaInicio: '08:00',
    horaFim: '10:00',
    tipoJornada: EscalaCodigos.jornadaNormal,
    horaInicioReal: '08:00',
    horaFimReal: '10:00',
    minutosPrevistos: 120,
    minutosRealizados: 120,
    motivoJornadaComplementar: '',
    classificadoPor: '',
    classificadoEm: null,
    observacao: '',
    criadoPor: 'responsavel',
    criadoEm: data,
    atualizadoPor: 'responsavel',
    atualizadoEm: data,
  );
}

EscalaIndisponibilidadeModel _indisponibilidade(
  String id,
  DateTime inicio,
  DateTime fim,
) {
  return EscalaIndisponibilidadeModel(
    id: id,
    dataInicio: inicio,
    dataFim: fim,
    membroEquipeId: 'membro-1',
    usuarioId: 'uid-1',
    nomeSnapshot: 'Agente',
    tipoId: 'compensacao',
    turnoId: 'manha',
    horaInicio: '08:00',
    horaFim: '09:00',
    observacao: '',
    criadoPor: 'responsavel',
    criadoEm: inicio,
    atualizadoPor: 'responsavel',
    atualizadoEm: inicio,
  );
}
