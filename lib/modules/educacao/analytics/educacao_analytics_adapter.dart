import '../../../core/analytics/analytics_record.dart';
import '../../../data/models/acao_model.dart';

/// Adaptador responsável por converter registros do domínio
/// Educação/GEDUC para o contrato institucional do Framework Atlas.
///
/// Esta classe pertence exclusivamente ao módulo Educação e conhece:
/// - o modelo operacional [AcaoModel];
/// - o contrato institucional [AnalyticsRecord].
///
/// O núcleo analítico permanece desacoplado e não conhece
/// conceitos específicos do GEDUC.
final class EducacaoAnalyticsAdapter {
  const EducacaoAnalyticsAdapter();

  /// Identificador institucional do domínio Educação.
  static const String domainName = 'educacao';

  /// Converte uma ação do GEDUC em um registro analítico genérico.
  ///
  /// Os valores das dimensões preservam seus tipos originais:
  /// - String permanece String;
  /// - int permanece int;
  /// - bool permanece bool.
  ///
  /// Nenhuma regra analítica é executada neste adapter.
  /// Sua responsabilidade é somente traduzir o modelo operacional
  /// para o contrato institucional do Framework Atlas.
  AnalyticsRecord toAnalyticsRecord(AcaoModel acao) {
    return AnalyticsRecord(
      id: acao.id,
      domain: domainName,
      occurredAt: acao.dataAcao,
      status: acao.status,
      peopleCount: acao.pessoasAlcancadas,
      vehicleCount: acao.veiculosAbordados,
      humanResourcesCount:
          acao.agentesTransito + acao.equipeTerceirizada,
      targetValue: acao.publicoMinimo.toDouble(),
      achievedValue: acao.pessoasAlcancadas.toDouble(),
      rating: null,
      dimensions: {
        'numero_rae': acao.numeroRAE,
        'ano_rae': acao.anoRAE,
        'turno': acao.turno,
        'nome_acao': acao.nomeAcao,
        'tipo_acao': acao.tipoAcao,
        'regional': acao.regional,
        'bairro': acao.bairro,
        'publico': acao.publicoId,
        'formacao': acao.formacaoId,
        'coordenador_id': acao.coordenadorId,
        'coordenador_nome': acao.coordenadorNome,
        'acao_planejada': acao.acaoPlanejada,
        'meta_atingida': acao.metaAtingida,
        'sincronizado': acao.sincronizado,
        'cobertura_midia': acao.coberturaMidia,
        'participacao_outro_orgao':
            acao.houveParticipacaoOutroOrgao,
        'orgao_participante':
            acao.orgaoParticipanteId,
        'instituicao_parceira':
            acao.instituicaoParceira,
        'sexo_predominante':
            acao.sexoPredominanteId,
        'mudanca_comportamento':
            acao.mudancaComportamentoId,
      },
    );
  }

  /// Converte uma coleção de ações do GEDUC em registros analíticos.
  ///
  /// A lista resultante não permite alteração estrutural.
  List<AnalyticsRecord> toAnalyticsRecords(
    Iterable<AcaoModel> acoes,
  ) {
    return List<AnalyticsRecord>.unmodifiable(
      acoes.map(toAnalyticsRecord),
    );
  }
}