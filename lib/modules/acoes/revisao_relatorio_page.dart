import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/services/faxita_insights_service.dart';
import '../../core/services/faxita_review_service.dart';
import '../../core/services/pdf_relatorio_service.dart';
import '../../core/widgets/rae_qrcode_widget.dart';
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
  State<RevisaoRelatorioPage> createState() =>
      _RevisaoRelatorioPageState();
}

class _RevisaoRelatorioPageState extends State<RevisaoRelatorioPage> {
  final FaxitaReviewService faxitaReviewService = FaxitaReviewService();
  final FaxitaInsightsService faxitaInsightsService =
      FaxitaInsightsService();

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

    await PdfRelatorioService().gerarRelatorioAcao(acao);
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

    final recursosOk =
        (acao.agentesTransito + acao.equipeTerceirizada) > 0 &&
            acao.materialUtilizadoIds.isNotEmpty;

    final resultadosOk = acao.pessoasAlcancadas > 0;

    final evidenciasOk = acao.fotosUrls.isNotEmpty &&
        acao.descricaoEvidencias.trim().length >= 10;

    final avaliacaoOk = acao.notaAvaliacao > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisão da Ação'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ReviewHeader(acao: acao),
            const SizedBox(height: 16),
            ReviewDashboard(acao: acao),
            const SizedBox(height: 16),
            ReviewHistoricalComparisonCard(
              acaoAtual: acao,
              historico: controller.historicoComparacao,
              carregando: controller.carregandoHistoricoComparacao,
              erro: controller.erroHistoricoComparacao,
              onTentarNovamente:
                  controller.carregarHistoricoComparacao,
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
      ),
    );
  }
}
