import 'package:flutter/material.dart';

import '../../../core/theme/fenix_visual_tokens.dart';

/// Shell responsivo compartilhado para páginas da Plataforma Fênix.
///
/// O widget não decide a navegação nem impõe rolagem ao conteúdo. Cada jornada
/// continua responsável pelo seu estado e pela estratégia de scroll.
class FenixPageScaffold extends StatelessWidget {
  const FenixPageScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.padding,
    this.maxContentWidth = FenixVisualTokens.contentMaxWidth,
    this.useSafeArea = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry? padding;
  final double maxContentWidth;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    final pageBody = LayoutBuilder(
      builder: (context, constraints) {
        final horizontal =
            constraints.maxWidth < FenixVisualTokens.compactBreakpoint
            ? FenixVisualTokens.space12
            : FenixVisualTokens.space16;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding:
                  padding ??
                  EdgeInsets.fromLTRB(
                    horizontal,
                    FenixVisualTokens.space16,
                    horizontal,
                    FenixVisualTokens.space24,
                  ),
              child: body,
            ),
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: FenixVisualTokens.canvas,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: useSafeArea ? SafeArea(child: pageBody) : pageBody,
    );
  }
}
