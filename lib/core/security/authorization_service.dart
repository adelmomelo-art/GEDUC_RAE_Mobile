import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/usuario_model.dart';
import '../services/usuario_service.dart';
import 'authorization_policy.dart';
import 'authorization_result.dart';
import 'permission.dart';

class AuthorizationService extends ChangeNotifier {
  AuthorizationService._({
    FirebaseAuth? firebaseAuth,
    UsuarioService? usuarioService,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _usuarioService = usuarioService ?? UsuarioService() {
    _authSubscription = _firebaseAuth.authStateChanges().listen(
          _onAuthStateChanged,
        );
  }

  static final AuthorizationService instance = AuthorizationService._();

  final FirebaseAuth _firebaseAuth;
  final UsuarioService _usuarioService;

  StreamSubscription<User?>? _authSubscription;
  UsuarioModel? _usuarioAtual;
  String? _uidCarregado;
  bool _carregando = false;
  Object? _ultimoErro;
  Future<void>? _carregamentoEmAndamento;

  UsuarioModel? get usuarioAtual => _usuarioAtual;
  bool get carregando => _carregando;
  Object? get ultimoErro => _ultimoErro;
  String get perfilAtual => AuthorizationPolicy.normalizarPerfil(
        _usuarioAtual?.perfilAcesso,
      );

  bool get autenticado => _firebaseAuth.currentUser != null;

  Future<void> garantirUsuarioAtual() {
    final uid = _firebaseAuth.currentUser?.uid;

    if (uid == null) {
      _limparUsuarioAtual();
      return Future<void>.value();
    }

    if (_uidCarregado == uid && _usuarioAtual != null) {
      return Future<void>.value();
    }

    return _carregamentoEmAndamento ??= _carregarUsuario(uid).whenComplete(() {
      _carregamentoEmAndamento = null;
    });
  }

  AuthorizationResult avaliar(Permission permissao) {
    if (!autenticado) {
      return AuthorizationResult.negado(
        permissao: permissao,
        perfilAcesso: perfilAtual,
        motivo: 'É necessário autenticar-se para acessar este recurso.',
      );
    }

    if (_usuarioAtual == null) {
      return AuthorizationResult.negado(
        permissao: permissao,
        perfilAcesso: perfilAtual,
        motivo: 'O perfil de acesso do usuário não pôde ser identificado.',
      );
    }

    if (AuthorizationPolicy.possuiPermissao(
      perfilAcesso: _usuarioAtual!.perfilAcesso,
      permissao: permissao,
    )) {
      return AuthorizationResult.autorizado(
        permissao: permissao,
        perfilAcesso: perfilAtual,
      );
    }

    return AuthorizationResult.negado(
      permissao: permissao,
      perfilAcesso: perfilAtual,
      motivo: 'O perfil atual não possui permissão para este recurso.',
    );
  }

  bool possuiPermissao(Permission permissao) => avaliar(permissao).autorizado;

  Future<AuthorizationResult> avaliarAtualizando(Permission permissao) async {
    await garantirUsuarioAtual();
    return avaliar(permissao);
  }

  Future<void> recarregar() async {
    _uidCarregado = null;
    _usuarioAtual = null;
    await garantirUsuarioAtual();
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _limparUsuarioAtual();
      return;
    }

    if (_uidCarregado != user.uid || _usuarioAtual == null) {
      await garantirUsuarioAtual();
    }
  }

  Future<void> _carregarUsuario(String uid) async {
    _carregando = true;
    _ultimoErro = null;
    notifyListeners();

    try {
      _usuarioAtual = await _usuarioService.buscarUsuario(uid);
      _uidCarregado = uid;
    } catch (erro) {
      _usuarioAtual = null;
      _uidCarregado = uid;
      _ultimoErro = erro;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  void _limparUsuarioAtual() {
    final precisaNotificar =
        _usuarioAtual != null || _uidCarregado != null || _ultimoErro != null;

    _usuarioAtual = null;
    _uidCarregado = null;
    _ultimoErro = null;
    _carregando = false;

    if (precisaNotificar) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
