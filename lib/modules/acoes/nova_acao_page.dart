import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/tipo_acao_model.dart';
import '../acoes/controllers/acao_controller.dart';

class NovaAcaoPage extends StatefulWidget {
  const NovaAcaoPage({super.key});

  @override
  State<NovaAcaoPage> createState() => _NovaAcaoPageState();
}

class _NovaAcaoPageState extends State<NovaAcaoPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? turno;
  TipoAcaoModel? tipoSelecionado;

  String? coordenadorId;
  String? coordenadorNome;

  List<TipoAcaoModel> tiposAcoes = [];
  List<Map<String, dynamic>> coordenadores = [];

  bool carregando = true;

  final dataHoje = DateFormat('dd/MM/yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    try {
      final tiposSnapshot = await firestore
          .collection('tipos_acoes')
          .orderBy('nomeAcao')
          .get();

      final coordenadoresSnapshot = await firestore
          .collection('coordenadores')
          .orderBy('nome')
          .get();

      if (!mounted) return;

      setState(() {
        tiposAcoes = tiposSnapshot.docs
            .map((doc) => TipoAcaoModel.fromMap(doc.data()))
            .where((tipo) => tipo.ativo)
            .toList();

        coordenadores = coordenadoresSnapshot.docs
            .map((doc) => doc.data())
            .where((coord) => coord['ativo'] == true)
            .toList();

        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar dados: $e'),
        ),
      );
    }
  }

  void avancar() {
    if (turno == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o turno da ação.')),
      );
      return;
    }

    if (tipoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome da ação.')),
      );
      return;
    }

    if (coordenadorId == null || coordenadorNome == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o coordenador responsável.')),
      );
      return;
    }

    context.read<AcaoController>().preencherDadosAcao(
          turno: turno!,
          nomeAcao: tipoSelecionado!.nomeAcao,
          tipoAcao: tipoSelecionado!.tipoAcao,
          publicoEstimado: tipoSelecionado!.publicoEstimadoPadrao,
          publicoMinimo: tipoSelecionado!.publicoMinimoPadrao,
          coordenadorId: coordenadorId,
          coordenadorNome: coordenadorNome,
        );

    context.go('/localizacao');
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Ação'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                carregando = true;
              });
              carregarDados();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            initialValue: dataHoje,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Data',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: turno,
            decoration: const InputDecoration(
              labelText: 'Turno',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Manhã', child: Text('Manhã')),
              DropdownMenuItem(value: 'Tarde', child: Text('Tarde')),
              DropdownMenuItem(value: 'Noite', child: Text('Noite')),
            ],
            onChanged: (valor) {
              setState(() {
                turno = valor;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<TipoAcaoModel>(
            initialValue: tipoSelecionado,
            decoration: const InputDecoration(
              labelText: 'Nome da ação',
              border: OutlineInputBorder(),
            ),
            items: tiposAcoes.map((tipo) {
              return DropdownMenuItem(
                value: tipo,
                child: Text(tipo.nomeAcao),
              );
            }).toList(),
            onChanged: (valor) {
              setState(() {
                tipoSelecionado = valor;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: coordenadorId,
            decoration: const InputDecoration(
              labelText: 'Coordenador responsável',
              border: OutlineInputBorder(),
            ),
            items: coordenadores.map((coord) {
              return DropdownMenuItem<String>(
                value: coord['id'],
                child: Text(coord['nome'] ?? ''),
              );
            }).toList(),
            onChanged: (valor) {
              final selecionado = coordenadores.firstWhere(
                (coord) => coord['id'] == valor,
              );

              setState(() {
                coordenadorId = valor;
                coordenadorNome = selecionado['nome'];
              });
            },
          ),
          const SizedBox(height: 20),
          if (tipoSelecionado != null)
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Nome: ${tipoSelecionado!.nomeAcao}'),
                    Text('Tipo: ${tipoSelecionado!.tipoAcao}'),
                    Text(
                      'Público estimado: '
                      '${tipoSelecionado!.publicoEstimadoPadrao}',
                    ),
                    Text(
                      'Público mínimo: '
                      '${tipoSelecionado!.publicoMinimoPadrao}',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Materiais sugeridos:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...tipoSelecionado!.materiaisSugeridos.map(
                      (material) => Text('• $material'),
                    ),
                  ],
                ),
              ),
            ),
          if (coordenadorNome != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Coordenador'),
                subtitle: Text(coordenadorNome!),
              ),
            ),
          const SizedBox(height: 30),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text('PRÓXIMO'),
              onPressed: avancar,
            ),
          ),
        ],
      ),
    );
  }
}