import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../services/app_state.dart';
import '../../shared/widgets/app_buttons.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/role_switcher_sheet.dart';
import '../../shared/widgets/status_chip.dart';

class SettlementScreen extends StatelessWidget {
  final AppState appState;

  const SettlementScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final order = appState.currentBulkOrder;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Direct Settlement'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Settlement Confirmation Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.secondaryContainer),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded, color: AppColors.success, size: 36),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settlement Completed',
                            style: AppTypography.headlineSmall.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Order #${order.orderId} delivered and ₹10,000 settled directly with 0% intermediary fee.',
                            style: AppTypography.bodySmall.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Total Payout Summary Card
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Order Value', style: AppTypography.labelLarge),
                        Text(
                          '₹10,000.00',
                          style: AppTypography.headlineMedium.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Buyer: FreshBasket Mandi', style: AppTypography.bodySmall),
                        Text('500 kg Tomato @ ₹20/kg', style: AppTypography.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Direct Farmer Payout Distribution',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Automated split based on verified supply contribution.',
                style: AppTypography.bodySmall,
              ),

              const SizedBox(height: 12),

              // 3 Farmers Settlement Breakdown
              ...order.settlements.map((settlement) {
                final isYou = settlement.farmerName.contains('A');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    backgroundColor: isYou ? AppColors.surfaceContainerLow : Colors.white,
                    borderColor: isYou ? AppColors.primary : AppColors.surfaceContainerHigh,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: isYou ? AppColors.primary : AppColors.surfaceContainer,
                                child: Text(
                                  settlement.farmerName.contains('A') ? 'A' : settlement.farmerName.contains('B') ? 'B' : 'C',
                                  style: TextStyle(
                                    color: isYou ? Colors.white : AppColors.textNavy,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      settlement.farmerName,
                                      style: AppTypography.labelLarge.copyWith(
                                        fontWeight: isYou ? FontWeight.w800 : FontWeight.w600,
                                        color: isYou ? AppColors.primary : AppColors.textNavy,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${settlement.quantityKg.toInt()} kg @ ₹20/kg • Bank Transfer',
                                      style: AppTypography.bodySmall.copyWith(fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${settlement.amount.toInt()}',
                              style: AppTypography.headlineSmall.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            StatusChip.success('PAID'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Trust note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security_rounded, size: 20, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Escrow-secured settlement directly deposited to registered Jan Dhan / UPI accounts upon Mandi gate entry.',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              PrimaryButton(
                text: 'BACK TO HOME DASHBOARD',
                icon: Icons.home_rounded,
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/farmer/home', (r) => false);
                },
              ),

              const SizedBox(height: 12),

              SecondaryButton(
                text: 'SWITCH ROLE FOR DEMO',
                icon: Icons.swap_horiz_rounded,
                onPressed: () => RoleSwitcherSheet.show(context, appState),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
