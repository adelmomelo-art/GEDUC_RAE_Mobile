import 'package:cloud_firestore/cloud_firestore.dart';

enum VinculoOperacional {
  agente('agente', 'Agente'),
  terceirizado('terceirizado', 'Terceirizado');

  const VinculoOperacional(this.codigo, this.rotulo);

  final String codigo;
  final String rotulo;

  static VinculoOperacional fromCodigo(Object? valor) {
    return VinculoOperacional.values.firstWhere(
      (item) => item.codigo == valor?.toString().trim().toLowerCase(),
      orElse: () => VinculoOperacional.agente,
    );
  }
}

class MembroEquipeModel {
  const MembroEquipeModel({
    required this.id,
    required this.usuarioId,
    required this.nome,
    required this.vinculo,
    required this.podeCoordenar,
    required this.ativo,
    required this.origem,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String usuarioId;
  final String nome;
  final VinculoOperacional vinculo;
  final bool podeCoordenar;
  final bool ativo;
  final String origem;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory MembroEquipeModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    return MembroEquipeModel(
      id: documentId,
      usuarioId: map['usuarioId']?.toString() ?? '',
      nome: map['nome']?.toString() ?? '',
      vinculo: VinculoOperacional.fromCodigo(map['vinculo']),
      podeCoordenar: map['podeCoordenar'] == true,
      ativo: map['ativo'] != false,
      origem: map['origem']?.toString() ?? 'usuario',
      createdAt: _data(map['createdAt']),
      updatedAt: _data(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'nome': nome.trim(),
      'vinculo': vinculo.codigo,
      'podeCoordenar': podeCoordenar,
      'ativo': ativo,
      'origem': origem,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static DateTime _data(Object? valor) {
    if (valor is Timestamp) return valor.toDate();
    if (valor is DateTime) return valor;
    return DateTime.tryParse(valor?.toString() ?? '') ?? DateTime.now();
  }
}
