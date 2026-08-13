import '../../../data/models/acao_model.dart';
import '../../../data/models/regional_model.dart';

enum CioTerritorialClassification {
  valid,
  legacy,
  orphan,
  inactive,
  ambiguous,
  outOfBounds,
  divergent,
  unresolved,
}

enum CioTerritorialFinding {
  missingRegionalId,
  unknownRegionalId,
  inactiveRegional,
  typeMismatch,
  missingNeighborhood,
  ambiguousNeighborhood,
  neighborhoodMismatch,
  missingCoordinates,
  invalidCoordinates,
  coordinatesOutOfBounds,
}

class CioTerritorialCatalogSnapshot {
  CioTerritorialCatalogSnapshot({
    required this.capturedAt,
    required Iterable<RegionalModel> regionals,
  }) : regionals = List<RegionalModel>.unmodifiable(regionals);

  final DateTime capturedAt;
  final List<RegionalModel> regionals;

  RegionalModel? findById(String id) {
    final normalizedId = id.trim();
    for (final regional in regionals) {
      if (regional.id == normalizedId) return regional;
    }
    return null;
  }
}

class CioNeighborhoodConflict {
  const CioNeighborhoodConflict({
    required this.normalizedNeighborhood,
    required this.type,
    required this.regionals,
  });

  final String normalizedNeighborhood;
  final TipoRegional type;
  final List<RegionalModel> regionals;
}

class CioTerritorialCatalogReport {
  const CioTerritorialCatalogReport({
    required this.totalRegionals,
    required this.activeRegionals,
    required this.inactiveRegionals,
    required this.neighborhoodConflicts,
  });

  final int totalRegionals;
  final int activeRegionals;
  final int inactiveRegionals;
  final List<CioNeighborhoodConflict> neighborhoodConflicts;

  bool get hasNeighborhoodConflicts => neighborhoodConflicts.isNotEmpty;
}

class CioTerritorialValidation {
  const CioTerritorialValidation({
    required this.action,
    required this.classification,
    required this.findings,
    this.catalogRegional,
  });

  final AcaoModel action;
  final CioTerritorialClassification classification;
  final Set<CioTerritorialFinding> findings;
  final RegionalModel? catalogRegional;

  bool get institutionallyValid =>
      classification == CioTerritorialClassification.valid;
}

class CioTerritorialGovernanceReport {
  const CioTerritorialGovernanceReport({
    required this.catalog,
    required this.validations,
  });

  final CioTerritorialCatalogReport catalog;
  final List<CioTerritorialValidation> validations;

  int count(CioTerritorialClassification classification) =>
      validations.where((item) => item.classification == classification).length;

  double get institutionalCoverage => validations.isEmpty
      ? 0
      : count(CioTerritorialClassification.valid) / validations.length;

  double get coordinateCoverage => validations.isEmpty
      ? 0
      : validations.where((item) {
            return !item.findings.contains(
                  CioTerritorialFinding.missingCoordinates,
                ) &&
                !item.findings.contains(
                  CioTerritorialFinding.invalidCoordinates,
                ) &&
                !item.findings.contains(
                  CioTerritorialFinding.coordinatesOutOfBounds,
                );
          }).length /
          validations.length;
}

class CioTerritorialDiagnostic {
  const CioTerritorialDiagnostic({
    required this.start,
    required this.end,
    required this.report,
    required this.sanitationQueue,
  });

  final DateTime start;
  final DateTime end;
  final CioTerritorialGovernanceReport report;
  final List<CioTerritorialSanitationItem> sanitationQueue;
}

class CioTerritorialSanitationItem {
  const CioTerritorialSanitationItem({
    required this.actionId,
    required this.raeNumber,
    required this.occurredAt,
    required this.regionalName,
    required this.neighborhood,
    required this.classification,
    required this.findings,
  });

  final String actionId;
  final String raeNumber;
  final DateTime occurredAt;
  final String regionalName;
  final String neighborhood;
  final CioTerritorialClassification classification;
  final Set<CioTerritorialFinding> findings;
}

