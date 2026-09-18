import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/membro_equipe_model.dart';
import 'package:geduc_rae_mobile/modules/escala/data/escala_gestao_repository.dart';
import 'package:geduc_rae_mobile/modules/escala/data/escala_repository.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';
import 'package:geduc_rae_mobile/modules/escala/pages/gestao_escala_page.dart';

void main() {
  final dia = DateTime(2026, 9, 17);
  final agora = DateTime(2026, 9, 17, 12);

  EscalaConfiguracaoModel config() => EscalaConfiguracaoModel(
        id: 'principal',
        responsavelEscalaUsuarioId: 'responsavel',
        responsavelEscalaMembroEquipeId: 'membro-responsavel',
        ativo: true,
        designadoPor: 'gerente',
        designadoEm: agora,
      );

  MembroEquipeModel membro(String id, String uid) => MembroEquipeModel(
        id: id,
        usuarioId: uid,
        nome: id,
        vinculo: VinculoOperacional.agente,
        podeCoordenar: false,
        ativo: true,
        origem: 'usuario',
        createdAt: agora,
        updatedAt: agora,
      );

  EscalaPerfilOperacionalModel perfil(String id, String uid) =>
      EscalaPerfilOperacionalModel(
        id: 'perfil-$id',
        membroEquipeId: id,
        usuarioId: uid,
        setorCodigo: 'GEDUC',
        cargaHorariaCodigo: '180H',
        ativo: true,
        criadoPor: 'gerente',
        criadoEm: agora,
        atualizadoPor: 'gerente',
        atualizadoEm: agora,
      );

  EscalaModel escala(String status) => EscalaModel(
        id: '2026-09-17',
        data: dia,
        status: status,
        versao: 1,
        observacaoGeral: '',
        motivoRevisao: '',
        criadoPor: 'responsavel',
        criadoEm: agora,
        atualizadoPor: 'responsavel',
        atualizadoEm: agora,
        publicadoPor:
            status == EscalaCodigos.statusPublicada ? 'responsavel' : '',
        publicadoEm: status == EscalaCodigos.statusPublicada ? agora : null,
      );

  EscalaAtividadeModel atividade() => EscalaAtividadeModel(
        id: 'a1',
        escalaId: '2026-09-17',
        data: dia,
        secaoId: 'comandos_tematicos',
        tipoAtividadeId: 'comando',
        naturezaAtividade: EscalaCodigos.naturezaEducativa,
        titulo: 'Motociclista Seguro',
        descricao: '',
        turnoId: 'manha',
        qtrHorario: '06:00',
        horaInicio: '06:00',
        horaFim: '12:00',
        qthLocal: 'Praca Central',
        qthEndereco: '',
        qthRegionalId: '',
        qthPontoReferencia: '',
        orientacaoOperacional: '',
        coordenadorMembroEquipeId: '',
        coordenadorUsuarioId: '',
        coordenadorNomeSnapshot: '',
        participanteUsuarioIds: const [],
        geraRae: true,
        contabilizaProdutividade: true,
        raeId: '',
        execucaoMissaoId: '',
        status: EscalaCodigos.atividadePlanejada,
        criadoPor: 'responsavel',
        criadoEm: agora,
        atualizadoPor: 'responsavel',
        atualizadoEm: agora,
      );

  EscalaGestaoDados dados({EscalaModel? escala, bool comAtividade = false}) =>
      EscalaGestaoDados(
        dia: EscalaDiaConsulta(
          data: dia,
          escala: escala,
          atividades: comAtividade ? [atividade()] : const [],
          alocacoes: const [],
          indisponibilidades: const [],
        ),
        configuracao: config(),
        membrosEquipe: [membro('membro-responsavel', 'responsavel')],
        perfisOperacionais: [perfil('membro-responsavel', 'responsavel')],
      );

  Future<void> pump(
    WidgetTester tester, {
    required String usuarioId,
    required String perfil,
    required EscalaGestaoDados estado,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: GestaoEscalaPage(
          usuarioId: usuarioId,
          perfilAcesso: perfil,
          dataInicial: dia,
          repository: _FakeRepo(estado),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('responsavel sem escala recebe Criar rascunho', (tester) async {
    await pump(
      tester,
      usuarioId: 'responsavel',
      perfil: 'agente',
      estado: dados(),
    );
    expect(find.byKey(const ValueKey('gestao-sem-escala')), findsOneWidget);
    expect(find.byKey(const ValueKey('criar-rascunho')), findsOneWidget);
  });

  testWidgets('gerente sem escala nao recebe criacao', (tester) async {
    await pump(
      tester,
      usuarioId: 'gerente',
      perfil: 'gerente',
      estado: dados(),
    );
    expect(find.byKey(const ValueKey('criar-rascunho')), findsNothing);
    expect(
      find.textContaining('exclusiva do agente responsável'),
      findsOneWidget,
    );
  });

  testWidgets('rascunho exibe resumo, atividade e Nova atividade', (
    tester,
  ) async {
    await pump(
      tester,
      usuarioId: 'responsavel',
      perfil: 'agente',
      estado: dados(
        escala: escala(EscalaCodigos.statusRascunho),
        comAtividade: true,
      ),
    );
    expect(find.text('RASCUNHO • v1'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('selecionar-data-gestao')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('nova-atividade')), findsOneWidget);
    expect(find.text('Motociclista Seguro'), findsOneWidget);
    expect(find.text('Cobertura'), findsOneWidget);
  });

  testWidgets('publicada fica somente consulta na D4', (tester) async {
    await pump(
      tester,
      usuarioId: 'gerente',
      perfil: 'gerente',
      estado: dados(
        escala: escala(EscalaCodigos.statusPublicada),
        comAtividade: true,
      ),
    );
    expect(find.byKey(const ValueKey('gestao-publicada')), findsOneWidget);
    expect(find.byKey(const ValueKey('nova-atividade')), findsNothing);
    expect(find.textContaining('ESC-001D.5'), findsWidgets);
  });
}

class _FakeRepo implements EscalaGestaoRepository {
  _FakeRepo(this.estado);
  EscalaGestaoDados estado;

  @override
  Future<EscalaConfiguracaoModel?> carregarConfiguracao() async =>
      estado.configuracao;
  @override
  Future<EscalaGestaoDados> carregarGestao(DateTime data) async => estado;
  @override
  Future<void> criarRascunho(EscalaModel escala) async {}
  @override
  String novoIdAtividade() => 'atividade';
  @override
  String novoIdAlocacao() => 'alocacao';
  @override
  Future<void> salvarAtividadeComEquipe(
    EscalaAtividadePersistencia persistencia,
  ) async {}
}
