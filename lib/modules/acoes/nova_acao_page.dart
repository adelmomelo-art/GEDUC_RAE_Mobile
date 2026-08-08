import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/tipo_acao_model.dart';
import '../../shared/widgets/journey/fenix_journey_header.dart';
import '../../shared/widgets/layout/fenix_app_bar.dart';
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
  bool carregando = true;

  List<TipoAcaoModel> tiposAcoes = [];
  List<Map<String, dynamic>> coordenadores = [];

  bool get dadosCompletos =>
      turno != null &&
      tipoSelecionado != null &&
      coordenadorId != null &&
      coordenadorNome != null;

  String get mensagemFaxita {
    if (turno == null) {
      return 'Vamos registrar os dados iniciais da ação. Informe a data, o turno e o nome da ação.';
    }
    if (tipoSelecionado == null) {
      return 'O turno foi informado. Agora selecione o nome da ação educativa.';
    }
    if (coordenadorId == null) {
      return 'Os dados estão quase completos. Informe o coordenador responsável.';
    }
    return 'Tudo certo! Confira as informações e avance para a localização.';
  }

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
      final tiposSnapshot =
          await firestore.collection('tipos_acoes').orderBy('nomeAcao').get();
      final coordenadoresSnapshot =
          await firestore.collection('coordenadores').orderBy('nome').get();

      if (!mounted) return;

      final tiposCarregados = tiposSnapshot.docs
          .map((doc) => TipoAcaoModel.fromMap(doc.data()))
          .where((tipo) => tipo.ativo)
          .toList();

      final coordenadoresCarregados = coordenadoresSnapshot.docs
          .map((doc) => doc.data())
          .where((coord) => coord['ativo'] == true)
          .toList();

      final acao = context.read<AcaoController>().acaoAtual;

      TipoAcaoModel? tipoRestaurado;
      if (acao != null && acao.nomeAcao.trim().isNotEmpty) {
        for (final tipo in tiposCarregados) {
          if (tipo.nomeAcao.trim() == acao.nomeAcao.trim()) {
            tipoRestaurado = tipo;
            break;
          }
        }
      }

      String? coordenadorIdRestaurado;
      String? coordenadorNomeRestaurado;

      if (acao != null && acao.coordenadorId.trim().isNotEmpty) {
        for (final coordenador in coordenadoresCarregados) {
          if (coordenador['id'] == acao.coordenadorId) {
            coordenadorIdRestaurado = acao.coordenadorId;
            coordenadorNomeRestaurado =
                (coordenador['nome'] ?? acao.coordenadorNome).toString();
            break;
          }
        }
      }

      setState(() {
        tiposAcoes = tiposCarregados;
        coordenadores = coordenadoresCarregados;

        if (acao != null) {
          dataSelecionada = acao.dataAcao;
          turno = acao.turno.trim().isEmpty ? null : acao.turno;
          acaoPlanejada = acao.acaoPlanejada;
          tipoSelecionado = tipoRestaurado;
          coordenadorId = coordenadorIdRestaurado;
          coordenadorNome = coordenadorNomeRestaurado;

          _nomeAcaoController.text = tipoRestaurado?.nomeAcao ?? acao.nomeAcao;
        }

        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => carregando = false);
      _mensagem('Erro ao carregar dados: $e');
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
    setState(() => dataSelecionada = data);
  }

  Future<void> pesquisarTipoAcao() async {
    final selecionado = await showModalBottomSheet<TipoAcaoModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _PesquisaTipoAcaoSheet(tiposAcoes: tiposAcoes),
    );

    if (selecionado == null || !mounted) return;

    setState(() {
      tipoSelecionado = selecionado;
      _nomeAcaoController.text = selecionado.nomeAcao;
    });
  }

  void avancar() {
    if (turno == null) {
      _mensagem('Informe o turno da ação.');
      return;
    }
    if (tipoSelecionado == null) {
      _mensagem('Informe o nome da ação.');
      return;
    }
    if (coordenadorId == null || coordenadorNome == null) {
      _mensagem('Informe o coordenador responsável.');
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

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
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
      appBar: FenixAppBar(
        title: 'Nova Ação',
        onBack: () => context.go('/home'),
        actions: [
          IconButton(
            tooltip: 'Atualizar cadastros',
            onPressed: () {
              setState(() => carregando = true);
              carregarDados();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Material(
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Voltar'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: avancar,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Próximo'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                FenixJourneyHeader(
                  step: 1,
                  totalSteps: 9,
                  title: 'Nova Ação Educativa',
                  subtitle: 'Cadastro inicial da operação • $dataFormatada',
                  icon: Icons.add_task_outlined,
                ),
                const SizedBox(height: 12),
                _FaxitaCard(
                  mensagem: mensagemFaxita,
                  concluido: dadosCompletos,
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  titulo: 'Dados da ação',
                  subtitulo: 'Identificação básica da atividade educativa.',
                  icone: Icons.assignment_outlined,
                  children: [
                    InkWell(
                      onTap: selecionarData,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data da ação',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_month_outlined),
                          suffixIcon: Icon(Icons.edit_calendar_outlined),
                        ),
                        child: Text(dataFormatada),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: turno,
                      decoration: const InputDecoration(
                        labelText: 'Turno *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.schedule_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Manhã', child: Text('Manhã')),
                        DropdownMenuItem(value: 'Tarde', child: Text('Tarde')),
                        DropdownMenuItem(value: 'Noite', child: Text('Noite')),
                        DropdownMenuItem(
                            value: 'Madrugada', child: Text('Madrugada')),
                      ],
                      onChanged: (valor) => setState(() => turno = valor),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomeAcaoController,
                      readOnly: true,
                      onTap: pesquisarTipoAcao,
                      decoration: const InputDecoration(
                        labelText: 'Nome da ação *',
                        hintText: 'Toque para pesquisar',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.campaign_outlined),
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  titulo: 'Planejamento',
                  subtitulo: 'Organização prévia e responsabilidade da ação.',
                  icone: Icons.fact_check_outlined,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        value: acaoPlanejada,
                        title: const Text('A ação foi previamente planejada?'),
                        subtitle: Text(acaoPlanejada ? 'Sim' : 'Não'),
                        secondary: Icon(
                          acaoPlanejada
                              ? Icons.check_circle_outline
                              : Icons.pending_actions_outlined,
                        ),
                        onChanged: (valor) =>
                            setState(() => acaoPlanejada = valor),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: coordenadorId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Coordenador responsável *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items: coordenadores.map((coord) {
                        return DropdownMenuItem<String>(
                          value: coord['id'],
                          child: Text(
                            coord['nome'] ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
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
                  ],
                ),
                if (tipoSelecionado != null) ...[
                  const SizedBox(height: 12),
                  _ResumoCard(
                    data: dataFormatada,
                    turno: turno,
                    tipo: tipoSelecionado!,
                    planejada: acaoPlanejada,
                    coordenador: coordenadorNome,
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FaxitaCard extends StatelessWidget {
  const _FaxitaCard({
    required this.mensagem,
    required this.concluido,
  });

  final String mensagem;
  final bool concluido;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fundo = concluido ? Colors.green.shade50 : scheme.primaryContainer;
    final frente =
        concluido ? Colors.green.shade900 : scheme.onPrimaryContainer;

    return Card(
      elevation: 0,
      color: fundo,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: frente.withValues(alpha: 0.12),
              foregroundColor: frente,
              child: Icon(
                concluido
                    ? Icons.check_circle_outline
                    : Icons.assistant_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Faixita',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: frente,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mensagem,
                    style: TextStyle(color: frente, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.titulo,
    required this.subtitulo,
    required this.icone,
    required this.children,
  });

  final String titulo;
  final String subtitulo;
  final IconData icone;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  child: Icon(icone),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      Text(
                        subtitulo,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  const _ResumoCard({
    required this.data,
    required this.turno,
    required this.tipo,
    required this.planejada,
    required this.coordenador,
  });

  final String data;
  final String? turno;
  final TipoAcaoModel tipo;
  final bool planejada;
  final String? coordenador;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      titulo: 'Resumo da ação',
      subtitulo: 'Conferência rápida antes de avançar.',
      icone: Icons.summarize_outlined,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final duasColunas = constraints.maxWidth >= 680;

            final colunaEsquerda = [
              _ResumoItem(
                icone: Icons.calendar_month_outlined,
                rotulo: 'Data',
                valor: data,
              ),
              _ResumoItem(
                icone: Icons.schedule_outlined,
                rotulo: 'Turno',
                valor: turno ?? 'Não informado',
              ),
              _ResumoItem(
                icone: Icons.campaign_outlined,
                rotulo: 'Nome da ação',
                valor: tipo.nomeAcao,
              ),
              _ResumoItem(
                icone: Icons.category_outlined,
                rotulo: 'Tipo',
                valor: tipo.tipoAcao,
              ),
            ];

            final colunaDireita = [
              _ResumoItem(
                icone: Icons.groups_outlined,
                rotulo: 'Público estimado',
                valor: '${tipo.publicoEstimadoPadrao}',
              ),
              _ResumoItem(
                icone: Icons.group_outlined,
                rotulo: 'Público mínimo',
                valor: '${tipo.publicoMinimoPadrao}',
              ),
              _ResumoItem(
                icone: Icons.fact_check_outlined,
                rotulo: 'Planejada',
                valor: planejada ? 'Sim' : 'Não',
              ),
              _ResumoItem(
                icone: Icons.person_outline,
                rotulo: 'Coordenador',
                valor: coordenador ?? 'Não informado',
              ),
            ];

            if (!duasColunas) {
              return Column(
                children: [
                  ...colunaEsquerda,
                  ...colunaDireita,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(children: colunaEsquerda),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(children: colunaDireita),
                ),
              ],
            );
          },
        ),
        if (tipo.materiaisSugeridos.isNotEmpty) ...[
          const Divider(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final material in tipo.materiaisSugeridos)
                Chip(
                  avatar: const Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                  ),
                  label: Text(material),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ResumoItem extends StatelessWidget {
  const _ResumoItem({
    required this.icone,
    required this.rotulo,
    required this.valor,
  });

  final IconData icone;
  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icone,
            size: 20,
            color: scheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rotulo,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PesquisaTipoAcaoSheet extends StatefulWidget {
  const _PesquisaTipoAcaoSheet({required this.tiposAcoes});
  final List<TipoAcaoModel> tiposAcoes;

  @override
  State<_PesquisaTipoAcaoSheet> createState() => _PesquisaTipoAcaoSheetState();
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
            Text(
              'Selecionar ação educativa',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pesquisaController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Pesquisar ação',
                hintText: 'Digite o nome ou o tipo da ação',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: resultados.isEmpty
                  ? const Center(child: Text('Nenhuma ação encontrada.'))
                  : ListView.separated(
                      itemCount: resultados.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final tipo = resultados[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.campaign_outlined),
                          ),
                          title: Text(tipo.nomeAcao),
                          subtitle: Text(tipo.tipoAcao),
                          onTap: () => Navigator.of(context).pop(tipo),
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
