import 'package:flutter/material.dart';

import 'dashboard_spacing.dart';
import 'dashboard_typography.dart';

class DashboardEmptyState extends StatelessWidget {
  const DashboardEmptyState({
    required this.message,
    super.key,
    this.icon = Icons.inbox_outlined,
    this.height = 250,
  });

  final String message;
  final IconData icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DashboardSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 34, color: Colors.black38),
              const SizedBox(height: DashboardSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: DashboardTypography.body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
