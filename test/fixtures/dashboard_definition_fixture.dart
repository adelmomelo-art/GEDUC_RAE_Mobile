import 'package:geduc_rae_mobile/core/analytics/dashboard_definition.dart';

/// Fábrica de definições reutilizáveis nos testes do Framework Atlas.
///
/// Centraliza a criação de dashboards para evitar repetição e manter
/// os cenários de teste consistentes.
final class DashboardDefinitionFixture {
  const DashboardDefinitionFixture._();

  static DashboardDefinition create({
    String id = 'dashboard_padrao',
    String title = 'Dashboard Padrão',
    String? description,
    String domain = 'institucional',
    DashboardAudience audience = DashboardAudience.general,
    DashboardCategory category = DashboardCategory.custom,
    String version = '1.0.0',
    bool enabled = true,
    Iterable<String> requiredIndicators = const [],
    Iterable<String> allowedProfiles = const [],
    Map<String, Object?> metadata = const {},
  }) {
    return DashboardDefinition(
      id: id,
      title: title,
      description: description,
      domain: domain,
      audience: audience,
      category: category,
      version: version,
      enabled: enabled,
      requiredIndicators: requiredIndicators,
      allowedProfiles: allowedProfiles,
      metadata: metadata,
    );
  }

  static DashboardDefinition geduc({
    String id = 'geduc_operacional',
    bool enabled = true,
  }) {
    return create(
      id: id,
      title: 'Dashboard Operacional GEDUC',
      description: 'Indicadores operacionais das ações educativas.',
      domain: 'educacao',
      audience: DashboardAudience.management,
      category: DashboardCategory.operational,
      enabled: enabled,
      requiredIndicators: const [
        'publico_alcancado',
        'veiculos_abordados',
      ],
      allowedProfiles: const [
        'administrador',
        'gestor',
        'coordenador',
      ],
      metadata: const {
        'module': 'GEDUC',
        'institutional': true,
      },
    );
  }

  static DashboardDefinition executive({
    String id = 'executivo_institucional',
    bool enabled = true,
  }) {
    return create(
      id: id,
      title: 'Dashboard Executivo',
      description: 'Indicadores estratégicos institucionais.',
      domain: 'institucional',
      audience: DashboardAudience.executive,
      category: DashboardCategory.strategic,
      enabled: enabled,
      requiredIndicators: const [
        'acoes_realizadas',
        'publico_total',
        'taxa_meta_atingida',
      ],
      allowedProfiles: const [
        'administrador',
        'gestor',
      ],
      metadata: const {
        'level': 'executive',
        'priority': 1,
      },
    );
  }

  static DashboardDefinition rpas({
    String id = 'rpas_operacional',
    bool enabled = true,
  }) {
    return create(
      id: id,
      title: 'Dashboard RPAS',
      description: 'Indicadores operacionais de aeronaves remotamente pilotadas.',
      domain: 'rpas',
      audience: DashboardAudience.management,
      category: DashboardCategory.operational,
      enabled: enabled,
      requiredIndicators: const [
        'voos_realizados',
        'horas_de_voo',
      ],
      allowedProfiles: const [
        'administrador',
        'gestor',
        'operador_rpas',
      ],
      metadata: const {
        'module': 'RPAS',
        'institutional': true,
      },
    );
  }

  static DashboardDefinition disabled({
    String id = 'dashboard_desabilitado',
  }) {
    return create(
      id: id,
      title: 'Dashboard Desabilitado',
      enabled: false,
    );
  }

  static List<DashboardDefinition> defaultCollection() {
    return [
      geduc(),
      executive(),
      rpas(),
      disabled(),
    ];
  }

  static List<DashboardDefinition> generate(
    int quantity, {
    String idPrefix = 'dashboard',
    String domain = 'institucional',
    bool enabled = true,
  }) {
    if (quantity < 0) {
      throw ArgumentError.value(
        quantity,
        'quantity',
        'A quantidade não pode ser negativa.',
      );
    }

    return List<DashboardDefinition>.generate(
      quantity,
      (index) => create(
        id: '${idPrefix}_$index',
        title: 'Dashboard $index',
        domain: domain,
        enabled: enabled,
        metadata: {
          'index': index,
          'generated': true,
        },
      ),
      growable: false,
    );
  }
}