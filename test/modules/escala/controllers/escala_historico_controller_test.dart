import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/controllers/escala_historico_controller.dart';
import 'package:geduc_rae_mobile/modules/escala/data/escala_repository.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';

void main() {
  group('EscalaHistoricoController ESC-001H.2', () {
    test(
      'gestor consulta período geral e recebe consolidação histórica',
      () async {
        final repository = _FakeRepository(_periodo());
        final controller = EscalaHistoricoController(
          repository: repository,
          usuarioId: 'gestor-1',
          perfilAcesso: 'gestor',
          inicioInicial: DateTime(2026, 9, 1, 20),
          fimInicial: DateTime(2026, 9, 30, 5),
        );

        expect(controller.podeConsultarGeral, isTrue);
        expect(controller.somenteMinhasHoras, isFalse);
        await controller.carregar();

        expect(controller.erro, isNull);
        expect(repository.chamadasPeriodo, 1);
        expect(repository.inicioConsultado, DateTime(2026, 9, 1));
        expect(repository.fimConsultado, DateTime(2026, 9, 30));
        expect(controller.periodo?.dias.single.alocacoes, hasLength(3));
        expect(controller.resumo?.totalAlocacoes, 3);
        expect(controller.resumo?.totalMinutosRealizados, 240);
      },
    );

    test('agente consulta apenas os próprios registros', () async {
      final repository = _FakeRepository(_periodo());
      final controller = EscalaHistoricoController(
        repository: repository,
        usuarioId: 'uid-1',
        perfilAcesso: 'agente',
        membroEquipeId: 'membro-uid-1',
        inicioInicial: DateTime(2026, 9, 1),
        fimInicial: DateTime(2026, 9, 30),
      );

      expect(controller.podeConsultarGeral, isFalse);
      expect(controller.podeConsultarProprio, isTrue);
      expect(controller.somenteMinhasHoras, isTrue);
      await controller.carregar();

      expect(controller.erro, isNull);
      expect(controller.periodo?.dias.single.alocacoes, hasLength(2));
      expect(controller.periodo?.dias.single.alocacoes.map((item) => item.id), [
        'aloc-1',
        'aloc-legada',
      ]);
      expect(controller.resumo?.totalAlocacoes, 2);
      expect(controller.resumo?.totalMinutosRealizados, 120);
      expect(
        () => controller.definirSomenteMinhasHoras(false),
        throwsStateError,
      );
    });

    test(
      'perfil desconhecido falha fechado sem consultar repository',
      () async {
        final repository = _FakeRepository(_periodo());
        final controller = EscalaHistoricoController(
          repository: repository,
          usuarioId: 'uid-1',
          perfilAcesso: 'desconhecido',
          inicioInicial: DateTime(2026, 9, 1),
          fimInicial: DateTime(2026, 9, 30),
        );

        await controller.carregar();

        expect(controller.erro, isA<StateError>());
        expect(controller.periodo, isNull);
        expect(controller.resumo, isNull);
        expect(repository.chamadasPeriodo, 0);
      },
    );

    test(
      'troca de período invalida resultado e rejeita intervalo excessivo',
      () async {
        final repository = _FakeRepository(_periodo());
        final controller = EscalaHistoricoController(
          repository: repository,
          usuarioId: 'gestor-1',
          perfilAcesso: 'gestor',
          inicioInicial: DateTime(2026, 9, 1),
          fimInicial: DateTime(2026, 9, 30),
        );
        await controller.carregar();
        expect(controller.resumo, isNotNull);

        controller.selecionarPeriodo(
          inicio: DateTime(2026, 10, 1),
          fim: DateTime(2026, 10, 31),
        );
        expect(controller.inicio, DateTime(2026, 10, 1));
        expect(controller.fim, DateTime(2026, 10, 31));
        expect(controller.resumo, isNull);

        expect(
          () => controller.selecionarPeriodo(
            inicio: DateTime(2026, 1, 1),
            fim: DateTime(2027, 1, 2),
          ),
          throwsArgumentError,
        );
      },
    );
  });
}

class _FakeRepository implements EscalaRepository {
  _FakeRepository(this.resultado);

  final EscalaPeriodoConsulta resultado;
  int chamadasPeriodo = 0;
  DateTime? inicioConsultado;
  DateTime? fimConsultado;

  @override
  Future<EscalaPeriodoConsulta> carregarPeriodo({
    required DateTime inicio,
    required DateTime fim,
  }) async {
    chamadasPeriodo++;
    inicioConsultado = inicio;
    fimConsultado = fim;
    return resultado;
  }

  @override
  Future<EscalaDiaConsulta> carregarDia(DateTime data) {
    throw UnsupportedError('Consulta diária não usada neste teste.');
  }

  @override
  Future<void> salvarHorasRealizadas({
    required String alocacaoId,
    required String usuarioId,
    required String horaInicioReal,
    required String horaFimReal,
    required int minutosRealizados,
    required String observacao,
    required DateTime atualizadoEm,
  }) {
    throw UnsupportedError('Gravação não usada neste teste.');
  }
}

EscalaPeriodoConsulta _periodo() {
  final data = DateTime(2026, 9, 10);
  final escala = EscalaModel(
    id: '2026-09-10-v1',
    data: data,
    status: EscalaCodigos.statusPublicada,
    versao: 1,
    observacaoGeral: '',
    motivoRevisao: '',
    criadoPor: 'responsavel',
    criadoEm: data,
    atualizadoPor: 'responsavel',
    atualizadoEm: data,
    publicadoPor: 'responsavel',
    publicadoEm: data,
  );
  return EscalaPeriodoConsulta(
    inicio: DateTime(2026, 9, 1),
    fim: DateTime(2026, 9, 30),
    dias: [
      EscalaDiaConsulta(
        data: data,
        escala: escala,
        atividades: const [],
        alocacoes: [
          _alocacao('aloc-1', 'uid-1', 60, data),
          _alocacao('aloc-2', 'uid-2', 120, data),
          _alocacao(
            'aloc-legada',
            '',
            60,
            data,
            membroEquipeId: 'membro-uid-1',
          ),
        ],
        indisponibilidades: const [],
      ),
    ],
  );
}

EscalaAlocacaoModel _alocacao(
  String id,
  String usuarioId,
  int minutos,
  DateTime data, {
  String? membroEquipeId,
}) {
  final fim = minutos == 60 ? '09:00' : '10:00';
  return EscalaAlocacaoModel(
    id: id,
    escalaId: '2026-09-10-v1',
    atividadeId: 'atividade-$id',
    data: data,
    membroEquipeId: membroEquipeId ?? 'membro-$usuarioId',
    usuarioId: usuarioId,
    nomeSnapshot: 'Agente $usuarioId',
    vinculoSnapshot: 'agente',
    setorSnapshot: 'GEDUC',
    cargaHorariaSnapshot: '40H',
    funcaoNaAtividade: 'participante',
    turnoId: 'manha',
    horaInicio: '08:00',
    horaFim: fim,
    tipoJornada: EscalaCodigos.jornadaNormal,
    horaInicioReal: '08:00',
    horaFimReal: fim,
    minutosPrevistos: minutos,
    minutosRealizados: minutos,
    motivoJornadaComplementar: '',
    classificadoPor: '',
    classificadoEm: null,
    observacao: '',
    criadoPor: 'responsavel',
    criadoEm: data,
    atualizadoPor: usuarioId,
    atualizadoEm: data,
  );
}
