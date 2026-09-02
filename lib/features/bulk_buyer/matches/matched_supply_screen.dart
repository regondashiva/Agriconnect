import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/match_score_badge.dart';
import '../../../shared/widgets/status_chip.dart';

class MatchedSupplyScreen extends StatelessWidget {
  final AppState appState;

  const MatchedSupplyScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final match = appState.activeMatch;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Matched Aggregated Supply'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Match Status Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryLight),
                ),
                child: Row(
                  children: [
                    const MatchScoreBadge(scorePercent: 92, isLarge: true),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '500 kg Tomato Ready',
                            style: AppTypography.headlineSmall.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Aggregated from 3 verified farmers in Chevella / Shabad cluster.',
                            style: AppTypography.bodySmall.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Aggregation Lot Breakdown
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Supply Aggregation Lot', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800)),
                        StatusChip.success('100% Target Met'),
                      ],
                    ),
                    ...match.contributors.map((c) => _buildSupplyRow(
                      c.farmerName,
                      c.location,
                      '${c.quantityKg.toInt()} kg',
                      '₹${c.payoutAmount.toInt()}',
                    )),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Aggregated Lot:', style: AppTypography.labelLarge),
                        Text('500 kg (₹10,000)', style: AppTypography.headlineSmall.copyWith(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Quality Confidence Badge & Link
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('AI Quality Evidence', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800)),
                        StatusChip.success('Risk: LOW'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI Score: 87/100 (91% Confidence). Color and size uniformity confirmed across all 3 lots.',
                      style: AppTypography.bodySmall.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => Navigator.pushNamed(context, '/coordination/quality'),
                      child: Text(
                        'Inspect Multi-Photo Evidence & Diagnostics →',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Smart Logistics Route Summary
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Logistics & Route Plan', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800)),
                        const Text('38.4 km • 1h 30m', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textNavy)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Route: Chevella → Shabad → Moinabad → Kothapet Delivery Gate.',
                      style: AppTypography.bodySmall.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              PrimaryButton(
                text: 'PLACE BULK ORDER (₹10,000)',
                icon: Icons.check_circle_rounded,
                onPressed: () {
                  Navigator.pushNamed(context, '/coordination/logistics');
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupplyRow(String name, String loc, String qty, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin_circle_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700)),
                  Text(loc, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(qty, style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary)),
              Text(val, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
