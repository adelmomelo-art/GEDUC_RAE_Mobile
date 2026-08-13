import 'dart:math' as math;

import '../../../data/models/acao_model.dart';
import '../models/cio_dashboard_filters.dart';

enum CioTemporalGranularity { daily, monthly, yearly }

enum CioTerritorialIdentityStatus { identified, legacy, unresolved }

enum CioTrendStatus { growth, stable, reduction, insufficientData }

class CioTrendMetric {
  const CioTrendMetric({
    required this.current,
    required this.previous,
    required this.absoluteChange,
    required this.percentageChange,
    required this.status,
  });

  final int current;
  final int previous;
  final int absoluteChange;
  final double? percentageChange;
  final CioTrendStatus status;
}

class CioTrendComparison {
  const CioTrendComparison({
    required this.actions,
    required this.peopleReached,
    required this.vehiclesApproached,
    required this.credentialsIssued,
  });

  final CioTrendMetric actions;
  final CioTrendMetric peopleReached;
  final CioTrendMetric vehiclesApproached;
  final CioTrendMetric credentialsIssued;
}

class CioTemporalBucket {
  const CioTemporalBucket({
    required this.start,
    required this.label,
    required this.actions,
    required this.peopleReached,
    required this.vehiclesApproached,
    required this.credentialsIssued,
  });

  final DateTime start;
  final String label;
  final int actions;
  final int peopleReached;
  final int vehiclesApproached;
  final int credentialsIssued;
}

class CioTemporalAnalysis {
  const CioTemporalAnalysis({
    required this.range,
    required this.granularity,
    required this.buckets,
  });

  final DateTimeRangeCio range;
  final CioTemporalGranularity granularity;
  final List<CioTemporalBucket> buckets;

  bool get hasEnoughSamples => buckets.length >= 3;
}

class CioTerritorialGroup {
  const CioTerritorialGroup({
    required this.id,
    required this.name,
    required this.status,
    required this.actions,
  });

  final String id;
  final String name;
  final CioTerritorialIdentityStatus status;
  final List<AcaoModel> actions;
}

class CioDataQualityReport {
  const CioDataQualityReport({
    required this.totalRecords,
    required this.recordsWithRegionalId,
    required this.recordsWithNeighborhood,
    required this.recordsWithValidCoordinates,
    required this.recordsWithValidatedLocation,
    required this.legacyTerritorialRecords,
    required this.unresolvedTerritorialRecords,
    required this.firstOccurrence,
    required this.lastOccurrence,
  });

  final int totalRecords;
  final int recordsWithRegionalId;
  final int recordsWithNeighborhood;
  final int recordsWithValidCoordinates;
  final int recordsWithValidatedLocation;
  final int legacyTerritorialRecords;
  final int unresolvedTerritorialRecords;
  final DateTime? firstOccurrence;
  final DateTime? lastOccurrence;

  double _coverage(int value) => totalRecords == 0 ? 0 : value / totalRecords;

  double get regionalIdCoverage => _coverage(recordsWithRegionalId);
  double get neighborhoodCoverage => _coverage(recordsWithNeighborhood);
  double get validCoordinatesCoverage => _coverage(recordsWithValidCoordinates);
  double get validatedLocationCoverage =>
      _coverage(recordsWithValidatedLocation);
}

class CioHistoricalTerritorialService {
  const CioHistoricalTerritorialService();

  CioTemporalAnalysis buildTimeline(
    List<AcaoModel> actions,
    DateTimeRangeCio range,
  ) {
    final normalizedRange = _normalizeRange(range);
    final granularity = _granularityFor(normalizedRange);
    final grouped = <DateTime, List<AcaoModel>>{};

    for (final action in actions) {
      final day = _day(action.dataAcao);
      if (day.isBefore(normalizedRange.inicio) ||
          day.isAfter(normalizedRange.fim)) {
        continue;
      }
      final key = _bucketStart(day, granularity);
      grouped.putIfAbsent(key, () => <AcaoModel>[]).add(action);
    }

    final buckets = <CioTemporalBucket>[];
    var cursor = _bucketStart(normalizedRange.inicio, granularity);
    final last = _bucketStart(normalizedRange.fim, granularity);
    while (!cursor.isAfter(last)) {
      final records = grouped[cursor] ?? const <AcaoModel>[];
      buckets.add(
        CioTemporalBucket(
          start: cursor,
          label: _label(cursor, granularity),
          actions: records.length,
          peopleReached: _sum(records, (action) => action.pessoasAlcancadas),
          vehiclesApproached:
              _sum(records, (action) => action.veiculosAbordados),
          credentialsIssued:
              _sum(records, (action) => action.credenciaisEmitidas),
        ),
      );
      cursor = _next(cursor, granularity);
    }

    return CioTemporalAnalysis(
      range: normalizedRange,
      granularity: granularity,
      buckets: List<CioTemporalBucket>.unmodifiable(buckets),
    );
  }

