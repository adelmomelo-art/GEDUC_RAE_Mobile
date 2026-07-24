import 'package:geduc_rae_mobile/core/analytics/analytics_record.dart';

/// Massa oficial de dados para os testes de integração do Core Analytics.
///
/// A fixture representa cenários operacionais da Plataforma Fênix sem
/// depender de Firebase, widgets, controllers ou modelos específicos dos
/// módulos operacionais.
///
/// Todos os métodos retornam novas listas, impedindo que um teste altere a
/// massa utilizada por outro teste.
final class AnalyticsIntegrationFixture {
  AnalyticsIntegrationFixture._();

  static const String educationDomain = 'educacao';
  static const String rpasDomain = 'rpas';
  static const String inspectionDomain = 'fiscalizacao';

  static const String completedStatus = 'concluida';
  static const String plannedStatus = 'planejada';
  static const String cancelledStatus = 'cancelada';

  /// Massa principal e determinística da suíte de integração.
  ///
  /// Contrato estrutural consolidado:
  /// - 24 registros;
  /// - 18 registros de educação;
  /// - 4 registros de RPAS;
  /// - 2 registros de fiscalização;
  /// - 18 concluídos;
  /// - 3 planejados;
  /// - 3 cancelados.
  ///
  /// Totais numéricos, médias, metas e avaliações não pertencem ao contrato
  /// estrutural desta fixture. Eles serão congelados e validados nos testes
  /// de regressão do AnalyticsEngine.
  static List<AnalyticsRecord> operationalRecords() {
    return List<AnalyticsRecord>.unmodifiable([
      _record(
        id: 'EDU-001',
        domain: educationDomain,
        occurredAt: DateTime(2026, 1, 10, 8),
        status: completedStatus,
        people: 120,
        vehicles: 35,
        humanResources: 5,
        target: 100,
        achieved: 120,
        rating: 4.5,
        regional: 'I',
        shift: 'manha',
        project: 'AMC nas Escolas',
        actionType: 'palestra',
      ),
      _record(
        id: 'EDU-002',
        domain: educationDomain,
        occurredAt: DateTime(2026, 1, 20, 14),
        status: completedStatus,
        people: 80,
        vehicles: 20,
        humanResources: 4,
        target: 100,
        achieved: 80,
        rating: 4,
        regional: 'II',
        shift: 'tarde',
        project: 'Pit Stop da Educacao',
        actionType: 'comando educativo',
      ),
      _record(
        id: 'EDU-003',
        domain: educationDomain,
        occurredAt: DateTime(2026, 2, 5, 9),
        status: completedStatus,
        people: 210,
        vehicles: 55,
        humanResources: 7,
        target: 200,
        achieved: 210,
        rating: 5,
        regional: 'VI',
        shift: 'manha',
        project: 'Volta as Aulas',
        actionType: 'acao integrada',
      ),
      _record(
        id: 'EDU-004',
        domain: educationDomain,
        occurredAt: DateTime(2026, 2, 18, 15),
        status: cancelledStatus,
        regional: 'III',
        shift: 'tarde',
        project: 'Bike Cidade',
        actionType: 'comando educativo',
      ),
      _record(
        id: 'EDU-005',
        domain: educationDomain,
        occurredAt: DateTime(2026, 3, 3, 8, 30),
        status: completedStatus,
        people: 160,
        vehicles: 40,
        humanResources: 6,
        target: 150,
        achieved: 160,
        rating: 4.2,
        regional: 'VI',
        shift: 'manha',
        project: 'Ciclista Seguro',
        actionType: 'comando educativo',
      ),
      _record(
        id: 'EDU-006',
        domain: educationDomain,
        occurredAt: DateTime(2026, 3, 22, 19),
        status: completedStatus,
        people: 95,
        vehicles: 60,
        humanResources: 5,
        target: 100,
        achieved: 95,
        rating: 3.8,
        regional: 'IV',
        shift: 'noite',
        project: 'AMC nos Bares',
        actionType: 'abordagem educativa',
      ),
      _record(
        id: 'EDU-007',
        domain: educationDomain,
        occurredAt: DateTime(2026, 4, 7, 10),
        status: plannedStatus,
        target: 180,
        regional: 'V',
        shift: 'manha',
        project: 'AMC Kids',
        actionType: 'minicircuito',
      ),
      _record(
        id: 'EDU-008',
        domain: educationDomain,
        occurredAt: DateTime(2026, 4, 25, 14),
        status: completedStatus,
        people: 300,
        vehicles: 75,
        humanResources: 9,
        target: 250,
        achieved: 300,
        rating: 4.9,
        regional: 'VI',
        shift: 'tarde',
        project: 'AMC Itinerante',
        actionType: 'acao integrada',
      ),
      _record(
        id: 'EDU-009',
        domain: educationDomain,
        occurredAt: DateTime(2026, 5, 9, 7, 30),
        status: completedStatus,
        people: 140,
        vehicles: 90,
        humanResources: 6,
        target: 140,
        achieved: 140,
        rating: 4.4,
        regional: 'I',
        shift: 'manha',
        project: 'Condutor Consciente',
        actionType: 'comando educativo',
      ),
      _record(
        id: 'EDU-010',
        domain: educationDomain,
        occurredAt: DateTime(2026, 5, 28, 16),
        status: completedStatus,
        people: 70,
        vehicles: 25,
        humanResources: 3,
        target: 80,
        achieved: 70,
        rating: 3.5,
        regional: 'II',
        shift: 'tarde',
        project: 'Crianca Segura',
        actionType: 'palestra',
      ),
      _record(
        id: 'EDU-011',
        domain: educationDomain,
        occurredAt: DateTime(2026, 6, 12, 9),
        status: completedStatus,
        people: 260,
        vehicles: 100,
        humanResources: 8,
        target: 250,
        achieved: 260,
        rating: 4.7,
        regional: 'VI',
        shift: 'manha',
        project: 'Motociclista Prudente',
        actionType: 'comando educativo',
      ),
      _record(
        id: 'EDU-012',
        domain: educationDomain,
        occurredAt: DateTime(2026, 6, 30, 20),
        status: cancelledStatus,
        target: 120,
        regional: 'XII',
        shift: 'noite',
        project: 'Alegria com Responsabilidade',
        actionType: 'comando educativo',
      ),
      _record(
        id: 'EDU-013',
        domain: educationDomain,
        occurredAt: DateTime(2026, 7, 1, 8),
        status: completedStatus,
        people: 180,
        vehicles: 65,
        humanResources: 7,
        target: 150,
        achieved: 180,
        rating: 4.8,
        regional: 'VI',
        shift: 'manha',
        project: 'Volta as Aulas',
        actionType: 'acao integrada',
      ),
      _record(
        id: 'EDU-014',
        domain: educationDomain,
        occurredAt: DateTime(2026, 7, 11, 8, 30),
        status: completedStatus,
        people: 240,
        vehicles: 85,
        humanResources: 8,
        target: 200,
        achieved: 240,
        rating: 4.6,
        regional: 'VI',
        shift: 'manha',
        project: 'Pit Stop da Educacao',
        actionType: 'comando educativo',
      ),
      _record(
        id: 'EDU-015',
        domain: educationDomain,
        occurredAt: DateTime(2026, 7, 15, 14),
        status: completedStatus,
        people: 110,
        vehicles: 45,
        humanResources: 5,
        target: 120,
        achieved: 110,
        rating: 4.1,
        regional: 'II',
        shift: 'tarde',
        project: 'Passeio Seguro',
        actionType: 'abordagem educativa',
      ),
      _record(
        id: 'EDU-016',
        domain: educationDomain,
        occurredAt: DateTime(2026, 7, 22, 9),
        status: completedStatus,
        people: 320,
        vehicles: 120,
        humanResources: 10,
        target: 300,
        achieved: 320,
        rating: 5,
        regional: 'VI',
        shift: 'manha',
        project: 'AMC nas Escolas',
        actionType: 'palestra',
      ),
      _record(
        id: 'EDU-017',
        domain: educationDomain,
        occurredAt: DateTime(2026, 7, 31, 18),
        status: plannedStatus,
        target: 200,
        regional: 'III',
        shift: 'noite',
        project: 'Desacelere',
        actionType: 'comando educativo',
      ),
      _record(
        id: 'EDU-018',
        domain: educationDomain,
        occurredAt: DateTime(2026, 8, 8, 10),
        status: completedStatus,
        people: 150,
        vehicles: 40,
        humanResources: 6,
        achieved: 150,
        regional: 'V',
        shift: 'manha',
        project: 'Transito e Meio Ambiente',
        actionType: 'palestra',
      ),
      _record(
        id: 'RPAS-001',
        domain: rpasDomain,
        occurredAt: DateTime(2026, 2, 12, 9),
        status: completedStatus,
        people: 35,
        vehicles: 2,
        humanResources: 4,
        target: 30,
        achieved: 35,
        rating: 4.8,
        regional: 'CENTRO',
        shift: 'manha',
        project: 'Workshop RPAS',
        actionType: 'capacitacao',
      ),
      _record(
        id: 'RPAS-002',
        domain: rpasDomain,
        occurredAt: DateTime(2026, 4, 15, 15),
        status: plannedStatus,
        target: 20,
        regional: 'VI',
        shift: 'tarde',
        project: 'Mapeamento Aereo',
        actionType: 'missao',
      ),
      _record(
        id: 'RPAS-003',
        domain: rpasDomain,
        occurredAt: DateTime(2026, 6, 21, 7),
        status: completedStatus,
        people: 20,
        vehicles: 1,
        humanResources: 3,
        target: 20,
        achieved: 20,
        rating: 4.5,
        regional: 'V',
        shift: 'manha',
        project: 'Inspecao Aerea',
        actionType: 'missao',
      ),
      _record(
        id: 'RPAS-004',
        domain: rpasDomain,
        occurredAt: DateTime(2026, 7, 18, 16),
        status: cancelledStatus,
        regional: 'II',
        shift: 'tarde',
        project: 'Cobertura Institucional',
        actionType: 'missao',
      ),
      _record(
        id: 'FIS-001',
        domain: inspectionDomain,
        occurredAt: DateTime(2026, 3, 14, 22),
        status: completedStatus,
        people: 60,
        vehicles: 110,
        humanResources: 8,
        target: 100,
        achieved: 110,
        rating: 4,
        regional: 'IV',
        shift: 'noite',
        project: 'Operacao Integrada',
        actionType: 'fiscalizacao',
      ),
      _record(
        id: 'FIS-002',
        domain: inspectionDomain,
        occurredAt: DateTime(2026, 7, 25, 21),
        status: completedStatus,
        people: 130,
        vehicles: 135,
        humanResources: 8,
        target: 120,
        achieved: 135,
        rating: 4.3,
        regional: 'VI',
        shift: 'noite',
        project: 'Operacao Integrada',
        actionType: 'fiscalizacao',
      ),
    ]);
  }

