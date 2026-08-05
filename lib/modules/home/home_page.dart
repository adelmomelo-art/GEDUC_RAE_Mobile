import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/security/authorization_service.dart';
import '../../data/models/acao_model.dart';
import '../acoes/controllers/acao_controller.dart';
import '../acoes/detalhe_acao_page.dart';
import 'controllers/home_controller.dart';
import 'models/home_state.dart';
import 'theme/home_visual_tokens.dart';
import 'widgets/atalhos_widget.dart';
import 'widgets/centro_operacoes_header.dart';
import 'widgets/faixita_operacional_card.dart';
import 'widgets/indicadores_widget.dart';
import 'widgets/status_widget.dart';
import 'widgets/ultimos_raes_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController homeController;

  @override
  void initState() {
    super.initState();
    homeController = HomeController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      homeController.carregarPortal(
        acaoController: context.read<AcaoController>(),
      );
    });
  }

  @override
  void dispose() {
    homeController.dispose();
    super.dispose();
  }

  Future<void> sair() async {
    await AuthorizationService.instance.encerrarSessao();
  }

  Future<void> atualizarPortal() {
    return homeController.atualizar(
      acaoController: context.read<AcaoController>(),
    );
  }

  void abrirRae(AcaoModel acao) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DetalheAcaoPage(acao: acao)),
    );
  }

  Future<void> abrirOrientacoesFaixita() async {
    final possuiRascunho = context
        .read<AcaoController>()
        .possuiRascunhoEmAndamento;
    final offline = homeController.state.estaOffline;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Orientações da Faixita',
            style: TextStyle(
              color: HomeVisualTokens.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            offline
                ? 'Você está trabalhando em modo offline. O rascunho permanece salvo neste dispositivo e poderá ser sincronizado quando a conexão for restabelecida.'
                : possuiRascunho
                ? 'Existe um rascunho salvo neste dispositivo. Recomendo continuar essa ação antes de iniciar um novo registro.'
                : 'Nenhum rascunho está pendente. Você pode iniciar uma nova ação, consultar os registros ou acompanhar os indicadores operacionais.',
            style: const TextStyle(fontSize: 15, height: 1.45),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('ENTENDI'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final acaoController = context.watch<AcaoController>();
    final authorizationService = context.watch<AuthorizationService>();

    return AnimatedBuilder(
      animation: homeController,
      builder: (context, _) {
        final state = homeController.state;

        if (state.carregando || state.status == HomeStatus.inicial) {
          return const Scaffold(
            backgroundColor: HomeVisualTokens.canvas,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: HomeVisualTokens.canvas,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: atualizarPortal,
              child: ListView(
                padding: const EdgeInsets.all(HomeVisualTokens.space16),
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: HomeVisualTokens.contentMaxWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CentroOperacoesHeader(
                            usuario: authorizationService.usuarioAtual,
                            onAtualizar: atualizarPortal,
                            onSair: sair,
                          ),
                          if (state.estaOffline || state.possuiErro) ...[
                            const SizedBox(height: HomeVisualTokens.space12),
                            _ModoOperacionalBanner(
                              offline: state.estaOffline,
                              mensagem: state.mensagem,
                              onAtualizar: atualizarPortal,
                            ),
                          ],
                          if (acaoController.possuiRascunhoEmAndamento) ...[
                            const SizedBox(height: HomeVisualTokens.space12),
                            _RascunhoCard(
                              titulo: acaoController.resumoRascunho,
                              onContinuar: () {
                                context.go(
                                  acaoController.rotaContinuacaoRascunho,
                                );
                              },
                              onDescartar: () =>
                                  _descartarRascunho(acaoController),
                            ),
                          ],
                          const SizedBox(height: HomeVisualTokens.space16),
                          const AtalhosWidget(),
                          const SizedBox(height: HomeVisualTokens.space16),
                          FaixitaOperacionalCard(
                            possuiRascunho:
                                acaoController.possuiRascunhoEmAndamento,
                            totalAcoes: state.totalAcoes,
                            totalPessoas: state.totalPessoas,
                            onOrientacoes: abrirOrientacoesFaixita,
                          ),
                          const SizedBox(height: HomeVisualTokens.space16),
                          IndicadoresWidget(
                            totalAcoes: state.totalAcoes,
                            totalPessoas: state.totalPessoas,
                            totalVeiculos: state.totalVeiculos,
                            totalCredenciais: state.totalCredenciais,
                          ),
                          const SizedBox(height: HomeVisualTokens.space16),
                          UltimosRaesWidget(
                            acoes: state.ultimosRaes,
                            onAbrirRae: abrirRae,
                          ),
                          const SizedBox(height: HomeVisualTokens.space16),
                          StatusWidget(homeState: state),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _descartarRascunho(AcaoController acaoController) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Descartar rascunho?'),
        content: const Text(
          'Essa ação removerá o rascunho salvo neste dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    await acaoController.descartarRascunho();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Rascunho descartado.')));
  }
}

class _ModoOperacionalBanner extends StatelessWidget {
  const _ModoOperacionalBanner({
    required this.offline,
    required this.mensagem,
    required this.onAtualizar,
  });

  final bool offline;
  final String? mensagem;
  final Future<void> Function() onAtualizar;

  @override
  Widget build(BuildContext context) {
    final cor = offline ? HomeVisualTokens.orange : Colors.red.shade700;

    return Material(
      color: cor.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              offline ? Icons.cloud_off_outlined : Icons.warning_amber_rounded,
              color: cor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                mensagem ??
                    'Os dados online não estão disponíveis neste momento.',
                style: const TextStyle(height: 1.35),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Tentar novamente',
              onPressed: onAtualizar,
              icon: const Icon(Icons.refresh),
              color: cor,
            ),
          ],
        ),
      ),
    );
  }
}

class _RascunhoCard extends StatelessWidget {
  const _RascunhoCard({
    required this.titulo,
    required this.onContinuar,
    required this.onDescartar,
  });

  final String titulo;
  final VoidCallback onContinuar;
  final Future<void> Function() onDescartar;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: HomeVisualTokens.orangeLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: HomeVisualTokens.orange.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compacto = constraints.maxWidth < 620;

            final conteudo = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.edit_note, color: HomeVisualTokens.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rascunho em andamento',
                        style: TextStyle(
                          color: HomeVisualTokens.teal,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(titulo, style: const TextStyle(height: 1.35)),
              ],
            );

            final acoes = Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onContinuar,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('CONTINUAR'),
                ),
                TextButton.icon(
                  onPressed: onDescartar,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('DESCARTAR'),
                ),
              ],
            );

            if (compacto) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [conteudo, const SizedBox(height: 14), acoes],
              );
            }

            return Row(
              children: [
                Expanded(child: conteudo),
                const SizedBox(width: 18),
                acoes,
              ],
            );
          },
        ),
      ),
    );
  }
}
