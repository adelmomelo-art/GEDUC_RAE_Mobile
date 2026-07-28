import '../../../data/models/acao_model.dart';

class HomeCacheData {
  const HomeCacheData({
    required this.totalAcoes,
    required this.totalPessoas,
    required this.totalVeiculos,
    required this.totalCredenciais,
    required this.ultimosRaes,
    required this.atualizadoEm,
  });

  final int totalAcoes;
  final int totalPessoas;
  final int totalVeiculos;
  final int totalCredenciais;
  final List<AcaoModel> ultimosRaes;
  final DateTime atualizadoEm;

  Map<String, dynamic> toMap() => {
        'totalAcoes': totalAcoes,
        'totalPessoas': totalPessoas,
        'totalVeiculos': totalVeiculos,
        'totalCredenciais': totalCredenciais,
        'ultimosRaes': ultimosRaes.map((acao) => acao.toMap()).toList(),
        'atualizadoEm': atualizadoEm.toIso8601String(),
      };

  factory HomeCacheData.fromMap(Map<String, dynamic> map) {
    final raesBrutos = map['ultimosRaes'];
    final raes = raesBrutos is List
        ? raesBrutos
            .whereType<Map>()
            .map((item) => AcaoModel.fromMap(Map<String, dynamic>.from(item)))
            .toList(growable: false)
        : const <AcaoModel>[];

    return HomeCacheData(
      totalAcoes: _toInt(map['totalAcoes']),
      totalPessoas: _toInt(map['totalPessoas']),
      totalVeiculos: _toInt(map['totalVeiculos']),
      totalCredenciais: _toInt(map['totalCredenciais']),
      ultimosRaes: raes,
      atualizadoEm: DateTime.tryParse(map['atualizadoEm']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static int _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
