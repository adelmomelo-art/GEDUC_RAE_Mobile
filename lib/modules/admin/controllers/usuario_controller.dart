import 'package:flutter/foundation.dart';

import '../../../core/security/access_scope.dart';
import '../../../core/security/scope_catalogs.dart';
import '../../../data/models/usuario_model.dart';
import '../../../repositories/usuario_repository.dart';
import '../../usuarios/models/convite_usuario_model.dart';
import '../../usuarios/services/cadastro_usuario_service.dart';
import '../../usuarios/services/convite_usuario_csv_parser.dart';

class UsuarioController extends ChangeNotifier {
  UsuarioController({
    required UsuarioRepository usuarioRepository,
    CadastroUsuarioService? cadastroUsuarioService,
  }) : _usuarioRepository = usuarioRepository,
       _cadastroUsuarioService =
           cadastroUsuarioService ?? CadastroUsuarioService();

  final UsuarioRepository _usuarioRepository;
  final CadastroUsuarioService _cadastroUsuarioService;

  List<UsuarioModel> _usuarios = const [];
  List<ConviteUsuarioModel> _convites = const [];
  bool _carregando = false;
  Object? _erro;

  List<UsuarioModel> get usuarios => List.unmodifiable(_usuarios);
  List<ConviteUsuarioModel> get convites => List.unmodifiable(_convites);
  bool get carregando => _carregando;
  Object? get erro => _erro;
  bool get possuiErro => _erro != null;

  Future<void> carregarUsuarios({bool forcar = false}) async {
    if (_carregando) return;
    if (!forcar && _usuarios.isNotEmpty && _erro == null) return;

    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final resultados = await Future.wait([
        _usuarioRepository.listarUsuarios(),
        _cadastroUsuarioService.listarConvites(),
      ]);
      _usuarios = resultados[0] as List<UsuarioModel>;
      _convites = resultados[1] as List<ConviteUsuarioModel>;
    } catch (erro) {
      _erro = erro;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> recarregar() => carregarUsuarios(forcar: true);

  Future<ScopeCatalogs> carregarCatalogosEscopo() {
    return _usuarioRepository.carregarCatalogosEscopo();
  }

  Future<void> atualizarEscopo({
    required UsuarioModel usuario,
    required AccessScope escopo,
    required String atualizadoPor,
  }) async {
    await _usuarioRepository.atualizarEscopo(
      usuarioId: usuario.id,
      escopo: escopo,
      atualizadoPor: atualizadoPor,
    );
    await recarregar();
  }

  Future<String> criarConvite({
    required ConviteUsuarioEntrada entrada,
    required String criadoPor,
  }) async {
    final id = await _cadastroUsuarioService.criarConvite(
      entrada: entrada,
      criadoPor: criadoPor,
    );
    await recarregar();
    return id;
  }

  Future<int> importarCsv({
    required String conteudo,
    required String criadoPor,
  }) async {
    final entradas = ConviteUsuarioCsvParser.parse(conteudo);
    await _cadastroUsuarioService.criarConvitesEmLote(
      entradas: entradas,
      criadoPor: criadoPor,
    );
    await recarregar();
    return entradas.length;
  }

  Future<void> atualizarAtivacao({
    required UsuarioModel usuario,
    required bool ativo,
    required String atualizadoPor,
  }) async {
    await _cadastroUsuarioService.atualizarAtivacao(
      usuarioId: usuario.id,
      ativo: ativo,
      atualizadoPor: atualizadoPor,
    );
    await recarregar();
  }
}
