import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/services/faxita_review_service.dart';
import '../../core/services/pdf_relatorio_service.dart';
import '../../core/widgets/rae_qrcode_widget.dart';
import '../../core/widgets/status_acao_chip.dart';
import 'controllers/acao_controller.dart';
import 'detalhe_acao_page.dart';

class RevisaoRelatorioPage extends StatefulWidget {
  const RevisaoRelatorioPage({super.key});

  @override
  State<RevisaoRelatorioPage> createState() => _RevisaoRelatorioPageState();
}

class _RevisaoRelatorioPageState extends State<RevisaoRelatorioPage> {
  final faxitaReviewService = FaxitaReviewService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<AcaoController>();
      controller.garantirNumeroRae();
    });
  }

  Widget _secao(
    String titulo,
    IconData icone,
    String conteudo,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icone),
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(conteudo),
      ),
    );
  }

  Widget _cardFaxita(FaxitaReviewResult review) {
    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Revisão Inteligente da Faxita',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${review.indiceQualidade}/100',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: review.indiceQualidade / 100,
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            Text(
              'Classificação: ${review.classificacao}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(review.parecer),
          ],
        ),
      ),
    );
  }

  Widget _listaRevisao({
    required String titulo,
    required IconData icone,
    required List<String> itens,
    required Color cor,
    required String vazio,
  }) {
    if (itens.isEmpty) {
      return Card(
        child: ListTile(
          leading: Icon(icone, color: cor),
          title: Text(titulo),
          subtitle: Text(vazio),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icone, color: cor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...itens.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(Icons.circle, size: 8, color: cor),
                title: Text(item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _acoesFinais({
    required BuildContext context,
    required AcaoController controller,
  }) {
    final acao = controller.acaoAtual;

    return Column(
      children: [
        SizedBox(
          height: 55,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.visibility),
            label: const Text('VER DETALHE DO RAE'),
            onPressed: acao == null
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetalheAcaoPage(
                          acao: acao,
                        ),
                      ),
                    );
                  },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 55,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('GERAR PDF'),
            onPressed: acao == null
                ? null
                : () async {
                    await PdfRelatorioService().gerarRelatorioAcao(
                      acao,
                    );
                  },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 55,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.cloud_upload),
            label: const Text('ENVIAR RELATÓRIO'),
            onPressed: () async {
              final ok = await controller.enviarRelatorio();

              if (!context.mounted) {
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
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AcaoController>();
    final acao = controller.acaoAtual;
    final review = acao == null ? null : faxitaReviewService.revisar(acao);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisão da Ação'),
      ),
      body: controller.gerandoNumeroRae
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resumo da ação',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(acao?.nomeAcao ?? 'Ação'),
                        Text(acao?.tipoAcao ?? ''),
                        if ((acao?.numeroRAE ?? '').isNotEmpty)
                          Text(
                            'RAE Nº ${acao!.numeroRAE}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (acao != null) ...[
                          const SizedBox(height: 12),
                          StatusAcaoChip(
                            status: acao.status,
                            sincronizado: acao.sincronizado,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (review != null) ...[
                  _cardFaxita(review),
                  _listaRevisao(
                    titulo: 'Pontos fortes',
                    icone: Icons.check_circle,
                    itens: review.pontosFortes,
                    cor: Colors.green,
                    vazio: 'Nenhum ponto forte identificado.',
                  ),
                  _listaRevisao(
                    titulo: 'Alertas',
                    icone: Icons.warning,
                    itens: review.alertas,
                    cor: Colors.orange,
                    vazio: 'Nenhum alerta identificado.',
                  ),
                  _listaRevisao(
                    titulo: 'Recomendações',
                    icone: Icons.lightbulb,
                    itens: review.recomendacoes,
                    cor: Colors.purple,
                    vazio: 'Nenhuma recomendação adicional.',
                  ),
                  const SizedBox(height: 12),
                ],
                _secao(
                  'Dados da ação',
                  Icons.assignment,
                  '''
Turno: ${acao?.turno ?? ''}

Tipo: ${acao?.tipoAcao ?? ''}

Coordenador:
${acao?.coordenadorNome ?? ''}
''',
                ),
                _secao(
                  'Localização',
                  Icons.location_on,
                  '''
Regional: ${acao?.regional ?? ''}

Bairro: ${acao?.bairro ?? ''}

Endereço:
${acao?.endereco ?? ''}

Equipamento:
${acao?.equipamentoReferencia ?? ''}
''',
                ),
                _secao(
                  'Resultados',
                  Icons.groups,
                  '''
Pessoas alcançadas:
${acao?.pessoasAlcancadas ?? 0}

Veículos abordados:
${acao?.veiculosAbordados ?? 0}

Credenciais:
${acao?.credenciaisEmitidas ?? 0}
''',
                ),
                _secao(
                  'Evidências',
                  Icons.camera_alt,
                  '''
Descrição:
${acao?.descricaoEvidencias ?? ''}

Fotos:
${acao?.fotosUrls.length ?? 0}
''',
                ),
                if (acao != null) ...[
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: RaeQrCodeWidget(
                          acaoId: acao.id,
                          numeroRAE: acao.numeroRAE,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _acoesFinais(
                  context: context,
                  controller: controller,
                ),
              ],
            ),
    );
  }
}
