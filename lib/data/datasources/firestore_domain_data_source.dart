import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/domain_model.dart';
import 'domain_data_source.dart';

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
  Future<void> salvar(DomainModel domain) async {
    await _collection.doc(domain.id).set(
          _toFirestore(domain),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> salvarTodos(List<DomainModel> domains) async {
    if (domains.isEmpty) {
      return;
    }

    const batchLimit = 450;

    for (var inicio = 0; inicio < domains.length; inicio += batchLimit) {
      final fim = (inicio + batchLimit < domains.length)
          ? inicio + batchLimit
          : domains.length;

      final batch = firestore.batch();

      for (final domain in domains.sublist(inicio, fim)) {
        batch.set(
          _collection.doc(domain.id),
          _toFirestore(domain),
          SetOptions(merge: true),
        );
      }

      await batch.commit();
    }
  }

  @override
  Future<void> ativar(String id) async {
    await _collection.doc(id).set(
      {
        'ativo': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> desativar(String id) async {
    await _collection.doc(id).set(
      {
        'ativo': false,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  DomainModel _fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = Map<String, dynamic>.from(document.data() ?? const {});

    data['id'] = document.id;
    data['inicioVigencia'] = _normalizarData(data['inicioVigencia']);
    data['fimVigencia'] = _normalizarData(data['fimVigencia']);

    return DomainModel.fromMap(data);
  }

  Map<String, dynamic> _toFirestore(DomainModel domain) {
    final data = Map<String, dynamic>.from(domain.toMap());

    data.remove('id');
    data['inicioVigencia'] = domain.inicioVigencia;
    data['fimVigencia'] = domain.fimVigencia;
    data['updatedAt'] = FieldValue.serverTimestamp();

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
