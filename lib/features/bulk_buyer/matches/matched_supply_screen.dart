import 'package:flutter/material.dart';
import '../../../models/match_model.dart';
import '../../../models/user_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/app_state.dart';
import '../../../services/razorpay_payment_service.dart';
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
    final double matchScore = match?.matchScorePercent ?? 92.0;
    final String cropName = match?.cropName.isNotEmpty == true ? match!.cropName : (appState.produceList.isNotEmpty ? appState.produceList.first.cropName : 'Tomato');

    final List<SupplyContributor> contributors = (match != null && match.contributors.isNotEmpty)
        ? match.contributors
        : (appState.produceList.isNotEmpty
            ? appState.produceList.map((p) => SupplyContributor(
                farmerId: p.farmerId,
                farmerName: p.farmerName.isNotEmpty ? p.farmerName : 'Cluster Farm Partner',
                location: p.location.isNotEmpty ? p.location : 'Cluster Hub',
                quantityKg: p.availableQuantityKg,
                payoutAmount: p.availableQuantityKg * p.expectedPricePerKg,
              )).toList()
            : [
                SupplyContributor(
                  farmerId: 'c1',
                  farmerName: appState.currentUser.name.isNotEmpty && appState.currentUser.role == UserRole.farmer
                      ? appState.currentUser.name
                      : 'Cluster Farm Partner 1',
                  location: 'Chevella Agro Cluster',
                  quantityKg: 100.0,
                  payoutAmount: 2000.0,
                ),
                const SupplyContributor(
                  farmerId: 'c2',
                  farmerName: 'Cluster Farm Partner 2',
                  location: 'Shabad Center',
                  quantityKg: 150.0,
                  payoutAmount: 3000.0,
                ),
                const SupplyContributor(
                  farmerId: 'c3',
                  farmerName: 'Cluster Farm Partner 3',
                  location: 'Moinabad Cluster',
                  quantityKg: 250.0,
                  payoutAmount: 5000.0,
                ),
              ]);

    final int farmerCount = contributors.length;
    final double calculatedKg = contributors.fold<double>(0.0, (s, c) => s + c.quantityKg);
    final double totalKg = match?.matchedQuantityKg ?? (calculatedKg > 0 ? calculatedKg : 500.0);
    final double calculatedAmt = contributors.fold<double>(0.0, (s, c) => s + c.payoutAmount);
    final double totalAmt = match?.totalEstimatedValue ?? (calculatedAmt > 0 ? calculatedAmt : 10000.0);

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
                    MatchScoreBadge(scorePercent: matchScore, isLarge: true),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${totalKg.toInt()} kg $cropName Ready',
                            style: AppTypography.headlineSmall.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Aggregated from $farmerCount verified farmer(s) in active cluster.',
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
                    ...contributors.map((c) => _buildSupplyRow(
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
                        Text(
                          '${totalKg.toInt()} kg (₹${totalAmt.toInt()})',
                          style: AppTypography.headlineSmall.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
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
                text: 'PLACE BULK ORDER (₹${totalAmt.toInt()})',
                icon: Icons.shield_outlined,
                onPressed: () => _showEscrowAdvanceSheet(context, totalAmt),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showEscrowAdvanceSheet(BuildContext context, double totalAmt) {
    final advanceAmt = (totalAmt * 0.20).roundToDouble();
    final remainingAmt = (totalAmt * 0.80).roundToDouble();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.security_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Escrow Milestone Payment', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800)),
                          Text('Secure 2-stage smart contract payout', style: AppTypography.bodySmall),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Order Value', style: AppTypography.bodyMedium),
                            Text('₹${totalAmt.toInt()}', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.lock_clock_rounded, color: Color(0xFFD97706), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('20% Advance Lock (Now)', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                                  Text('Held in smart escrow until transit starts', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                                ],
                              ),
                            ),
                            Text('₹${advanceAmt.toInt()}', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFFD97706))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('80% Balance On Delivery', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                                  Text('Released to farmers via 6-digit OTP', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                                ],
                              ),
                            ),
                            Text('₹${remainingAmt.toInt()}', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  PrimaryButton(
                    text: 'LOCK ₹${advanceAmt.toInt()} IN ESCROW & DISPATCH',
                    icon: Icons.lock_outline_rounded,
                    onPressed: () {
                      Navigator.pop(ctx);
                      final orderId = 'AGR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

                        RazorpayPaymentService.instance.openCheckout(
                          context: context,
                          amountInr: advanceAmt,
                          internalOrderId: orderId,
                          customerName: appState.currentUser.name.isNotEmpty ? appState.currentUser.name : 'FreshBasket Mandi',
                          customerPhone: appState.currentUser.phoneNumber.isNotEmpty ? appState.currentUser.phoneNumber : '9876543210',
                          customerEmail: 'buyer@agriconnect.org',
                          paymentType: 'advance_20',
                          onSuccess: (result) async {
                            final success = await appState.payEscrowAdvance(
                              orderId: orderId,
                              totalAmount: totalAmt,
                            );

                            if (context.mounted) {
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.primary,
                                    content: Text('₹${advanceAmt.toInt()} locked in Escrow via Razorpay! Mini-truck dispatched.'),
                                  ),
                                );
                                Navigator.pushNamed(context, '/coordination/tracking');
                              }
                            }
                          },
                          onFailure: (errMsg) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red.shade700,
                                  content: Text('Escrow Advance Failed: $errMsg'),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
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
