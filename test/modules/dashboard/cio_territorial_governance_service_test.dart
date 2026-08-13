import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/data/models/acao_model.dart';
import 'package:geduc_rae_mobile/data/models/regional_model.dart';
import 'package:geduc_rae_mobile/modules/dashboard/services/cio_territorial_governance_service.dart';

void main() {
  final snapshot = CioTerritorialCatalogSnapshot(
    capturedAt: DateTime(2026, 8, 13),
    regionals: const [
      RegionalModel(
        id: 'r1',
        nome: 'Regional 1',
        bairros: ['São José', 'Centro'],
      ),
      RegionalModel(
        id: 'r2',
        nome: 'Regional 2',
        bairros: ['Aldeota'],
      ),
      RegionalModel(
        id: 'r3',
        nome: 'Regional 3',
        bairros: ['Centro'],
      ),
      RegionalModel(
        id: 'inativa',
        nome: 'Regional antiga',
        ativo: false,
      ),
    ],
  );
  const service = CioTerritorialGovernanceService();

  test('snapshot é estruturalmente imutável', () {
    expect(
        () => snapshot.regionals.add(const RegionalModel(id: 'x', nome: 'X')),
        throwsUnsupportedError);
  });

  test('audita bairro duplicado por tipologia entre regionais ativas', () {
    final report = service.auditCatalog(snapshot);

    expect(report.totalRegionals, 4);
    expect(report.activeRegionals, 3);
    expect(report.inactiveRegionals, 1);
    expect(report.neighborhoodConflicts, hasLength(1));
    expect(
        report.neighborhoodConflicts.single.normalizedNeighborhood, 'centro');
    expect(report.neighborhoodConflicts.single.regionals, hasLength(2));
  });

  test('classifica ID reconhecido e bairro coerente como válido', () {
    final result = service.validateAction(
      _action('1', regionalId: 'r1', neighborhood: 'Sao Jose'),
      snapshot,
    );

    expect(result.classification, CioTerritorialClassification.valid);
    expect(result.institutionallyValid, isTrue);
    expect(
      result.findings,
      contains(CioTerritorialFinding.missingCoordinates),
    );
    expect(result.catalogRegional?.id, 'r1');
  });

  test('mede coordenadas separadamente e inclui pendencia na fila', () {
    final action = _action(
      'sem-coordenadas',
      regionalId: 'r1',
      regionalName: 'Regional 1',
      neighborhood: 'São José',
    ).copyWith(dataAcao: DateTime(2026, 8, 1));

    final diagnostic = service.buildTwelveMonthDiagnostic(
      [action],
      snapshot,
      reference: DateTime(2026, 8, 13),
    );

    expect(diagnostic.report.institutionalCoverage, 1);
    expect(diagnostic.report.coordinateCoverage, 0);
    expect(diagnostic.sanitationQueue, hasLength(1));
    expect(
      diagnostic.sanitationQueue.single.findings,
      contains(CioTerritorialFinding.missingCoordinates),
    );
  });

  test('classifica ID desconhecido como órfão', () {
    final result = service.validateAction(
      _action('1', regionalId: 'nao-existe'),
      snapshot,
    );

    expect(result.classification, CioTerritorialClassification.orphan);
    expect(result.findings, contains(CioTerritorialFinding.unknownRegionalId));
  });

  test('classifica regional inativa sem perder referência do catálogo', () {
    final result = service.validateAction(
      _action('1', regionalId: 'inativa'),
      snapshot,
    );

    expect(result.classification, CioTerritorialClassification.inactive);
    expect(result.catalogRegional?.id, 'inativa');
  });

  test('classifica registro nominal sem ID como legado', () {
    final result = service.validateAction(
      _action('1', regionalName: 'Regional 1'),
      snapshot,
    );

    expect(result.classification, CioTerritorialClassification.legacy);
    expect(result.findings, contains(CioTerritorialFinding.missingRegionalId));
  });

  test('classifica ausência de identidade como não resolvida', () {
    final result = service.validateAction(_action('1'), snapshot);

    expect(result.classification, CioTerritorialClassification.unresolved);
  });

  test('bairro duplicado torna o registro ambíguo', () {
    final result = service.validateAction(
      _action('1', regionalId: 'r1', neighborhood: 'Centro'),
      snapshot,
    );

    expect(result.classification, CioTerritorialClassification.ambiguous);
    expect(
      result.findings,
      contains(CioTerritorialFinding.ambiguousNeighborhood),
    );
  });

  test('tipologia divergente impede cobertura institucional válida', () {
    final result = service.validateAction(
      _action(
        '1',
        regionalId: 'r1',
        neighborhood: 'São José',
        type: TipoRegional.saude.codigo,
      ),
      snapshot,
    );

    expect(result.classification, CioTerritorialClassification.divergent);
    expect(result.findings, contains(CioTerritorialFinding.typeMismatch));
  });

  test('limite injetado classifica coordenada externa', () {
    final boundedService = CioTerritorialGovernanceService(
      coordinateBoundaryValidator: (latitude, longitude) =>
          latitude < -3 && longitude < -38,
    );
    final result = boundedService.validateAction(
      _action(
        '1',
        regionalId: 'r1',
        neighborhood: 'São José',
        latitude: 10,
        longitude: 10,
      ),
      snapshot,
    );

    expect(result.classification, CioTerritorialClassification.outOfBounds);
  });

  test('relatório reconcilia total e cobertura institucional', () {
    final report = service.validate(
      [
        _action('1', regionalId: 'r1', neighborhood: 'São José'),
        _action('2', regionalId: 'desconhecida'),
        _action('3', regionalName: 'Regional antiga'),
      ],
      snapshot,
    );

    expect(report.validations, hasLength(3));
    expect(report.count(CioTerritorialClassification.valid), 1);
    expect(report.count(CioTerritorialClassification.orphan), 1);
    expect(report.count(CioTerritorialClassification.legacy), 1);
    expect(report.institutionalCoverage, closeTo(1 / 3, 0.0001));
  });

  test('diagnóstico considera somente a janela consolidada de 12 meses', () {
    final diagnostic = service.buildTwelveMonthDiagnostic(
      [
        _action(
          'limite',
          regionalId: 'r1',
          neighborhood: 'São José',
          latitude: -3.7,
          longitude: -38.5,
        ).copyWith(dataAcao: DateTime(2025, 8, 13)),
        _action('recente', regionalId: 'desconhecida')
            .copyWith(dataAcao: DateTime(2026, 8, 12)),
        _action('antiga', regionalId: 'desconhecida')
            .copyWith(dataAcao: DateTime(2025, 8, 12)),
        _action('futura', regionalId: 'desconhecida')
            .copyWith(dataAcao: DateTime(2026, 8, 14)),
      ],
      snapshot,
      reference: DateTime(2026, 8, 13, 18),
    );

    expect(diagnostic.start, DateTime(2025, 8, 13));
    expect(diagnostic.end, DateTime(2026, 8, 13));
    expect(diagnostic.report.validations, hasLength(2));
    expect(diagnostic.sanitationQueue, hasLength(1));
    expect(diagnostic.sanitationQueue.single.actionId, 'recente');
  });

  test('fila contém identificação mínima e não expõe dados pessoais', () {
    final action = _action(
      'acao-1',
      regionalId: 'desconhecida',
      regionalName: 'Regional antiga',
      neighborhood: 'Centro',
    ).copyWith(
      numeroRAE: '2026-001',
      coordenadorNome: 'Nome que não deve integrar a fila',
    );

    final item = service
        .buildTwelveMonthDiagnostic(
          [action],
          snapshot,
          reference: DateTime(2026, 8, 13),
        )
        .sanitationQueue
        .single;

    expect(item.actionId, 'acao-1');
    expect(item.raeNumber, '2026-001');
    expect(item.regionalName, 'Regional antiga');
    expect(item.neighborhood, 'Centro');
    expect(item.toString(), isNot(contains('Nome que não deve')));
  });
}

AcaoModel _action(
  String id, {
  String regionalId = '',
  String regionalName = '',
  String neighborhood = '',
  String type = 'administrativa',
  double latitude = 0,
  double longitude = 0,
}) =>
    AcaoModel.fromMap({
      'id': id,
      'dataAcao': '2026-08-13T10:00:00.000',
      'regionalId': regionalId,
      'regional': regionalName,
      'bairro': neighborhood,
      'tipoRegional': type,
      'latitude': latitude,
      'longitude': longitude,
      'status': 'concluido',
    });
