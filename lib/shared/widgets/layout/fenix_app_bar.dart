import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FenixAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FenixAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.showBackButton = true,
    this.fallbackRoute = '/home',
    this.onBack,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = false,
    this.elevation = 0,
  });

  final String title;
  final List<Widget> actions;
  final bool showBackButton;
  final String fallbackRoute;
  final VoidCallback? onBack;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool centerTitle;
  final double elevation;

  static void navigateBack(
    BuildContext context, {
    String fallbackRoute = '/home',
    VoidCallback? onBack,
  }) {
    if (onBack != null) {
      onBack();
      return;
    }

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(fallbackRoute);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              tooltip: 'Voltar',
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => navigateBack(
                context,
                fallbackRoute: fallbackRoute,
                onBack: onBack,
              ),
            )
          : null,
      title: Text(title),
      actions: actions,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      centerTitle: centerTitle,
      elevation: elevation,
    );
  }
}
