import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/tipo_acao_model.dart';

abstract interface class TipoAcaoDataSource {
  Future<List<TipoAcaoModel>> listarTiposAcoes({bool somenteAtivos = false});

  Future<TipoAcaoModel> salvarTipoAcao(TipoAcaoModel tipoAcao);

  Future<void> atualizarTipoAcao(TipoAcaoModel tipoAcao);

  Future<void> alterarStatus(String id, bool ativo);
}

class TipoAcaoService implements TipoAcaoDataSource {
  TipoAcaoService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String collectionPath = 'tipos_acoes';

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(collectionPath);

  @override
  Future<List<TipoAcaoModel>> listarTiposAcoes({
    bool somenteAtivos = false,
  }) async {
    final snapshot = await _collection.orderBy('nomeAcao').get();

    final tipos = snapshot.docs
        .map(
          (documento) =>
              TipoAcaoModel.fromMap(documento.data(), documentId: documento.id),
        )
        .where((tipo) => !somenteAtivos || tipo.ativo)
        .toList(growable: false);

    return List<TipoAcaoModel>.unmodifiable(tipos);
  }

  @override
  Future<TipoAcaoModel> salvarTipoAcao(TipoAcaoModel tipoAcao) async {
    final normalizado = tipoAcao.normalizado();
    final referencia = normalizado.id.isEmpty
        ? _collection.doc()
        : _collection.doc(normalizado.id);
    final persistido = normalizado.copyWith(id: referencia.id);

    await referencia.set(<String, dynamic>{
      ...persistido.toMap(incluirMetadados: false),
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    });

    return persistido;
  }

  @override
  Future<void> atualizarTipoAcao(TipoAcaoModel tipoAcao) async {
    final normalizado = tipoAcao.normalizado();
    if (normalizado.id.isEmpty) {
      throw ArgumentError.value(
        normalizado.id,
        'tipoAcao.id',
        'O identificador é obrigatório para atualizar.',
      );
    }

    final dados = normalizado.toMap(incluirMetadados: false)..remove('id');

    await _collection.doc(normalizado.id).set(<String, dynamic>{
      ...dados,
      'id': normalizado.id,
      'atualizadoEm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> alterarStatus(String id, bool ativo) async {
    final identificador = id.trim();
    if (identificador.isEmpty) {
      throw ArgumentError.value(
        id,
        'id',
        'O identificador é obrigatório para alterar o status.',
      );
    }

    await _collection.doc(identificador).update(<String, dynamic>{
      'ativo': ativo,
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }
}