  static List<AnalyticsRecord> educationRecords() {
    return List<AnalyticsRecord>.unmodifiable(
      operationalRecords().where(
        (record) => record.domain == educationDomain,
      ),
    );
  }

  static List<AnalyticsRecord> completedEducationRecords() {
    return List<AnalyticsRecord>.unmodifiable(
      educationRecords().where(
        (record) => record.status == completedStatus,
      ),
    );
  }

  static List<AnalyticsRecord> julyEducationRecords() {
    return List<AnalyticsRecord>.unmodifiable(
      educationRecords().where(
        (record) =>
            record.occurredAt.year == 2026 &&
            record.occurredAt.month == DateTime.july,
      ),
    );
  }

  static List<AnalyticsRecord> regionalVIMorningCompletedEducationRecords() {
    return List<AnalyticsRecord>.unmodifiable(
      educationRecords().where(
        (record) =>
            record.status == completedStatus &&
            record.dimension('regional') == 'VI' &&
            record.dimension('turno') == 'manha',
      ),
    );
  }

  /// Cenário com dados opcionais ausentes, útil para validar segurança do Core.
  static List<AnalyticsRecord> partialDataRecords() {
    return List<AnalyticsRecord>.unmodifiable([
      _record(
        id: 'PARTIAL-001',
        domain: educationDomain,
        occurredAt: DateTime(2026, 9, 1),
        status: completedStatus,
        people: 50,
        regional: 'I',
        shift: 'manha',
        project: 'Sem avaliacao e sem meta',
        actionType: 'palestra',
      ),
      _record(
        id: 'PARTIAL-002',
        domain: educationDomain,
        occurredAt: DateTime(2026, 9, 2),
        status: completedStatus,
        people: 80,
        target: 100,
        regional: 'II',
        shift: 'tarde',
        project: 'Meta sem realizado',
        actionType: 'palestra',
      ),
      _record(
        id: 'PARTIAL-003',
        domain: educationDomain,
        occurredAt: DateTime(2026, 9, 3),
        status: completedStatus,
        achieved: 70,
        rating: 4,
        regional: 'III',
        shift: 'noite',
        project: 'Realizado sem meta',
        actionType: 'acao integrada',
      ),
      AnalyticsRecord(
        id: 'PARTIAL-004',
        domain: educationDomain,
        occurredAt: DateTime(2026, 9, 4),
        status: plannedStatus,
      ),
    ]);
  }

