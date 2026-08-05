import 'package:flutter/material.dart';

import '../../../data/models/usuario_model.dart';
import '../theme/home_visual_tokens.dart';

class CentroOperacoesHeader extends StatelessWidget {
  const CentroOperacoesHeader({
    super.key,
    required this.usuario,
    required this.onAtualizar,
    required this.onSair,
  });

  final UsuarioModel? usuario;
  final VoidCallback onAtualizar;
  final VoidCallback onSair;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(HomeVisualTokens.space16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(HomeVisualTokens.radiusLarge),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HomeVisualTokens.headerOrangeStart,
            HomeVisualTokens.headerOrangeEnd,
          ],
        ),
        boxShadow: HomeVisualTokens.softShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact =
              constraints.maxWidth < HomeVisualTokens.headerCompactBreakpoint;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompact)
                _CompactHeaderTop(
                  onAtualizar: onAtualizar,
                  onSair: onSair,
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: _IdentidadeInstitucional()),
                    const SizedBox(width: HomeVisualTokens.space12),
                    _HeaderActions(
                      onAtualizar: onAtualizar,
                      onSair: onSair,
                    ),
                  ],
                ),
              if (isCompact) ...[
                const SizedBox(height: HomeVisualTokens.space12),
                const _InstitutionalText(),
              ],
              const SizedBox(height: HomeVisualTokens.space12),
              Text(
                'Bem-vindo, ${_nomeUsuario()}.',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: HomeVisualTokens.space4),
              Text(
                'Seu centro de trabalho está pronto.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.86),
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _nomeUsuario() {
    final nome = usuario?.nome.trim();
    if (nome == null || nome.isEmpty) return 'usuário';
    return nome.split(RegExp(r'\s+')).first;
  }
}

class _IdentidadeInstitucional extends StatelessWidget {
  const _IdentidadeInstitucional();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InstitutionalAvatar(),
        SizedBox(width: HomeVisualTokens.space12),
        Expanded(child: _InstitutionalText()),
      ],
    );
  }
}

class _CompactHeaderTop extends StatelessWidget {
  const _CompactHeaderTop({
    required this.onAtualizar,
    required this.onSair,
  });

  final VoidCallback onAtualizar;
  final VoidCallback onSair;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _InstitutionalAvatar(),
        const Spacer(),
        _HeaderActions(
          onAtualizar: onAtualizar,
          onSair: onSair,
        ),
      ],
    );
  }
}

class _InstitutionalAvatar extends StatelessWidget {
  const _InstitutionalAvatar();

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 22,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.hub_outlined,
        size: 25,
        color: HomeVisualTokens.orange,
      ),
    );
  }
}

class _InstitutionalText extends StatelessWidget {
  const _InstitutionalText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Centro de Operações Educativas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
        ),
        const SizedBox(height: HomeVisualTokens.space4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(HomeVisualTokens.radiusSmall),
          ),
          child: Text(
            'Plataforma Fênix • GEDUC',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: HomeVisualTokens.navy,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _HeaderActions extends StatelessWidget {
  const _HeaderActions({
    required this.onAtualizar,
    required this.onSair,
  });

  final VoidCallback onAtualizar;
  final VoidCallback onSair;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeaderAction(
          tooltip: 'Atualizar informações',
          semanticLabel: 'Atualizar a Home',
          icon: Icons.refresh_rounded,
          onPressed: onAtualizar,
        ),
        const SizedBox(width: HomeVisualTokens.space8),
        _HeaderAction(
          tooltip: 'Sair da plataforma',
          semanticLabel: 'Sair da plataforma',
          icon: Icons.logout_rounded,
          onPressed: onSair,
          highlighted: true,
        ),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.tooltip,
    required this.semanticLabel,
    required this.icon,
    required this.onPressed,
    this.highlighted = false,
  });

  final String tooltip;
  final String semanticLabel;
  final IconData icon;
  final VoidCallback onPressed;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color:
              highlighted ? HomeVisualTokens.charcoal : HomeVisualTokens.navy,
          borderRadius: BorderRadius.circular(HomeVisualTokens.radiusSmall),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(HomeVisualTokens.radiusSmall),
            child: SizedBox.square(
              dimension: HomeVisualTokens.minTouchTarget,
              child: Icon(icon, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
