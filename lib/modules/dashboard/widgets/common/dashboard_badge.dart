import 'package:flutter/material.dart';

import 'dashboard_colors.dart';
import 'dashboard_radius.dart';
import 'dashboard_spacing.dart';

class DashboardBadge extends StatelessWidget {
  const DashboardBadge({
    required this.text,
    super.key,
    this.color = DashboardColors.primary,
    this.icon,
  });

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DashboardSpacing.xs,
        vertical: DashboardSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(DashboardRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: DashboardSpacing.xxs),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
