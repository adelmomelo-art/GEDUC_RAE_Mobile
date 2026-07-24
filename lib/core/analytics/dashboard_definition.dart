/// Público institucional ao qual um dashboard se destina.
///
/// O público não representa diretamente um perfil de autenticação.
/// Ele descreve a finalidade principal do dashboard e poderá ser
/// utilizado futuramente por:
/// - mecanismos de autorização;
/// - geração automática de menus;
/// - APIs;
/// - documentação;
/// - assistente Faxita.
enum DashboardAudience {
  /// Dashboard destinado à alta administração.
  executive,

  /// Dashboard destinado a gestores institucionais.
  management,

  /// Dashboard destinado a coordenadores operacionais.
  coordination,

  /// Dashboard destinado às equipes de execução.
  operational,

  /// Dashboard destinado a analistas e equipes técnicas.
  technical,

  /// Dashboard disponível para múltiplos públicos.
  general,
}

/// Categoria funcional do dashboard.
///
/// A categoria permite organizar o catálogo institucional do Atlas
/// sem vincular o dashboard a componentes de interface.
enum DashboardCategory {
  /// Indicadores estratégicos e de alto nível.
  strategic,

  /// Indicadores gerenciais e de acompanhamento.
  management,

  /// Indicadores relacionados à operação.
  operational,

  /// Indicadores de produtividade.
  productivity,

  /// Indicadores de qualidade e conformidade.
  quality,

  /// Indicadores analíticos especializados.
  analytical,

  /// Dashboard construído para uma finalidade específica.
  custom,
}

/// Definição institucional de um dashboard do Framework Atlas.
///
/// Esta classe descreve a identidade, a finalidade e os requisitos
/// de um dashboard, sem realizar cálculos e sem construir componentes
/// visuais.
///
/// Uma definição poderá ser utilizada por:
/// - [DashboardRegistry];
/// - [DashboardFactory];
/// - menus automáticos;
/// - mecanismos de autorização;
/// - APIs;
/// - documentação;
/// - assistente Faxita.
///
/// A classe permanece independente de:
/// - Flutter;
/// - Firebase;
/// - banco de dados;
/// - componentes visuais;
/// - módulos operacionais específicos.
final class DashboardDefinition {
  DashboardDefinition({
    required this.id,
    required this.title,
    required this.domain,
    required this.audience,
    required this.category,
    this.description,
    this.version = '1.0.0',
    this.enabled = true,
    Iterable<String> requiredIndicators = const [],
    Iterable<String> allowedProfiles = const [],
    Map<String, Object?> metadata = const {},
  })  : requiredIndicators = List<String>.unmodifiable(
          _normalizeValues(requiredIndicators),
        ),
        allowedProfiles = List<String>.unmodifiable(
          _normalizeValues(allowedProfiles),
        ),
        metadata = Map<String, Object?>.unmodifiable(
          metadata,
        ) {
    _validate();
  }

  /// Identificador institucional único.
  ///
  /// Exemplos:
  /// - executive;
  /// - operational;
  /// - geduc;
  /// - rpas.
  final String id;

  /// Título institucional apresentado aos consumidores.
  final String title;

  /// Descrição funcional opcional.
  final String? description;

  /// Domínio institucional principal.
  ///
  /// Exemplos:
  /// - institucional;
  /// - educacao;
  /// - fiscalizacao;
  /// - rpas;
  /// - engenharia.
  final String domain;

  /// Público principal do dashboard.
  final DashboardAudience audience;

  /// Categoria funcional do dashboard.
  final DashboardCategory category;

  /// Versão semântica da definição.
  ///
  /// Exemplo:
  /// `1.0.0`
  final String version;

  /// Indica se o dashboard está disponível para utilização.
  final bool enabled;

  /// Indicadores necessários para a construção do dashboard.
  final List<String> requiredIndicators;

  /// Perfis autorizados a acessar o dashboard.
  ///
  /// Uma lista vazia significa que a definição não impõe restrição
  /// própria e que a autorização poderá ser resolvida externamente.
  final List<String> allowedProfiles;

  /// Informações adicionais preservadas com seus respectivos tipos.
  final Map<String, Object?> metadata;

  /// Indica se existe uma descrição institucional.
  bool get hasDescription =>
      description != null &&
      description!.trim().isNotEmpty;

  /// Indica se o dashboard exige indicadores específicos.
  bool get hasRequiredIndicators =>
      requiredIndicators.isNotEmpty;

  /// Indica se existem perfis autorizados declarados.
  bool get hasAllowedProfiles =>
      allowedProfiles.isNotEmpty;

  /// Indica se existem metadados adicionais.
  bool get hasMetadata => metadata.isNotEmpty;

  /// Retorna a quantidade de indicadores obrigatórios.
  int get requiredIndicatorsCount =>
      requiredIndicators.length;

  /// Retorna a quantidade de perfis autorizados.
  int get allowedProfilesCount =>
      allowedProfiles.length;

  /// Verifica se determinado indicador é obrigatório.
  bool requiresIndicator(
    String indicatorId,
  ) {
    final normalizedId = indicatorId.trim();

    if (normalizedId.isEmpty) {
      return false;
    }

    return requiredIndicators.contains(normalizedId);
  }

