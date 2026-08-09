import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/domains/domain_provider.dart';
import '../../core/services/faxita_insights_service.dart';
import '../../core/services/faxita_review_service.dart';
import '../../core/services/pdf_relatorio_service.dart';
import '../../core/widgets/rae_qrcode_widget.dart';
import '../../shared/widgets/journey/fenix_journey_header.dart';
import '../../shared/widgets/layout/fenix_app_bar.dart';
import '../../shared/widgets/layout/fenix_page_scaffold.dart';
import 'controllers/acao_controller.dart';
import 'detalhe_acao_page.dart';
import 'widgets/revisao/review_actions.dart';
import 'widgets/revisao/review_alerts_card.dart';
import 'widgets/revisao/review_dashboard.dart';
import 'widgets/revisao/review_header.dart';
import 'widgets/revisao/review_historical_comparison_card.dart';
import 'widgets/revisao/review_points_card.dart';
import 'widgets/revisao/review_quality_card.dart';
import 'widgets/revisao/review_section_card.dart';
import 'widgets/revisao/review_timeline.dart';

class RevisaoRelatorioPage extends StatefulWidget {
  const RevisaoRelatorioPage({super.key});

  @override
  State<RevisaoRelatorioPage> createState() => _RevisaoRelatorioPageState();
}