  CioTrendComparison compareTimelines(
    CioTemporalAnalysis current,
    CioTemporalAnalysis previous,
  ) {
    int total(
      CioTemporalAnalysis analysis,
      int Function(CioTemporalBucket) value,
    ) =>
        analysis.buckets.fold<int>(0, (sum, bucket) => sum + value(bucket));

    CioTrendMetric metric(int currentValue, int previousValue) => _trendMetric(
          currentValue,
          previousValue,
          hasEnoughSamples:
              current.hasEnoughSamples && previous.hasEnoughSamples,
        );

    return CioTrendComparison(
      actions: metric(
        total(current, (item) => item.actions),
        total(previous, (item) => item.actions),
      ),
      peopleReached: metric(
        total(current, (item) => item.peopleReached),
        total(previous, (item) => item.peopleReached),
      ),
      vehiclesApproached: metric(
        total(current, (item) => item.vehiclesApproached),
        total(previous, (item) => item.vehiclesApproached),
      ),
      credentialsIssued: metric(
        total(current, (item) => item.credentialsIssued),
        total(previous, (item) => item.credentialsIssued),
      ),
    );
  }

  List<CioTerritorialGroup> groupTerritories(List<AcaoModel> actions) {
    final groups = <String, _MutableTerritorialGroup>{};
    for (final action in actions) {
      final identity = _territorialIdentity(action);
      final group = groups.putIfAbsent(
        identity.key,
        () => _MutableTerritorialGroup(
          id: identity.id,
          name: identity.name,
          status: identity.status,
        ),
      );
      group.actions.add(action);
    }

    final result = groups.values
        .map(
          (group) => CioTerritorialGroup(
            id: group.id,
            name: group.name,
            status: group.status,
            actions: List<AcaoModel>.unmodifiable(group.actions),
          ),
        )
        .toList(growable: false)
      ..sort((a, b) {
        final byCount = b.actions.length.compareTo(a.actions.length);
        return byCount != 0 ? byCount : a.name.compareTo(b.name);
      });
    return List<CioTerritorialGroup>.unmodifiable(result);
  }

  CioDataQualityReport assessQuality(List<AcaoModel> actions) {
    var withRegionalId = 0;
    var withNeighborhood = 0;
    var withCoordinates = 0;
    var withValidatedLocation = 0;
    var legacy = 0;
    var unresolved = 0;
    DateTime? first;
    DateTime? last;

    for (final action in actions) {
      final identity = _territorialIdentity(action);
      if (action.regionalId.trim().isNotEmpty) withRegionalId++;
      if (action.bairro.trim().isNotEmpty) withNeighborhood++;
      if (_hasValidCoordinates(action)) withCoordinates++;
      if (action.localizacaoValidada) withValidatedLocation++;
      if (identity.status == CioTerritorialIdentityStatus.legacy) legacy++;
      if (identity.status == CioTerritorialIdentityStatus.unresolved) {
        unresolved++;
      }
      final occurredAt = action.dataAcao;
      if (first == null || occurredAt.isBefore(first)) first = occurredAt;
      if (last == null || occurredAt.isAfter(last)) last = occurredAt;
    }

    return CioDataQualityReport(
      totalRecords: actions.length,
      recordsWithRegionalId: withRegionalId,
      recordsWithNeighborhood: withNeighborhood,
      recordsWithValidCoordinates: withCoordinates,
      recordsWithValidatedLocation: withValidatedLocation,
      legacyTerritorialRecords: legacy,
      unresolvedTerritorialRecords: unresolved,
      firstOccurrence: first,
      lastOccurrence: last,
    );
  }

  DateTimeRangeCio _normalizeRange(DateTimeRangeCio range) {
    final first = _day(range.inicio);
    final last = _day(range.fim);
    return first.isAfter(last)
        ? DateTimeRangeCio(last, first)
        : DateTimeRangeCio(first, last);
  }

