import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/models/usuario_model.dart';
import '../../acoes/controllers/acao_controller.dart';

class AtalhosWidget extends StatelessWidget {
  final UsuarioModel? usuario;

  const AtalhosWidget({
    super.key,
    required this.usuario,
  });

  Future<void> _abrirNovaAcao(BuildContext context) async {
    final acaoController = context.read<AcaoController>();

    if (!acaoController.possuiRascunhoEmAndamento) {
      acaoController.criarRascunhoInicial();
      context.push('/nova-acao');
      return;
    }

    final escolha = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Existe um rascunho em andamento'),
          content: const Text(
            'Você deseja continuar o rascunho atual ou iniciar uma nova ação?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'continuar'),
              child: const Text('Continuar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'nova'),
              child: const Text('Nova ação'),
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;

    if (escolha == 'continuar') {
      context.push(acaoController.rotaContinuacaoRascunho);
      return;
    }

    if (escolha == 'nova') {
      await acaoController.descartarRascunho();
      acaoController.criarRascunhoInicial();

      if (!context.mounted) return;

      context.push('/nova-acao');
    }
  }

  @override
  Widget build(BuildContext context) {
    final atalhos = <_AtalhoItem>[
      _AtalhoItem(
        icon: Icons.add_rounded,
        titulo: 'Nova Ação',
        destaque: true,
        onTap: () => _abrirNovaAcao(context),
      ),
      _AtalhoItem(
        icon: Icons.search_rounded,
        titulo: 'Consulta RAE',
        destaque: true,
        onTap: () => context.push('/consulta-rae'),
      ),
      _AtalhoItem(
        icon: Icons.dashboard_rounded,
        titulo: 'Dashboard',
        onTap: () => context.push('/dashboard'),
      ),
      _AtalhoItem(
        icon: Icons.analytics_rounded,
        titulo: 'BI GEDUC',
        onTap: () => context.push('/bi-geduc'),
      ),
      _AtalhoItem(
        icon: Icons.cloud_sync_rounded,
        titulo: 'Offline',
        onTap: () => context.push('/sincronizacao'),
      ),
      if (usuario?.perfilAcesso == 'administrador' ||
          usuario?.perfilAcesso == 'gestor')
        _AtalhoItem(
          icon: Icons.admin_panel_settings_rounded,
          titulo: 'Administração',
          onTap: () => context.push('/admin'),
        ),
    ];

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.grid_view_rounded,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Acessos Rápidos',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                const columns = 3;
                const spacing = 12.0;

                final itemWidth =
                    (constraints.maxWidth - (spacing * (columns - 1))) /
                        columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final atalho in atalhos)
                      SizedBox(
                        width: itemWidth,
                        child: _AtalhoCard(item: atalho),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AtalhoCard extends StatelessWidget {
  final _AtalhoItem item;

  const _AtalhoCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final backgroundColor = item.destaque
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.55);

    final foregroundColor =
        item.destaque ? colorScheme.onPrimary : colorScheme.primary;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 108,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: item.destaque
                ? null
                : Border.all(
                    color: colorScheme.outlineVariant,
                  ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 34,
                color: foregroundColor,
              ),
              const SizedBox(height: 10),
              Text(
                item.titulo,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AtalhoItem {
  final IconData icon;
  final String titulo;
  final VoidCallback onTap;
  final bool destaque;

  const _AtalhoItem({
    required this.icon,
    required this.titulo,
    required this.onTap,
    this.destaque = false,
  });
}
