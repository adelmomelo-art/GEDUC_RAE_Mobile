import 'dart:convert';

import 'analytics_entity.dart';
import 'analytics_enums.dart';

class RankingItem extends AnalyticsEntity {
  const RankingItem({
    required super.id,
    required super.dataGeracao,
    required super.origem,
    required this.nome,
    required this.categoria,
    required this.valor,
    required this.indice,
    required this.posicao,
    this.tendencia = TendenciaIndicador.indisponivel,
    this.descricao,
    this.quantidadeAcoes = 0,
    this.pessoasAlcancadas = 0,
    this.veiculosAbordados = 0,
    this.credenciaisEmitidas = 0,
    this.percentualMetasAtingidas = 0,
    super.observacao,
  });

  final String nome;
  final RankingCategoria categoria;
  final double valor;
  final double indice;
  final int posicao;
  final TendenciaIndicador tendencia;
  final String? descricao;

  final int quantidadeAcoes;
  final int pessoasAlcancadas;
  final int veiculosAbordados;
  final int credenciaisEmitidas;
  final double percentualMetasAtingidas;

  RankingItem copyWith({
    String? id,
    DateTime? dataGeracao,
    OrigemAnalise? origem,
    String? observacao,
    String? nome,
    RankingCategoria? categoria,
    double? valor,
    double? indice,
    int? posicao,
    TendenciaIndicador? tendencia,
    String? descricao,
    int? quantidadeAcoes,
    int? pessoasAlcancadas,
    int? veiculosAbordados,
    int? credenciaisEmitidas,
    double? percentualMetasAtingidas,
  }) {
    return RankingItem(
      id: id ?? this.id,
      dataGeracao: dataGeracao ?? this.dataGeracao,
      origem: origem ?? this.origem,
      observacao: observacao ?? this.observacao,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      valor: valor ?? this.valor,
      indice: indice ?? this.indice,
      posicao: posicao ?? this.posicao,
      tendencia: tendencia ?? this.tendencia,
      descricao: descricao ?? this.descricao,
      quantidadeAcoes: quantidadeAcoes ?? this.quantidadeAcoes,
      pessoasAlcancadas: pessoasAlcancadas ?? this.pessoasAlcancadas,
      veiculosAbordados: veiculosAbordados ?? this.veiculosAbordados,
      credenciaisEmitidas:
          credenciaisEmitidas ?? this.credenciaisEmitidas,
      percentualMetasAtingidas:
          percentualMetasAtingidas ?? this.percentualMetasAtingidas,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ...baseToMap(),
      'nome': nome,
      'categoria': categoria.name,
      'valor': valor,
      'indice': indice,
      'posicao': posicao,
      'tendencia': tendencia.name,
      'descricao': descricao,
      'quantidadeAcoes': quantidadeAcoes,
      'pessoasAlcancadas': pessoasAlcancadas,
      'veiculosAbordados': veiculosAbordados,
      'credenciaisEmitidas': credenciaisEmitidas,
      'percentualMetasAtingidas': percentualMetasAtingidas,
    };
  }

  factory RankingItem.fromMap(Map<String, dynamic> map) {
    return RankingItem(
      id: map['id']?.toString() ?? '',
      dataGeracao: AnalyticsEntity.parseDate(map['dataGeracao']),
      origem: OrigemAnalise.values.byName(
        map['origem']?.toString() ?? OrigemAnalise.sistema.name,
      ),
      observacao: map['observacao']?.toString(),
      nome: map['nome']?.toString() ?? '',
      categoria: RankingCategoria.values.byName(
        map['categoria']?.toString() ?? RankingCategoria.outro.name,
      ),
      valor: (map['valor'] as num?)?.toDouble() ?? 0,
      indice: (map['indice'] as num?)?.toDouble() ?? 0,
      posicao: (map['posicao'] as num?)?.toInt() ?? 0,
      tendencia: TendenciaIndicador.values.byName(
        map['tendencia']?.toString() ??
            TendenciaIndicador.indisponivel.name,
      ),
      descricao: map['descricao']?.toString(),
      quantidadeAcoes: (map['quantidadeAcoes'] as num?)?.toInt() ?? 0,
      pessoasAlcancadas:
          (map['pessoasAlcancadas'] as num?)?.toInt() ?? 0,
      veiculosAbordados:
          (map['veiculosAbordados'] as num?)?.toInt() ?? 0,
      credenciaisEmitidas:
          (map['credenciaisEmitidas'] as num?)?.toInt() ?? 0,
      percentualMetasAtingidas:
          (map['percentualMetasAtingidas'] as num?)?.toDouble() ?? 0,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory RankingItem.fromJson(String source) {
    return RankingItem.fromMap(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }

  @override
  String toString() {
    return 'RankingItem(nome: $nome, categoria: $categoria, '
        'indice: $indice, posicao: $posicao)';
  }

  @override
  bool operator ==(Object other) {
    return super == other &&
        other is RankingItem &&
        nome == other.nome &&
        categoria == other.categoria &&
        valor == other.valor &&
        indice == other.indice &&
        posicao == other.posicao &&
        tendencia == other.tendencia &&
        descricao == other.descricao &&
        quantidadeAcoes == other.quantidadeAcoes &&
        pessoasAlcancadas == other.pessoasAlcancadas &&
        veiculosAbordados == other.veiculosAbordados &&
        credenciaisEmitidas == other.credenciaisEmitidas &&
        percentualMetasAtingidas == other.percentualMetasAtingidas;
  }

  @override
  int get hashCode {
    return Object.hash(
      super.hashCode,
      nome,
      categoria,
      valor,
      indice,
      posicao,
      tendencia,
      descricao,
      quantidadeAcoes,
      pessoasAlcancadas,
      veiculosAbordados,
      credenciaisEmitidas,
      percentualMetasAtingidas,
    );
  }
}
