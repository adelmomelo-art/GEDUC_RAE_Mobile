import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/membro_equipe_model.dart';
import 'package:geduc_rae_mobile/modules/escala/data/escala_configuracao_repository.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';
import 'package:geduc_rae_mobile/modules/escala/pages/escala_configuracao_page.dart';

void main() {
  final agora = DateTime(2026, 9, 18, 8);

  MembroEquipeModel membro() => MembroEquipeModel(
        id: 'membro-a',
        usuarioId: 'uid-a',
        nome: 'Agente A',
        vinculo: VinculoOperacional.agente,
        podeCoordenar: true,
        ativo: true,
        origem: 'usuario',
        createdAt: agora,
        updatedAt: agora,
      );

  EscalaPerfilOperacionalModel perfil() => EscalaPerfilOperacionalModel(
        id: 'perfil-a',
        membroEquipeId: 'membro-a',
        usuarioId: 'uid-a',
        setorCodigo: 'GEDUC',
        cargaHorariaCodigo: '180H',
        ativo: true,
        criadoPor: 'gerente',
        criadoEm: agora,
        atualizadoPor: 'gerente',
        atualizadoEm: agora,
      );

  testWidgets('configuracao exibe responsavel e Equipe GEDUC', (tester) async {
    final repo = _FakePageConfigRepo(
      EscalaConfiguracaoDados(
        configuracao: null,
        membrosEquipe: [membro()],
        perfisOperacionais: [perfil()],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: EscalaConfiguracaoPage(
          usuarioId: 'gerente',
          perfilAcesso: 'gerente',
          repository: repo,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Responsável fixo'), findsOneWidget);
    expect(find.text('Equipe GEDUC'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('responsavel-fixo-dropdown')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('perfil-ativo-membro-a')), findsOneWidget);
    expect(find.byKey(const ValueKey('carga-membro-a')), findsOneWidget);
    expect(find.text('Agente A'), findsWidgets);
  });

  testWidgets('agente comum recebe acesso restrito', (tester) async {
    final repo = _FakePageConfigRepo(
      EscalaConfiguracaoDados(
        configuracao: null,
        membrosEquipe: [membro()],
        perfisOperacionais: [perfil()],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: EscalaConfiguracaoPage(
          usuarioId: 'agente',
          perfilAcesso: 'agente',
          repository: repo,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Acesso restrito'), findsOneWidget);
  });
}

class _FakePageConfigRepo implements EscalaConfiguracaoRepository {
  _FakePageConfigRepo(this.estado);

  EscalaConfiguracaoDados estado;

  @override
  Future<EscalaConfiguracaoDados> carregarConfiguracaoOperacional() async =>
      estado;

  @override
  Future<void> salvarConfiguracaoEscala(
    EscalaConfiguracaoModel configuracao,
  ) async {
    estado = EscalaConfiguracaoDados(
      configuracao: configuracao,
      membrosEquipe: estado.membrosEquipe,
      perfisOperacionais: estado.perfisOperacionais,
    );
  }

  @override
  Future<void> salvarPerfilOperacional(
    EscalaPerfilOperacionalModel perfil,
  ) async {}
}
