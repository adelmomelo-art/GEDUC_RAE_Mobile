import 'package:cloud_firestore/cloud_firestore.dart';

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

  const UsuarioModel({
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
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      telefone: map['telefone'] ?? '',
      cargo: map['cargo'] ?? '',
      setor: map['setor'] ?? '',
      perfilAcesso: map['perfilAcesso'] ?? 'agente',
      ativo: map['ativo'] ?? true,
      dataCriacao: _converterData(map['dataCriacao']),
      ultimoAcesso: map['ultimoAcesso'] != null
          ? _converterData(map['ultimoAcesso'])
          : null,
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
      'ultimoAcesso': ultimoAcesso != null
          ? Timestamp.fromDate(ultimoAcesso!)
          : null,
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