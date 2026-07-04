class AcaoRulesService {
  static bool calcularMeta({required int pessoasAlcancadas, required int publicoMinimo}) => pessoasAlcancadas >= publicoMinimo;
  static bool motivoMetaObrigatorio({required bool metaAtingida, required String? motivo}) => !metaAtingida && (motivo == null || motivo.trim().isEmpty);
}
