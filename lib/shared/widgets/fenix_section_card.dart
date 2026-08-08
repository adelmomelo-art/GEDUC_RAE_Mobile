import 'package:flutter/material.dart';

import '../../core/theme/fenix_visual_tokens.dart';

class FenixSectionCard extends StatelessWidget {
  const FenixSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(FenixVisualTokens.space16),
    this.backgroundColor = FenixVisualTokens.surface,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(FenixVisualTokens.radiusMedium),
        border: Border.all(color: FenixVisualTokens.border),
        boxShadow: FenixVisualTokens.softShadow,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
