import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/services/firebase_acao_service.dart';
import '../../core/services/usuario_service.dart';
import '../../data/models/acao_model.dart';
import '../../data/models/usuario_model.dart';
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