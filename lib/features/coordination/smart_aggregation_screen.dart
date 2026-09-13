import 'package:flutter/material.dart';
import '../../models/match_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../services/app_state.dart';
import '../../shared/widgets/app_buttons.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/status_chip.dart';

class SmartAggregationScreen extends StatelessWidget {
  final AppState appState;

  const SmartAggregationScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final match = appState.activeMatch;
    final currentFarmerName = appState.currentUser.name.trim().isNotEmpty
        ? appState.currentUser.name.trim()
        : 'Your Farm';
    final currentProduce = appState.produceList.isNotEmpty ? appState.produceList.first : null;
    final double userQty = currentProduce?.availableQuantityKg ?? 100.0;
    final double userPrice = currentProduce?.expectedPricePerKg ?? 20.0;

    final List<SupplyContributor> contributors = (match != null && match.contributors.isNotEmpty)
        ? match.contributors
        : [
            SupplyContributor(
              farmerId: appState.currentUser.id.isNotEmpty ? appState.currentUser.id : 'usr_farmer_me',
              farmerName: '$currentFarmerName (You)',
              location: appState.currentUser.location.isNotEmpty ? appState.currentUser.location : 'Chevella Village',
              quantityKg: userQty,
              payoutAmount: userQty * userPrice,
            ),
            const SupplyContributor(
              farmerId: 'partner_01',
              farmerName: 'Cluster Partner Farm 1',
              location: 'Shabad Center',
              quantityKg: 150.0,
              payoutAmount: 3000.0,
            ),
            const SupplyContributor(
              farmerId: 'partner_02',
              farmerName: 'Cluster Partner Farm 2',
              location: 'Moinabad Cluster',
              quantityKg: 250.0,
              payoutAmount: 5000.0,
            ),
          ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Smart Supply Aggregation'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Aggregation Status Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.secondaryContainer),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bulk Requirement Fulfilled (100%)',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Aggregated across 3 verified smallholder farmers within 15 km cluster.',
                            style: AppTypography.bodySmall.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Buyer Demand Spec
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Buyer Demand Order', style: AppTypography.labelLarge),
                        StatusChip.info('500 kg Required'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('🍅', style: TextStyle(fontSize: 22)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tomato (Grade A)',
                                style: AppTypography.headlineSmall.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text('Buyer: FreshBasket Mandi, Kothapet', style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: const LinearProgressIndicator(
                        value: 1.0,
                        minHeight: 10,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Aggregated Supply: 500 / 500 kg', style: AppTypography.labelSmall),
                        Text('100% Target Met', style: AppTypography.labelSmall.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Participating Farmer Supplies',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Individual lots verified for cluster pickup.',
                style: AppTypography.bodySmall,
              ),

              const SizedBox(height: 12),

              ...contributors.map((contributor) {
                final isCurrent = contributor.farmerName.contains('(You)') ||
                    contributor.farmerId == appState.currentUser.id ||
                    (currentFarmerName.isNotEmpty && contributor.farmerName.toLowerCase().contains(currentFarmerName.toLowerCase()));
                final initial = contributor.farmerName.trim().isNotEmpty ? contributor.farmerName.trim()[0].toUpperCase() : 'F';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    backgroundColor: isCurrent ? AppColors.surfaceContainerLow : Colors.white,
                    borderColor: isCurrent ? AppColors.primary : AppColors.surfaceContainerHigh,
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: isCurrent ? AppColors.primary : AppColors.surfaceContainer,
                          child: Text(
                            initial,
                            style: TextStyle(
                              color: isCurrent ? Colors.white : AppColors.textNavy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    contributor.farmerName,
                                    style: AppTypography.labelLarge.copyWith(
                                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                                      color: isCurrent ? AppColors.primary : AppColors.textNavy,
                                    ),
                                  ),
                                  if (isCurrent) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('YOU', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${contributor.location} • Grade A Assessed',
                                style: AppTypography.bodySmall.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${contributor.quantityKg.toInt()} kg',
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '₹${contributor.payoutAmount.toInt()}',
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              PrimaryButton(
                text: 'CONTINUE TO QUALITY EVIDENCE',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  Navigator.pushNamed(context, '/coordination/quality');
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