  /// Verifica se determinado perfil está autorizado.
  ///
  /// Quando nenhuma restrição estiver declarada, qualquer perfil
  /// será considerado permitido pela própria definição.
  bool allowsProfile(
    String profile,
  ) {
    if (!hasAllowedProfiles) {
      return true;
    }

    final normalizedProfile = profile.trim().toLowerCase();

    if (normalizedProfile.isEmpty) {
      return false;
    }

    return allowedProfiles.any(
      (allowedProfile) =>
          allowedProfile.toLowerCase() ==
          normalizedProfile,
    );
  }

  /// Obtém um metadado pelo nome.
  Object? metadataValue(
    String key,
  ) {
    final normalizedKey = key.trim();

    if (normalizedKey.isEmpty) {
      return null;
    }

    return metadata[normalizedKey];
  }

  /// Indica se determinado metadado existe.
  bool containsMetadata(
    String key,
  ) {
    final normalizedKey = key.trim();

    if (normalizedKey.isEmpty) {
      return false;
    }

    return metadata.containsKey(normalizedKey);
  }

  /// Retorna uma nova definição alterando apenas os campos informados.
  DashboardDefinition copyWith({
    String? id,
    String? title,
    String? description,
    String? domain,
    DashboardAudience? audience,
    DashboardCategory? category,
    String? version,
    bool? enabled,
    Iterable<String>? requiredIndicators,
    Iterable<String>? allowedProfiles,
    Map<String, Object?>? metadata,
  }) {
    return DashboardDefinition(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      domain: domain ?? this.domain,
      audience: audience ?? this.audience,
      category: category ?? this.category,
      version: version ?? this.version,
      enabled: enabled ?? this.enabled,
      requiredIndicators:
          requiredIndicators ??
          this.requiredIndicators,
      allowedProfiles:
          allowedProfiles ??
          this.allowedProfiles,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Retorna uma nova definição habilitada.
  DashboardDefinition enable() {
    if (enabled) {
      return this;
    }

    return copyWith(enabled: true);
  }

  /// Retorna uma nova definição desabilitada.
  DashboardDefinition disable() {
    if (!enabled) {
      return this;
    }

    return copyWith(enabled: false);
  }

  /// Retorna uma nova definição adicionando ou substituindo
  /// um metadado.
  DashboardDefinition withMetadata(
    String key,
    Object? value,
  ) {
    final normalizedKey = key.trim();

    if (normalizedKey.isEmpty) {
      throw ArgumentError.value(
        key,
        'key',
        'A chave do metadado não pode ser vazia.',
      );
    }

    final updatedMetadata =
        Map<String, Object?>.from(metadata);

    updatedMetadata[normalizedKey] = value;

    return copyWith(metadata: updatedMetadata);
  }

  /// Retorna uma nova definição sem o metadado informado.
  DashboardDefinition withoutMetadata(
    String key,
  ) {
    final normalizedKey = key.trim();

    if (normalizedKey.isEmpty ||
        !metadata.containsKey(normalizedKey)) {
      return this;
    }

    final updatedMetadata =
        Map<String, Object?>.from(metadata)
          ..remove(normalizedKey);

    return copyWith(metadata: updatedMetadata);
  }

  /// Retorna uma nova definição incluindo um indicador obrigatório.
  DashboardDefinition withRequiredIndicator(
    String indicatorId,
  ) {
    final normalizedId = indicatorId.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError.value(
        indicatorId,
        'indicatorId',
        'O identificador do indicador não pode ser vazio.',
      );
    }

    if (requiresIndicator(normalizedId)) {
      return this;
    }

    return copyWith(
      requiredIndicators: [
        ...requiredIndicators,
        normalizedId,
      ],
    );
  }

  /// Retorna uma nova definição sem determinado indicador obrigatório.
  DashboardDefinition withoutRequiredIndicator(
    String indicatorId,
  ) {
    final normalizedId = indicatorId.trim();

    if (normalizedId.isEmpty ||
        !requiresIndicator(normalizedId)) {
      return this;
    }

    return copyWith(
      requiredIndicators: requiredIndicators
          .where(
            (id) => id != normalizedId,
          )
          .toList(growable: false),
    );
  }

  /// Valida a consistência mínima da definição.
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

    if (version.trim().isEmpty) {
      throw ArgumentError.value(
        version,
        'version',
        'A versão do dashboard não pode ser vazia.',
      );
    }

    if (!_isSemanticVersion(version)) {
      throw ArgumentError.value(
        version,
        'version',
        'A versão deve seguir o formato semântico '
            'major.minor.patch.',
      );
    }
  }

  static List<String> _normalizeValues(
    Iterable<String> values,
  ) {
    final normalizedValues = <String>[];
    final uniqueValues = <String>{};

    for (final value in values) {
      final normalizedValue = value.trim();

      if (normalizedValue.isEmpty) {
        continue;
      }

      if (uniqueValues.add(normalizedValue)) {
        normalizedValues.add(normalizedValue);
      }
    }

    return normalizedValues;
  }

  static bool _isSemanticVersion(
    String value,
  ) {
    final semanticVersionPattern = RegExp(
      r'^\d+\.\d+\.\d+$',
    );

    return semanticVersionPattern.hasMatch(
      value.trim(),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DashboardDefinition &&
            other.id == id &&
            other.version == version;
  }

  @override
  int get hashCode => Object.hash(
        id,
        version,
      );

  @override
  String toString() {
    return 'DashboardDefinition('
        'id: $id, '
        'title: $title, '
        'domain: $domain, '
        'audience: ${audience.name}, '
        'category: ${category.name}, '
        'version: $version, '
        'enabled: $enabled'
        ')';
  }
}