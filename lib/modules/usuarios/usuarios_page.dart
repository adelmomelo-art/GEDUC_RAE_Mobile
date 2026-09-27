import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/security/access_scope.dart';
import '../../core/security/authorization_service.dart';
import '../../core/security/scope_catalogs.dart';
import '../../data/models/usuario_model.dart';
import '../admin/controllers/usuario_controller.dart';
import 'models/convite_usuario_model.dart';
import 'services/convite_usuario_csv_parser.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UsuarioController>().carregarUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UsuarioController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários'),
        actions: [
          IconButton(
            tooltip: 'Atualizar usuários',
            icon: const Icon(Icons.refresh),
            onPressed: controller.carregando ? null : controller.recarregar,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('novo-convite-usuario'),
        onPressed: controller.carregando ? null : () => _abrirAcoes(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('CONVIDAR'),
      ),
      body: _UsuariosBody(controller: controller),
    );
  }

  Future<void> _abrirAcoes(BuildContext context) async {
    final acao = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add_alt_1),
              title: const Text('Novo convite'),
              onTap: () => Navigator.pop(context, 'novo'),
            ),
            ListTile(
              leading: const Icon(Icons.table_view_outlined),
              title: const Text('Importar lista CSV'),
              subtitle: const Text('Cole o conteúdo exportado pelo Excel'),
              onTap: () => Navigator.pop(context, 'csv'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || acao == null) return;
    if (acao == 'novo') {
      await _novoConvite(context);
    } else {
      await _importarCsv(context);
    }
  }

  Future<void> _novoConvite(BuildContext context) async {
    final entrada = await showDialog<ConviteUsuarioEntrada>(
      context: context,
      builder: (_) => const _ConviteUsuarioDialog(),
    );
    if (entrada == null || !context.mounted) return;
    final controller = context.read<UsuarioController>();
    final adminId = context.read<AuthorizationService>().usuarioAtual?.id ?? '';
    try {
      final codigo = await controller.criarConvite(
        entrada: entrada,
        criadoPor: adminId,
      );
      await Clipboard.setData(ClipboardData(text: codigo));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Convite criado e código copiado.')),
      );
    } catch (erro) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível criar o convite: $erro')),
      );
    }
  }

  Future<void> _importarCsv(BuildContext context) async {
    final conteudo = await showDialog<String>(
      context: context,
      builder: (_) => const _ImportarCsvDialog(),
    );
    if (conteudo == null || !context.mounted) return;
    final controller = context.read<UsuarioController>();
    final adminId = context.read<AuthorizationService>().usuarioAtual?.id ?? '';
    try {
      final total = await controller.importarCsv(
        conteudo: conteudo,
        criadoPor: adminId,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$total convite(s) importado(s).')),
      );
    } catch (erro) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Importação recusada: $erro')));
    }
  }
}

class _UsuariosBody extends StatelessWidget {
  const _UsuariosBody({required this.controller});

  final UsuarioController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.carregando && controller.usuarios.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.possuiErro && controller.usuarios.isEmpty) {
      return _ErroUsuarios(onTentarNovamente: controller.recarregar);
    }

    return RefreshIndicator(
      onRefresh: controller.recarregar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (controller.possuiErro) ...[
            _AvisoErro(onTentarNovamente: controller.recarregar),
            const SizedBox(height: 12),
          ],
          Card(
            color: Colors.blue.shade50,
            child: ListTile(
              leading: controller.carregando
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.people),
              title: const Text('Usuários cadastrados'),
              subtitle: Text(
                '${controller.usuarios.length} usuário(s) encontrado(s)',
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (controller.convites.isNotEmpty) ...[
            Text('Convites', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...controller.convites.map(_ConviteCard.new),
            const SizedBox(height: 16),
            Text(
              'Identidades vinculadas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
          ],
          if (controller.usuarios.isEmpty)
            const _SemUsuarios()
          else
            ...controller.usuarios.map(_UsuarioCard.new),
        ],
      ),
    );
  }
}

class _UsuarioCard extends StatelessWidget {
  const _UsuarioCard(this.usuario);

  final UsuarioModel usuario;

