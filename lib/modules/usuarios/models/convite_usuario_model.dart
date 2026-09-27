import 'package:cloud_firestore/cloud_firestore.dart';

class ConviteUsuarioModel {
  const ConviteUsuarioModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.cargo,
    required this.setor,
    required this.perfilAcesso,
    required this.status,
    required this.expiraEm,
    this.usuarioId = '',
  });

  final String id;
  final String nome;
  final String email;
  final String telefone;
  final String cargo;
  final String setor;
  final String perfilAcesso;
  final String status;
  final DateTime expiraEm;
  final String usuarioId;

  bool get pendente => status == 'pendente' && expiraEm.isAfter(DateTime.now());

  factory ConviteUsuarioModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    final expiraEm = map['expiraEm'];
    return ConviteUsuarioModel(
      id: documentId,
      nome: map['nome']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      telefone: map['telefone']?.toString() ?? '',
      cargo: map['cargo']?.toString() ?? '',
      setor: map['setor']?.toString() ?? '',
      perfilAcesso: map['perfilAcesso']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      expiraEm: expiraEm is Timestamp
          ? expiraEm.toDate()
          : DateTime.tryParse(expiraEm?.toString() ?? '') ?? DateTime(1970),
      usuarioId: map['usuarioId']?.toString() ?? '',
    );
  }
}
