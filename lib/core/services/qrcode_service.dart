class QrCodeService {
  static String gerarConteudoRae({
    required String acaoId,
    required String numeroRAE,
  }) {
    return 'GEDUC-RAE|id:$acaoId|numero:$numeroRAE';
  }

  static String gerarUrlConsulta({
    required String acaoId,
  }) {
    return 'https://geduc-rae.web.app/rae/$acaoId';
  }

  static String gerarTextoQr({
    required String acaoId,
    required String numeroRAE,
  }) {
    return gerarUrlConsulta(acaoId: acaoId);
  }
}