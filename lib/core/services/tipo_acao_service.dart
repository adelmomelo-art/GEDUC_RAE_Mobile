import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/tipo_acao_model.dart';

class TipoAcaoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<TipoAcaoModel>> listarTiposAcoes() async {
    final snapshot = await _firestore.collection('tipos_acoes').orderBy('nomeAcao').get();
    return snapshot.docs.map((doc)=>TipoAcaoModel.fromMap(doc.data())).toList();
  }
  Future<void> salvarTipoAcao(TipoAcaoModel tipoAcao) async => _firestore.collection('tipos_acoes').doc(tipoAcao.id).set(tipoAcao.toMap());
}
