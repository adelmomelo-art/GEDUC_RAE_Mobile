import 'package:flutter/material.dart';

import '../../core/navigation/navigation_manager.dart';
import 'domain/admin_module_catalog.dart';
import 'widgets/admin_module_card.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const modulos = AdminModuleCatalog.modulos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administração'),
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: () => NavigationManager.backOrCentro(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: _AdminHeader(totalModulos: modulos.length),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final largura = constraints.crossAxisExtent;
                final colunas = largura >= 1100
                    ? 3
                    : largura >= 700
                        ? 2
                        : 1;

                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: colunas,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 220,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final modulo = modulos[index];

                      return AdminModuleCard(
                        modulo: modulo,
                        onTap: modulo.permiteNavegacao
                            ? () => NavigationManager.push<void>(
                                  context,
                                  modulo.rota,
                                )
                            : null,
                      );
                    },
                    childCount: modulos.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  final int totalModulos;

  const _AdminHeader({required this.totalModulos});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 26,
              child: Icon(
                Icons.admin_panel_settings_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fundação Administrativa',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Acesso centralizado aos módulos de parametrização e governança da Plataforma Fênix.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$totalModulos módulos catalogados',
                    style: theme.textTheme.labelLarge,
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