  /// Gera volume determinístico para testes futuros de desempenho.
  ///
  /// Os registros são válidos e não utilizam aleatoriedade, permitindo
  /// resultados repetíveis em qualquer ambiente.
  static List<AnalyticsRecord> largeDataset({
    int count = 1000,
  }) {
    if (count < 0) {
      throw ArgumentError.value(
        count,
        'count',
        'A quantidade de registros não pode ser negativa.',
      );
    }

    return List<AnalyticsRecord>.unmodifiable(
      List<AnalyticsRecord>.generate(count, (index) {
        final number = index + 1;
        final people = 20 + (index % 181);
        final vehicles = index % 71;
        final humanResources = 2 + (index % 9);
        final target = 50.0 + (index % 151);
        final achieved = target + ((index % 5) - 2) * 10;

        return AnalyticsRecord(
          id: 'LOAD-${number.toString().padLeft(5, '0')}',
          domain: index.isEven ? educationDomain : rpasDomain,
          occurredAt: DateTime(
            2026,
            1 + (index % 12),
            1 + (index % 28),
            index % 24,
          ),
          status: index % 7 == 0 ? plannedStatus : completedStatus,
          peopleCount: people,
          vehicleCount: vehicles,
          humanResourcesCount: humanResources,
          targetValue: target,
          achievedValue: achieved < 0 ? 0 : achieved,
          rating: (index % 6).toDouble().clamp(0, 5),
          dimensions: {
            'regional': _regionals[index % _regionals.length],
            'turno': _shifts[index % _shifts.length],
            'projeto': 'Projeto ${(index % 10) + 1}',
            'tipo_acao': 'Tipo ${(index % 5) + 1}',
          },
        );
      }),
    );
  }

  static AnalyticsRecord _record({
    required String id,
    required String domain,
    required DateTime occurredAt,
    required String status,
    int people = 0,
    int vehicles = 0,
    int humanResources = 0,
    double? target,
    double? achieved,
    double? rating,
    required String regional,
    required String shift,
    required String project,
    required String actionType,
  }) {
    return AnalyticsRecord(
      id: id,
      domain: domain,
      occurredAt: occurredAt,
      status: status,
      peopleCount: people,
      vehicleCount: vehicles,
      humanResourcesCount: humanResources,
      targetValue: target,
      achievedValue: achieved,
      rating: rating,
      dimensions: {
        'regional': regional,
        'turno': shift,
        'projeto': project,
        'tipo_acao': actionType,
      },
    );
  }

  static const List<String> _regionals = [
    'I',
    'II',
    'III',
    'IV',
    'V',
    'VI',
    'XII',
  ];

  static const List<String> _shifts = [
    'manha',
    'tarde',
    'noite',
  ];
}
