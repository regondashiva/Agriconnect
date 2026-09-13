import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/order_model.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';
import 'consumer_tracking_screen.dart';

class ConsumerOrderHistoryScreen extends StatefulWidget {
  final AppState appState;
  final bool isTab;

  const ConsumerOrderHistoryScreen({
    super.key,
    required this.appState,
    this.isTab = false,
  });

  @override
  State<ConsumerOrderHistoryScreen> createState() => _ConsumerOrderHistoryScreenState();
}

class _ConsumerOrderHistoryScreenState extends State<ConsumerOrderHistoryScreen> {
  String _selectedFilter = 'All'; // 'All', 'Active', 'Delivered'

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final allOrders = widget.appState.consumerOrders;
        final filteredOrders = allOrders.where((order) {
          final isDelivered = order.currentStatusText.toLowerCase().contains('delivered');
          if (_selectedFilter == 'Active') return !isDelivered;
          if (_selectedFilter == 'Delivered') return isDelivered;
          return true;
        }).toList();

        final activeCount = allOrders.where((o) => !o.currentStatusText.toLowerCase().contains('delivered')).length;
        final deliveredCount = allOrders.where((o) => o.currentStatusText.toLowerCase().contains('delivered')).length;

        final body = SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    if (!widget.isTab && Navigator.canPop(context)) ...[
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 14),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'My Orders History',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${allOrders.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF166534),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Direct farm-to-table deliveries • Escrow protected',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Small Support / Help Icon
                    IconButton(
                      icon: const Icon(Icons.help_outline_rounded, color: Color(0xFF475569), size: 22),
                      tooltip: 'Orders Help',
                      onPressed: () => _showHelpModal(context),
                    ),
                  ],
                ),
              ),

              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip('All', 'All (${allOrders.length})'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Active', '🚚 Active ($activeCount)'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Delivered', '✅ Delivered ($deliveredCount)'),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Orders List
              Expanded(
                child: filteredOrders.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredOrders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          return _buildOrderCard(context, filteredOrders[index]);
                        },
                      ),
              ),
            ],
          ),
        );

        if (widget.isTab) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAF8),
            body: body,
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAF8),
          body: body,
        );
      },
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = filterKey),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF15803D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF15803D) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF15803D).withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final isDelivered = order.currentStatusText.toLowerCase().contains('delivered');
    final dateStr = order.orderDate != null
        ? '${order.orderDate!.day} ${_getMonth(order.orderDate!.month)}, ${_formatTime(order.orderDate!)}'
        : 'Today, 10:30 AM';

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Order ID, Date & Status Chip
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '#${order.orderId}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: order.orderId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Order ID #${order.orderId} copied!'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: const Icon(Icons.copy_rounded, size: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        dateStr,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Status Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDelivered ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDelivered ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDelivered ? Icons.check_circle_rounded : Icons.local_shipping_rounded,
                      size: 13,
                      color: isDelivered ? const Color(0xFF15803D) : const Color(0xFFB45309),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isDelivered ? 'Delivered' : 'Out for Delivery',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isDelivered ? const Color(0xFF15803D) : const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Middle: Items & Produce details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Produce Veggie Thumbnail
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: const Center(
                  child: Text('🥗', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.cropName,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.itemsSummary.join(' • '),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Provenance badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.eco_rounded, size: 12, color: Color(0xFF15803D)),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Direct from Rural FPO Clusters',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF15803D),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Price & Payment Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF16A34A)),
                    const SizedBox(width: 4),
                    Text(
                      order.paymentMethod,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                  ],
                ),
                Text(
                  '₹${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Action Buttons: Contextual based on delivery status
          if (!isDelivered) ...[
            // Active order actions
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'TRACK LIVE DELIVERY',
                    icon: Icons.navigation_rounded,
                    fontSize: 12,
                    minHeight: 44,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConsumerTrackingScreen(appState: widget.appState),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SecondaryButton(
                    text: 'VIEW OTP',
                    icon: Icons.key_rounded,
                    fontSize: 12,
                    minHeight: 44,
                    onPressed: () => _showOtpModal(context, widget.appState.deliveryOtp),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Delivered order actions
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'ORDER AGAIN',
                    icon: Icons.replay_rounded,
                    fontSize: 12,
                    minHeight: 44,
                    backgroundColor: const Color(0xFF15803D),
                    onPressed: () {
                      widget.appState.reorderConsumerItems(order);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF15803D),
                          content: Row(
                            children: [
                              const Icon(Icons.shopping_cart_checkout_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text('Fresh produce items added back to your cart!'),
                              ),
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  Navigator.pushNamed(context, '/consumer/cart');
                                },
                                child: const Text('VIEW CART', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SecondaryButton(
                    text: 'VIEW BILL',
                    icon: Icons.receipt_rounded,
                    fontSize: 12,
                    minHeight: 44,
                    onPressed: () => _showInvoiceModal(context, order),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.receipt_long_outlined, size: 42, color: Color(0xFF94A3B8)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Orders Found',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'You have no orders in this category yet. Explore our farm-fresh vegetables and fruits!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'EXPLORE PRODUCE',
              icon: Icons.storefront_rounded,
              onPressed: () {
                if (widget.isTab) {
                  // Handled by parent tab switcher if needed
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showOtpModal(BuildContext context, String otp) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 18),
              const Icon(Icons.shield_rounded, size: 40, color: Color(0xFF15803D)),
              const SizedBox(height: 10),
              const Text(
                'Delivery Verification OTP',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Share this 6-digit code with the delivery partner upon doorstep handover to release escrow payment.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
                ),
                child: Text(
                  otp.isNotEmpty ? otp : '749210',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'DONE',
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInvoiceModal(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tax & Settlement Invoice',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        'Order #${order.orderId} • SIH-AGR-VERIFIED',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PAID',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF166534)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Itemized Breakdown
              ...order.itemsSummary.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                      const Text('₹70.00', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 6),
              const Divider(),
              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('FPO Aggregation & Quality Crate', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  Text('₹10.00', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Green EV Doorstep Delivery', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  Text('₹25.00', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Middleman Commission Cut', style: TextStyle(fontSize: 12, color: Color(0xFF15803D), fontWeight: FontWeight.w700)),
                  Text('-₹0.00 (0%)', style: TextStyle(fontSize: 12, color: Color(0xFF15803D), fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Grand Total Paid', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                  Text('₹${order.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF15803D))),
                ],
              ),

              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_rounded, color: Color(0xFF15803D), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '100% of produce value was released directly to rural cluster farmers via Smart Escrow upon OTP confirmation.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF475569), height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              PrimaryButton(
                text: 'CLOSE INVOICE',
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHelpModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Orders Help & Support', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              const Text('• All orders are aggregated directly from local FPO farmers within 12 hours of harvest.'),
              const SizedBox(height: 6),
              const Text('• Payment is held safely in escrow until you enter your 6-digit OTP at doorstep delivery.'),
              const SizedBox(height: 6),
              const Text('• If you need instant assistance, our Agro Support helpline is available 24/7.'),
              const SizedBox(height: 18),
              PrimaryButton(text: 'OKAY, GOT IT', onPressed: () => Navigator.pop(ctx)),
            ],
          ),
        );
      },
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1).clamp(0, 11)];
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
