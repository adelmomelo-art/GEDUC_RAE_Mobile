import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/escala/data/escala_gestao_repository.dart';
import 'package:geduc_rae_mobile/modules/escala/data/escala_repository.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';
import 'package:geduc_rae_mobile/modules/escala/pages/gestao_escala_page.dart';

void main() {
  final dia = DateTime(2026, 9, 17);
  final agora = DateTime(2026, 9, 17, 12);

  EscalaConfiguracaoModel configuracao() => EscalaConfiguracaoModel(
        id: 'principal',
        responsavelEscalaUsuarioId: 'responsavel',
        responsavelEscalaMembroEquipeId: 'membro-responsavel',
        ativo: true,
        designadoPor: 'gerente',
        designadoEm: agora,
      );

  EscalaModel escala({
    required String status,
    int versao = 1,
    String motivo = '',
    String origem = '',
    bool preparada = true,
  }) =>
      EscalaModel(
        id: versao == 1 ? '2026-09-17' : '2026-09-17-v$versao',
        data: dia,
        status: status,
        versao: versao,
        observacaoGeral: '',
        motivoRevisao: motivo,
        revisaoDeEscalaId: origem,
        revisaoPreparada: preparada,
        criadoPor: 'responsavel',
        criadoEm: agora,
        atualizadoPor: 'responsavel',
        atualizadoEm: agora,
        publicadoPor:
            status == EscalaCodigos.statusPublicada ? 'responsavel' : '',
        publicadoEm: status == EscalaCodigos.statusPublicada ? agora : null,
      );

  EscalaAtividadeModel atividade(String escalaId) => EscalaAtividadeModel(
        id: 'atividade-1',
        escalaId: escalaId,
        data: dia,
        secaoId: 'comandos_tematicos',
        tipoAtividadeId: 'comando',
        naturezaAtividade: EscalaCodigos.naturezaEducativa,
        titulo: 'Motociclista Seguro',
        descricao: '',
        turnoId: 'manha',
        qtrHorario: '06:00',
        horaInicio: '07:00',
        horaFim: '11:00',
        qthLocal: 'Praça Central',
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

  EscalaGestaoDados dados(EscalaModel item) => EscalaGestaoDados(
        dia: EscalaDiaConsulta(
          data: dia,
          escala: item,
          atividades: [atividade(item.id)],
          alocacoes: const [],
          indisponibilidades: const [],
        ),
        configuracao: configuracao(),
        membrosEquipe: const [],
        perfisOperacionais: const [],
      );

  Future<void> pump(
    WidgetTester tester, {
    required EscalaModel item,
    required String usuarioId,
    required String perfil,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: GestaoEscalaPage(
          usuarioId: usuarioId,
          perfilAcesso: perfil,
          dataInicial: dia,
          repository: _FakePageD5Repo(dados(item)),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('rascunho preparado oferece revisao de publicacao', (
    tester,
  ) async {
    await pump(
      tester,
      item: escala(status: EscalaCodigos.statusRascunho),
      usuarioId: 'responsavel',
      perfil: 'agente',
    );

    expect(find.byKey(const ValueKey('revisar-publicacao')), findsOneWidget);
  });

  testWidgets('publicada oferece Revisar escala para gerente', (tester) async {
    await pump(
      tester,
      item: escala(status: EscalaCodigos.statusPublicada),
      usuarioId: 'gerente',
      perfil: 'gerente',
    );

    expect(find.byKey(const ValueKey('revisar-escala')), findsOneWidget);
  });

  testWidgets('revisao incompleta oferece retomada e bloqueia edicao', (
    tester,
  ) async {
    await pump(
      tester,
      item: escala(
        status: EscalaCodigos.statusRascunho,
        versao: 2,
        motivo: 'Mudança',
        origem: '2026-09-17',
        preparada: false,
      ),
      usuarioId: 'gerente',
      perfil: 'gerente',
    );

    expect(find.byKey(const ValueKey('retomar-revisao')), findsOneWidget);
    expect(find.byKey(const ValueKey('nova-atividade')), findsNothing);
  });
}

class _FakePageD5Repo implements EscalaGestaoRepository {
  _FakePageD5Repo(this.estado);

  final EscalaGestaoDados estado;

  @override
  Future<EscalaConfiguracaoModel?> carregarConfiguracao() async =>
      estado.configuracao;

  @override
  Future<EscalaGestaoDados> carregarGestao(DateTime data) async => estado;

  @override
  Future<void> criarRascunho(EscalaModel escala) async {}

  @override
  Future<void> salvarAtividadeComEquipe(
    EscalaAtividadePersistencia persistencia,
  ) async {}

  @override
  Future<void> publicarEscala({
    required EscalaModel escalaAtual,
    required String usuarioId,
    required DateTime agora,
  }) async {}

  @override
  Future<void> prepararRevisao({
    required EscalaModel escalaAtual,
    required String motivo,
    required String usuarioId,
    required DateTime agora,
  }) async {}

  @override
  String novoIdAtividade() => 'atividade';

  @override
  String novoIdAlocacao() => 'alocacao';
}
