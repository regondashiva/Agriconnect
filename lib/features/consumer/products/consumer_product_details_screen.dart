import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/consumer_product_model.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_chip.dart';

class ConsumerProductDetailsScreen extends StatefulWidget {
  final AppState appState;
  final ConsumerProduct product;

  const ConsumerProductDetailsScreen({
    super.key,
    required this.appState,
    required this.product,
  });

  @override
  State<ConsumerProductDetailsScreen> createState() =>
      _ConsumerProductDetailsScreenState();
}

class _ConsumerProductDetailsScreenState
    extends State<ConsumerProductDetailsScreen> {
  double _selectedQuantity = 2.0;

  @override
  Widget build(BuildContext context) {
    final double totalPrice = widget.product.pricePerKg * _selectedQuantity;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Product Card
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000767),
                        offset: Offset(0, 6),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.product.iconEmoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: AppTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Fresh Harvest • 100% Farm Sourced',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                  Text(
                    '₹${widget.product.pricePerKg.toInt()} / kg',
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Source & Verification Badge Card
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Supply Source:', style: AppTypography.bodySmall),
                        Text(
                          widget.product.source,
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Distance to You:', style: AppTypography.bodySmall),
                        Text(
                          '${widget.product.distanceKm} km (Direct Hub Delivery)',
                          style: AppTypography.labelLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Quality Grade:', style: AppTypography.bodySmall),
                        StatusChip.success(widget.product.qualityGrade),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quantity Selector
              Text(
                'Select Quantity for Your Home',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildQtyBtn(Icons.remove, () {
                    if (_selectedQuantity > 0.5) {
                      setState(() => _selectedQuantity -= 0.5);
                    }
                  }),
                  const SizedBox(width: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Text(
                      '${_selectedQuantity == _selectedQuantity.toInt() ? _selectedQuantity.toInt() : _selectedQuantity} kg',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  _buildQtyBtn(Icons.add, () {
                    setState(() => _selectedQuantity += 0.5);
                  }),
                ],
              ),

              const SizedBox(height: 24),

              // Total Calculation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount:', style: AppTypography.labelLarge),
                    Text(
                      '₹${totalPrice.toStringAsFixed(0)}',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              PrimaryButton(
                text: 'ADD TO CART (₹${totalPrice.toStringAsFixed(0)})',
                icon: Icons.shopping_bag_outlined,
                onPressed: () {
                  widget.appState.addToCart(widget.product, _selectedQuantity);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added $_selectedQuantity kg ${widget.product.name} to Cart'),
                      action: SnackBarAction(
                        label: 'VIEW CART',
                        textColor: AppColors.harvestOrange,
                        onPressed: () {
                          Navigator.pushNamed(context, '/consumer/cart');
                        },
                      ),
                    ),
                  );
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
    );
  }
}
