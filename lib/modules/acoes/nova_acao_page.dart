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
  final TextEditingController _nomeAcaoController = TextEditingController();

  DateTime dataSelecionada = DateTime.now();
  String? turno;
  TipoAcaoModel? tipoSelecionado;

  String? coordenadorId;
  String? coordenadorNome;

  bool acaoPlanejada = true;

  List<TipoAcaoModel> tiposAcoes = [];
  List<Map<String, dynamic>> coordenadores = [];

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  @override
  void dispose() {
    _nomeAcaoController.dispose();
    super.dispose();
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

  Future<void> selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Selecione a data da ação',
      cancelText: 'CANCELAR',
      confirmText: 'CONFIRMAR',
    );

    if (data == null || !mounted) return;

    setState(() {
      dataSelecionada = data;
    });
  }

  Future<void> pesquisarTipoAcao() async {
    final selecionado = await showModalBottomSheet<TipoAcaoModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return _PesquisaTipoAcaoSheet(
          tiposAcoes: tiposAcoes,
        );
      },
    );

    if (selecionado == null || !mounted) return;

    setState(() {
      tipoSelecionado = selecionado;
      _nomeAcaoController.text = selecionado.nomeAcao;
    });
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
          dataAcao: dataSelecionada,
          turno: turno!,
          nomeAcao: tipoSelecionado!.nomeAcao,
          tipoAcao: tipoSelecionado!.tipoAcao,
          publicoEstimado: tipoSelecionado!.publicoEstimadoPadrao,
          publicoMinimo: tipoSelecionado!.publicoMinimoPadrao,
          acaoPlanejada: acaoPlanejada,
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

    final dataFormatada = DateFormat('dd/MM/yyyy').format(dataSelecionada);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Ação'),
        actions: [
          IconButton(
            tooltip: 'Atualizar cadastros',
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
          InkWell(
            onTap: selecionarData,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Data da ação',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_month),
              ),
              child: Text(dataFormatada),
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
              DropdownMenuItem(value: 'Madrugada', child: Text('Madrugada')),
            ],
            onChanged: (valor) {
              setState(() {
                turno = valor;
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nomeAcaoController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Nome da ação',
              hintText: 'Toque para pesquisar',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.search),
            ),
            onTap: pesquisarTipoAcao,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: acaoPlanejada,
            title: const Text('A ação foi previamente planejada?'),
            subtitle: Text(acaoPlanejada ? 'Sim' : 'Não'),
            onChanged: (valor) {
              setState(() {
                acaoPlanejada = valor;
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
                    Text('Data: $dataFormatada'),
                    Text('Turno: ${turno ?? 'Não informado'}'),
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
                    Text(
                      'Ação planejada: ${acaoPlanejada ? 'Sim' : 'Não'}',
                    ),
                    Text(
                      'Coordenador: '
                      '${coordenadorNome ?? 'Não informado'}',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Materiais sugeridos:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (tipoSelecionado!.materiaisSugeridos.isEmpty)
                      const Text('Nenhum material sugerido.')
                    else
                      ...tipoSelecionado!.materiaisSugeridos.map(
                        (material) => Text('• $material'),
                      ),
                  ],
                ),
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

class _PesquisaTipoAcaoSheet extends StatefulWidget {
  const _PesquisaTipoAcaoSheet({
    required this.tiposAcoes,
  });

  final List<TipoAcaoModel> tiposAcoes;

  @override
  State<_PesquisaTipoAcaoSheet> createState() =>
      _PesquisaTipoAcaoSheetState();
}

class _PesquisaTipoAcaoSheetState extends State<_PesquisaTipoAcaoSheet> {
  final TextEditingController _pesquisaController = TextEditingController();

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final termo = _pesquisaController.text.trim().toLowerCase();

    final resultados = widget.tiposAcoes.where((tipo) {
      return termo.isEmpty ||
          tipo.nomeAcao.toLowerCase().contains(termo) ||
          tipo.tipoAcao.toLowerCase().contains(termo);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        top: 16,
        right: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: [
            TextField(
              controller: _pesquisaController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Pesquisar ação',
                hintText: 'Digite o nome ou o tipo da ação',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: resultados.isEmpty
                  ? const Center(
                      child: Text('Nenhuma ação encontrada.'),
                    )
                  : ListView.separated(
                      itemCount: resultados.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final tipo = resultados[index];

                        return ListTile(
                          title: Text(tipo.nomeAcao),
                          subtitle: Text(tipo.tipoAcao),
                          onTap: () {
                            Navigator.of(context).pop(tipo);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
