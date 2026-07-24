import 'package:flutter/material.dart';

import 'dashboard_colors.dart';
import 'dashboard_radius.dart';
import 'dashboard_spacing.dart';
import 'dashboard_typography.dart';

class DashboardTitle extends StatelessWidget {
  const DashboardTitle({
    required this.title,
    required this.icon,
    super.key,
    this.subtitle,
    this.iconColor = DashboardColors.primary,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(DashboardRadius.small),
          ),
          child: Icon(icon, color: iconColor, size: 21),
        ),
        const SizedBox(width: DashboardSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: DashboardTypography.panelTitle),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: DashboardTypography.panelSubtitle),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: DashboardSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}
