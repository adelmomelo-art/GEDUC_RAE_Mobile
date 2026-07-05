import 'package:flutter/material.dart';

import '../../core/services/domain_service.dart';
import '../../data/models/domain_model.dart';
import '../../repositories/domain_repository.dart';

class DomainListPage extends StatefulWidget {
  const DomainListPage({super.key});

  @override
  State<DomainListPage> createState() => _DomainListPageState();
}

class _DomainListPageState extends State<DomainListPage> {
  final DomainRepository repository = DomainRepository(
    domainService: DomainService(),
  );

  final pesquisaController = TextEditingController();

  String grupoSelecionado = 'todos';
  bool carregando = true;
  List<DomainModel> dominios = [];

  final grupos = const {
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
    });

    await repository.salvarTodos(_dominiosSemente());

    final lista = await repository.listarTodos();

    if (!mounted) return;

    setState(() {
      dominios = lista;
      carregando = false;
    });
  }

  List<DomainModel> get dominiosFiltrados {
    final termo = pesquisaController.text.toLowerCase().trim();

    final filtrados = dominios.where((domain) {
      final grupoOk =
          grupoSelecionado == 'todos' || domain.grupo == grupoSelecionado;

      final textoOk = termo.isEmpty ||
          domain.nome.toLowerCase().contains(termo) ||
          domain.codigo.toLowerCase().contains(termo) ||
          domain.grupo.toLowerCase().contains(termo);

      return grupoOk && textoOk;
    }).toList();

    filtrados.sort((a, b) {
      final grupoCompare = a.grupo.compareTo(b.grupo);

      if (grupoCompare != 0) {
        return grupoCompare;
      }

      final ordemCompare = a.ordem.compareTo(b.ordem);

      if (ordemCompare != 0) {
        return ordemCompare;
      }

      return a.nome.compareTo(b.nome);
    });

    return filtrados;
  }

  void alternarAtivo(DomainModel domain) async {
    await repository.salvar(
      domain.copyWith(ativo: !domain.ativo),
    );

    final lista = await repository.listarTodos();

    if (!mounted) return;

    setState(() {
      dominios = lista;
    });
  }

  Widget _filtros() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: pesquisaController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Pesquisar domínio',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _resumo() {
    final ativos = dominiosFiltrados.where((item) => item.ativo).length;
    final inativos = dominiosFiltrados.length - ativos;

    return Card(
      color: Colors.blue.shade50,
      child: ListTile(
        leading: const Icon(Icons.category),
        title: const Text('Central de Domínios Administráveis'),
        subtitle: Text(
          '${dominiosFiltrados.length} domínio(s) | '
          '$ativos ativo(s) | $inativos inativo(s)',
        ),
      ),
    );
  }

  Widget _lista() {
    if (dominiosFiltrados.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.info),
          title: Text('Nenhum domínio encontrado'),
          subtitle: Text('Ajuste os filtros ou cadastre novos domínios.'),
        ),
      );
    }

    return Column(
      children: dominiosFiltrados.map((domain) {
        return Card(
          child: ListTile(
            leading: Icon(
              domain.ativo ? Icons.check_circle : Icons.cancel,
              color: domain.ativo ? Colors.green : Colors.grey,
            ),
            title: Text(domain.nome),
            subtitle: Text(
              'Grupo: ${domain.grupo}\n'
              'Código: ${domain.codigo}\n'
              'Ordem: ${domain.ordem}',
            ),
            isThreeLine: true,
            trailing: Switch(
              value: domain.ativo,
              onChanged: (_) => alternarAtivo(domain),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<DomainModel> _dominiosSemente() {
    return const [
      DomainModel(
        id: 'formacao_palestra',
        grupo: 'formacao',
        codigo: 'palestra',
        nome: 'Palestra',
        ordem: 1,
      ),
      DomainModel(
        id: 'formacao_oficina',
        grupo: 'formacao',
        codigo: 'oficina',
        nome: 'Oficina',
        ordem: 2,
      ),
      DomainModel(
        id: 'formacao_curso',
        grupo: 'formacao',
        codigo: 'curso',
        nome: 'Curso',
        ordem: 3,
      ),
      DomainModel(
        id: 'publico_criancas',
        grupo: 'publico',
        codigo: 'criancas',
        nome: 'Crianças',
        ordem: 1,
      ),
      DomainModel(
        id: 'publico_adolescentes',
        grupo: 'publico',
        codigo: 'adolescentes',
        nome: 'Adolescentes',
        ordem: 2,
      ),
      DomainModel(
        id: 'perfil_pedestre',
        grupo: 'perfil_usuario',
        codigo: 'pedestre',
        nome: 'Pedestre',
        ordem: 1,
      ),
      DomainModel(
        id: 'perfil_ciclista',
        grupo: 'perfil_usuario',
        codigo: 'ciclista',
        nome: 'Ciclista',
        ordem: 2,
      ),
      DomainModel(
        id: 'perfil_motociclista',
        grupo: 'perfil_usuario',
        codigo: 'motociclista',
        nome: 'Motociclista',
        ordem: 3,
      ),
      DomainModel(
        id: 'fator_risco_velocidade',
        grupo: 'fator_risco',
        codigo: 'velocidade',
        nome: 'Excesso de velocidade',
        ordem: 1,
      ),
      DomainModel(
        id: 'fator_risco_celular',
        grupo: 'fator_risco',
        codigo: 'celular',
        nome: 'Uso do celular',
        ordem: 2,
      ),
      DomainModel(
        id: 'material_caixa_som',
        grupo: 'material',
        codigo: 'caixa_som',
        nome: 'Caixa de som',
        ordem: 1,
      ),
      DomainModel(
        id: 'material_tenda',
        grupo: 'material',
        codigo: 'tenda',
        nome: 'Tenda',
        ordem: 2,
      ),
      DomainModel(
        id: 'orgao_amc',
        grupo: 'orgao',
        codigo: 'amc',
        nome: 'AMC',
        ordem: 1,
      ),
      DomainModel(
        id: 'orgao_detran',
        grupo: 'orgao',
        codigo: 'detran',
        nome: 'DETRAN',
        ordem: 2,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Central de Domínios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregarDominios,
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _resumo(),
                const SizedBox(height: 12),
                _filtros(),
                const SizedBox(height: 12),
                _lista(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Cadastro completo será implementado no CE-030A.2.2.',
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
    );
  }
}
