import 'package:flutter/material.dart';

import 'dashboard_spacing.dart';

class DashboardSection extends StatelessWidget {
  const DashboardSection({
    required this.child,
    super.key,
    this.bottomSpacing = DashboardSpacing.md,
  });

  final Widget child;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: child,
    );
  }
}
