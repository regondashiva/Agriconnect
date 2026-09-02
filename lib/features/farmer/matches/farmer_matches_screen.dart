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

            // Main 92% Opportunity Card (SIH Central Demo Transaction)
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
                        child: const Text('🍅', style: TextStyle(fontSize: 20)),
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
                                '500 kg Tomato (Grade A)',
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
                                '100 kg (Full batch)',
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
                                '₹2,000 (₹20/kg)',
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
                  _buildFarmerRow('Farmer A (Ramesh - You)', '100 kg • ₹2,000', isYou: true),
                  _buildFarmerRow('Farmer B (Suresh Rao)', '150 kg • ₹3,000'),
                  _buildFarmerRow('Farmer C (Ravi Kumar)', '250 kg • ₹5,000'),

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
                          '500 / 500 kg (100% Fulfilled)',
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
                    text: 'ACCEPT OPPORTUNITY & VIEW AGGREGATION',
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
