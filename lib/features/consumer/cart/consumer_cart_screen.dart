import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';

class ConsumerCartScreen extends StatefulWidget {
  final AppState appState;

  const ConsumerCartScreen({super.key, required this.appState});

  @override
  State<ConsumerCartScreen> createState() => _ConsumerCartScreenState();
}

class _ConsumerCartScreenState extends State<ConsumerCartScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = widget.appState.cart;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your Household Cart'),
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 56, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('Your cart is currently empty.', style: AppTypography.headlineSmall),
                  const SizedBox(height: 6),
                  Text('Discover fresh produce directly from local farmers.', style: AppTypography.bodySmall),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/consumer/home'),
                    child: const Text('Explore Produce'),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
                        final item = cart[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppCard(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(item.product.iconEmoji, style: const TextStyle(fontSize: 26)),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '₹${item.product.pricePerKg.toInt()} / kg • ${item.product.source}',
                                        style: AppTypography.bodySmall.copyWith(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      padding: const EdgeInsets.all(4),
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.remove_circle_outline, size: 22, color: AppColors.primary),
                                      onPressed: () {
                                        setState(() {
                                          widget.appState.updateCartQuantity(item.product.id, item.quantityKg - 0.5);
                                        });
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Text(
                                        '${item.quantityKg == item.quantityKg.toInt() ? item.quantityKg.toInt() : item.quantityKg} kg',
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                      ),
                                    ),
                                    IconButton(
                                      padding: const EdgeInsets.all(4),
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.add_circle_outline, size: 22, color: AppColors.primary),
                                      onPressed: () {
                                        setState(() {
                                          widget.appState.updateCartQuantity(item.product.id, item.quantityKg + 0.5);
                                        });
                                      },
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

                  // Bill Details Summary Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x0C000000),
                          offset: Offset(0, -4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Item Subtotal', style: AppTypography.bodySmall),
                            Text('₹${widget.appState.cartSubtotal.toInt()}', style: AppTypography.labelLarge),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Eco Delivery Partner Fee', style: AppTypography.bodySmall),
                            Text('₹${widget.appState.deliveryFee.toInt()}', style: AppTypography.labelLarge),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Amount', style: AppTypography.headlineSmall.copyWith(fontSize: 17, fontWeight: FontWeight.w800)),
                            Text(
                              '₹${widget.appState.cartTotal.toInt()}',
                              style: AppTypography.headlineSmall.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          text: 'PROCEED TO CHECKOUT (₹${widget.appState.cartTotal.toInt()})',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () {
                            Navigator.pushNamed(context, '/consumer/checkout');
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
}