  @override
  Widget build(BuildContext context) {
    final cor = _corPerfil(usuario.perfilAcesso);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cor.withValues(alpha: 0.15),
          child: Icon(Icons.person, color: cor),
        ),
        title: Text(usuario.nome),
        subtitle: Text(
          '${usuario.email}\n'
          'Perfil: ${usuario.perfilAcesso}\n'
          'Ativo: ${usuario.ativo ? "Sim" : "Não"}',
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: usuario.ativo ? 'Desativar conta' : 'Ativar conta',
          icon: Icon(
            usuario.ativo ? Icons.person_off_outlined : Icons.person_add_alt,
          ),
          onPressed: () => _alterarAtivacao(context),
        ),
        onTap: () => _editarEscopo(context),
      ),
    );
  }

  Future<void> _alterarAtivacao(BuildContext context) async {
    final novoEstado = !usuario.ativo;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(novoEstado ? 'Ativar conta?' : 'Desativar conta?'),
        content: Text(
          novoEstado
              ? 'A ativação só será aceita se o vínculo operacional ou o escopo exigido estiver pronto.'
              : 'O usuário perderá o acesso imediatamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CONFIRMAR'),
          ),
        ],
      ),
    );
    if (confirmou != true || !context.mounted) return;
    final controller = context.read<UsuarioController>();
    final adminId = context.read<AuthorizationService>().usuarioAtual?.id ?? '';
    try {
      await controller.atualizarAtivacao(
        usuario: usuario,
        ativo: novoEstado,
        atualizadoPor: adminId,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(novoEstado ? 'Conta ativada.' : 'Conta desativada.'),
        ),
      );
    } catch (erro) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ativação recusada: $erro')));
    }
  }

  Future<void> _editarEscopo(BuildContext context) async {
    final controller = context.read<UsuarioController>();
    final authorization = context.read<AuthorizationService>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      final catalogos = await controller.carregarCatalogosEscopo();
      if (!context.mounted) return;
      final escopo = await showDialog<AccessScope>(
        context: context,
        builder: (_) =>
            _EscopoUsuarioDialog(usuario: usuario, catalogos: catalogos),
      );
      if (escopo == null || !context.mounted) return;

      await controller.atualizarEscopo(
        usuario: usuario,
        escopo: escopo,
        atualizadoPor: authorization.usuarioAtual?.id ?? '',
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Escopo atualizado com segurança.')),
      );
    } catch (erro) {
      messenger.showSnackBar(
        SnackBar(content: Text('Não foi possível atualizar o escopo: $erro')),
      );
    }
  }

  Color _corPerfil(String perfil) {
    return switch (perfil.trim().toLowerCase()) {
      'administrador' => Colors.blue,
      'gestor' => Colors.green,
      'gerente' => Colors.teal,
      'coordenador' => Colors.orange,
      'agente' => Colors.purple,
      _ => Colors.grey,
    };
  }
}

class _ConviteCard extends StatelessWidget {
  const _ConviteCard(this.convite);
  final ConviteUsuarioModel convite;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          convite.pendente
              ? Icons.mark_email_unread_outlined
              : Icons.mark_email_read_outlined,
        ),
        title: Text(convite.nome),
        subtitle: Text(
          '${convite.email}\n${convite.perfilAcesso} • ${convite.status}',
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: 'Copiar código',
          onPressed: convite.pendente
              ? () async {
                  await Clipboard.setData(ClipboardData(text: convite.id));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Código copiado.')),
                    );
                  }
                }
              : null,
          icon: const Icon(Icons.copy),
        ),
      ),
    );
  }
}

class _ConviteUsuarioDialog extends StatefulWidget {
  const _ConviteUsuarioDialog();
  @override
  State<_ConviteUsuarioDialog> createState() => _ConviteUsuarioDialogState();
}

class _ConviteUsuarioDialogState extends State<_ConviteUsuarioDialog> {
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _telefone = TextEditingController();
  final _cargo = TextEditingController();
  final _setor = TextEditingController(text: 'GEDUC');
  String _perfil = 'agente';

  @override
  void dispose() {
    for (final controller in [_nome, _email, _telefone, _cargo, _setor]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Convidar usuário'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _campo(_nome, 'Nome completo'),
              _campo(_email, 'E-mail institucional'),
              _campo(_telefone, 'Telefone'),
              _campo(_cargo, 'Cargo'),
              _campo(_setor, 'Setor'),
              DropdownButtonFormField<String>(
                initialValue: _perfil,
                decoration: const InputDecoration(
                  labelText: 'Perfil de acesso',
                ),
                items: ConviteUsuarioCsvParser.perfisPermitidos
                    .map(
                      (perfil) =>
                          DropdownMenuItem(value: perfil, child: Text(perfil)),
                    )
                    .toList(growable: false),
                onChanged: (valor) =>
                    setState(() => _perfil = valor ?? 'agente'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR'),
        ),
        FilledButton(onPressed: _salvar, child: const Text('CRIAR CONVITE')),
      ],
    );
  }

  Widget _campo(TextEditingController controller, String rotulo) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: rotulo),
        ),
      );

  void _salvar() {
    final conteudo = '${_nome.text};${_email.text};${_telefone.text};'
        '${_cargo.text};${_setor.text};$_perfil';
    try {
      final entrada = ConviteUsuarioCsvParser.parse(
        '${ConviteUsuarioCsvParser.cabecalho}\n$conteudo',
      ).single;
      Navigator.pop(context, entrada);
    } catch (erro) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$erro')));
    }
  }
}

class _ImportarCsvDialog extends StatefulWidget {
  const _ImportarCsvDialog();
  @override
  State<_ImportarCsvDialog> createState() => _ImportarCsvDialogState();
}

