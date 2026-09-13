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
    final isLoading = appState.isLoading;

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
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => appState.fetchProduceList(),
        child: isLoading && listings.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : listings.isEmpty
                ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inventory_2_outlined,
                                size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text('No produce listed yet.',
                                style: AppTypography.bodyMedium),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/farmer/add-produce'),
                              child: const Text('+ List Produce'),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                            appState.setSelectedProduceItem(item);
                            Navigator.pushNamed(
                              context,
                              '/farmer/produce/detail',
                              arguments: item,
                            );
                          },
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _getProduceEmoji(item.cropName),
                                            style: const TextStyle(fontSize: 20),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.cropName,
                                            style: AppTypography.headlineSmall.copyWith(
                                                fontSize: 16, fontWeight: FontWeight.w700),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            item.variety,
                                            style: AppTypography.bodySmall.copyWith(
                                                fontSize: 12, color: AppColors.textMuted),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  StatusChip.success(item.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${item.quantityKg.toInt()} kg available • ${item.gradeLabel}',
                                style: AppTypography.bodySmall.copyWith(fontSize: 13),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      const Icon(Icons.auto_awesome,
                                          size: 14, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        'AI Quality: ${item.qualityScore.toStringAsFixed(1)}/100',
                                        style: AppTypography.labelSmall.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary),
                                      ),
                                    ]),
                                    Text(
                                      '₹${item.expectedPricePerKg.toStringAsFixed(0)} / kg',
                                      style: AppTypography.bodySmall.copyWith(
                                          fontSize: 12, fontWeight: FontWeight.w600),
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
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  String _getProduceEmoji(String cropName) {
    final lower = cropName.toLowerCase();
    if (lower.contains('tomato')) return '🍅';
    if (lower.contains('potato')) return '🥔';
    if (lower.contains('onion')) return '🧅';
    if (lower.contains('chilli') || lower.contains('pepper')) return '🌶️';
    if (lower.contains('capsicum')) return '🫑';
    if (lower.contains('wheat')) return '🌾';
    if (lower.contains('rice') || lower.contains('paddy')) return '🍚';
    return '🥬';
  }
}