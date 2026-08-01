import 'package:flutter/material.dart';

import '../../core/navigation/navigation_manager.dart';
import '../../core/security/authorization_service.dart';

class AccessDeniedPage extends StatelessWidget {
  const AccessDeniedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authorizationService = AuthorizationService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acesso não autorizado'),
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: () => NavigationManager.backOrCentro(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 64),
                    const SizedBox(height: 20),
                    Text(
                      'Você não possui permissão para acessar este módulo.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Perfil identificado: ${authorizationService.perfilAtual}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => NavigationManager.backOrCentro(context),
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Voltar ao Centro de Operações'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
