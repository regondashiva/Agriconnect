import 'package:flutter/material.dart';
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
  double _selectedQuantity = 1.0;

  @override
  Widget build(BuildContext context) {
    final double totalPrice = widget.product.pricePerKg * _selectedQuantity;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: Text(widget.product.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Product Card
              Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        offset: Offset(0, 6),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: (widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty)
                        ? Image.network(
                            widget.product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Text(
                                widget.product.iconEmoji,
                                style: const TextStyle(fontSize: 64),
                              ),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: const Color(0xFFF1F5F9),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              widget.product.iconEmoji,
                              style: const TextStyle(fontSize: 64),
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Title, Unit, Price & Discount
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: AppTypography.headlineMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${widget.product.unit} • ${widget.product.harvestFreshness}',
                          style: AppTypography.bodySmall.copyWith(color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${widget.product.pricePerKg.toInt()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: Color(0xFF164E2A),
                        ),
                      ),
                      if (widget.product.mrpPrice > widget.product.pricePerKg)
                        Text(
                          'MRP ₹${widget.product.mrpPrice.toInt()}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Source & Verification Badge Card
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Supply Source:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        Flexible(
                          child: Text(
                            widget.product.source,
                            style: const TextStyle(
                              color: Color(0xFF164E2A),
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Delivery Time:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        Text(
                          '⚡ ${widget.product.deliveryTime} (${widget.product.distanceKm} km)',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Quality Grade:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        StatusChip.success(widget.product.qualityGrade),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Quantity Selector
              const Text(
                'Select Quantity for Your Home',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color(0xFF0F172A),
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
                  const SizedBox(width: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF164E2A), width: 1.8),
                    ),
                    child: Text(
                      '${_selectedQuantity == _selectedQuantity.toInt() ? _selectedQuantity.toInt() : _selectedQuantity} kg',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: Color(0xFF164E2A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  _buildQtyBtn(Icons.add, () {
                    setState(() => _selectedQuantity += 0.5);
                  }),
                ],
              ),

              const SizedBox(height: 20),

              // Total Calculation
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(
                      '₹${totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Color(0xFF164E2A),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              PrimaryButton(
                text: 'ADD TO CART (₹${totalPrice.toStringAsFixed(0)})',
                icon: Icons.shopping_bag_outlined,
                onPressed: () {
                  widget.appState.addToCart(widget.product, _selectedQuantity);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added $_selectedQuantity kg ${widget.product.name} to Cart'),
                      backgroundColor: const Color(0xFF164E2A),
                      action: SnackBarAction(
                        label: 'VIEW CART',
                        textColor: const Color(0xFFFEF3C7),
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Icon(icon, color: const Color(0xFF164E2A), size: 22),
      ),
    );
  }
}
