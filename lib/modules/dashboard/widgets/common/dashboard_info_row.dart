import 'package:flutter/material.dart';

import 'dashboard_colors.dart';
import 'dashboard_spacing.dart';
import 'dashboard_typography.dart';

class DashboardInfoRow extends StatelessWidget {
  const DashboardInfoRow({
    required this.title,
    required this.value,
    super.key,
    this.icon,
    this.valueColor = DashboardColors.textPrimary,
  });

  final String title;
  final String value;
  final IconData? icon;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: Colors.black45),
          const SizedBox(width: DashboardSpacing.xs),
        ],
        Expanded(
          child: Text(title, style: DashboardTypography.body),
        ),
        const SizedBox(width: DashboardSpacing.md),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: DashboardTypography.infoValue.copyWith(color: valueColor),
          ),
        ),
      ],
    );
  }
}
