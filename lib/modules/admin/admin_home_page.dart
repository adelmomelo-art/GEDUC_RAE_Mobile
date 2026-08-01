import 'package:flutter/material.dart';

import '../../core/navigation/navigation_manager.dart';
import '../../core/security/authorization_service.dart';
import 'domain/admin_module.dart';
import 'domain/admin_module_catalog.dart';
import 'widgets/admin_module_card.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authorizationService = AuthorizationService.instance;

    return ListenableBuilder(
      listenable: authorizationService,
      builder: (context, child) {
        const modulos = AdminModuleCatalog.modulos;
        final modulosAutorizados = modulos
            .where(
              (modulo) => authorizationService.possuiPermissao(
                modulo.permissao,
              ),
            )
            .toList(growable: false);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Administração'),
            leading: IconButton(
              tooltip: 'Voltar',
              onPressed: () => NavigationManager.backOrCentro(context),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: _AdminBody(
            carregando: authorizationService.carregando,
            modulos: modulosAutorizados,
            perfilAcesso: authorizationService.perfilAtual,
          ),
        );
      },
    );
  }
}

class _AdminBody extends StatelessWidget {
  final bool carregando;
  final List<AdminModule> modulos;
  final String perfilAcesso;

  const _AdminBody({
    required this.carregando,
    required this.modulos,
    required this.perfilAcesso,
  });

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: _AdminHeader(
              totalModulos: modulos.length,
              perfilAcesso: perfilAcesso,
            ),
          ),
        ),
        if (modulos.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _SemModulosAutorizados(),
          )
        else
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
    );
  }
}

class _AdminHeader extends StatelessWidget {
  final int totalModulos;
  final String perfilAcesso;

  const _AdminHeader({
    required this.totalModulos,
    required this.perfilAcesso,
  });

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
                    'Acesso centralizado aos módulos autorizados para o perfil $perfilAcesso.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$totalModulos módulos autorizados',
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

class _SemModulosAutorizados extends StatelessWidget {
  const _SemModulosAutorizados();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Nenhum módulo administrativo está autorizado para o perfil atual.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
