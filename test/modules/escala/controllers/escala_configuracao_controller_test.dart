import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/membro_equipe_model.dart';
import 'package:geduc_rae_mobile/modules/escala/controllers/escala_configuracao_controller.dart';
import 'package:geduc_rae_mobile/modules/escala/data/escala_configuracao_repository.dart';
import 'package:geduc_rae_mobile/modules/escala/models/escala_models.dart';

void main() {
  final agora = DateTime(2026, 9, 18, 8);

  MembroEquipeModel membro(
    String id,
    String uid, {
    bool ativo = true,
    VinculoOperacional vinculo = VinculoOperacional.agente,
  }) {
    return MembroEquipeModel(
      id: id,
      usuarioId: uid,
      nome: id,
      vinculo: vinculo,
      podeCoordenar: false,
      ativo: ativo,
      origem: 'usuario',
      createdAt: agora,
      updatedAt: agora,
    );
  }

  EscalaPerfilOperacionalModel perfil(
    String membroId,
    String uid, {
    bool ativo = true,
    String carga = '180H',
  }) {
    return EscalaPerfilOperacionalModel(
      id: 'perfil-$membroId',
      membroEquipeId: membroId,
      usuarioId: uid,
      setorCodigo: 'GEDUC',
      cargaHorariaCodigo: carga,
      ativo: ativo,
      criadoPor: 'gerente',
      criadoEm: agora,
      atualizadoPor: 'gerente',
      atualizadoEm: agora,
    );
  }

  EscalaConfiguracaoModel config(String membroId, String uid) {
    return EscalaConfiguracaoModel(
      id: 'principal',
      responsavelEscalaUsuarioId: uid,
      responsavelEscalaMembroEquipeId: membroId,
      ativo: true,
      designadoPor: 'gerente',
      designadoEm: agora,
    );
  }

  test(
    'candidatos exigem membro ativo perfil GEDUC ativo e UID canonico',
    () async {
      final repo = _FakeConfigRepo(
        EscalaConfiguracaoDados(
          configuracao: null,
          membrosEquipe: [
            membro('membro-a', 'uid-a'),
            membro('membro-b', 'uid-b'),
            membro('membro-sem-uid', ''),
            membro('membro-inativo', 'uid-inativo', ativo: false),
            membro(
              'membro-terceiro',
              'uid-terceiro',
              vinculo: VinculoOperacional.terceirizado,
            ),
          ],
          perfisOperacionais: [
            perfil('membro-a', 'uid-a'),
            perfil('membro-b', 'uid-b', ativo: false),
            perfil('membro-sem-uid', ''),
            perfil('membro-inativo', 'uid-inativo'),
            perfil('membro-terceiro', 'uid-terceiro'),
          ],
        ),
      );

      final controller = EscalaConfiguracaoController(
        repository: repo,
        usuarioId: 'gerente',
        perfilAcesso: 'gerente',
        agora: () => agora,
      );

      await controller.carregar();

      expect(controller.candidatosResponsavel.map((item) => item.membro.id), [
        'membro-a',
      ]);
    },
  );

  test('gerente designa responsavel com auditoria', () async {
    final repo = _FakeConfigRepo(
      EscalaConfiguracaoDados(
        configuracao: null,
        membrosEquipe: [membro('membro-a', 'uid-a')],
        perfisOperacionais: [perfil('membro-a', 'uid-a')],
      ),
    );

    final controller = EscalaConfiguracaoController(
      repository: repo,
      usuarioId: 'gerente',
      perfilAcesso: 'gerente',
      agora: () => agora,
    );

    await controller.carregar();
    await controller.salvarResponsavel('membro-a');

    expect(repo.configuracaoSalva!.responsavelEscalaUsuarioId, 'uid-a');
    expect(repo.configuracaoSalva!.responsavelEscalaMembroEquipeId, 'membro-a');
    expect(repo.configuracaoSalva!.designadoPor, 'gerente');
    expect(repo.configuracaoSalva!.designadoEm, agora);
  });

  test('nao designa perfil inativo como responsavel', () async {
    final repo = _FakeConfigRepo(
      EscalaConfiguracaoDados(
        configuracao: null,
        membrosEquipe: [membro('membro-a', 'uid-a')],
        perfisOperacionais: [perfil('membro-a', 'uid-a', ativo: false)],
      ),
    );

    final controller = EscalaConfiguracaoController(
      repository: repo,
      usuarioId: 'gerente',
      perfilAcesso: 'gerente',
      agora: () => agora,
    );

    await controller.carregar();

    await expectLater(
      controller.salvarResponsavel('membro-a'),
      throwsA(isA<StateError>()),
    );
  });

  test('salva carga e impede retirar responsavel atual', () async {
    final repo = _FakeConfigRepo(
      EscalaConfiguracaoDados(
        configuracao: config('membro-a', 'uid-a'),
        membrosEquipe: [membro('membro-a', 'uid-a')],
        perfisOperacionais: [perfil('membro-a', 'uid-a')],
      ),
    );

    final controller = EscalaConfiguracaoController(
      repository: repo,
      usuarioId: 'admin',
      perfilAcesso: 'administrador',
      agora: () => agora,
    );

    await controller.carregar();

    await controller.salvarPerfil(
      membroEquipeId: 'membro-a',
      ativo: true,
      cargaHorariaCodigo: '240H',
    );

    expect(repo.perfilSalvo!.cargaHorariaCodigo, '240H');

    await expectLater(
      controller.salvarPerfil(
        membroEquipeId: 'membro-a',
        ativo: false,
        cargaHorariaCodigo: '240H',
      ),
      throwsA(isA<StateError>()),
    );
  });
}

class _FakeConfigRepo implements EscalaConfiguracaoRepository {
  _FakeConfigRepo(this.estado);

  EscalaConfiguracaoDados estado;
  EscalaConfiguracaoModel? configuracaoSalva;
  EscalaPerfilOperacionalModel? perfilSalvo;

  @override
  Future<EscalaConfiguracaoDados> carregarConfiguracaoOperacional() async =>
      estado;

  @override
  Future<void> salvarConfiguracaoEscala(
    EscalaConfiguracaoModel configuracao,
  ) async {
    configuracaoSalva = configuracao;
    estado = EscalaConfiguracaoDados(
      configuracao: configuracao,
      membrosEquipe: estado.membrosEquipe,
      perfisOperacionais: estado.perfisOperacionais,
    );
  }

  @override
  Future<void> salvarPerfilOperacional(
    EscalaPerfilOperacionalModel perfil,
  ) async {
    perfilSalvo = perfil;

    final perfis = [
      ...estado.perfisOperacionais.where((item) => item.id != perfil.id),
      perfil,
    ];

    estado = EscalaConfiguracaoDados(
      configuracao: estado.configuracao,
      membrosEquipe: estado.membrosEquipe,
      perfisOperacionais: perfis,
    );
  }
}
