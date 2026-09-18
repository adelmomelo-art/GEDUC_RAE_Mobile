import 'package:flutter/foundation.dart';

import '../../../data/models/membro_equipe_model.dart';
import '../data/escala_configuracao_repository.dart';
import '../models/escala_models.dart';
import '../security/escala_navigation_policy.dart';

class EscalaConfiguracaoController extends ChangeNotifier {
  EscalaConfiguracaoController({
    required EscalaConfiguracaoRepository repository,
    required String usuarioId,
    required String perfilAcesso,
    DateTime Function()? agora,
  })  : _repository = repository,
        _usuarioId = usuarioId.trim(),
        _perfilAcesso = perfilAcesso.trim(),
        _agora = agora ?? DateTime.now;

  static const cargasHorarias = <String>['180H', '240H'];

  final EscalaConfiguracaoRepository _repository;
  final String _usuarioId;
  final String _perfilAcesso;
  final DateTime Function() _agora;

  EscalaConfiguracaoDados? _dados;
  bool _loading = false;
  bool _saving = false;
  Object? _erro;

  bool get loading => _loading;
  bool get saving => _saving;
  Object? get erro => _erro;
  EscalaConfiguracaoDados? get dados => _dados;

  bool get podeConfigurar => EscalaNavigationPolicy.podeConfigurar(
        perfilAcesso: _perfilAcesso,
        usuarioId: _usuarioId,
      );

  String get responsavelAtualMembroId => _dados?.configuracao?.ativo == true
      ? _dados!.configuracao!.responsavelEscalaMembroEquipeId.trim()
      : '';

  List<EscalaConfiguracaoMembro> get membros {
    final atual = _dados;
    if (atual == null) return const <EscalaConfiguracaoMembro>[];

    final perfisPorMembro = <String, EscalaPerfilOperacionalModel>{};
    for (final perfil in atual.perfisOperacionais) {
      final membroId = perfil.membroEquipeId.trim();
      if (membroId.isEmpty) continue;

      final existente = perfisPorMembro[membroId];
      if (existente == null ||
          (!existente.ativo && perfil.ativo) ||
          (existente.setorCodigo != 'GEDUC' && perfil.setorCodigo == 'GEDUC')) {
        perfisPorMembro[membroId] = perfil;
      }
    }

    final itens = atual.membrosEquipe
        .map(
          (membro) => EscalaConfiguracaoMembro(
            membro: membro,
            perfil: perfisPorMembro[membro.id],
          ),
        )
        .toList()
      ..sort(
        (a, b) => a.membro.nome.toLowerCase().compareTo(
              b.membro.nome.toLowerCase(),
            ),
      );

    return List<EscalaConfiguracaoMembro>.unmodifiable(itens);
  }

  List<EscalaConfiguracaoMembro> get candidatosResponsavel =>
      membros.where((item) => item.elegivelResponsavel).toList(growable: false);

  Future<void> carregar() async {
    _loading = true;
    _erro = null;
    notifyListeners();

    try {
      _dados = await _repository.carregarConfiguracaoOperacional();
    } catch (erro) {
      _erro = erro;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> salvarResponsavel(String membroEquipeId) async {
    _validarPermissao();

    final candidato =
        candidatosResponsavel.cast<EscalaConfiguracaoMembro?>().firstWhere(
              (item) => item?.membro.id == membroEquipeId,
              orElse: () => null,
            );

    if (candidato == null) {
      throw StateError(
        'O responsável deve ser integrante ativo da GEDUC, possuir perfil '
        'operacional ativo e usuário canônico.',
      );
    }

    final agora = _agora();

    final configuracao = EscalaConfiguracaoModel(
      id: 'principal',
      responsavelEscalaUsuarioId: candidato.membro.usuarioId.trim(),
      responsavelEscalaMembroEquipeId: candidato.membro.id,
      ativo: true,
      designadoPor: _usuarioId,
      designadoEm: agora,
    );

    await _executarSalvamento(
      () => _repository.salvarConfiguracaoEscala(configuracao),
    );
  }

  Future<void> salvarPerfil({
    required String membroEquipeId,
    required bool ativo,
    required String cargaHorariaCodigo,
  }) async {
    _validarPermissao();

    final carga = cargaHorariaCodigo.trim().toUpperCase();
    if (!cargasHorarias.contains(carga)) {
      throw StateError('Carga horária inválida para a Escala GEDUC.');
    }

    final item = membros.cast<EscalaConfiguracaoMembro?>().firstWhere(
          (linha) => linha?.membro.id == membroEquipeId,
          orElse: () => null,
        );

    if (item == null) {
      throw StateError('Integrante da Equipe Operacional não encontrado.');
    }

    if (ativo && !item.membro.ativo) {
      throw StateError(
        'Integrante inativo na Equipe Operacional não pode ser ativado '
        'na Escala GEDUC.',
      );
    }

    if (!ativo && responsavelAtualMembroId == membroEquipeId) {
      throw StateError(
        'Designe outro responsável antes de retirar o responsável atual '
        'da Escala GEDUC.',
      );
    }

    final existente = item.perfil;
    final agora = _agora();

    final perfil = EscalaPerfilOperacionalModel(
      id: existente?.id.trim().isNotEmpty == true
          ? existente!.id
          : item.membro.id,
      membroEquipeId: item.membro.id,
      usuarioId: existente == null
          ? item.membro.usuarioId.trim()
          : existente.usuarioId.trim(),
      setorCodigo: 'GEDUC',
      cargaHorariaCodigo: carga,
      ativo: ativo,
      criadoPor: existente?.criadoPor.trim().isNotEmpty == true
          ? existente!.criadoPor
          : _usuarioId,
      criadoEm: existente?.criadoEm ?? agora,
      atualizadoPor: _usuarioId,
      atualizadoEm: agora,
    );

    await _executarSalvamento(
      () => _repository.salvarPerfilOperacional(perfil),
    );
  }

  void _validarPermissao() {
    if (!podeConfigurar) {
      throw StateError(
        'Somente Gerente ou Administrador podem configurar a Escala GEDUC.',
      );
    }
  }

  Future<void> _executarSalvamento(Future<void> Function() operacao) async {
    if (_saving) return;

    _saving = true;
    _erro = null;
    notifyListeners();

    try {
      await operacao();
      _dados = await _repository.carregarConfiguracaoOperacional();
    } catch (erro) {
      _erro = erro;
      rethrow;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}

class EscalaConfiguracaoMembro {
  const EscalaConfiguracaoMembro({required this.membro, required this.perfil});

  final MembroEquipeModel membro;
  final EscalaPerfilOperacionalModel? perfil;

  bool get ativoNaEscala =>
      membro.ativo &&
      perfil?.ativo == true &&
      perfil?.setorCodigo.trim().toUpperCase() == 'GEDUC';

  String get cargaHorariaCodigo {
    final valor = perfil?.cargaHorariaCodigo.trim().toUpperCase() ?? '';
    return EscalaConfiguracaoController.cargasHorarias.contains(valor)
        ? valor
        : '180H';
  }

  bool get identidadeCanonica =>
      membro.usuarioId.trim().isNotEmpty &&
      (perfil == null ||
          perfil!.usuarioId.trim().isEmpty ||
          perfil!.usuarioId.trim() == membro.usuarioId.trim());

  bool get elegivelResponsavel =>
      ativoNaEscala &&
      identidadeCanonica &&
      membro.vinculo == VinculoOperacional.agente;
}
