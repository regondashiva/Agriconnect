import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  factory StatusChip.success(String label) {
    return StatusChip(
      label: label,
      backgroundColor: AppColors.successLight,
      textColor: AppColors.success,
      icon: Icons.check_circle_outline,
    );
  }

  factory StatusChip.green(String label) {
    return StatusChip(
      label: label,
      backgroundColor: AppColors.successLight,
      textColor: AppColors.success,
      icon: Icons.check_circle_outline,
    );
  }

  factory StatusChip.warning(String label) {
    return StatusChip(
      label: label,
      backgroundColor: AppColors.warningLight,
      textColor: AppColors.warning,
      icon: Icons.access_time,
    );
  }

  factory StatusChip.info(String label) {
    return StatusChip(
      label: label,
      backgroundColor: AppColors.infoLight,
      textColor: AppColors.info,
      icon: Icons.info_outline,
    );
  }

  factory StatusChip.orange(String label) {
    return StatusChip(
      label: label,
      backgroundColor: AppColors.harvestOrangeLight,
      textColor: AppColors.harvestOrangeDark,
      icon: Icons.bolt,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.secondaryLight;
    final txt = textColor ?? AppColors.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: txt),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: txt,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
