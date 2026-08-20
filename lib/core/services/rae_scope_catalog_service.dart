import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/equipe_model.dart';
import '../../data/models/projeto_model.dart';

class RaeScopeCatalogService {
  RaeScopeCatalogService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<EquipeModel>> listarEquipes() async {
    final snapshot = await _firestore.collection('equipes').get();

    return snapshot.docs
        .map(
          (doc) => EquipeModel.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .where((equipe) => equipe.valido)
        .toList(growable: false);
  }

  Future<List<ProjetoModel>> listarProjetos() async {
    final snapshot = await _firestore.collection('projetos').get();

    return snapshot.docs
        .map(
          (doc) => ProjetoModel.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .where((projeto) => projeto.valido)
        .toList(growable: false);
  }
}
