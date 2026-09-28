import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/fenix_visual_tokens.dart';
import '../../data/models/tipo_acao_model.dart';
import '../../shared/widgets/layout/fenix_page_scaffold.dart';
import 'controllers/tipo_acao_controller.dart';
import 'tipo_acao_form_args.dart';
import 'tipo_acao_form_page.dart';

class TiposAcoesPage extends StatefulWidget {
  const TiposAcoesPage({super.key});

  @override
  State<TiposAcoesPage> createState() => _TiposAcoesPageState();
}

class _TiposAcoesPageState extends State<TiposAcoesPage> {
  final _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = context.read<TipoAcaoController>();
      if (controller.tipos.isEmpty) controller.carregar();
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TipoAcaoController>();

    return FenixPageScaffold(
      appBar: AppBar(
        title: const Text('Tipos de Ações'),
        actions: [
          IconButton(
            key: const ValueKey('tipos-acoes-atualizar'),
            tooltip: 'Atualizar catálogo',
            onPressed: controller.carregando || controller.salvando
                ? null
                : controller.carregar,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('tipo-acao-novo'),
        onPressed: controller.salvando ? null : () => _abrirFormulario(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('NOVO TIPO'),
      ),
      body: RefreshIndicator(
        onRefresh: controller.carregar,
        child: ListView(
          key: const ValueKey('tipos-acoes-lista'),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _ResumoCatalogo(controller: controller),
            const SizedBox(height: FenixVisualTokens.space16),
            _FiltrosCatalogo(
              controller: controller,
              buscaController: _buscaController,
              onLimpar: () {
                _buscaController.clear();
                controller.limparFiltros();
              },
            ),
            if (controller.carregando) ...[
              const SizedBox(height: FenixVisualTokens.space12),
              const LinearProgressIndicator(),
            ],
            if (controller.erro != null) ...[
              const SizedBox(height: FenixVisualTokens.space12),
              _AvisoErro(
                mensagem: controller.erro!,
                onTentarNovamente: controller.carregar,
              ),
            ],
            const SizedBox(height: FenixVisualTokens.space16),
            _ConteudoCatalogo(
              controller: controller,
              onEditar: (tipo) => _abrirFormulario(context, tipo: tipo),
              onAlterarStatus: (tipo) => _confirmarStatus(context, tipo),
            ),
            const SizedBox(height: 88),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirFormulario(
    BuildContext context, {
    TipoAcaoModel? tipo,
  }) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => TipoAcaoFormPage(
          args: TipoAcaoFormArgs(tipoAcao: tipo),
        ),
      ),
    );
  }

  Future<void> _confirmarStatus(
    BuildContext context,
    TipoAcaoModel tipo,
  ) async {
    final novoEstado = !tipo.ativo;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            novoEstado ? 'Ativar tipo de ação?' : 'Inativar tipo de ação?'),
        content: Text(
          novoEstado
              ? 'O tipo “${tipo.nomeAcao}” voltará a ficar disponível para novos registros.'
              : 'O tipo “${tipo.nomeAcao}” deixará de ser oferecido em novas ações. O histórico será preservado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            key: const ValueKey('tipo-acao-status-confirmar'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CONFIRMAR'),
          ),
        ],
      ),
    );

    if (confirmou != true || !context.mounted) return;
    final controller = context.read<TipoAcaoController>();
    final sucesso = await controller.alterarStatus(tipo, novoEstado);
    if (!context.mounted) return;

    final mensagem = sucesso
        ? (novoEstado ? 'Tipo de ação ativado.' : 'Tipo de ação inativado.')
        : (controller.erro ?? 'Não foi possível alterar o status.');
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }
}

class _ResumoCatalogo extends StatelessWidget {
  const _ResumoCatalogo({required this.controller});
  final TipoAcaoController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const espacamento = FenixVisualTokens.space12;
        final colunas = constraints.maxWidth >= 720 ? 3 : 1;
        final largura =
            (constraints.maxWidth - (espacamento * (colunas - 1))) / colunas;