typedef CioCoordinateBoundaryValidator = bool Function(
  double latitude,
  double longitude,
);

class CioTerritorialGovernanceService {
  const CioTerritorialGovernanceService({
    this.coordinateBoundaryValidator,
  });

  final CioCoordinateBoundaryValidator? coordinateBoundaryValidator;

  CioTerritorialCatalogReport auditCatalog(
    CioTerritorialCatalogSnapshot snapshot,
  ) {
    final active = snapshot.regionals.where((item) => item.ativo).toList();
    final neighborhoods = <(TipoRegional, String), List<RegionalModel>>{};

    for (final regional in active) {
      for (final neighborhood in regional.bairros) {
        final normalized = normalizeText(neighborhood);
        if (normalized.isEmpty) continue;
        neighborhoods
            .putIfAbsent((regional.tipo, normalized), () => []).add(regional);
      }
    }

    final conflicts = neighborhoods.entries
        .where((entry) => entry.value.map((item) => item.id).toSet().length > 1)
        .map(
          (entry) => CioNeighborhoodConflict(
            normalizedNeighborhood: entry.key.$2,
            type: entry.key.$1,
            regionals: List<RegionalModel>.unmodifiable(entry.value),
          ),
        )
        .toList(growable: false)
      ..sort((a, b) =>
          a.normalizedNeighborhood.compareTo(b.normalizedNeighborhood));

    return CioTerritorialCatalogReport(
      totalRegionals: snapshot.regionals.length,
      activeRegionals: active.length,
      inactiveRegionals: snapshot.regionals.length - active.length,
      neighborhoodConflicts:
          List<CioNeighborhoodConflict>.unmodifiable(conflicts),
    );
  }

  CioTerritorialGovernanceReport validate(
    Iterable<AcaoModel> actions,
    CioTerritorialCatalogSnapshot snapshot,
  ) {
    final catalog = auditCatalog(snapshot);
    final validations = actions
        .map((action) => validateAction(action, snapshot))
        .toList(growable: false);
    return CioTerritorialGovernanceReport(
      catalog: catalog,
      validations: List<CioTerritorialValidation>.unmodifiable(validations),
    );
  }

  CioTerritorialDiagnostic buildTwelveMonthDiagnostic(
    Iterable<AcaoModel> actions,
    CioTerritorialCatalogSnapshot snapshot, {
    required DateTime reference,
  }) {
    final end = DateTime(reference.year, reference.month, reference.day);
    final start = DateTime(end.year - 1, end.month, end.day);
    final records = actions.where((action) {
      final occurredAt = DateTime(
        action.dataAcao.year,
        action.dataAcao.month,
        action.dataAcao.day,
      );
      return !occurredAt.isBefore(start) && !occurredAt.isAfter(end);
    }).toList(growable: false);
    final report = validate(records, snapshot);
    final queue = report.validations
        .where((item) => !item.institutionallyValid || item.findings.isNotEmpty)
        .map(
          (item) => CioTerritorialSanitationItem(
            actionId: item.action.id,
            raeNumber: item.action.numeroRAE,
            occurredAt: item.action.dataAcao,
            regionalName: item.action.regional,
            neighborhood: item.action.bairro,
            classification: item.classification,
            findings: Set<CioTerritorialFinding>.unmodifiable(item.findings),
          ),
        )
        .toList(growable: false)
      ..sort((a, b) {
        final byDate = b.occurredAt.compareTo(a.occurredAt);
        return byDate != 0 ? byDate : a.actionId.compareTo(b.actionId);
      });
    return CioTerritorialDiagnostic(
      start: start,
      end: end,
      report: report,
      sanitationQueue: List<CioTerritorialSanitationItem>.unmodifiable(queue),
    );
  }

