import 'package:flutter/material.dart';

import '../../core/services/domain_service.dart';
import '../../data/models/domain_model.dart';
import '../../repositories/domain_repository.dart';
import '../../shared/widgets/layout/fenix_app_bar.dart';
import 'domain_form_args.dart';
import 'domain_form_page.dart';

class DomainListPage extends StatefulWidget {
  const DomainListPage({super.key});

  @override
  State<DomainListPage> createState() => _DomainListPageState();
}

class _DomainListPageState extends State<DomainListPage> {
  final DomainRepository repository = DomainRepository(
    domainService: DomainService(),
  );

  final TextEditingController pesquisaController = TextEditingController();

  String grupoSelecionado = 'todos';
  bool carregando = true;
  String? mensagemErro;
  List<DomainModel> dominios = [];

  static const Map<String, String> grupos = {
    'todos': 'Todos',
    'formacao': 'Formação',
    'publico': 'Público',
    'perfil_usuario': 'Perfil do usuário',
    'tipo_participacao': 'Tipo de participação',
    'foco_tematico': 'Foco temático',
    'fator_risco': 'Fatores de risco',
    'material': 'Materiais',
    'orgao': 'Órgãos parceiros',
    'sexo_predominante': 'Sexo predominante',
    'mudanca_comportamento': 'Mudança de comportamento',
  };

  @override
  void initState() {
    super.initState();
    carregarDominios();
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  Future<void> carregarDominios() async {
    setState(() {
      carregando = true;
      mensagemErro = null;
    });

    try {
      final lista = await repository.listarTodos();

      if (!mounted) return;

      setState(() {
        dominios = lista;
        carregando = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        carregando = false;
        mensagemErro = 'Não foi possível carregar a Central de Domínios.';
      });
    }
  }

  Future<void> abrirFormulario(DomainFormArgs args) async {
    final alterado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DomainFormPage(args: args),
      ),
    );

    if (alterado != true) {
      return;
    }

    await carregarDominios();

    if (!mounted) return;

