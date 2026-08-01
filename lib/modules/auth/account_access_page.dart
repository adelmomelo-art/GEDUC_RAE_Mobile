import 'package:flutter/material.dart';

import '../../core/security/authorization_service.dart';
import '../../core/security/identity_status.dart';

class AccountAccessPage extends StatelessWidget {
  const AccountAccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authorizationService = AuthorizationService.instance;

    return ListenableBuilder(
      listenable: authorizationService,
      builder: (context, _) {
        final status = authorizationService.status;

        return Scaffold(
          backgroundColor: const Color(0xFFF3F7F7),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _icone(status),
                            size: 68,
                            color: _cor(status),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _titulo(status),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _mensagem(status),
                            textAlign: TextAlign.center,
                            style: const TextStyle(height: 1.45),
                          ),
                          const SizedBox(height: 24),
                          if (status == IdentityStatus.carregando)
                            const CircularProgressIndicator()
                          else ...[
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () => authorizationService.recarregar(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('TENTAR NOVAMENTE'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    authorizationService.encerrarSessao(),
                                icon: const Icon(Icons.logout),
                                label: const Text('SAIR'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _titulo(IdentityStatus status) {
    return switch (status) {
      IdentityStatus.carregando => 'Validando sua identidade',
      IdentityStatus.semCadastro => 'Cadastro operacional não localizado',
      IdentityStatus.inativo => 'Conta inativa',
      IdentityStatus.perfilInvalido => 'Perfil de acesso inválido',
      IdentityStatus.erro => 'Não foi possível validar o acesso',
      _ => 'Acesso indisponível',
    };
  }

  String _mensagem(IdentityStatus status) {
    return switch (status) {
      IdentityStatus.carregando =>
        'Aguarde enquanto a Plataforma Fênix confirma seu cadastro e suas permissões.',
      IdentityStatus.semCadastro =>
        'Sua autenticação foi confirmada, mas ainda não existe um cadastro operacional vinculado a esta conta. Procure a administração da plataforma.',
      IdentityStatus.inativo =>
        'Seu cadastro está inativo. Procure a administração da Plataforma Fênix para verificar a situação do acesso.',
      IdentityStatus.perfilInvalido =>
        'O perfil associado à conta não é reconhecido pela política de segurança. Procure a administração da plataforma.',
      IdentityStatus.erro =>
        'Ocorreu uma falha ao consultar sua identidade. Verifique a conexão e tente novamente.',
      _ => 'Esta conta não pode acessar os recursos da plataforma neste momento.',
    };
  }

  IconData _icone(IdentityStatus status) {
    return switch (status) {
      IdentityStatus.carregando => Icons.manage_accounts_outlined,
      IdentityStatus.semCadastro => Icons.person_search_outlined,
      IdentityStatus.inativo => Icons.person_off_outlined,
      IdentityStatus.perfilInvalido => Icons.admin_panel_settings_outlined,
      IdentityStatus.erro => Icons.cloud_off_outlined,
      _ => Icons.lock_outline,
    };
  }

  Color _cor(IdentityStatus status) {
    return switch (status) {
      IdentityStatus.carregando => const Color(0xFF007A78),
      IdentityStatus.erro => Colors.orange.shade800,
      _ => Colors.red.shade700,
    };
  }
}
