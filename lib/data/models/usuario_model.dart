import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/security/access_scope.dart';

class UsuarioModel {
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final String cargo;
  final String setor;
  final String perfilAcesso;
  final bool ativo;
  final DateTime dataCriacao;
  final DateTime? ultimoAcesso;
  final AccessScope escopoAcesso;

  UsuarioModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.cargo,
    required this.setor,
    required this.perfilAcesso,
    required this.ativo,
    required this.dataCriacao,
    this.ultimoAcesso,
    AccessScope? escopoAcesso,
  }) : escopoAcesso = escopoAcesso ?? AccessScope();

  factory UsuarioModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    return UsuarioModel(
      id: documentId ?? map['id']?.toString() ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      telefone: map['telefone'] ?? '',
      cargo: map['cargo'] ?? '',
      setor: map['setor'] ?? '',
      perfilAcesso: map['perfilAcesso']?.toString() ?? '',
      ativo: map['ativo'] == true,
      dataCriacao: _converterData(map['dataCriacao']),
      ultimoAcesso: map['ultimoAcesso'] != null
          ? _converterData(map['ultimoAcesso'])
          : null,
      escopoAcesso: AccessScope.fromMap(
        map['escopoAcesso'] is Map
            ? Map<String, dynamic>.from(map['escopoAcesso'] as Map)
            : null,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'cargo': cargo,
      'setor': setor,
      'perfilAcesso': perfilAcesso,
      'ativo': ativo,
      'dataCriacao': Timestamp.fromDate(dataCriacao),
      'ultimoAcesso':
          ultimoAcesso != null ? Timestamp.fromDate(ultimoAcesso!) : null,
      'escopoAcesso': escopoAcesso.toMap(),
    };
  }

  static DateTime _converterData(dynamic valor) {
    if (valor is Timestamp) {
      return valor.toDate();
    }

    if (valor is String) {
      return DateTime.tryParse(valor) ?? DateTime.now();
    }

    return DateTime.now();
  }
}