    final mensagem = switch (args.mode) {
      DomainFormMode.novo => 'Domínio cadastrado com sucesso.',
      DomainFormMode.editar => 'Domínio atualizado com sucesso.',
      DomainFormMode.duplicar => 'Domínio duplicado com sucesso.',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
    );
  }

  Future<void> duplicarDominio(DomainModel domain) {
    return abrirFormulario(
      DomainFormArgs.duplicar(domain),
    );
  }

  List<DomainModel> get dominiosFiltrados {
    final termo = pesquisaController.text.toLowerCase().trim();

    final filtrados = dominios.where((domain) {
      final grupoOk =
          grupoSelecionado == 'todos' || domain.grupo == grupoSelecionado;

      final textoOk = termo.isEmpty ||
          domain.nome.toLowerCase().contains(termo) ||
          domain.codigo.toLowerCase().contains(termo) ||
          domain.grupo.toLowerCase().contains(termo) ||
          domain.descricao.toLowerCase().contains(termo);

      return grupoOk && textoOk;
    }).toList();

    filtrados.sort((a, b) {
      final grupoCompare = a.grupo.compareTo(b.grupo);

      if (grupoCompare != 0) return grupoCompare;

      final ordemCompare = a.ordem.compareTo(b.ordem);

      if (ordemCompare != 0) return ordemCompare;

      return a.nome.compareTo(b.nome);
    });

    return filtrados;
  }

  int get totalAtivos => dominios.where((item) => item.ativo).length;
  int get totalInativos => dominios.length - totalAtivos;
  int get totalGrupos => dominios
      .map((item) => item.grupo)
      .where((item) => item.isNotEmpty)
      .toSet()
      .length;

  Future<void> alternarAtivo(DomainModel domain) async {
    final novoStatus = !domain.ativo;

    try {
      if (novoStatus) {
        await repository.ativar(domain.id);
      } else {
        await repository.desativar(domain.id);
      }

      final lista = await repository.listarTodos();

      if (!mounted) return;

      setState(() {
        dominios = lista;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            novoStatus
                ? '${domain.nome} foi ativado.'
                : '${domain.nome} foi inativado.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível alterar o status do domínio.'),
        ),
      );
    }
  }

  void limparFiltros() {
    pesquisaController.clear();

    setState(() {
      grupoSelecionado = 'todos';
    });
  }

  String nomeGrupo(String grupo) => grupos[grupo] ?? grupo;

  IconData iconeGrupo(String grupo) {
    switch (grupo) {
      case 'formacao':
        return Icons.school_outlined;
      case 'publico':
        return Icons.groups_outlined;
      case 'perfil_usuario':
        return Icons.person_search_outlined;
      case 'tipo_participacao':
        return Icons.how_to_reg_outlined;
      case 'foco_tematico':
        return Icons.track_changes_outlined;
      case 'fator_risco':
        return Icons.warning_amber_outlined;
      case 'material':
        return Icons.inventory_2_outlined;
      case 'orgao':
        return Icons.account_balance_outlined;
      case 'sexo_predominante':
        return Icons.people_alt_outlined;
      case 'mudanca_comportamento':
        return Icons.psychology_alt_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Widget _cabecalho() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compacto = constraints.maxWidth < 700;

            final conteudo = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Central Administrativa de Domínios',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Núcleo de parametrização dos catálogos utilizados pela '
                  'Plataforma Fênix.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            );

            final acao = FilledButton.icon(
              onPressed: () => abrirFormulario(
                const DomainFormArgs.novo(),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Novo domínio'),
            );

            if (compacto) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  conteudo,
                  const SizedBox(height: 16),
                  acao,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: conteudo),
                const SizedBox(width: 20),
                acao,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _indicadores() {
    final indicadores = [
      _IndicadorDominio(
        titulo: 'Total',
        valor: dominios.length.toString(),
        icone: Icons.category_outlined,
      ),
      _IndicadorDominio(
        titulo: 'Ativos',
        valor: totalAtivos.toString(),
        icone: Icons.check_circle_outline,
      ),
      _IndicadorDominio(
        titulo: 'Inativos',
        valor: totalInativos.toString(),
        icone: Icons.pause_circle_outline,
      ),
      _IndicadorDominio(
        titulo: 'Grupos',
        valor: totalGrupos.toString(),
        icone: Icons.folder_copy_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        final colunas = largura >= 1000
            ? 4
            : largura >= 600
                ? 2
                : 1;
        final larguraItem = (largura - ((colunas - 1) * 12)) / colunas;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: indicadores
              .map(
                (item) => SizedBox(
                  width: larguraItem,
                  child: item,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _filtros() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compacto = constraints.maxWidth < 720;

            final pesquisa = TextField(
              controller: pesquisaController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Pesquisar domínio',
                hintText: 'Nome, código, grupo ou descrição',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            );

            final seletorGrupo = DropdownButtonFormField<String>(
              initialValue: grupoSelecionado,
              decoration: const InputDecoration(
                labelText: 'Grupo',
                border: OutlineInputBorder(),
              ),
              items: grupos.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  grupoSelecionado = valor ?? 'todos';
                });
              },
            );

            final limpar = OutlinedButton.icon(
              onPressed: limparFiltros,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Limpar'),
            );

            if (compacto) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  pesquisa,
                  const SizedBox(height: 12),
                  seletorGrupo,
                  const SizedBox(height: 12),
                  limpar,
                ],
              );
            }

            return Row(
              children: [
                Expanded(flex: 2, child: pesquisa),
                const SizedBox(width: 12),
                Expanded(child: seletorGrupo),
                const SizedBox(width: 12),
                limpar,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _gruposResumo() {
    final contagens = <String, int>{};

    for (final dominio in dominios) {
      contagens.update(
        dominio.grupo,
        (valor) => valor + 1,
        ifAbsent: () => 1,
      );
    }

    final gruposOrdenados = contagens.entries.toList()
      ..sort((a, b) => nomeGrupo(a.key).compareTo(nomeGrupo(b.key)));

    if (gruposOrdenados.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: gruposOrdenados.map((entry) {
            final selecionado = grupoSelecionado == entry.key;

            return FilterChip(
              selected: selecionado,
              avatar: Icon(iconeGrupo(entry.key), size: 18),
              label: Text('${nomeGrupo(entry.key)} (${entry.value})'),
              onSelected: (_) {
                setState(() {
                  grupoSelecionado = selecionado ? 'todos' : entry.key;
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _lista() {
    if (dominiosFiltrados.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.search_off_outlined),
          title: Text('Nenhum domínio encontrado'),
          subtitle: Text('Ajuste os filtros ou cadastre um novo domínio.'),
        ),
      );
    }

    return Column(
      children: dominiosFiltrados.map((domain) {
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              child: Icon(iconeGrupo(domain.grupo)),
            ),
            title: Text(
              domain.nome,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${nomeGrupo(domain.grupo)} • ${domain.codigo} • '
              'Ordem ${domain.ordem}',
            ),
            onTap: () => abrirFormulario(
              DomainFormArgs.editar(domain),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: domain.ativo,
                  onChanged: (_) => alternarAtivo(domain),
                ),
                PopupMenuButton<String>(
                  onSelected: (valor) {
                    if (valor == 'editar') {
                      abrirFormulario(
                        DomainFormArgs.editar(domain),
                      );
                    } else if (valor == 'duplicar') {
                      duplicarDominio(domain);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'editar',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Editar'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'duplicar',
                      child: ListTile(
                        leading: Icon(Icons.copy_outlined),
                        title: Text('Duplicar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _conteudo() {
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (mensagemErro != null) {
      return Center(
        child: FilledButton.icon(
          onPressed: carregarDominios,
          icon: const Icon(Icons.refresh),
          label: const Text('Tentar novamente'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: carregarDominios,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _cabecalho(),
          const SizedBox(height: 12),
          _indicadores(),
          const SizedBox(height: 12),
          _gruposResumo(),
          const SizedBox(height: 12),
          _filtros(),
          const SizedBox(height: 12),
          Text(
            '${dominiosFiltrados.length} resultado(s)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          _lista(),
          const SizedBox(height: 88),
        ],
      ),
    );
  }

  void _voltar() {
    FenixAppBar.navigateBack(
      context,
      fallbackRoute: '/home',
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _voltar();
        }
      },
      child: Scaffold(
        appBar: FenixAppBar(
          title: 'Central de Domínios',
          fallbackRoute: '/home',
          actions: [
            IconButton(
              tooltip: 'Atualizar',
              onPressed: carregarDominios,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _conteudo(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => abrirFormulario(
            const DomainFormArgs.novo(),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Novo'),
        ),
      ),
    );
  }
}

class _IndicadorDominio extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;

  const _IndicadorDominio({
    required this.titulo,
    required this.valor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(child: Icon(icone)),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valor,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(titulo),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
