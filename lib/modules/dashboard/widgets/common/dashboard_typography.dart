import 'package:flutter/material.dart';

import 'dashboard_colors.dart';

abstract final class DashboardTypography {
  static const TextStyle panelTitle = TextStyle(
    color: DashboardColors.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle panelSubtitle = TextStyle(
    color: Colors.black54,
    fontSize: 10,
  );

  static const TextStyle body = TextStyle(
    color: DashboardColors.textSecondary,
    fontSize: 11,
    height: 1.35,
  );

  static const TextStyle infoValue = TextStyle(
    color: DashboardColors.textPrimary,
    fontSize: 11,
    fontWeight: FontWeight.w800,
  );
}
