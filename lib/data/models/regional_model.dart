import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoRegional {
  administrativa('administrativa', 'Regional Administrativa'),
  saude('saude', 'Regional de Saude'),
  educacao('educacao', 'Regional de Educacao'),
  outra('outra', 'Outra tipologia');

  const TipoRegional(this.codigo, this.rotulo);

  final String codigo;
  final String rotulo;

  static TipoRegional fromValue(dynamic value) {
    final codigo = value?.toString().trim().toLowerCase();
    return values.firstWhere(
      (tipo) => tipo.codigo == codigo,
      orElse: () => TipoRegional.administrativa,
    );
  }
}

class RegionalModel {
  const RegionalModel({
    required this.id,
    required this.nome,
    this.codigo = '',
    this.tipo = TipoRegional.administrativa,
    this.bairros = const <String>[],
    this.ativo = true,
  });

  final String id;
  final String nome;
  final String codigo;
  final TipoRegional tipo;
  final List<String> bairros;
  final bool ativo;

  factory RegionalModel.fromMap(String id, Map<String, dynamic> map) {
    final nome = <dynamic>[
      map['nomeRegional'],
      map['nome'],
      map['descricao'],
    ].map((item) => item?.toString().trim() ?? '').firstWhere(
          (item) => item.isNotEmpty,
          orElse: () => '',
        );
    final bairrosRaw = map['bairrosVinculados'];

    return RegionalModel(
      id: id,
      nome: nome,
      codigo: map['codigo']?.toString().trim() ?? '',
      tipo: TipoRegional.fromValue(map['tipoRegional']),
      bairros: bairrosRaw is Iterable
          ? bairrosRaw
              .map((item) => item?.toString().trim() ?? '')
              .where((item) => item.isNotEmpty)
              .toList(growable: false)
          : const <String>[],
      ativo: map['ativo'] != false,
    );
  }

  Map<String, dynamic> toMap({bool incluirCriacao = false}) {
    return <String, dynamic>{
      'id': id,
      'nomeRegional': nome.trim(),
      'codigo': codigo.trim(),
      'tipoRegional': tipo.codigo,
      'bairrosVinculados': bairros,
      'ativo': ativo,
      if (incluirCriacao) 'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    };
  }
}
