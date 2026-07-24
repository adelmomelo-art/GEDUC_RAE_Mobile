import 'dart:convert';

import 'analytics_entity.dart';
import 'analytics_enums.dart';

class IndicadorEstrategico extends AnalyticsEntity {
  const IndicadorEstrategico({
    required super.id,
    required super.dataGeracao,
    required super.origem,
    required this.titulo,
    required this.valor,
    required this.unidade,
    required this.status,
    this.meta,
    this.percentual,
    this.tendencia = TendenciaIndicador.indisponivel,
    this.descricao,
    super.observacao,
  });

  final String titulo;
  final double valor;
  final String unidade;
  final double? meta;
  final double? percentual;
  final TendenciaIndicador tendencia;
  final StatusIndicador status;
  final String? descricao;

  bool get possuiMeta => meta != null;

  bool get atingiuMeta {
    if (meta == null) {
      return false;
    }
    return valor >= meta!;
  }

  IndicadorEstrategico copyWith({
    String? id,
    DateTime? dataGeracao,
    OrigemAnalise? origem,
    String? observacao,
    String? titulo,
    double? valor,
    String? unidade,
    double? meta,
    double? percentual,
    TendenciaIndicador? tendencia,
    StatusIndicador? status,
    String? descricao,
  }) {
    return IndicadorEstrategico(
      id: id ?? this.id,
      dataGeracao: dataGeracao ?? this.dataGeracao,
      origem: origem ?? this.origem,
      observacao: observacao ?? this.observacao,
      titulo: titulo ?? this.titulo,
      valor: valor ?? this.valor,
      unidade: unidade ?? this.unidade,
      meta: meta ?? this.meta,
      percentual: percentual ?? this.percentual,
      tendencia: tendencia ?? this.tendencia,
      status: status ?? this.status,
      descricao: descricao ?? this.descricao,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ...baseToMap(),
      'titulo': titulo,
      'valor': valor,
      'unidade': unidade,
      'meta': meta,
      'percentual': percentual,
      'tendencia': tendencia.name,
      'status': status.name,
      'descricao': descricao,
    };
  }

  factory IndicadorEstrategico.fromMap(Map<String, dynamic> map) {
    return IndicadorEstrategico(
      id: map['id']?.toString() ?? '',
      dataGeracao: AnalyticsEntity.parseDate(map['dataGeracao']),
      origem: OrigemAnalise.values.byName(
        map['origem']?.toString() ?? OrigemAnalise.sistema.name,
      ),
      observacao: map['observacao']?.toString(),
      titulo: map['titulo']?.toString() ?? '',
      valor: (map['valor'] as num?)?.toDouble() ?? 0,
      unidade: map['unidade']?.toString() ?? '',
      meta: (map['meta'] as num?)?.toDouble(),
      percentual: (map['percentual'] as num?)?.toDouble(),
      tendencia: TendenciaIndicador.values.byName(
        map['tendencia']?.toString() ??
            TendenciaIndicador.indisponivel.name,
      ),
      status: StatusIndicador.values.byName(
        map['status']?.toString() ?? StatusIndicador.indisponivel.name,
      ),
      descricao: map['descricao']?.toString(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory IndicadorEstrategico.fromJson(String source) {
    return IndicadorEstrategico.fromMap(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }

  @override
  String toString() {
    return 'IndicadorEstrategico(titulo: $titulo, valor: $valor, '
        'unidade: $unidade, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return super == other &&
        other is IndicadorEstrategico &&
        titulo == other.titulo &&
        valor == other.valor &&
        unidade == other.unidade &&
        meta == other.meta &&
        percentual == other.percentual &&
        tendencia == other.tendencia &&
        status == other.status &&
        descricao == other.descricao;
  }

  @override
  int get hashCode {
    return Object.hash(
      super.hashCode,
      titulo,
      valor,
      unidade,
      meta,
      percentual,
      tendencia,
      status,
      descricao,
    );
  }
}
