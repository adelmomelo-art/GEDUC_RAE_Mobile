import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/usuario_model.dart';
import '../services/usuario_service.dart';
import 'access_scope.dart';
import 'authorization_policy.dart';
import 'authorization_result.dart';
import 'identity_status.dart';
import 'permission.dart';
import 'rae_access_policy.dart';
import 'rae_access_record.dart';

class AuthorizationService extends ChangeNotifier {
  AuthorizationService._({
    FirebaseAuth? firebaseAuth,
    UsuarioService? usuarioService,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _usuarioService = usuarioService ?? UsuarioService() {
    _status = _firebaseAuth.currentUser == null
        ? IdentityStatus.naoAutenticado
        : IdentityStatus.carregando;
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
  late IdentityStatus _status;
  Object? _ultimoErro;
  Future<void>? _carregamentoEmAndamento;
  String? _uidEmCarregamento;
  int _geracaoSessao = 0;

  UsuarioModel? get usuarioAtual => _usuarioAtual;
  AccessScope get escopoAtual => _usuarioAtual?.escopoAcesso ?? AccessScope();
  IdentityStatus get status => _status;
  bool get carregando => _status == IdentityStatus.carregando;
  bool get identidadeValida => _status.identidadeValida;
  Object? get ultimoErro => _ultimoErro;

  String get perfilAtual => AuthorizationPolicy.normalizarPerfil(
        _usuarioAtual?.perfilAcesso,
      );

  bool get autenticado => _firebaseAuth.currentUser != null;

  Future<void> garantirUsuarioAtual() {
    final uid = _firebaseAuth.currentUser?.uid;

    if (uid == null) {
      _definirNaoAutenticado();
      return Future<void>.value();
    }

    if (_uidCarregado == uid && _status != IdentityStatus.carregando) {
      return Future<void>.value();
    }

    if (_uidEmCarregamento == uid && _carregamentoEmAndamento != null) {
      return _carregamentoEmAndamento!;
    }

    final geracao = _geracaoSessao;
    _uidEmCarregamento = uid;
    _carregamentoEmAndamento = _carregarUsuario(
      uid: uid,
      geracao: geracao,
    ).whenComplete(() {
      if (_geracaoSessao == geracao && _uidEmCarregamento == uid) {
        _uidEmCarregamento = null;
        _carregamentoEmAndamento = null;
      }
    });

    return _carregamentoEmAndamento!;
  }

  AuthorizationResult avaliar(Permission permissao) {
    if (!autenticado || _status == IdentityStatus.naoAutenticado) {
      return AuthorizationResult.negado(
        permissao: permissao,
        perfilAcesso: perfilAtual,
        motivo: 'É necessário autenticar-se para acessar este recurso.',
      );
    }

    if (!identidadeValida || _usuarioAtual == null) {
      return AuthorizationResult.negado(
        permissao: permissao,
        perfilAcesso: perfilAtual,
        motivo: _motivoBloqueio,
      );
    }

    if (perfilAtual == 'gerente' &&
        AuthorizationPolicy.exigeEscopoCompletoDoGerente(permissao) &&
        !_usuarioAtual!.escopoAcesso.completoParaGerente) {
      return AuthorizationResult.negado(
        permissao: permissao,
        perfilAcesso: perfilAtual,
        motivo: 'O escopo do Gerente está incompleto.',
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

  bool possuiPermissaoNoRae({
    required Permission permissao,
    required RaeAccessRecord rae,
  }) {
    final usuario = _usuarioAtual;
    if (!identidadeValida || usuario == null) return false;
    return RaeAccessPolicy.autoriza(
      perfilAcesso: usuario.perfilAcesso,
      usuarioId: usuario.id,
      permissao: permissao,
      rae: rae,
      escopo: usuario.escopoAcesso,
    );
  }

  bool get podeCriarRae {
    final usuario = _usuarioAtual;
    if (!identidadeValida || usuario == null) return false;
    return RaeAccessPolicy.autorizaCriacao(
      perfilAcesso: usuario.perfilAcesso,
      usuarioId: usuario.id,
    );
  }

  Future<AuthorizationResult> avaliarAtualizando(Permission permissao) async {
    await garantirUsuarioAtual();
    return avaliar(permissao);
  }

  Future<void> recarregar() async {
    final user = _firebaseAuth.currentUser;
    _geracaoSessao++;
    _invalidarCarregamento();

    if (user == null) {
      _definirNaoAutenticado();
      return;
    }

    _usuarioAtual = null;
    _uidCarregado = null;
    _status = IdentityStatus.carregando;
    _ultimoErro = null;
    notifyListeners();
    await garantirUsuarioAtual();
  }

  Future<void> encerrarSessao() async {
    _geracaoSessao++;
    _invalidarCarregamento();
    _definirNaoAutenticado();
    await _firebaseAuth.signOut();
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _geracaoSessao++;
    _invalidarCarregamento();

    if (user == null) {
      _definirNaoAutenticado();
      return;
    }

    _usuarioAtual = null;
    _uidCarregado = null;
    _status = IdentityStatus.carregando;
    _ultimoErro = null;
    notifyListeners();
    await garantirUsuarioAtual();
  }

  Future<void> _carregarUsuario({
    required String uid,
    required int geracao,
  }) async {
    _status = IdentityStatus.carregando;
    _ultimoErro = null;

    try {
      final usuario = await _usuarioService.buscarUsuario(uid);
      if (!_resultadoAindaPertenceASessao(uid, geracao)) return;

      _uidCarregado = uid;
      _usuarioAtual = usuario;

      if (usuario == null) {
        _status = IdentityStatus.semCadastro;
      } else if (!usuario.ativo) {
        _status = IdentityStatus.inativo;
      } else if (!AuthorizationPolicy.perfilReconhecido(
        usuario.perfilAcesso,
      )) {
        _status = IdentityStatus.perfilInvalido;
      } else {
        _status = IdentityStatus.ativo;
      }
    } catch (erro) {
      if (!_resultadoAindaPertenceASessao(uid, geracao)) return;
      _uidCarregado = uid;
      _usuarioAtual = null;
      _status = IdentityStatus.erro;
      _ultimoErro = erro;
    } finally {
      if (_resultadoAindaPertenceASessao(uid, geracao)) {
        notifyListeners();
      }
    }
  }

  bool _resultadoAindaPertenceASessao(String uid, int geracao) {
    return geracao == _geracaoSessao && _firebaseAuth.currentUser?.uid == uid;
  }

  void _invalidarCarregamento() {
    _carregamentoEmAndamento = null;
    _uidEmCarregamento = null;
  }

  void _definirNaoAutenticado() {
    final precisaNotificar = _status != IdentityStatus.naoAutenticado ||
        _usuarioAtual != null ||
        _uidCarregado != null ||
        _ultimoErro != null;

    _usuarioAtual = null;
    _uidCarregado = null;
    _status = IdentityStatus.naoAutenticado;
    _ultimoErro = null;

    if (precisaNotificar) notifyListeners();
  }

  String get _motivoBloqueio {
    return switch (_status) {
      IdentityStatus.carregando => 'A identidade ainda está sendo validada.',
      IdentityStatus.semCadastro =>
        'Não existe cadastro operacional vinculado a esta conta.',
      IdentityStatus.inativo => 'Esta conta está inativa na Plataforma Fênix.',
      IdentityStatus.perfilInvalido =>
        'O perfil de acesso da conta não é reconhecido.',
      IdentityStatus.erro =>
        'Não foi possível validar a identidade desta conta.',
      _ => 'A identidade atual não está autorizada.',
    };
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
