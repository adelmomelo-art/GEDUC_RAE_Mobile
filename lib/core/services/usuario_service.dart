import 'package:cloud_firestore/cloud_firestore.dart';

import '../security/access_scope.dart';
import '../security/scope_catalogs.dart';
import '../../data/models/usuario_model.dart';

class UsuarioService {
  UsuarioService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<UsuarioModel>> listarUsuarios() async {
    final snapshot =
        await _firestore.collection('usuarios').orderBy('nome').get();

    return snapshot.docs
        .map(
          (doc) => UsuarioModel.fromMap(
            doc.data(),
            documentId: doc.id,
          ),
        )
        .toList();
  }

  Future<UsuarioModel?> buscarUsuario(String uid) async {
    final doc = await _firestore.collection('usuarios').doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    return UsuarioModel.fromMap(
      doc.data()!,
      documentId: doc.id,
    );
  }

  Future<ScopeCatalogs> carregarCatalogosEscopo() async {
    final resultados = await Future.wait([
      _firestore.collection('regionais').where('ativo', isEqualTo: true).get(),
      _firestore.collection('equipes').where('ativo', isEqualTo: true).get(),
      _firestore.collection('projetos').where('ativo', isEqualTo: true).get(),
    ]);

    return ScopeCatalogs(
      regionais: _itens(resultados[0]),
      equipes: _itens(resultados[1]),
      projetos: _itens(resultados[2]),
    );
  }

  Future<void> atualizarEscopo({
    required String usuarioId,
    required AccessScope escopo,
    required String atualizadoPor,
  }) async {
    if (usuarioId.trim().isEmpty || atualizadoPor.trim().isEmpty) {
      throw ArgumentError(
          'Usuário e responsável pela alteração são obrigatórios.');
    }

    await _firestore.runTransaction((transaction) async {
      final usuarioRef = _firestore.collection('usuarios').doc(usuarioId);
      final usuario = await transaction.get(usuarioRef);
      if (!usuario.exists) throw StateError('Usuário não encontrado.');

      await _validarReferencias(
        transaction: transaction,
        colecao: 'regionais',
        ids: escopo.regionalIds,
      );
      await _validarReferencias(
        transaction: transaction,
        colecao: 'equipes',
        ids: escopo.equipeIds,
      );
      await _validarReferencias(
        transaction: transaction,
        colecao: 'projetos',
        ids: escopo.projetoIds,
      );

      transaction.update(usuarioRef, <String, dynamic>{
        'escopoAcesso': escopo.toMap(),
        'scopeUpdatedAt': FieldValue.serverTimestamp(),
        'scopeUpdatedBy': atualizadoPor,
      });
    });
  }

  Future<void> _validarReferencias({
    required Transaction transaction,
    required String colecao,
    required Iterable<String> ids,
  }) async {
    for (final id in ids) {
      final documento = await transaction.get(
        _firestore.collection(colecao).doc(id),
      );
      if (!documento.exists || documento.data()?['ativo'] != true) {
        throw StateError('Referência inativa ou inexistente: $colecao/$id.');
      }
    }
  }

  List<ScopeCatalogItem> _itens(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final itens = snapshot.docs.map((documento) {
      final dados = documento.data();
      final nome = (dados['nome'] ?? dados['nomeRegional'] ?? dados['codigo'])
          ?.toString()
          .trim();
      return ScopeCatalogItem(
        id: documento.id,
        nome: nome?.isNotEmpty == true ? nome! : documento.id,
      );
    }).toList(growable: false)
      ..sort((a, b) => a.nome.compareTo(b.nome));
    return itens;
  }
}
