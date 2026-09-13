import 'package:flutter/material.dart';
import '../../../models/consumer_product_model.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';

class ConsumerCartScreen extends StatefulWidget {
  final AppState appState;
  final bool isTab;
  final VoidCallback? onExplore;

  const ConsumerCartScreen({
    super.key,
    required this.appState,
    this.isTab = false,
    this.onExplore,
  });

  @override
  State<ConsumerCartScreen> createState() => _ConsumerCartScreenState();
}

class _ConsumerCartScreenState extends State<ConsumerCartScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        final cart = widget.appState.cart;

        final content = cart.isEmpty
            ? _buildEmptyCart(context)
            : SafeArea(
                child: Column(
                  children: [
                    if (widget.isTab) _buildTabHeader(context, cart.length),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: cart.length,
                        itemBuilder: (context, index) {
                          final item = cart[index];
                          return _buildCartItemCard(context, item);
                        },
                      ),
                    ),
                    _buildBillSummaryCard(context),
                  ],
                ),
              );

        if (widget.isTab) {
          return Container(
            color: const Color(0xFFF8FAF8),
            child: content,
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAF8),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'My Farm Basket',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            actions: [
              if (cart.isNotEmpty)
                TextButton(
                  onPressed: () {
                    widget.appState.clearCart();
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          body: content,
        );
      },
    );
  }

  Widget _buildTabHeader(BuildContext context, int itemCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, color: Color(0xFF164E2A), size: 20),
              const SizedBox(width: 8),
              Text(
                'My Farm Basket ($itemCount items)',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () => widget.appState.clearCart(),
            child: const Text(
              'Clear All',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: Color(0xFFF0FDF4),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🛒', style: TextStyle(fontSize: 42)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your Farm Basket is Empty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fill it with crisp vegetables, sweet orchard fruits, and clean morning-harvested greens directly from local FPOs.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: () {
                if (widget.onExplore != null) {
                  widget.onExplore!();
                } else if (!widget.isTab && Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/consumer/home');
                }
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text(
                'Shop Farm Fresh Produce',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF164E2A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItem item) {
    final product = item.product;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 62,
                height: 62,
                color: const Color(0xFFF1F5F9),
                child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(product.iconEmoji, style: const TextStyle(fontSize: 28)),
                        ),
                      )
                    : Center(
                        child: Text(product.iconEmoji, style: const TextStyle(fontSize: 28)),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${product.pricePerKg.toInt()} / ${product.unit}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, size: 12, color: Color(0xFF16A34A)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          product.source,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF16A34A),
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Stepper and Item Total Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '₹${item.itemTotal.toInt()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF164E2A),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          widget.appState.updateCartQuantity(product.id, item.quantityKg - 0.5);
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          child: Icon(Icons.remove, size: 15, color: Color(0xFF164E2A)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '${item.quantityKg == item.quantityKg.toInt() ? item.quantityKg.toInt() : item.quantityKg}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF164E2A),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          widget.appState.updateCartQuantity(product.id, item.quantityKg + 0.5);
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          child: Icon(Icons.add, size: 15, color: Color(0xFF164E2A)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillSummaryCard(BuildContext context) {
    final subtotal = widget.appState.cartSubtotal;
    final delivery = widget.appState.deliveryFee;
    final total = widget.appState.cartTotal;

    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Produce Subtotal', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              Text('₹${subtotal.toInt()}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('FPO Eco-Delivery Fee', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              delivery == 0
                  ? const Text('FREE', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF16A34A)))
                  : Text('₹${delivery.toInt()}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Direct Middleman Margin Cut', style: TextStyle(fontSize: 12, color: Color(0xFF16A34A))),
              Text('₹0 (100% to Farmer)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF16A34A))),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total to Pay',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
              Text(
                '₹${total.toInt()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF164E2A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            text: 'PROCEED TO CHECKOUT (₹${total.toInt()})',
            icon: Icons.arrow_forward_rounded,
            onPressed: () {
              Navigator.pushNamed(context, '/consumer/checkout');
            },
          ),
        ],
      ),
    );
  }
}
