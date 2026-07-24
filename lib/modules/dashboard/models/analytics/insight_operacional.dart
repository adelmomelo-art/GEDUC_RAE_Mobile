import 'dart:convert';

import 'analytics_entity.dart';
import 'analytics_enums.dart';

class InsightOperacional extends AnalyticsEntity {
  const InsightOperacional({
    required super.id,
    required super.dataGeracao,
    required super.origem,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.criticidade,
    required this.prioridade,
    this.entidadeRelacionada,
    this.valorReferencia,
    this.acaoSugerida,
    super.observacao,
  });

  final String titulo;
  final String descricao;
  final InsightCategoria categoria;
  final NivelCriticidade criticidade;
  final PrioridadeAnalise prioridade;
  final String? entidadeRelacionada;
  final double? valorReferencia;
  final String? acaoSugerida;

  InsightOperacional copyWith({
    String? id,
    DateTime? dataGeracao,
    OrigemAnalise? origem,
    String? observacao,
    String? titulo,
    String? descricao,
    InsightCategoria? categoria,
    NivelCriticidade? criticidade,
    PrioridadeAnalise? prioridade,
    String? entidadeRelacionada,
    double? valorReferencia,
    String? acaoSugerida,
  }) {
    return InsightOperacional(
      id: id ?? this.id,
      dataGeracao: dataGeracao ?? this.dataGeracao,
      origem: origem ?? this.origem,
      observacao: observacao ?? this.observacao,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      criticidade: criticidade ?? this.criticidade,
      prioridade: prioridade ?? this.prioridade,
      entidadeRelacionada:
          entidadeRelacionada ?? this.entidadeRelacionada,
      valorReferencia: valorReferencia ?? this.valorReferencia,
      acaoSugerida: acaoSugerida ?? this.acaoSugerida,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ...baseToMap(),
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria.name,
      'criticidade': criticidade.name,
      'prioridade': prioridade.name,
      'entidadeRelacionada': entidadeRelacionada,
      'valorReferencia': valorReferencia,
      'acaoSugerida': acaoSugerida,
    };
  }

  factory InsightOperacional.fromMap(Map<String, dynamic> map) {
    return InsightOperacional(
      id: map['id']?.toString() ?? '',
      dataGeracao: AnalyticsEntity.parseDate(map['dataGeracao']),
      origem: OrigemAnalise.values.byName(
        map['origem']?.toString() ?? OrigemAnalise.sistema.name,
      ),
      observacao: map['observacao']?.toString(),
      titulo: map['titulo']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      categoria: InsightCategoria.values.byName(
        map['categoria']?.toString() ?? InsightCategoria.outro.name,
      ),
      criticidade: NivelCriticidade.values.byName(
        map['criticidade']?.toString() ?? NivelCriticidade.baixa.name,
      ),
      prioridade: PrioridadeAnalise.values.byName(
        map['prioridade']?.toString() ?? PrioridadeAnalise.normal.name,
      ),
      entidadeRelacionada: map['entidadeRelacionada']?.toString(),
      valorReferencia: (map['valorReferencia'] as num?)?.toDouble(),
      acaoSugerida: map['acaoSugerida']?.toString(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory InsightOperacional.fromJson(String source) {
    return InsightOperacional.fromMap(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }

  @override
  String toString() {
    return 'InsightOperacional(titulo: $titulo, categoria: $categoria, '
        'criticidade: $criticidade, prioridade: $prioridade)';
  }

  @override
  bool operator ==(Object other) {
    return super == other &&
        other is InsightOperacional &&
        titulo == other.titulo &&
        descricao == other.descricao &&
        categoria == other.categoria &&
        criticidade == other.criticidade &&
        prioridade == other.prioridade &&
        entidadeRelacionada == other.entidadeRelacionada &&
        valorReferencia == other.valorReferencia &&
        acaoSugerida == other.acaoSugerida;
  }

  @override
  int get hashCode {
    return Object.hash(
      super.hashCode,
      titulo,
      descricao,
      categoria,
      criticidade,
      prioridade,
      entidadeRelacionada,
      valorReferencia,
      acaoSugerida,
    );
  }
}
