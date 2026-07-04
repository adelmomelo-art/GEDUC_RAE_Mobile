import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCadastroService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> salvar({required String colecao, required String id, required Map<String,dynamic> dados}) async => _firestore.collection(colecao).doc(id).set(dados);
  Future<List<Map<String,dynamic>>> listar(String colecao) async {
    final snapshot = await _firestore.collection(colecao).get();
    return snapshot.docs.map((doc)=>doc.data()).toList();
  }
}