  CioTemporalGranularity _granularityFor(DateTimeRangeCio range) {
    final days = range.fim.difference(range.inicio).inDays + 1;
    if (days <= 31) return CioTemporalGranularity.daily;
    final months = (range.fim.year - range.inicio.year) * 12 +
        range.fim.month -
        range.inicio.month +
        1;
    return months <= 24
        ? CioTemporalGranularity.monthly
        : CioTemporalGranularity.yearly;
  }

  DateTime _bucketStart(DateTime date, CioTemporalGranularity granularity) {
    switch (granularity) {
      case CioTemporalGranularity.daily:
        return _day(date);
      case CioTemporalGranularity.monthly:
        return DateTime(date.year, date.month);
      case CioTemporalGranularity.yearly:
        return DateTime(date.year);
    }
  }

  DateTime _next(DateTime date, CioTemporalGranularity granularity) {
    switch (granularity) {
      case CioTemporalGranularity.daily:
        return date.add(const Duration(days: 1));
      case CioTemporalGranularity.monthly:
        return DateTime(date.year, date.month + 1);
      case CioTemporalGranularity.yearly:
        return DateTime(date.year + 1);
    }
  }

  String _label(DateTime date, CioTemporalGranularity granularity) {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    switch (granularity) {
      case CioTemporalGranularity.daily:
        return '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}';
      case CioTemporalGranularity.monthly:
        return '${months[date.month - 1]}/${date.year}';
      case CioTemporalGranularity.yearly:
        return '${date.year}';
    }
  }

  _TerritorialIdentity _territorialIdentity(AcaoModel action) {
    final regionalId = action.regionalId.trim();
    final regionalName = action.regional.trim();
    if (regionalId.isNotEmpty) {
      return _TerritorialIdentity(
        key: 'id:${_normalize(regionalId)}',
        id: regionalId,
        name: regionalName.isEmpty ? regionalId : regionalName,
        status: CioTerritorialIdentityStatus.identified,
      );
    }
    if (regionalName.isNotEmpty) {
      final normalizedName = _normalize(regionalName);
      return _TerritorialIdentity(
        key: 'legacy:$normalizedName',
        id: 'legacy_$normalizedName',
        name: regionalName,
        status: CioTerritorialIdentityStatus.legacy,
      );
    }
    return const _TerritorialIdentity(
      key: 'unresolved',
      id: 'unresolved',
      name: 'Não informado',
      status: CioTerritorialIdentityStatus.unresolved,
    );
  }

  String _normalize(String value) {
    final withoutDiacritics = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp('[áàâãäå]'), 'a')
        .replaceAll(RegExp('[éèêë]'), 'e')
        .replaceAll(RegExp('[íìîï]'), 'i')
        .replaceAll(RegExp('[óòôõö]'), 'o')
        .replaceAll(RegExp('[úùûü]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll('ñ', 'n');

    return withoutDiacritics
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  bool _hasValidCoordinates(AcaoModel action) {
    final latitude = action.latitude;
    final longitude = action.longitude;
    return latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180 &&
        (latitude.abs() > 0.000001 || longitude.abs() > 0.000001);
  }

  int _sum(List<AcaoModel> records, int Function(AcaoModel) value) => records
      .fold<int>(0, (total, record) => total + math.max(0, value(record)));

  CioTrendMetric _trendMetric(
    int current,
    int previous, {
    required bool hasEnoughSamples,
  }) {
    final absolute = current - previous;
    if (!hasEnoughSamples || previous == 0) {
      return CioTrendMetric(
        current: current,
        previous: previous,
        absoluteChange: absolute,
        percentageChange: previous == 0 && current == 0 ? 0 : null,
        status: CioTrendStatus.insufficientData,
      );
    }
    final percentage = absolute / previous * 100;
    final status = percentage > 5
        ? CioTrendStatus.growth
        : percentage < -5
            ? CioTrendStatus.reduction
            : CioTrendStatus.stable;
    return CioTrendMetric(
      current: current,
      previous: previous,
      absoluteChange: absolute,
      percentageChange: percentage,
      status: status,
    );
  }

  DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
}

class _MutableTerritorialGroup {
  _MutableTerritorialGroup({
    required this.id,
    required this.name,
    required this.status,
  });

  final String id;
  final String name;
  final CioTerritorialIdentityStatus status;
  final List<AcaoModel> actions = <AcaoModel>[];
}

class _TerritorialIdentity {
  const _TerritorialIdentity({
    required this.key,
    required this.id,
    required this.name,
    required this.status,
  });

  final String key;
  final String id;
  final String name;
  final CioTerritorialIdentityStatus status;
}
