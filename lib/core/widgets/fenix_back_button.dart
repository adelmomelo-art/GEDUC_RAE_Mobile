import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Botão padronizado de retorno da Plataforma Fênix.
///
/// Regras:
/// 1. Quando existe uma página anterior válida, retorna para ela.
/// 2. Quando não existe histórico de navegação, direciona para a rota segura.
/// 3. Nunca executa logout nem direciona diretamente para a tela de login.
///
/// Exemplo:
///
/// ```dart
/// FenixBackButton(
///   fallbackRoute: '/centro-operacoes-educativas',
/// )
/// ```
class FenixBackButton extends StatelessWidget {
  const FenixBackButton({
    required this.fallbackRoute,
    super.key,
    this.preferPreviousPage = true,
    this.icon,
    this.tooltip = 'Voltar',
    this.color,
    this.size = 24,
    this.onBeforeBack,
  });

  /// Rota segura utilizada quando não há uma página anterior disponível.
  ///
  /// Recomenda-se utilizar a rota do Centro de Operações Educativas.
  final String fallbackRoute;

  /// Quando verdadeiro, tenta retornar para a tela anterior antes de utilizar
  /// a rota segura.
  final bool preferPreviousPage;

  /// Ícone personalizado.
  final Widget? icon;

  /// Texto exibido ao manter o cursor sobre o botão.
  final String tooltip;

  /// Cor do ícone.
  final Color? color;

  /// Tamanho do ícone padrão.
  final double size;

  /// Callback opcional executado antes da navegação.
  ///
  /// Retorne `false` para cancelar o retorno. Pode ser utilizado para confirmar
  /// o descarte de alterações não salvas.
  final Future<bool> Function()? onBeforeBack;

  Future<void> _handleBack(BuildContext context) async {
    final canContinue = await onBeforeBack?.call() ?? true;

    if (!canContinue || !context.mounted) {
      return;
    }

    if (preferPreviousPage && context.canPop()) {
      context.pop();
      return;
    }

    context.go(fallbackRoute);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: () => _handleBack(context),
      icon: icon ??
          Icon(
            Icons.arrow_back_rounded,
            color: color,
            size: size,
          ),
    );
  }
}
