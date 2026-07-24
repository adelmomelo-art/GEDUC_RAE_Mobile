import 'analytics_indicator.dart';
import 'analytics_indicator_value.dart';

/// Modelo institucional de dashboard do Framework Atlas.
///
/// Representa um conjunto consolidado de indicadores analíticos,
/// acompanhado dos metadados necessários para sua apresentação
/// em dashboards, relatórios, APIs, BI e pela assistente Faxita.
///
/// Esta classe não executa cálculos e não depende de:
/// - Flutter;
/// - Firebase;
/// - banco de dados;
/// - módulos operacionais;
/// - componentes de interface.
final class AnalyticsDashboardModel {
  AnalyticsDashboardModel({
    required this.id,
    required this.title,
    required this.domain,
    required this.generatedAt,
    required Iterable<AnalyticsIndicatorValue> indicators,
    this.description,
    this.referenceStartDate,
    this.referenceEndDate,
    this.processedRecords = 0,
    this.ignoredRecords = 0,
    this.processingTime = Duration.zero,
    Map<String, Object?> metadata = const {},
  })  : indicators = List<AnalyticsIndicatorValue>.unmodifiable(
          indicators,
        ),
        metadata = Map<String, Object?>.unmodifiable(
          metadata,
        ) {
    _validate();
  }

  /// Identificador único do dashboard.
  final String id;

  /// Título institucional.
  final String title;

  /// Descrição opcional do conteúdo apresentado.
  final String? description;

  /// Domínio institucional de origem.
  ///
  /// Exemplos:
  /// - educacao;
  /// - fiscalizacao;
  /// - rpas;
  /// - engenharia.
  final String domain;

  /// Data e hora em que o dashboard foi gerado.
  final DateTime generatedAt;

  /// Início do período analisado.
  final DateTime? referenceStartDate;

  /// Final do período analisado.
  final DateTime? referenceEndDate;

  /// Relação imutável de indicadores.
  final List<AnalyticsIndicatorValue> indicators;

  /// Quantidade de registros efetivamente processados.
  final int processedRecords;

  /// Quantidade de registros ignorados pelo processamento.
  final int ignoredRecords;

  /// Tempo necessário para produzir o resultado analítico.
  final Duration processingTime;

  /// Metadados adicionais do dashboard.
  ///
  /// Este mapa pode armazenar informações institucionais que não
  /// fazem parte do contrato principal, preservando seus tipos.
  final Map<String, Object?> metadata;

  /// Quantidade total de registros considerados pelo processamento.
  int get totalInputRecords =>
      processedRecords + ignoredRecords;

  /// Indica se o dashboard possui indicadores.
  bool get hasIndicators => indicators.isNotEmpty;

  /// Indica se existem registros processados.
  bool get hasProcessedRecords => processedRecords > 0;

  /// Indica se existem registros ignorados.
  bool get hasIgnoredRecords => ignoredRecords > 0;

  /// Indica se existe período de referência completo.
  bool get hasReferencePeriod =>
      referenceStartDate != null &&
      referenceEndDate != null;

  /// Localiza um indicador pelo identificador institucional.
  AnalyticsIndicatorValue? indicatorById(
    String indicatorId,
  ) {
    final normalizedId = indicatorId.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    for (final indicatorValue in indicators) {
      if (indicatorValue.indicator.id == normalizedId) {
        return indicatorValue;
      }
    }

    return null;
  }

  /// Indica se o dashboard contém determinado indicador.
  bool containsIndicator(
    String indicatorId,
  ) {
    return indicatorById(indicatorId) != null;
  }

  /// Retorna os indicadores de uma categoria institucional.
  List<AnalyticsIndicatorValue> indicatorsByCategory(
    AnalyticsIndicatorCategory category,
  ) {
    return List<AnalyticsIndicatorValue>.unmodifiable(
      indicators.where(
        (indicatorValue) =>
            indicatorValue.indicator.category == category,
      ),
    );
  }

  /// Retorna os indicadores operacionais.
  List<AnalyticsIndicatorValue> get operationIndicators =>
      indicatorsByCategory(
        AnalyticsIndicatorCategory.operation,
      );

  /// Retorna os indicadores de produtividade.
  List<AnalyticsIndicatorValue> get productivityIndicators =>
      indicatorsByCategory(
        AnalyticsIndicatorCategory.productivity,
      );

  /// Retorna os indicadores de qualidade.
  List<AnalyticsIndicatorValue> get qualityIndicators =>
      indicatorsByCategory(
        AnalyticsIndicatorCategory.quality,
      );

  /// Retorna os indicadores de gestão.
  List<AnalyticsIndicatorValue> get managementIndicators =>
      indicatorsByCategory(
        AnalyticsIndicatorCategory.management,
      );

  /// Retorna os indicadores estratégicos.
  List<AnalyticsIndicatorValue> get strategicIndicators =>
      indicatorsByCategory(
        AnalyticsIndicatorCategory.strategic,
      );

  /// Obtém um metadado pelo identificador.
  Object? metadataValue(
    String key,
  ) {
    return metadata[key];
  }

