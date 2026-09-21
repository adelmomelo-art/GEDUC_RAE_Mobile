import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/membro_equipe_model.dart';
import 'package:geduc_rae_mobile/modules/escala/data/escala_execucao_repository.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';
import 'package:geduc_rae_mobile/modules/escala/pages/escala_execucao_missao_page.dart';

void main() {
  final data = DateTime(2026, 9, 18);
  final instante = DateTime(2026, 9, 18, 12);

  EscalaExecucaoContexto contexto({
    String usuarioId = 'agente',
    String statusEscala = EscalaCodigos.statusPublicada,
  }) {
    return EscalaExecucaoContexto(
      escala: EscalaModel.fromMap({
        'data': data,
        'status': statusEscala,
        'versao': 1,
      }, documentId: 'escala'),
      atividade: EscalaAtividadeModel.fromMap({
        'escalaId': 'escala',
        'data': data,
        'naturezaAtividade': EscalaCodigos.naturezaAdministrativa,
        'titulo': 'Tratamento de dados',
        'participanteUsuarioIds': ['agente'],
        'coordenadorUsuarioId': 'coordenador',
        'geraRae': false,
      }, documentId: 'atividade'),
      equipe: const [],
      executor: MembroEquipeModel(
        id: 'membro-$usuarioId',
        usuarioId: usuarioId,
        nome: 'Executor A',
        vinculo: VinculoOperacional.agente,
        podeCoordenar: usuarioId == 'coordenador',
        ativo: true,
        origem: 'usuario',
        createdAt: instante,
        updatedAt: instante,
      ),
      execucao: null,
    );
  }

  Future<void> abrir(
    WidgetTester tester,
    _RepositorioFake repo, {
    String usuarioId = 'agente',
    String perfil = 'agente',
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: EscalaExecucaoMissaoPage(
        atividadeId: 'atividade',
        usuarioId: usuarioId,
        perfilAcesso: perfil,
        repository: repo,
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('participante inicia, salva e conclui com resultado',
      (tester) async {
    final repo = _RepositorioFake(contexto());
    await abrir(tester, repo);

    expect(find.text('Tratamento de dados'), findsOneWidget);
    expect(find.byKey(const ValueKey('missao-iniciar')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('missao-iniciar')));
    await tester.pumpAndSettle();
    expect(repo.inicios, 1);

    await tester.enterText(
        find.byKey(const ValueKey('missao-resultado')), 'Dados consolidados');
    await tester.ensureVisible(find.byKey(const ValueKey('missao-salvar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('missao-salvar')));
    await tester.pumpAndSettle();
    expect(repo.execucao!.resultadoResumo, 'Dados consolidados');
    expect(repo.execucao!.status, EscalaCodigos.execucaoEmExecucao);

    await tester.ensureVisible(find.byKey(const ValueKey('missao-concluir')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('missao-concluir')));
    await tester.pumpAndSettle();
    expect(repo.execucao!.status, EscalaCodigos.execucaoEmExecucao);
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(repo.execucao!.status, EscalaCodigos.execucaoConcluida);
    expect(find.byKey(const ValueKey('missao-salvar')), findsNothing);
    expect(find.text('Execução encerrada. Registro disponível para consulta.'),
        findsOneWidget);
  });

  testWidgets('conclusão vazia é bloqueada; cancelamento requer confirmação',
      (tester) async {
    final repo = _RepositorioFake(contexto(usuarioId: 'coordenador'));
    await abrir(tester, repo, usuarioId: 'coordenador', perfil: 'coordenador');
    await tester.tap(find.byKey(const ValueKey('missao-iniciar')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('missao-concluir')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('missao-concluir')));
    await tester.pump();
    expect(repo.execucao!.status, EscalaCodigos.execucaoEmExecucao);
    expect(find.text('Informe o resultado/entrega da missão.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('missao-cancelar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('missao-cancelar')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    expect(repo.execucao!.status, EscalaCodigos.execucaoEmExecucao);

    await tester.tap(find.byKey(const ValueKey('missao-cancelar')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(repo.execucao!.status, EscalaCodigos.execucaoCancelada);
    expect(find.byKey(const ValueKey('missao-concluir')), findsNothing);
  });

  testWidgets('pessoa fora da equipe não recebe ação de início',
      (tester) async {
    await abrir(tester, _RepositorioFake(contexto(usuarioId: 'outro')),
        usuarioId: 'outro');
    expect(find.text('Você não pode registrar a execução desta missão.'),
        findsOneWidget);
    expect(find.byKey(const ValueKey('missao-iniciar')), findsNothing);
  });

  testWidgets('erro de carregamento oferece nova tentativa', (tester) async {
    final repo = _RepositorioFake(contexto())..falharCarregamento = true;
    await abrir(tester, repo);
    expect(find.text('Tentar novamente'), findsOneWidget);
    repo.falharCarregamento = false;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('missao-iniciar')), findsOneWidget);
  });
}

class _RepositorioFake implements EscalaExecucaoRepository {
  _RepositorioFake(this.contexto);

  final EscalaExecucaoContexto contexto;
  ExecucaoMissaoModel? execucao;
  int inicios = 0;
  bool falharCarregamento = false;

  @override
  String idExecucao({required String atividadeId, required String usuarioId}) =>
      'exec-$atividadeId-$usuarioId';

  @override
  Future<EscalaExecucaoContexto> carregarContexto({
    required String atividadeId,
    required String usuarioId,
  }) async {
    if (falharCarregamento) throw StateError('indisponível');
    return execucao == null ? contexto : contexto.comExecucao(execucao!);
  }

  @override
  Future<ExecucaoMissaoModel> iniciarExecucao(ExecucaoMissaoModel valor) async {
    inicios++;
    return execucao ??= valor;
  }

  @override
  Future<void> atualizarExecucao(ExecucaoMissaoModel valor) async {
    execucao = valor;
  }
}
