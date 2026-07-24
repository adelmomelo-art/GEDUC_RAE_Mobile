import 'package:flutter/material.dart';

import 'dashboard_colors.dart';
import 'dashboard_radius.dart';
import 'dashboard_spacing.dart';
import 'dashboard_theme.dart';

class DashboardPanel extends StatelessWidget {
  const DashboardPanel({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(DashboardSpacing.lg),
    this.backgroundColor = DashboardColors.panelBackground,
    this.gradient,
    this.borderColor = DashboardColors.border,
    this.borderRadius = DashboardRadius.large,
    this.boxShadow,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Gradient? gradient;
  final Color borderColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? backgroundColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
        boxShadow: boxShadow ?? DashboardTheme.panelShadow,
      ),
      child: child,
    );
  }
}
