import 'package:flutter/material.dart';

import 'dashboard_colors.dart';

abstract final class DashboardTheme {
  static List<BoxShadow> panelShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static EdgeInsets pagePadding(double width) {
    final horizontal = width >= 700 ? 24.0 : 14.0;
    return EdgeInsets.fromLTRB(horizontal, 16, horizontal, 28);
  }

  static ThemeData extend(ThemeData base) {
    return base.copyWith(
      scaffoldBackgroundColor: DashboardColors.pageBackground,
      colorScheme: base.colorScheme.copyWith(
        primary: DashboardColors.primary,
        secondary: DashboardColors.orange,
      ),
    );
  }
}