        return Wrap(
          spacing: espacamento,
          runSpacing: espacamento,
          children: [
            SizedBox(
              width: largura,
              child: _Indicador(
                key: const ValueKey('tipo-acao-total'),
                titulo: 'Total cadastrado',
                valor: controller.total.toString(),
                icon: Icons.category_outlined,
                cor: FenixVisualTokens.navy,
              ),
            ),
            SizedBox(
              width: largura,
              child: _Indicador(
                key: const ValueKey('tipo-acao-ativos'),
                titulo: 'Ativos',
                valor: controller.totalAtivos.toString(),
                icon: Icons.check_circle_outline,
                cor: FenixVisualTokens.success,
              ),
            ),
            SizedBox(
              width: largura,
              child: _Indicador(
                key: const ValueKey('tipo-acao-inativos'),
                titulo: 'Inativos',
                valor: controller.totalInativos.toString(),
                icon: Icons.pause_circle_outline,
                cor: FenixVisualTokens.warning,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Indicador extends StatelessWidget {
  const _Indicador({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icon,
    required this.cor,
  });

  final String titulo;
  final String valor;
  final IconData icon;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(FenixVisualTokens.space16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: cor.withValues(alpha: 0.12),
              child: Icon(icon, color: cor),
            ),
            const SizedBox(width: FenixVisualTokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    valor,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
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

class _FiltrosCatalogo extends StatelessWidget {
  const _FiltrosCatalogo({
    required this.controller,
    required this.buscaController,
    required this.onLimpar,
  });

  final TipoAcaoController controller;
  final TextEditingController buscaController;
  final VoidCallback onLimpar;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(FenixVisualTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const ValueKey('tipo-acao-busca'),
              controller: buscaController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar no catálogo',
                hintText: 'Nome, classificação ou material',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: controller.definirFiltroTexto,
            ),
            const SizedBox(height: FenixVisualTokens.space12),
            Wrap(
              spacing: FenixVisualTokens.space8,
              runSpacing: FenixVisualTokens.space8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _FiltroChip(
                  key: const ValueKey('filtro-todos'),
                  label: 'Todos',
                  selecionado:
                      controller.filtroStatus == TipoAcaoFiltroStatus.todos,
                  onSelected: () => controller
                      .definirFiltroStatus(TipoAcaoFiltroStatus.todos),
                ),
                _FiltroChip(
                  key: const ValueKey('filtro-ativos'),
                  label: 'Ativos',
                  selecionado:
                      controller.filtroStatus == TipoAcaoFiltroStatus.ativos,
                  onSelected: () => controller
                      .definirFiltroStatus(TipoAcaoFiltroStatus.ativos),
                ),
                _FiltroChip(
                  key: const ValueKey('filtro-inativos'),
                  label: 'Inativos',
                  selecionado:
                      controller.filtroStatus == TipoAcaoFiltroStatus.inativos,
                  onSelected: () => controller
                      .definirFiltroStatus(TipoAcaoFiltroStatus.inativos),
                ),
                if (controller.filtroTexto.isNotEmpty ||
                    controller.filtroStatus != TipoAcaoFiltroStatus.todos)
                  TextButton.icon(
                    key: const ValueKey('tipo-acao-limpar-filtros'),
                    onPressed: onLimpar,
                    icon: const Icon(Icons.filter_alt_off_outlined),
                    label: const Text('LIMPAR'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  const _FiltroChip({
    super.key,
    required this.label,
    required this.selecionado,
    required this.onSelected,
  });

  final String label;
  final bool selecionado;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selecionado,
      onSelected: (_) => onSelected(),
    );
  }
}

class _ConteudoCatalogo extends StatelessWidget {
  const _ConteudoCatalogo({
    required this.controller,
    required this.onEditar,
    required this.onAlterarStatus,
  });

  final TipoAcaoController controller;
  final ValueChanged<TipoAcaoModel> onEditar;
  final ValueChanged<TipoAcaoModel> onAlterarStatus;

  @override
  Widget build(BuildContext context) {
    if (controller.carregando && controller.tipos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.erro != null && controller.tipos.isEmpty) {
      return const _EstadoVazio(
        icon: Icons.cloud_off_outlined,
        titulo: 'Não foi possível carregar o catálogo',
        mensagem: 'Verifique a conexão e tente novamente.',
      );
    }

    if (controller.tipos.isEmpty) {
      return const _EstadoVazio(
        icon: Icons.category_outlined,
        titulo: 'Nenhum tipo de ação cadastrado',
        mensagem: 'Use “Novo tipo” para iniciar o catálogo administrativo.',
      );
    }

    final itens = controller.tiposFiltrados;
    if (itens.isEmpty) {
      return const _EstadoVazio(
        icon: Icons.search_off_rounded,
        titulo: 'Nenhum resultado encontrado',
        mensagem: 'Revise o texto pesquisado ou os filtros selecionados.',
      );
    }

    return Column(
      children: [
        for (final tipo in itens) ...[
          _TipoAcaoCard(
            tipo: tipo,
            salvando: controller.salvando,
            onEditar: () => onEditar(tipo),
            onAlterarStatus: () => onAlterarStatus(tipo),
          ),
          const SizedBox(height: FenixVisualTokens.space12),
        ],
      ],
    );
  }
}

class _TipoAcaoCard extends StatelessWidget {
  const _TipoAcaoCard({
    required this.tipo,
    required this.salvando,
    required this.onEditar,
    required this.onAlterarStatus,
  });

  final TipoAcaoModel tipo;
  final bool salvando;
  final VoidCallback onEditar;
  final VoidCallback onAlterarStatus;

  @override
  Widget build(BuildContext context) {
    final cor =
        tipo.ativo ? FenixVisualTokens.success : FenixVisualTokens.warning;
    return Card(
      key: ValueKey('tipo-acao-${tipo.id}'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(FenixVisualTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: cor.withValues(alpha: 0.12),
                  child: Icon(
                    tipo.ativo ? Icons.check_rounded : Icons.pause_rounded,
                    color: cor,
                  ),
                ),
                const SizedBox(width: FenixVisualTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tipo.nomeAcao,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: FenixVisualTokens.space4),
                      Text(tipo.tipoAcao),
                    ],
                  ),
                ),
                _StatusPill(ativo: tipo.ativo),
              ],
            ),
            const SizedBox(height: FenixVisualTokens.space12),
            Wrap(
              spacing: FenixVisualTokens.space8,
              runSpacing: FenixVisualTokens.space8,
              children: [
                _InfoPill(
                  icon: Icons.groups_2_outlined,
                  label: 'Estimado: ${tipo.publicoEstimadoPadrao}',
                ),
                _InfoPill(
                  icon: Icons.group_outlined,
                  label: 'Mínimo: ${tipo.publicoMinimoPadrao}',
                ),
                if (tipo.materiaisSugeridos.isNotEmpty)
                  _InfoPill(
                    icon: Icons.inventory_2_outlined,
                    label: '${tipo.materiaisSugeridos.length} material(is)',
                  ),
              ],
            ),
            if (tipo.materiaisSugeridos.isNotEmpty) ...[
              const SizedBox(height: FenixVisualTokens.space8),
              Text(
                tipo.materiaisSugeridos.join(' • '),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: FenixVisualTokens.space12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: FenixVisualTokens.space8,
              runSpacing: FenixVisualTokens.space8,
              children: [
                OutlinedButton.icon(
                  key: ValueKey('tipo-acao-editar-${tipo.id}'),
                  onPressed: salvando ? null : onEditar,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('EDITAR'),
                ),
                FilledButton.tonalIcon(
                  key: ValueKey('tipo-acao-status-${tipo.id}'),
                  onPressed: salvando ? null : onAlterarStatus,
                  icon: Icon(tipo.ativo
                      ? Icons.pause_outlined
                      : Icons.play_arrow_rounded),
                  label: Text(tipo.ativo ? 'INATIVAR' : 'ATIVAR'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.ativo});
  final bool ativo;

  @override
  Widget build(BuildContext context) {
    final cor = ativo ? FenixVisualTokens.success : FenixVisualTokens.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        ativo ? 'ATIVO' : 'INATIVO',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cor,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: FenixVisualTokens.navyLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: FenixVisualTokens.navy),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _AvisoErro extends StatelessWidget {
  const _AvisoErro({required this.mensagem, required this.onTentarNovamente});
  final String mensagem;
  final Future<void> Function() onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FenixVisualTokens.danger.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(FenixVisualTokens.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.all(FenixVisualTokens.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: FenixVisualTokens.danger,
                ),
                const SizedBox(width: FenixVisualTokens.space8),
                Expanded(child: Text(mensagem)),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onTentarNovamente,
                child: const Text('TENTAR NOVAMENTE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio({
    required this.icon,
    required this.titulo,
    required this.mensagem,
  });

  final IconData icon;
  final String titulo;
  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(icon, size: 52, color: FenixVisualTokens.mutedText),
          const SizedBox(height: FenixVisualTokens.space12),
          Text(titulo, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: FenixVisualTokens.space4),
          Text(mensagem, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
