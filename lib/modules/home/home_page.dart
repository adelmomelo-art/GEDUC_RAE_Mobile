import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../core/services/firebase_acao_service.dart';
import '../../core/services/usuario_service.dart';
import '../../data/models/acao_model.dart';
import '../../data/models/usuario_model.dart';
import '../acoes/controllers/acao_controller.dart';
import 'widgets/atalhos_widget.dart';
import 'widgets/home_header.dart';
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
    carregarPortal();
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

    if (!mounted) return;

    context.go('/login');
  }

  Future<void> atualizarPortal() async {
    setState(() {
      carregando = true;
    });

    await carregarPortal();
  }

  @override
  Widget build(BuildContext context) {
    final acaoController = context.watch<AcaoController>();

    if (carregando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal Executivo GEDUC'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: atualizarPortal,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: sair,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          HomeHeader(
            usuario: usuario,
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
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Descartar rascunho?'),
                      content: const Text(
                        'Essa ação removerá o rascunho salvo neste dispositivo.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
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
          UltimosRaesWidget(
            acoes: ultimosRaes,
          ),
          const SizedBox(height: 16),
          const StatusWidget(),
        ],
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
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.edit_note,
                  color: Colors.orange,
                ),
                SizedBox(width: 8),
                Text(
                  'Rascunho em andamento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(titulo),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onContinuar,
              icon: const Icon(Icons.play_arrow),
              label: const Text('CONTINUAR RASCUNHO'),
            ),
            TextButton.icon(
              onPressed: onDescartar,
              icon: const Icon(Icons.delete_outline),
              label: const Text('DESCARTAR RASCUNHO'),
            ),
          ],
        ),
      ),
    );
  }
}