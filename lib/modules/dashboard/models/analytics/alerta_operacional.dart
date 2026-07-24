import 'dart:convert';

import 'analytics_entity.dart';
import 'analytics_enums.dart';

class AlertaOperacional extends AnalyticsEntity {
  const AlertaOperacional({
    required super.id,
    required super.dataGeracao,
    required super.origem,
    required this.titulo,
    required this.descricao,
    required this.nivel,
    required this.tipo,
    required this.prioridade,
    this.acaoRecomendada,
    this.responsavel,
    this.entidadeRelacionada,
    this.resolvido = false,
    super.observacao,
  });

  final String titulo;
  final String descricao;
  final NivelAlerta nivel;
  final TipoAlertaOperacional tipo;
  final PrioridadeAnalise prioridade;
  final String? acaoRecomendada;
  final String? responsavel;
  final String? entidadeRelacionada;
  final bool resolvido;

  bool get exigeAtencaoImediata {
    return nivel == NivelAlerta.critico ||
        prioridade == PrioridadeAnalise.urgente;
  }

  AlertaOperacional copyWith({
    String? id,
    DateTime? dataGeracao,
    OrigemAnalise? origem,
    String? observacao,
    String? titulo,
    String? descricao,
    NivelAlerta? nivel,
    TipoAlertaOperacional? tipo,
    PrioridadeAnalise? prioridade,
    String? acaoRecomendada,
    String? responsavel,
    String? entidadeRelacionada,
    bool? resolvido,
  }) {
    return AlertaOperacional(
      id: id ?? this.id,
      dataGeracao: dataGeracao ?? this.dataGeracao,
      origem: origem ?? this.origem,
      observacao: observacao ?? this.observacao,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      nivel: nivel ?? this.nivel,
      tipo: tipo ?? this.tipo,
      prioridade: prioridade ?? this.prioridade,
      acaoRecomendada: acaoRecomendada ?? this.acaoRecomendada,
      responsavel: responsavel ?? this.responsavel,
      entidadeRelacionada:
          entidadeRelacionada ?? this.entidadeRelacionada,
      resolvido: resolvido ?? this.resolvido,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ...baseToMap(),
      'titulo': titulo,
      'descricao': descricao,
      'nivel': nivel.name,
      'tipo': tipo.name,
      'prioridade': prioridade.name,
      'acaoRecomendada': acaoRecomendada,
      'responsavel': responsavel,
      'entidadeRelacionada': entidadeRelacionada,
      'resolvido': resolvido,
    };
  }

  factory AlertaOperacional.fromMap(Map<String, dynamic> map) {
    return AlertaOperacional(
      id: map['id']?.toString() ?? '',
      dataGeracao: AnalyticsEntity.parseDate(map['dataGeracao']),
      origem: OrigemAnalise.values.byName(
        map['origem']?.toString() ?? OrigemAnalise.sistema.name,
      ),
      observacao: map['observacao']?.toString(),
      titulo: map['titulo']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      nivel: NivelAlerta.values.byName(
        map['nivel']?.toString() ?? NivelAlerta.informativo.name,
      ),
      tipo: TipoAlertaOperacional.values.byName(
        map['tipo']?.toString() ?? TipoAlertaOperacional.outro.name,
      ),
      prioridade: PrioridadeAnalise.values.byName(
        map['prioridade']?.toString() ?? PrioridadeAnalise.normal.name,
      ),
      acaoRecomendada: map['acaoRecomendada']?.toString(),
      responsavel: map['responsavel']?.toString(),
      entidadeRelacionada: map['entidadeRelacionada']?.toString(),
      resolvido: map['resolvido'] as bool? ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory AlertaOperacional.fromJson(String source) {
    return AlertaOperacional.fromMap(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }

  @override
  String toString() {
    return 'AlertaOperacional(titulo: $titulo, nivel: $nivel, '
        'prioridade: $prioridade, resolvido: $resolvido)';
  }

  @override
  bool operator ==(Object other) {
    return super == other &&
        other is AlertaOperacional &&
        titulo == other.titulo &&
        descricao == other.descricao &&
        nivel == other.nivel &&
        tipo == other.tipo &&
        prioridade == other.prioridade &&
        acaoRecomendada == other.acaoRecomendada &&
        responsavel == other.responsavel &&
        entidadeRelacionada == other.entidadeRelacionada &&
        resolvido == other.resolvido;
  }

  @override
  int get hashCode {
    return Object.hash(
      super.hashCode,
      titulo,
      descricao,
      nivel,
      tipo,
      prioridade,
      acaoRecomendada,
      responsavel,
      entidadeRelacionada,
      resolvido,
    );
  }
}