  /// Obtém um metadado convertido para String.
  String? metadataAsString(
    String key,
  ) {
    final value = metadataValue(key);

    if (value == null) {
      return null;
    }

    return value.toString();
  }

  /// Obtém um metadado do tipo inteiro.
  int? metadataAsInt(
    String key,
  ) {
    final value = metadataValue(key);

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim());
    }

    return null;
  }

  /// Obtém um metadado do tipo decimal.
  double? metadataAsDouble(
    String key,
  ) {
    final value = metadataValue(key);

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(
        value.trim().replaceAll(',', '.'),
      );
    }

    return null;
  }

  /// Obtém um metadado do tipo booleano.
  bool? metadataAsBool(
    String key,
  ) {
    final value = metadataValue(key);

    if (value is bool) {
      return value;
    }

    if (value is num) {
      if (value == 1) {
        return true;
      }

      if (value == 0) {
        return false;
      }
    }

    if (value is String) {
      switch (value.trim().toLowerCase()) {
        case 'true':
        case '1':
        case 'sim':
        case 'yes':
          return true;

        case 'false':
        case '0':
        case 'não':
        case 'nao':
        case 'no':
          return false;
      }
    }

    return null;
  }

  /// Retorna uma nova instância alterando apenas os campos informados.
  AnalyticsDashboardModel copyWith({
    String? id,
    String? title,
    String? description,
    String? domain,
    DateTime? generatedAt,
    DateTime? referenceStartDate,
    DateTime? referenceEndDate,
    Iterable<AnalyticsIndicatorValue>? indicators,
    int? processedRecords,
    int? ignoredRecords,
    Duration? processingTime,
    Map<String, Object?>? metadata,
  }) {
    return AnalyticsDashboardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      domain: domain ?? this.domain,
      generatedAt: generatedAt ?? this.generatedAt,
      referenceStartDate:
          referenceStartDate ?? this.referenceStartDate,
      referenceEndDate:
          referenceEndDate ?? this.referenceEndDate,
      indicators: indicators ?? this.indicators,
      processedRecords:
          processedRecords ?? this.processedRecords,
      ignoredRecords:
          ignoredRecords ?? this.ignoredRecords,
      processingTime:
          processingTime ?? this.processingTime,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Cria uma nova versão do dashboard com um metadado
  /// adicionado ou substituído.
  AnalyticsDashboardModel withMetadata(
    String key,
    Object? value,
  ) {
    final updatedMetadata =
        Map<String, Object?>.from(metadata);

    updatedMetadata[key] = value;

    return copyWith(
      metadata: updatedMetadata,
    );
  }

  /// Cria uma nova versão do dashboard sem o metadado informado.
  AnalyticsDashboardModel withoutMetadata(
    String key,
  ) {
    if (!metadata.containsKey(key)) {
      return this;
    }

    final updatedMetadata =
        Map<String, Object?>.from(metadata)
          ..remove(key);

    return copyWith(
      metadata: updatedMetadata,
    );
  }

  /// Valida a consistência mínima do modelo.
  void _validate() {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(
        id,
        'id',
        'O identificador do dashboard não pode ser vazio.',
      );
    }

    if (title.trim().isEmpty) {
      throw ArgumentError.value(
        title,
        'title',
        'O título do dashboard não pode ser vazio.',
      );
    }

    if (domain.trim().isEmpty) {
      throw ArgumentError.value(
        domain,
        'domain',
        'O domínio do dashboard não pode ser vazio.',
      );
    }

    if (processedRecords < 0) {
      throw ArgumentError.value(
        processedRecords,
        'processedRecords',
        'A quantidade de registros processados não pode ser negativa.',
      );
    }

    if (ignoredRecords < 0) {
      throw ArgumentError.value(
        ignoredRecords,
        'ignoredRecords',
        'A quantidade de registros ignorados não pode ser negativa.',
      );
    }

    if (processingTime.isNegative) {
      throw ArgumentError.value(
        processingTime,
        'processingTime',
        'O tempo de processamento não pode ser negativo.',
      );
    }

    if (referenceStartDate != null &&
        referenceEndDate != null &&
        referenceEndDate!.isBefore(referenceStartDate!)) {
      throw ArgumentError(
        'A data final do período não pode ser anterior '
        'à data inicial.',
      );
    }

    final indicatorIds = <String>{};

    for (final indicatorValue in indicators) {
      final indicatorId =
          indicatorValue.indicator.id;

      if (!indicatorIds.add(indicatorId)) {
        throw ArgumentError(
          'O dashboard não pode conter indicadores duplicados: '
          '$indicatorId.',
        );
      }
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AnalyticsDashboardModel &&
            other.id == id &&
            other.generatedAt == generatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        generatedAt,
      );

  @override
  String toString() {
    return 'AnalyticsDashboardModel('
        'id: $id, '
        'title: $title, '
        'domain: $domain, '
        'indicators: ${indicators.length}, '
        'processedRecords: $processedRecords, '
        'ignoredRecords: $ignoredRecords'
        ')';
  }
}