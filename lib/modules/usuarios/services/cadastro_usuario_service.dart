import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../models/convite_usuario_model.dart';
import 'convite_usuario_csv_parser.dart';

class CadastroUsuarioService {
  CadastroUsuarioService({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  static const _uuid = Uuid();

  CollectionReference<Map<String, dynamic>> get _convites =>
      _firestore.collection('convites_usuarios');

  Future<List<ConviteUsuarioModel>> listarConvites() async {
    final snapshot = await _convites
        .orderBy('criadoEm', descending: true)
        .get();
    return snapshot.docs
        .map(
          (doc) => ConviteUsuarioModel.fromMap(doc.data(), documentId: doc.id),
        )
        .toList(growable: false);
  }

  Future<String> criarConvite({
    required ConviteUsuarioEntrada entrada,
    required String criadoPor,
  }) async {
    final id = _uuid.v4();
    final agora = DateTime.now().toUtc();
    await _convites.doc(id).set({
      'nome': entrada.nome.trim(),
      'email': entrada.email.trim().toLowerCase(),
      'telefone': entrada.telefone.trim(),
      'cargo': entrada.cargo.trim(),
      'setor': entrada.setor.trim(),
      'perfilAcesso': entrada.perfilAcesso.trim().toLowerCase(),
      'status': 'pendente',
      'criadoPor': criadoPor,
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
      'expiraEm': Timestamp.fromDate(agora.add(const Duration(days: 30))),
      'usuarioId': '',
    });
    return id;
  }

  Future<List<String>> criarConvitesEmLote({
    required List<ConviteUsuarioEntrada> entradas,
    required String criadoPor,
  }) async {
    if (entradas.length > 400) {
      throw ArgumentError('O lote deve possuir no máximo 400 usuários.');
    }
    final ids = <String>[];
    final batch = _firestore.batch();
    final agora = DateTime.now().toUtc();
    for (final entrada in entradas) {
      final id = _uuid.v4();
      ids.add(id);
      batch.set(_convites.doc(id), {
        'nome': entrada.nome.trim(),
        'email': entrada.email.trim().toLowerCase(),
        'telefone': entrada.telefone.trim(),
        'cargo': entrada.cargo.trim(),
        'setor': entrada.setor.trim(),
        'perfilAcesso': entrada.perfilAcesso.trim().toLowerCase(),
        'status': 'pendente',
        'criadoPor': criadoPor,
        'criadoEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
        'expiraEm': Timestamp.fromDate(agora.add(const Duration(days: 30))),
        'usuarioId': '',
      });
    }
    await batch.commit();
    return List.unmodifiable(ids);
  }

  Future<void> criarIdentidade({
    required String email,
    required String senha,
  }) async {
    final credencial = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: senha,
    );
    await credencial.user?.sendEmailVerification();
    await _firebaseAuth.signOut();
  }

  Future<void> vincularConvite(String conviteId) async {
    final usuario = _firebaseAuth.currentUser;
    if (usuario == null) throw StateError('Sessão não autenticada.');
    await usuario.reload();
    final atual = _firebaseAuth.currentUser;
    if (atual == null || !atual.emailVerified) {
      throw StateError('Confirme o e-mail antes de vincular o convite.');
    }

    final conviteRef = _convites.doc(conviteId.trim());
    final usuarioRef = _firestore.collection('usuarios').doc(atual.uid);
    final membroRef = _firestore
        .collection('equipe_operacional')
        .doc(atual.uid);
    await _firestore.runTransaction((transaction) async {
      final conviteDoc = await transaction.get(conviteRef);
      if (!conviteDoc.exists) throw StateError('Convite não localizado.');
      final convite = conviteDoc.data()!;
      final emailConvite = convite['email']?.toString().trim().toLowerCase();
      if (emailConvite != atual.email?.trim().toLowerCase()) {
        throw StateError('O convite pertence a outro e-mail.');
      }
      if (convite['status'] != 'pendente') {
        throw StateError('Este convite já foi utilizado ou cancelado.');
      }
      final expiraEm = convite['expiraEm'];
      if (expiraEm is! Timestamp ||
          expiraEm.toDate().isBefore(DateTime.now())) {
        throw StateError('Este convite expirou.');
      }

      final perfil = convite['perfilAcesso']?.toString() ?? '';
      transaction.set(usuarioRef, {
        'nome': convite['nome'],
        'email': convite['email'],
        'telefone': convite['telefone'],
        'cargo': convite['cargo'],
        'setor': convite['setor'],
        'perfilAcesso': perfil,
        'ativo': false,
        'dataCriacao': FieldValue.serverTimestamp(),
        'ultimoAcesso': null,
        'escopoAcesso': {
          'regionalIds': <String>[],
          'equipeIds': <String>[],
          'projetoIds': <String>[],
          'scopeVersion': 1,
        },
        'conviteId': conviteId.trim(),
      });
      if (perfil == 'agente' || perfil == 'coordenador') {
        transaction.set(membroRef, {
          'usuarioId': atual.uid,
          'nome': convite['nome'],
          'vinculo': 'agente',
          'podeCoordenar': perfil == 'coordenador',
          'ativo': false,
          'origem': 'convite',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      transaction.update(conviteRef, {
        'status': 'utilizado',
        'usuarioId': atual.uid,
        'utilizadoEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> atualizarAtivacao({
    required String usuarioId,
    required bool ativo,
    required String atualizadoPor,
  }) {
    return _firestore.collection('usuarios').doc(usuarioId).update({
      'ativo': ativo,
      'ativadoEm': FieldValue.serverTimestamp(),
      'ativadoPor': atualizadoPor,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
