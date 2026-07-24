import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/services/firebase_acao_service.dart';
import '../../core/services/usuario_service.dart';
import '../../data/models/acao_model.dart';
import '../../data/models/usuario_model.dart';
import '../acoes/controllers/acao_controller.dart';
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
  final FirebaseAcaoService acaoService = FirebaseAcaoService();

  UsuarioModel? usuario;
  bool carregando = true;

  int totalAcoes = 0;
  int totalPessoas = 0;
  int totalVeiculos = 0;
  int totalCredenciais = 0;

  List<AcaoModel> ultimosRaes = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      carregarPortal();
    });
  }

  Future<void> carregarPortal() async {
    final acaoController = context.read<AcaoController>();

    await acaoController.carregarRascunhoSeExistir();

    final uid = FirebaseAuth.instance.currentUser?.uid;

    UsuarioModel? usuarioCarregado;

    if (uid != null) {
      usuarioCarregado = await UsuarioService().buscarUsuario(uid);
    }

    final acoes = await acaoService.totalAcoes();
    final pessoas = await acaoService.totalPessoasAlcancadas();
    final veiculos = await acaoService.totalVeiculosAbordados();
    final credenciais = await acaoService.totalCredenciaisEmitidas();

    final lista = await acaoService.listarAcoesFuture();

    lista.sort((a, b) => b.dataAcao.compareTo(a.dataAcao));

    if (!mounted) return;

    setState(() {
      usuario = usuarioCarregado;
      totalAcoes = acoes;
      totalPessoas = pessoas;
      totalVeiculos = veiculos;
      totalCredenciais = credenciais;
      ultimosRaes = lista.take(3).toList();
      carregando = false;
    });
  }

  Future<void> sair() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> atualizarPortal() async {
    setState(() {
      carregando = true;
    });

    await carregarPortal();
  }

  Future<void> abrirOrientacoesFaixita() async {
    final possuiRascunho =
        context.read<AcaoController>().possuiRascunhoEmAndamento;

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
              color: Color(0xFF007A78),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            possuiRascunho
                ? 'Existe um rascunho salvo neste dispositivo. Recomendo continuar essa ação antes de iniciar um novo registro.'
                : 'Nenhum rascunho está pendente. Você pode iniciar uma nova ação, consultar os registros ou acompanhar os indicadores operacionais.',
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
            ),
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

    if (carregando) {
      return const Scaffold(
        backgroundColor: Color(0xFFF3F7F7),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F7),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: atualizarPortal,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CentroOperacoesHeader(
                usuario: usuario,
                onAtualizar: atualizarPortal,
                onSair: sair,
              ),
              const SizedBox(height: 16),
              if (acaoController.possuiRascunhoEmAndamento) ...[
                _RascunhoCard(
                  titulo: acaoController.resumoRascunho,
                  onContinuar: () {
                    context.go(acaoController.rotaContinuacaoRascunho);
                  },
                  onDescartar: () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text('Descartar rascunho?'),
                          content: const Text(
                            'Essa ação removerá o rascunho salvo neste dispositivo.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              child: const Text('Descartar'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmar != true) return;

                    await acaoController.descartarRascunho();

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rascunho descartado.'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
              IndicadoresWidget(
                totalAcoes: totalAcoes,
                totalPessoas: totalPessoas,
                totalVeiculos: totalVeiculos,
                totalCredenciais: totalCredenciais,
              ),
              const SizedBox(height: 16),
              AtalhosWidget(
                usuario: usuario,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 950;

                  if (!isWide) {
                    return Column(
                      children: [
                        UltimosRaesWidget(
                          acoes: ultimosRaes,
                        ),
                        const SizedBox(height: 16),
                        FaixitaOperacionalCard(
                          possuiRascunho:
                              acaoController.possuiRascunhoEmAndamento,
                          totalAcoes: totalAcoes,
                          totalPessoas: totalPessoas,
                          onOrientacoes: abrirOrientacoesFaixita,
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: UltimosRaesWidget(
                          acoes: ultimosRaes,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: FaixitaOperacionalCard(
                          possuiRascunho:
                              acaoController.possuiRascunhoEmAndamento,
                          totalAcoes: totalAcoes,
                          totalPessoas: totalPessoas,
                          onOrientacoes: abrirOrientacoesFaixita,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              const StatusWidget(),
            ],
          ),
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

  static const Color verdeInstitucional = Color(0xFF007A78);
  static const Color laranjaInstitucional = Color(0xFFF37021);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: const Color(0xFFFFF5E8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: laranjaInstitucional.withValues(alpha: 0.35),
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
                    Icon(
                      Icons.edit_note,
                      color: laranjaInstitucional,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rascunho em andamento',
                        style: TextStyle(
                          color: verdeInstitucional,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  titulo,
                  style: const TextStyle(height: 1.35),
                ),
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
                children: [
                  conteudo,
                  const SizedBox(height: 14),
                  acoes,
                ],
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
