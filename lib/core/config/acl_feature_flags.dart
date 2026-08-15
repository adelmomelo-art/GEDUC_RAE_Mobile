class AclFeatureFlags {
  const AclFeatureFlags._();

  /// Etapa 5: integração preparada, mas desativada no APK padrão.
  static const bool scopedAccessEnabled = bool.fromEnvironment(
    'ACL001_SCOPED_ACCESS_ENABLED',
    defaultValue: false,
  );
}
