import 'package:flutter/material.dart';

import '../domain/admin_module.dart';
import '../domain/admin_module_status.dart';

class AdminModuleCard extends StatelessWidget {
  final AdminModule modulo;
  final VoidCallback? onTap;

  const AdminModuleCard({
    super.key,
    required this.modulo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habilitado = modulo.permiteNavegacao && onTap != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: habilitado ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Icon(modulo.icone),
                  ),
                  const Spacer(),
                  _StatusBadge(status: modulo.status),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                modulo.titulo,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  modulo.descricao,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    habilitado ? 'Acessar módulo' : 'Acesso indisponível',
                    style: theme.textTheme.labelLarge,
                  ),
                  const Spacer(),
                  Icon(
                    habilitado ? Icons.arrow_forward : Icons.lock_outline,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AdminModuleStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          status.rotulo,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
