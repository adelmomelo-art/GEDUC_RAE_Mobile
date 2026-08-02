import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/usuario_model.dart';

class UsuarioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UsuarioModel>> listarUsuarios() async {
    final snapshot = await _firestore
        .collection('usuarios')
        .orderBy('nome')
        .get();

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
    final doc = await _firestore
        .collection('usuarios')
        .doc(uid)
        .get();

    if (!doc.exists) {
      return null;
    }

    return UsuarioModel.fromMap(
      doc.data()!,
      documentId: doc.id,
    );
  }
}
