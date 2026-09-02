import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class MatchScoreBadge extends StatelessWidget {
  final double scorePercent;
  final bool isLarge;

  const MatchScoreBadge({
    super.key,
    required this.scorePercent,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 14 : 10,
        vertical: isLarge ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(isLarge ? 24 : 16),
        border: Border.all(color: AppColors.secondary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: isLarge ? 18 : 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            '${scorePercent.toInt()}% Match',
            style: (isLarge ? AppTypography.labelLarge : AppTypography.labelSmall).copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class QualityScoreBadge extends StatelessWidget {
  final double qualityScore;
  final double confidenceScore;

  const QualityScoreBadge({
    super.key,
    required this.qualityScore,
    required this.confidenceScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 16, color: AppColors.secondary),
          const SizedBox(width: 6),
          Text(
            'Quality: ${qualityScore.toInt()}/100',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '(${confidenceScore.toInt()}% conf)',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
