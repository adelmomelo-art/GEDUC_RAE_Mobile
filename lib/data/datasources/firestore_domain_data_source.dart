import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/domain_model.dart';
import 'domain_data_source.dart';

class DomainAlreadyExistsException implements Exception {
  final String id;

  const DomainAlreadyExistsException(this.id);

  @override
  String toString() => 'Já existe um domínio com o identificador "$id".';
}

class DomainNotFoundException implements Exception {
  final String id;

  const DomainNotFoundException(this.id);

  @override
  String toString() => 'O domínio "$id" não foi encontrado.';
}

class FirestoreDomainDataSource implements DomainDataSource {
  static const String collectionName = 'domains';

  final FirebaseFirestore firestore;

  FirestoreDomainDataSource({
    FirebaseFirestore? firestore,
  }) : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection {
    return firestore.collection(collectionName);
  }

  @override
  Future<List<DomainModel>> listarTodos() async {
    final snapshot = await _collection.get();

    final domains = snapshot.docs
        .map(_fromDocument)
        .toList()
      ..sort(_comparar);

    return List<DomainModel>.unmodifiable(domains);
  }

  @override
  Future<List<DomainModel>> listarPorGrupo(String grupo) async {
    final snapshot = await _collection
        .where('grupo', isEqualTo: grupo)
        .where('ativo', isEqualTo: true)
        .get();

    final domains = snapshot.docs
        .map(_fromDocument)
        .where((domain) => domain.vigente)
        .toList()
      ..sort(_comparar);

    return List<DomainModel>.unmodifiable(domains);
  }

  @override
  Future<DomainModel?> buscarPorId(String id) async {
    final document = await _collection.doc(id).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return _fromDocument(document);
  }

  @override
  Future<DomainModel?> buscarPorCodigo({
    required String grupo,
    required String codigo,
  }) async {
    final snapshot = await _collection
        .where('grupo', isEqualTo: grupo)
        .where('codigo', isEqualTo: codigo)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return _fromDocument(snapshot.docs.first);
  }

  @override
  Future<void> criar(DomainModel domain) async {
    final reference = _collection.doc(domain.id);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);

      if (snapshot.exists) {
        throw DomainAlreadyExistsException(domain.id);
      }

      transaction.set(
        reference,
        _toFirestore(
          domain,
          incluirCreatedAt: true,
        ),
      );
    });
  }

  @override
  Future<void> atualizar(DomainModel domain) async {
    final reference = _collection.doc(domain.id);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);

      if (!snapshot.exists) {
        throw DomainNotFoundException(domain.id);
      }

      transaction.update(
        reference,
        _toFirestore(domain),
      );
    });
  }

  @override
  Future<void> salvarTodosSeAusentes(
    List<DomainModel> domains,
  ) async {
    for (final domain in domains) {
      final reference = _collection.doc(domain.id);

      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(reference);

        if (!snapshot.exists) {
          transaction.set(
            reference,
            _toFirestore(
              domain,
              incluirCreatedAt: true,
            ),
          );
        }
      });
    }
  }

  @override
  Future<void> ativar(String id) {
    return _alterarStatus(
      id: id,
      ativo: true,
    );
  }

  @override
  Future<void> desativar(String id) {
    return _alterarStatus(
      id: id,
      ativo: false,
    );
  }

  Future<void> _alterarStatus({
    required String id,
    required bool ativo,
  }) async {
    final reference = _collection.doc(id);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);

      if (!snapshot.exists) {
        throw DomainNotFoundException(id);
      }

      transaction.update(
        reference,
        {
          'ativo': ativo,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    });
  }

  DomainModel _fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = Map<String, dynamic>.from(
      document.data() ?? const {},
    );

    data['id'] = document.id;
    data['inicioVigencia'] =
        _normalizarData(data['inicioVigencia']);
    data['fimVigencia'] =
        _normalizarData(data['fimVigencia']);

    return DomainModel.fromMap(data);
  }

  Map<String, dynamic> _toFirestore(
    DomainModel domain, {
    bool incluirCreatedAt = false,
  }) {
    final data = Map<String, dynamic>.from(domain.toMap());

    data.remove('id');
    data['inicioVigencia'] = domain.inicioVigencia;
    data['fimVigencia'] = domain.fimVigencia;
    data['updatedAt'] = FieldValue.serverTimestamp();

    if (incluirCreatedAt) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    return data;
  }

  dynamic _normalizarData(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return value;
  }

  int _comparar(DomainModel a, DomainModel b) {
    final grupo = a.grupo.compareTo(b.grupo);

    if (grupo != 0) {
      return grupo;
    }

    final ordem = a.ordem.compareTo(b.ordem);

    if (ordem != 0) {
      return ordem;
    }

    return a.nome.compareTo(b.nome);
  }
}
