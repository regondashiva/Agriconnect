import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/order_model.dart';

class OrderTimelineWidget extends StatelessWidget {
  final List<TimelineStep> steps;

  const OrderTimelineWidget({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Indicator Column
            Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: step.isCompleted
                        ? AppColors.primary
                        : step.isCurrent
                            ? AppColors.harvestOrange
                            : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: step.isCompleted
                          ? AppColors.primary
                          : step.isCurrent
                              ? AppColors.harvestOrange
                              : AppColors.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: step.isCompleted
                        ? const Icon(Icons.check, size: 15, color: Colors.white)
                        : step.isCurrent
                            ? const Icon(Icons.circle, size: 8, color: Colors.white)
                            : Container(),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2.5,
                    height: 44,
                    color: step.isCompleted ? AppColors.primary : AppColors.outlineVariant,
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Right Step Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            step.title,
                            style: AppTypography.headlineSmall.copyWith(
                              fontSize: 14.5,
                              color: step.isCompleted || step.isCurrent
                                  ? AppColors.textNavy
                                  : AppColors.textMuted,
                              fontWeight: step.isCurrent ? FontWeight.w700 : FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (step.isCurrent) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.harvestOrangeLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'CURRENT',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.harvestOrangeDark,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step.subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
