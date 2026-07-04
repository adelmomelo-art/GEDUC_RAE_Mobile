import 'package:flutter/material.dart';

import '../../core/services/firebase_acao_service.dart';
import '../../data/models/acao_model.dart';
import 'detalhe_acao_page.dart';

class ConsultaRaePage extends StatefulWidget {
  const ConsultaRaePage({super.key});

  @override
  State<ConsultaRaePage> createState() => _ConsultaRaePageState();
}

class _ConsultaRaePageState extends State<ConsultaRaePage> {
  final FirebaseAcaoService service = FirebaseAcaoService();
  final TextEditingController pesquisaController = TextEditingController();

  String filtro = '';

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  List<AcaoModel> filtrarAcoes(List<AcaoModel> acoes) {
    if (filtro.trim().isEmpty) return acoes;

    final termo = filtro.toLowerCase();

    return acoes.where((acao) {
      return acao.numeroRAE.toLowerCase().contains(termo) ||
          acao.nomeAcao.toLowerCase().contains(termo) ||
          acao.tipoAcao.toLowerCase().contains(termo) ||
          acao.coordenadorNome.toLowerCase().contains(termo) ||
          acao.regional.toLowerCase().contains(termo) ||
          acao.bairro.toLowerCase().contains(termo);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de RAE'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: pesquisaController,
              decoration: InputDecoration(
                labelText: 'Pesquisar RAE',
                hintText: 'Número, ação, regional, bairro...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: filtro.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          pesquisaController.clear();
                          setState(() {
                            filtro = '';
                          });
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (valor) {
                setState(() {
                  filtro = valor;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AcaoModel>>(
              stream: service.listarAcoes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar RAEs: ${snapshot.error}',
                    ),
                  );
                }

                final acoes = filtrarAcoes(snapshot.data ?? []);

                if (acoes.isEmpty) {
                  return const Center(
                    child: Text('Nenhum RAE encontrado.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: acoes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final acao = acoes[index];

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.assignment),
                        title: Text(
                          acao.nomeAcao,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'RAE Nº ${acao.numeroRAE}\n'
                          '${acao.regional} - ${acao.bairro}\n'
                          'Coordenador: ${acao.coordenadorNome}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DetalheAcaoPage(
                                acao: acao,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}