class _ImportarCsvDialogState extends State<_ImportarCsvDialog> {
  final _conteudo = TextEditingController(
    text: '${ConviteUsuarioCsvParser.cabecalho}\n',
  );
  @override
  void dispose() {
    _conteudo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Importar lista CSV'),
        content: SizedBox(
          width: 720,
          child: TextField(
            key: const ValueKey('csv-convites'),
            controller: _conteudo,
            minLines: 10,
            maxLines: 18,
            style: const TextStyle(fontFamily: 'monospace'),
            decoration: const InputDecoration(
              helperText:
                  'Máximo de 400 linhas. Separador vírgula ou ponto e vírgula.',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _conteudo.text),
            child: const Text('IMPORTAR'),
          ),
        ],
      );
}

class _EscopoUsuarioDialog extends StatefulWidget {
  const _EscopoUsuarioDialog({required this.usuario, required this.catalogos});

  final UsuarioModel usuario;
  final ScopeCatalogs catalogos;

  @override
  State<_EscopoUsuarioDialog> createState() => _EscopoUsuarioDialogState();
}

class _EscopoUsuarioDialogState extends State<_EscopoUsuarioDialog> {
  late final Set<String> _regionais;
  late final Set<String> _equipes;
  late final Set<String> _projetos;

  bool get _gerente =>
      widget.usuario.perfilAcesso.trim().toLowerCase() == 'gerente';

  @override
  void initState() {
    super.initState();
    final escopo = widget.usuario.escopoAcesso;
    _regionais = {...escopo.regionalIds};
    _equipes = {...escopo.equipeIds};
    _projetos = {...escopo.projetoIds};
  }

  @override
  Widget build(BuildContext context) {
    final escopo = AccessScope(
      regionalIds: _regionais,
      equipeIds: _equipes,
      projetoIds: _projetos,
      version: widget.usuario.escopoAcesso.version,
    );

    return AlertDialog(
      title: Text('Escopo de ${widget.usuario.nome}'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_gerente && !escopo.completoParaGerente)
                const Card(
                  color: Color(0xFFFFF3CD),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Gerente permanece bloqueado até possuir ao menos uma '
                      'Regional, uma equipe e um projeto.',
                    ),
                  ),
                ),
              _GrupoEscopo(
                titulo: 'Regionais',
                itens: widget.catalogos.regionais,
                selecionados: _regionais,
                onChanged: _alternar,
              ),
              _GrupoEscopo(
                titulo: 'Equipes',
                itens: widget.catalogos.equipes,
                selecionados: _equipes,
                onChanged: _alternar,
              ),
              _GrupoEscopo(
                titulo: 'Projetos',
                itens: widget.catalogos.projetos,
                selecionados: _projetos,
                onChanged: _alternar,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR'),
        ),
        FilledButton(
          onPressed: _gerente && !escopo.completoParaGerente
              ? null
              : () => Navigator.pop(context, escopo),
          child: const Text('SALVAR ESCOPO'),
        ),
      ],
    );
  }

  void _alternar(Set<String> conjunto, String id, bool selecionado) {
    setState(() {
      if (selecionado) {
        conjunto.add(id);
      } else {
        conjunto.remove(id);
      }
    });
  }
}

class _GrupoEscopo extends StatelessWidget {
  const _GrupoEscopo({
    required this.titulo,
    required this.itens,
    required this.selecionados,
    required this.onChanged,
  });

  final String titulo;
  final List<ScopeCatalogItem> itens;
  final Set<String> selecionados;
  final void Function(Set<String>, String, bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('$titulo (${selecionados.length})'),
      children: itens.isEmpty
          ? const [ListTile(title: Text('Nenhum item ativo disponível.'))]
          : itens
              .map(
                (item) => CheckboxListTile(
                  value: selecionados.contains(item.id),
                  title: Text(item.nome),
                  subtitle: Text(item.id),
                  onChanged: (valor) =>
                      onChanged(selecionados, item.id, valor == true),
                ),
              )
              .toList(growable: false),
    );
  }
}

class _ErroUsuarios extends StatelessWidget {
  const _ErroUsuarios({required this.onTentarNovamente});

  final Future<void> Function() onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 56),
            const SizedBox(height: 16),
            const Text(
              'Não foi possível carregar os usuários.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onTentarNovamente,
              icon: const Icon(Icons.refresh),
              label: const Text('TENTAR NOVAMENTE'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvisoErro extends StatelessWidget {
  const _AvisoErro({required this.onTentarNovamente});

  final Future<void> Function() onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: ListTile(
        leading: const Icon(Icons.warning_amber_rounded),
        title: const Text('Não foi possível atualizar a lista.'),
        trailing: TextButton(
          onPressed: onTentarNovamente,
          child: const Text('TENTAR'),
        ),
      ),
    );
  }
}

class _SemUsuarios extends StatelessWidget {
  const _SemUsuarios();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.person_search_outlined, size: 52),
          SizedBox(height: 12),
          Text('Nenhum usuário foi encontrado.'),
        ],
      ),
    );
  }
}
