import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/match_score_badge.dart';

class FarmerMatchesScreen extends StatelessWidget {
  final AppState appState;

  const FarmerMatchesScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final currentFarmerName = appState.currentUser.name.trim().isNotEmpty
        ? appState.currentUser.name.trim()
        : 'Your Farm';

    final hasProduce = appState.produceList.isNotEmpty;
    final activeProduce = hasProduce ? appState.produceList.first : null;
    final String cropName = activeProduce?.cropName ?? 'Tomato';
    final String cropEmoji = cropName.toLowerCase().contains('onion')
        ? '🧅'
        : (cropName.toLowerCase().contains('potato')
            ? '🥔'
            : (cropName.toLowerCase().contains('chilli')
                ? '🌶️'
                : '🍅'));

    final double userQty = activeProduce != null ? activeProduce.availableQuantityKg : 100.0;
    final double pricePerKg = activeProduce != null ? activeProduce.expectedPricePerKg : 20.0;
    final double userPayout = userQty * pricePerKg;

    const double cluster1Qty = 150.0;
    final double cluster1Payout = cluster1Qty * pricePerKg;
    const double cluster2Qty = 250.0;
    final double cluster2Payout = cluster2Qty * pricePerKg;
    final double totalLot = userQty + cluster1Qty + cluster2Qty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buyer Opportunities'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Intelligent Buyer Matches',
              style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Aggregated demand opportunities based on your listed produce.',
              style: AppTypography.bodySmall,
            ),

            const SizedBox(height: 14),

            // Main Opportunity Card
            AppCard(
              borderColor: AppColors.primary,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Buyer Info & Match Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(cropEmoji, style: const TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FreshBasket Wholesale Mandi',
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Kothapet, Hyderabad (34 km)',
                              style: AppTypography.bodySmall.copyWith(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const MatchScoreBadge(scorePercent: 92),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Buyer Requirement:',
                              style: AppTypography.bodySmall.copyWith(fontSize: 11),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${totalLot.toInt()} kg $cropName (Grade A)',
                                style: AppTypography.labelLarge.copyWith(fontSize: 12),
                                textAlign: TextAlign.end,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              'Your Allocated Supply:',
                              style: AppTypography.bodySmall.copyWith(fontSize: 11),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${userQty.toInt()} kg (Full batch)',
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.end,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              'Guaranteed Payout:',
                              style: AppTypography.bodySmall.copyWith(fontSize: 11),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '₹${userPayout.toInt()} (₹${pricePerKg.toInt()}/kg)',
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.end,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Multi-Farmer Aggregation Breakdown:',
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildFarmerRow('$currentFarmerName (You)', '${userQty.toInt()} kg • ₹${userPayout.toInt()}', isYou: true),
                  _buildFarmerRow('Cluster Partner Farm 1 (Shabad)', '${cluster1Qty.toInt()} kg • ₹${cluster1Payout.toInt()}'),
                  _buildFarmerRow('Cluster Partner Farm 2 (Moinabad)', '${cluster2Qty.toInt()} kg • ₹${cluster2Payout.toInt()}'),

                  const SizedBox(height: 6),
                  const Divider(),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Text(
                        'Total Aggregated Lot:',
                        style: AppTypography.labelLarge.copyWith(fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${totalLot.toInt()} / ${totalLot.toInt()} kg (100% Fulfilled)',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  PrimaryButton(
                    text: 'Accept Opportunity & View Aggregation',
                    fontSize: 12.5,
                    minHeight: 54,
                    icon: Icons.check_circle_rounded,
                    onPressed: () {
                      Navigator.pushNamed(context, '/coordination/aggregation');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmerRow(String name, String details, {bool isYou = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            isYou ? Icons.account_circle : Icons.person_outline,
            size: 15,
            color: isYou ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isYou ? FontWeight.w700 : FontWeight.w500,
                color: isYou ? AppColors.primary : AppColors.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            details,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isYou ? FontWeight.w700 : FontWeight.w500,
              color: isYou ? AppColors.primary : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
