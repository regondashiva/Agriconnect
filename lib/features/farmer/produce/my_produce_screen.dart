import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_chip.dart';

class MyProduceScreen extends StatelessWidget {
  final AppState appState;

  const MyProduceScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final listings = appState.produceList;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Produce Listings'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/farmer/add-produce'),
            icon: const Icon(Icons.add_circle, color: AppColors.primary),
            tooltip: 'Add Produce',
          ),
        ],
      ),
      body: listings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text("You haven't listed any produce yet.", style: AppTypography.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/farmer/add-produce'),
                    child: const Text('+ List Produce'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final item = listings[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    onTap: () {
                      Navigator.pushNamed(context, '/farmer/produce/detail');
                    },
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.cropName,
                              style: AppTypography.headlineSmall.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            StatusChip.success(item.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.quantityKg.toInt()} kg • ${item.gradeLabel} • Available in 1 day',
                          style: AppTypography.bodySmall.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'AI Quality: ${item.qualityScore.toInt()}/100',
                                    style: AppTypography.labelSmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${item.photoCount} photos attached',
                                style: AppTypography.bodySmall.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'View AI Assessment & Matches →',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