  CioTerritorialValidation validateAction(
    AcaoModel action,
    CioTerritorialCatalogSnapshot snapshot,
  ) {
    final findings = <CioTerritorialFinding>{};
    final regionalId = action.regionalId.trim();
    final neighborhood = normalizeText(action.bairro);

    if (regionalId.isEmpty) {
      findings.add(CioTerritorialFinding.missingRegionalId);
      if (action.bairro.trim().isEmpty) {
        findings.add(CioTerritorialFinding.missingNeighborhood);
      }
      return CioTerritorialValidation(
        action: action,
        classification: action.regional.trim().isEmpty
            ? CioTerritorialClassification.unresolved
            : CioTerritorialClassification.legacy,
        findings: Set<CioTerritorialFinding>.unmodifiable(findings),
      );
    }

    final regional = snapshot.findById(regionalId);
    if (regional == null) {
      findings.add(CioTerritorialFinding.unknownRegionalId);
      return CioTerritorialValidation(
        action: action,
        classification: CioTerritorialClassification.orphan,
        findings: Set<CioTerritorialFinding>.unmodifiable(findings),
      );
    }

    if (!regional.ativo) {
      findings.add(CioTerritorialFinding.inactiveRegional);
    }
    if (action.tipoRegional.trim().isNotEmpty &&
        action.tipoRegional.trim().toLowerCase() != regional.tipo.codigo) {
      findings.add(CioTerritorialFinding.typeMismatch);
    }

    if (neighborhood.isEmpty) {
      findings.add(CioTerritorialFinding.missingNeighborhood);
    } else {
      final matches = snapshot.regionals.where((item) {
        return item.ativo &&
            item.tipo == regional.tipo &&
            item.bairros.any((value) => normalizeText(value) == neighborhood);
      }).toList(growable: false);
      if (matches.length > 1) {
        findings.add(CioTerritorialFinding.ambiguousNeighborhood);
      } else if (matches.length == 1 && matches.single.id != regional.id) {
        findings.add(CioTerritorialFinding.neighborhoodMismatch);
      }
    }

    final hasCoordinates = _hasCoordinates(action);
    if (!hasCoordinates) {
      findings.add(CioTerritorialFinding.missingCoordinates);
    } else if (!_validWorldCoordinates(action)) {
      findings.add(CioTerritorialFinding.invalidCoordinates);
    } else if (hasCoordinates &&
        coordinateBoundaryValidator != null &&
        !coordinateBoundaryValidator!(action.latitude, action.longitude)) {
      findings.add(CioTerritorialFinding.coordinatesOutOfBounds);
    }

    final classification = _primaryClassification(regional, findings);
    return CioTerritorialValidation(
      action: action,
      classification: classification,
      findings: Set<CioTerritorialFinding>.unmodifiable(findings),
      catalogRegional: regional,
    );
  }

  CioTerritorialClassification _primaryClassification(
    RegionalModel regional,
    Set<CioTerritorialFinding> findings,
  ) {
    if (!regional.ativo) return CioTerritorialClassification.inactive;
    if (findings.contains(CioTerritorialFinding.ambiguousNeighborhood)) {
      return CioTerritorialClassification.ambiguous;
    }
    if (findings.contains(CioTerritorialFinding.coordinatesOutOfBounds)) {
      return CioTerritorialClassification.outOfBounds;
    }
    if (findings.contains(CioTerritorialFinding.typeMismatch) ||
        findings.contains(CioTerritorialFinding.neighborhoodMismatch) ||
        findings.contains(CioTerritorialFinding.invalidCoordinates)) {
      return CioTerritorialClassification.divergent;
    }
    return CioTerritorialClassification.valid;
  }

  bool _hasCoordinates(AcaoModel action) =>
      action.latitude != 0 || action.longitude != 0;

  bool _validWorldCoordinates(AcaoModel action) =>
      action.latitude.isFinite &&
      action.longitude.isFinite &&
      action.latitude >= -90 &&
      action.latitude <= 90 &&
      action.longitude >= -180 &&
      action.longitude <= 180;

  static String normalizeText(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp('[áàâãäå]'), 'a')
        .replaceAll(RegExp('[éèêë]'), 'e')
        .replaceAll(RegExp('[íìîï]'), 'i')
        .replaceAll(RegExp('[óòôõö]'), 'o')
        .replaceAll(RegExp('[úùûü]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll('ñ', 'n');
    return normalized.replaceAll(RegExp(r'\s+'), ' ');
  }
}
