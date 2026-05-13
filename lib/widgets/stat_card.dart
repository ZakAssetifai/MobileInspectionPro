import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color iconBg;
  final Color iconFg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration:
                BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconFg, size: 18),
          ),
          const SizedBox(height: 14),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7)),
        ],
      ),
    );
  }
}
