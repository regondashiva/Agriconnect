import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';

class ConsumerCheckoutScreen extends StatefulWidget {
  final AppState appState;

  const ConsumerCheckoutScreen({super.key, required this.appState});

  @override
  State<ConsumerCheckoutScreen> createState() => _ConsumerCheckoutScreenState();
}

class _ConsumerCheckoutScreenState extends State<ConsumerCheckoutScreen> {
  String _paymentMethod = 'UPI';
  bool _isPlacing = false;

  void _handlePlaceOrder() {
    setState(() => _isPlacing = true);

    Future.delayed(const Duration(milliseconds: 1200), () {
      widget.appState.placeConsumerOrder();
      setState(() => _isPlacing = false);

      Navigator.pushReplacementNamed(context, '/consumer/tracking');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout & Confirmation'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Address Card
              Text('Delivery Address', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Home • Ananya Sharma', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text('Flat 402, Green Meadows, Madhapur, Hyderabad', style: AppTypography.bodySmall),
                          const SizedBox(height: 2),
                          Text('+91 91234 56789', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Payment Method Options
              Text('Payment Method', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),

              _buildPaymentOption('UPI (Google Pay / PhonePe / Paytm)', 'UPI', Icons.account_balance_wallet_outlined),
              const SizedBox(height: 8),
              _buildPaymentOption('Cash on Delivery (Verified Hub Partner)', 'COD', Icons.payments_outlined),

              const SizedBox(height: 20),

              // Order Summary
              Text('Order Summary', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),

              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryRow('Fresh Farm Tomatoes (2 kg)', '₹56'),
                    const SizedBox(height: 6),
                    _buildSummaryRow('Organic Potatoes (1 kg)', '₹24'),
                    const SizedBox(height: 6),
                    _buildSummaryRow('Direct Farm Logistics Fee', '₹20'),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount to Pay', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800)),
                        Text(
                          '₹100.00',
                          style: AppTypography.headlineSmall.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // AI Demand Loop Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 18, color: AppColors.harvestOrange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your order feeds into AgriConnect AI demand forecast, alerting local farmers to plant & supply more tomatoes.',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              PrimaryButton(
                text: _isPlacing ? 'CONFIRMING ORDER…' : 'PLACE ORDER (₹100)',
                icon: Icons.check_circle_outline,
                isLoading: _isPlacing,
                onPressed: _handlePlaceOrder,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, String val, IconData icon) {
    final isSelected = _paymentMethod == val;
    return InkWell(
      onTap: () => setState(() => _paymentMethod = val),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainerLow : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textMuted, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textDark,
                ),
              ),
            ),
            Radio<String>(
              value: val,
              groupValue: _paymentMethod,
              activeColor: AppColors.primary,
              onChanged: (v) {
                if (v != null) setState(() => _paymentMethod = v);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.bodySmall),
        Text(price, style: AppTypography.labelLarge),
      ],
    );
  }
}
