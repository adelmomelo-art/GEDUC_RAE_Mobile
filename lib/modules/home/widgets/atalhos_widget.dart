import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/security/authorization_service.dart';
import '../../../core/security/permission.dart';
import '../../acoes/controllers/acao_controller.dart';
import '../theme/home_visual_tokens.dart';

class AtalhosWidget extends StatelessWidget {
  const AtalhosWidget({super.key});

  Future<void> _abrirNovaAcao(BuildContext context) async {
    final acaoController = context.read<AcaoController>();

    if (!acaoController.possuiRascunhoEmAndamento) {
      acaoController.criarRascunhoInicial();
      context.push('/nova-acao');
      return;
    }

    final escolha = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Existe um rascunho em andamento'),
        content: const Text(
          'Você deseja continuar o rascunho atual ou iniciar uma nova ação?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'continuar'),
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'nova'),
            child: const Text('Nova ação'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;

    if (escolha == 'continuar') {
      context.push(acaoController.rotaContinuacaoRascunho);
      return;
    }

    if (escolha == 'nova') {
      await acaoController.descartarRascunho();
      acaoController.criarRascunhoInicial();
      if (context.mounted) context.push('/nova-acao');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authorizationService = context.watch<AuthorizationService>();
    final podeAcessarAdministracao = authorizationService.possuiPermissao(
      Permission.acessarAdministracao,
    );

    final principais = <_AtalhoItem>[
      _AtalhoItem(
        icon: Icons.add_rounded,
        title: 'Nova Ação',
        subtitle: 'Registrar atividade',
        color: HomeVisualTokens.orange,
        onTap: () => _abrirNovaAcao(context),
      ),
      _AtalhoItem(
        icon: Icons.search_rounded,
        title: 'Consultar RAE',
        subtitle: 'Localizar registros',
        color: HomeVisualTokens.teal,
        onTap: () => context.push('/consulta-rae'),
      ),
    ];

    final secundarios = <_AtalhoItem>[
      _AtalhoItem(
        icon: Icons.dashboard_rounded,
        title: 'Dashboard',
        color: HomeVisualTokens.teal,
        onTap: () => context.push('/dashboard'),
      ),
      _AtalhoItem(
        icon: Icons.analytics_rounded,
        title: 'BI GEDUC',
        color: HomeVisualTokens.blue,
        onTap: () => context.push('/bi-geduc'),
      ),
      _AtalhoItem(
        icon: Icons.cloud_sync_rounded,
        title: 'Offline',
        color: HomeVisualTokens.blue,
        onTap: () => context.push('/sincronizacao'),
      ),
      if (podeAcessarAdministracao)
        _AtalhoItem(
          icon: Icons.admin_panel_settings_rounded,
          title: 'Administração',
          color: HomeVisualTokens.navy,
          onTap: () => context.push('/admin'),
        ),
    ];

    return _HomeSection(
      icon: Icons.bolt_rounded,
      title: 'O que você precisa fazer?',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final primaryColumns =
              constraints.maxWidth < HomeVisualTokens.compactBreakpoint ? 1 : 2;
          final secondaryColumns =
              constraints.maxWidth >= HomeVisualTokens.tabletBreakpoint ? 4 : 2;

          return Column(
            children: [
              _ResponsiveActionGrid(
                items: principais,
                columns: primaryColumns,
                primary: true,
              ),
              const SizedBox(height: HomeVisualTokens.space12),
              _ResponsiveActionGrid(
                items: secundarios,
                columns: secondaryColumns,
                primary: false,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HomeSection extends StatelessWidget {
  const _HomeSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: HomeVisualTokens.surface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: HomeVisualTokens.border),
        borderRadius: BorderRadius.circular(HomeVisualTokens.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(HomeVisualTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: HomeVisualTokens.teal),
                const SizedBox(width: HomeVisualTokens.space8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: HomeVisualTokens.text,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: HomeVisualTokens.space12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ResponsiveActionGrid extends StatelessWidget {
  const _ResponsiveActionGrid({
    required this.items,
    required this.columns,
    required this.primary,
  });

  final List<_AtalhoItem> items;
  final int columns;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    const spacing = HomeVisualTokens.space12;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: primary
                    ? _PrimaryAction(item: item)
                    : _SecondaryAction(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.item});

  final _AtalhoItem item;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: item.title,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(HomeVisualTokens.radiusMedium),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                item.color,
                Color.lerp(item.color, Colors.black, 0.10)!,
              ],
            ),
            borderRadius: BorderRadius.circular(HomeVisualTokens.radiusMedium),
          ),
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(HomeVisualTokens.radiusMedium),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: HomeVisualTokens.primaryActionMinHeight,
              ),
              padding: const EdgeInsets.all(HomeVisualTokens.space16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        HomeVisualTokens.radiusSmall,
                      ),
                    ),
                    child: Icon(item.icon, color: item.color, size: 28),
                  ),
                  const SizedBox(width: HomeVisualTokens.space12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: HomeVisualTokens.space4),
                          Text(
                            item.subtitle!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.84),
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({required this.item});

  final _AtalhoItem item;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: item.title,
      child: Material(
        color: HomeVisualTokens.surface,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: HomeVisualTokens.border),
          borderRadius: BorderRadius.circular(HomeVisualTokens.radiusMedium),
        ),
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(HomeVisualTokens.radiusMedium),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: HomeVisualTokens.secondaryActionMinHeight,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: HomeVisualTokens.space8,
              vertical: HomeVisualTokens.space12,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: item.color, size: 26),
                const SizedBox(height: HomeVisualTokens.space8),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: HomeVisualTokens.text,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AtalhoItem {
  const _AtalhoItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
}