class _RevisaoRelatorioPageState extends State<RevisaoRelatorioPage> {
  final FaxitaReviewService faxitaReviewService = FaxitaReviewService();
  final FaxitaInsightsService faxitaInsightsService = FaxitaInsightsService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final controller = context.read<AcaoController>();
      controller.garantirNumeroRae();
      controller.carregarHistoricoComparacao();
    });
  }

  Future<void> _gerarPdf(AcaoController controller) async {
    final acao = controller.acaoAtual;

    if (acao == null) {
      return;
    }

    final domainProvider = context.read<DomainProvider>();
    await PdfRelatorioService().gerarRelatorioAcao(
      acao,
      catalogos: PdfRelatorioService.catalogosDe(domainProvider),
    );
  }

  Future<void> _enviarRelatorio(AcaoController controller) async {
    final ok = await controller.enviarRelatorio();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Relatório enviado com sucesso.'
              : controller.erro ?? 'Erro ao salvar.',
        ),
      ),
    );

    if (ok) {
      context.go('/home');
    }
  }

  void _verDetalhe(AcaoController controller) {
    final acao = controller.acaoAtual;

    if (acao == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetalheAcaoPage(
          acao: acao,
        ),
      ),
    );
  }

  String _nomeDominio(
    DomainProvider provider,
    String grupo,
    String id,
  ) {
    if (id.trim().isEmpty) {
      return 'Não informado';
    }
    return provider.opcoesDoGrupo(grupo)[id] ?? id;
  }

  String _nomesDominios(
    DomainProvider provider,
    String grupo,
    List<String> ids,
  ) {
    if (ids.isEmpty) {
      return 'Não informado';
    }
    return ids.map((id) => _nomeDominio(provider, grupo, id)).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AcaoController>();
    final acao = controller.acaoAtual;

    if (controller.gerandoNumeroRae) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (acao == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Revisão da Ação'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.assignment_late_outlined,
                  size: 56,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma ação disponível para revisão.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('VOLTAR AO INÍCIO'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final review = faxitaReviewService.revisar(acao);
    final domainProvider = context.watch<DomainProvider>();
    final alertasPriorizados =
        faxitaInsightsService.priorizarAlertas(review.alertas);

    final planejamentoOk = acao.turno.isNotEmpty &&
        acao.nomeAcao.isNotEmpty &&
        acao.publicoEstimado > 0 &&
        acao.publicoMinimo > 0;

    final localizacaoOk = acao.endereco.isNotEmpty &&
        acao.bairro.isNotEmpty &&
        acao.regional.isNotEmpty &&
        acao.equipamentoReferencia.isNotEmpty;

    final caracterizacaoOk = acao.formacaoId.isNotEmpty &&
        acao.publicoId.isNotEmpty &&
        acao.focoTematicoIds.isNotEmpty &&
        acao.fatorRiscoIds.isNotEmpty;

    final recursosOk = (acao.agentesTransito + acao.equipeTerceirizada) > 0 &&
        acao.materialUtilizadoIds.isNotEmpty;

    final resultadosOk = acao.pessoasAlcancadas > 0;

    final evidenciasOk = acao.fotosUrls.isNotEmpty &&
        acao.descricaoEvidencias.trim().length >= 10;

    final avaliacaoOk = acao.notaAvaliacao > 0;

    return FenixPageScaffold(
      appBar: const FenixAppBar(
        title: 'Revisão da Ação',
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const FenixJourneyHeader(
            step: 9,
            totalSteps: 9,
            title: 'Revisão do relatório',
            subtitle: 'Confira os dados consolidados antes de concluir o RAE.',
            icon: Icons.fact_check_outlined,
          ),
          const SizedBox(height: 16),
          ReviewHeader(acao: acao),
          const SizedBox(height: 16),
          ReviewDashboard(acao: acao),
          const SizedBox(height: 16),
          ReviewHistoricalComparisonCard(
            acaoAtual: acao,
            historico: controller.historicoComparacao,
            carregando: controller.carregandoHistoricoComparacao,
            erro: controller.erroHistoricoComparacao,
            onTentarNovamente: controller.carregarHistoricoComparacao,
          ),
          const SizedBox(height: 16),
          ReviewQualityCard(
            review: review,
            insightsService: faxitaInsightsService,
          ),
          const SizedBox(height: 16),
          ReviewTimeline(
            planejamento: planejamentoOk,
            localizacao: localizacaoOk,
            caracterizacao: caracterizacaoOk,
            recursos: recursosOk,
            resultados: resultadosOk,
            evidencias: evidenciasOk,
            avaliacao: avaliacaoOk,
          ),
          const SizedBox(height: 16),
          ReviewAlertsCard(
            alertas: alertasPriorizados,
            mensagemVazia:
                'Nenhum alerta prioritário identificado pela Faxita.',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final horizontal = constraints.maxWidth >= 760;

              final pontosFortes = ReviewPointsCard(
                itens: review.pontosFortes,
                tipo: ReviewPointsType.pontosFortes,
              );

              final recomendacoes = ReviewPointsCard(
                itens: review.recomendacoes,
                tipo: ReviewPointsType.recomendacoes,
              );

              if (!horizontal) {
                return Column(
                  children: [
                    pontosFortes,
                    const SizedBox(height: 16),
                    recomendacoes,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: pontosFortes),
                  const SizedBox(width: 16),
                  Expanded(child: recomendacoes),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          ReviewSectionCard(
            titulo: 'Dados da ação',
            subtitulo: 'Planejamento e coordenação',
            icone: Icons.assignment_rounded,
            expandidoInicialmente: true,
            conteudo: '''
Turno: ${acao.turno}

Tipo: ${acao.tipoAcao}

Coordenador:
${acao.coordenadorNome}
''',
          ),
          const SizedBox(height: 10),
          ReviewSectionCard(
            titulo: 'Localização',
            subtitulo: 'Referência territorial da atividade',
            icone: Icons.location_on_rounded,
            conteudo: '''
Regional: ${acao.regional}

Bairro: ${acao.bairro}

Endereço:
${acao.endereco}

Equipamento:
${acao.equipamentoReferencia}
''',
          ),
          const SizedBox(height: 10),
          ReviewSectionCard(
            titulo: 'Caracterização da ação',
            subtitulo: 'Público, formação e temas trabalhados',
            icone: Icons.category_rounded,
            conteudo: '''
Formação: ${_nomeDominio(domainProvider, 'formacao', acao.formacaoId)}

Público-alvo: ${_nomeDominio(domainProvider, 'publico', acao.publicoId)}

Tipo de participação: ${_nomesDominios(domainProvider, 'tipo_participacao', acao.tipoParticipacaoIds)}

Perfis atendidos: ${_nomesDominios(domainProvider, 'perfil_usuario', acao.perfilUsuarioIds)}

Sexo predominante: ${_nomeDominio(domainProvider, 'sexo_predominante', acao.sexoPredominanteId)}

Focos temáticos: ${_nomesDominios(domainProvider, 'foco_tematico', acao.focoTematicoIds)}

Fatores de risco: ${_nomesDominios(domainProvider, 'fator_risco', acao.fatorRiscoIds)}
''',
          ),
          const SizedBox(height: 10),
          ReviewSectionCard(
            titulo: 'Recursos e integração',
            subtitulo: 'Equipe, materiais e participação institucional',
            icone: Icons.handshake_rounded,
            conteudo: '''
Agentes de trânsito: ${acao.agentesTransito}

Equipe terceirizada: ${acao.equipeTerceirizada}

Materiais: ${_nomesDominios(domainProvider, 'material', acao.materialUtilizadoIds)}

Cobertura de mídia: ${acao.coberturaMidia ? 'Sim' : 'Não'}

Outro órgão participante: ${acao.houveParticipacaoOutroOrgao ? _nomeDominio(domainProvider, 'orgao', acao.orgaoParticipanteId) : 'Não'}
''',
          ),
          const SizedBox(height: 10),
          ReviewSectionCard(
            titulo: 'Resultados',
            subtitulo: 'Indicadores consolidados da execução',
            icone: Icons.groups_rounded,
            conteudo: '''
Pessoas alcançadas:
${acao.pessoasAlcancadas}

Veículos abordados:
${acao.veiculosAbordados}

Credenciais:
${acao.credenciaisEmitidas}
''',
          ),
          const SizedBox(height: 10),
          ReviewSectionCard(
            titulo: 'Avaliação e aprendizagem operacional',
            subtitulo: 'Lições registradas pela equipe',
            icone: Icons.insights_rounded,
            conteudo: '''
Avaliação: ${acao.notaAvaliacao > 0 ? '${acao.notaAvaliacao}/5' : 'Não avaliada'}

Pontos positivos:
${acao.pontosPositivos.isEmpty ? 'Não informado' : acao.pontosPositivos}

Dificuldades encontradas:
${acao.dificuldadesEncontradas.isEmpty ? 'Não informado' : acao.dificuldadesEncontradas}

Recomendações da equipe:
${acao.recomendacoes.isEmpty ? 'Não informado' : acao.recomendacoes}
''',
          ),
          const SizedBox(height: 10),
          ReviewSectionCard(
            titulo: 'Evidências',
            subtitulo: 'Registros documentais da ação',
            icone: Icons.camera_alt_rounded,
            conteudo: '''
Descrição:
${acao.descricaoEvidencias}

Fotos:
${acao.fotosUrls.length}
''',
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: RaeQrCodeWidget(
                  acaoId: acao.id,
                  numeroRAE: acao.numeroRAE,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ReviewActions(
            onVerDetalhe: () => _verDetalhe(controller),
            onGerarPdf: () => _gerarPdf(controller),
            onEnviarRelatorio: () => _enviarRelatorio(controller),
            podeVerDetalhe: true,
            podeGerarPdf: true,
            podeEnviar: true,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
