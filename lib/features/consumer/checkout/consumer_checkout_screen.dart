import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/app_state.dart';
import '../../../services/razorpay_payment_service.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';

class ConsumerCheckoutScreen extends StatefulWidget {
  final AppState appState;

  const ConsumerCheckoutScreen({super.key, required this.appState});

  @override
  State<ConsumerCheckoutScreen> createState() => _ConsumerCheckoutScreenState();
}

class _ConsumerCheckoutScreenState extends State<ConsumerCheckoutScreen> {
  String _paymentMethod = 'UPI'; // 'UPI' or 'COD'
  String _selectedUpiApp = 'PhonePe'; // 'PhonePe', 'Google Pay', 'Paytm'

  late String _deliveryTag;
  late String _deliveryName;
  late String _deliveryAddress;
  late String _deliveryPhone;

  final List<Map<String, String>> _savedAddresses = [
    {
      'tag': 'Home',
      'name': 'Ananya Sharma',
      'address': 'Flat 402, Green Meadows, Madhapur, Hyderabad',
      'phone': '+91 91234 56789',
    },
    {
      'tag': 'Work / Office',
      'name': 'Ananya Sharma',
      'address': 'Tower 3, Mindspace IT Park, Hitech City, Hyderabad',
      'phone': '+91 91234 56789',
    },
    {
      'tag': 'Villa / Parents',
      'name': 'R. Sharma',
      'address': 'Plot 18, Road No. 36, Jubilee Hills, Hyderabad',
      'phone': '+91 98765 43210',
    },
  ];

  @override
  void initState() {
    super.initState();
    _deliveryTag = widget.appState.deliveryTag;
    _deliveryName = widget.appState.deliveryName;
    _deliveryAddress = widget.appState.deliveryAddress;
    _deliveryPhone = widget.appState.deliveryPhone;
  }

  double get _orderTotal {
    if (widget.appState.cart.isNotEmpty) {
      return widget.appState.cartTotal;
    }
    return 100.0;
  }

  void _showChangeAddressSheet() {
    String tempTag = _deliveryTag;
    String tempName = _deliveryName;
    String tempAddress = _deliveryAddress;
    String tempPhone = _deliveryPhone;
    bool isAddingCustom = false;

    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    String customTag = 'Other';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Delivery Address',
                          style: AppTypography.headlineSmall.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 22),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Saved Addresses List
                    ..._savedAddresses.map((addr) {
                      final isSelected = !isAddingCustom &&
                          tempAddress == addr['address'] &&
                          tempTag == addr['tag'];

                      IconData iconData = Icons.home_rounded;
                      if (addr['tag']!.contains('Work')) {
                        iconData = Icons.business_rounded;
                      } else if (addr['tag']!.contains('Villa')) {
                        iconData = Icons.holiday_village_rounded;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () {
                            setModalState(() {
                              isAddingCustom = false;
                              tempTag = addr['tag']!;
                              tempName = addr['name']!;
                              tempAddress = addr['address']!;
                              tempPhone = addr['phone']!;
                            });
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.surfaceContainerLow
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.outlineVariant,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    iconData,
                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            addr['tag']!,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors.textNavy,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '• ${addr['name']}',
                                            style: AppTypography.bodySmall.copyWith(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        addr['address']!,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textDark,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        addr['phone']!,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Radio<bool>(
                                  value: true,
                                  groupValue: isSelected,
                                  activeColor: AppColors.primary,
                                  onChanged: (_) {
                                    setModalState(() {
                                      isAddingCustom = false;
                                      tempTag = addr['tag']!;
                                      tempName = addr['name']!;
                                      tempAddress = addr['address']!;
                                      tempPhone = addr['phone']!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 8),

                    // Add Custom Address Button / Form
                    if (!isAddingCustom)
                      OutlinedButton.icon(
                        onPressed: () {
                          setModalState(() => isAddingCustom = true);
                        },
                        icon: const Icon(Icons.add_location_alt_outlined, color: AppColors.primary),
                        label: const Text('+ Add New Delivery Address',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 46),
                          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary, width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'New Address Details',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel_outlined, size: 20),
                                  onPressed: () => setModalState(() => isAddingCustom = false),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'Contact Name',
                                hintText: 'e.g. Ananya Sharma',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: addressController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: 'Complete Flat/Building & Street',
                                hintText: 'e.g. Flat 101, Lakeview Apt, Gachibowli, Hyderabad',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                hintText: 'e.g. +91 98765 43210',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: ['Home', 'Work', 'Farm', 'Other'].map((t) {
                                final isTagSelected = customTag == t;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                    label: Text(t, style: TextStyle(fontSize: 11, color: isTagSelected ? Colors.white : AppColors.textDark)),
                                    selected: isTagSelected,
                                    selectedColor: AppColors.primary,
                                    onSelected: (val) {
                                      if (val) setModalState(() => customTag = t);
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 18),

                    // Confirm Selection Button
                    PrimaryButton(
                      text: 'DELIVER TO THIS ADDRESS',
                      icon: Icons.check_circle_rounded,
                      onPressed: () {
                        if (isAddingCustom && addressController.text.trim().isNotEmpty) {
                          final newAddr = {
                            'tag': customTag,
                            'name': nameController.text.trim().isNotEmpty
                                ? nameController.text.trim()
                                : 'Ananya Sharma',
                            'address': addressController.text.trim(),
                            'phone': phoneController.text.trim().isNotEmpty
                                ? phoneController.text.trim()
                                : '+91 91234 56789',
                          };
                          _savedAddresses.insert(0, newAddr);
                          tempTag = newAddr['tag']!;
                          tempName = newAddr['name']!;
                          tempAddress = newAddr['address']!;
                          tempPhone = newAddr['phone']!;
                        }

                        setState(() {
                          _deliveryTag = tempTag;
                          _deliveryName = tempName;
                          _deliveryAddress = tempAddress;
                          _deliveryPhone = tempPhone;
                        });

                        widget.appState.updateConsumerDeliveryAddress(
                          tag: tempTag,
                          name: tempName,
                          address: tempAddress,
                          phone: tempPhone,
                        );

                        Navigator.pop(modalContext);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handlePlaceOrder() {
    final total = _orderTotal;
    final isUpi = _paymentMethod == 'UPI';

    if (isUpi) {
      // Launch Official Razorpay Gateway with Synchronous Verification
      final tempOrderId = 'AGR-${(1000 + DateTime.now().millisecondsSinceEpoch % 9000)}';
      RazorpayPaymentService.instance.openCheckout(
        context: context,
        amountInr: total,
        internalOrderId: tempOrderId,
        customerName: _deliveryName,
        customerPhone: _deliveryPhone,
        customerEmail: 'consumer@agriconnect.org',
        paymentType: 'full_100',
        onSuccess: (result) {
          final paymentId = result['data']?['payment_id'] ?? 'pay_verified';
          widget.appState.placeConsumerOrder(
            deliveryAddress: '$_deliveryTag: $_deliveryAddress',
            buyerName: _deliveryName,
            paymentMethod: 'Razorpay / UPI ($paymentId)',
            totalAmount: total,
            cropName: widget.appState.cart.isNotEmpty
                ? widget.appState.cart.map((e) => e.product.name).join(', ')
                : 'Farm Fresh Vegetables Basket',
          );
          Navigator.pushReplacementNamed(context, '/consumer/tracking');
        },
        onFailure: (errMsg) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment Failed: $errMsg'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
      return;
    }

    // Cash on Delivery
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _PaymentProcessingDialog(
          isUpi: false,
          upiApp: '',
          totalAmount: total,
          deliveryAddress: _deliveryAddress,
          onComplete: () {
            Navigator.of(dialogContext, rootNavigator: true).pop();

            // Record real working consumer order in AppState
            widget.appState.placeConsumerOrder(
              deliveryAddress: '$_deliveryTag: $_deliveryAddress',
              buyerName: _deliveryName,
              paymentMethod: 'Cash on Delivery',
              totalAmount: total,
              cropName: widget.appState.cart.isNotEmpty
                  ? widget.appState.cart.map((e) => e.product.name).join(', ')
                  : 'Farm Fresh Vegetables Basket',
            );

            // Navigate to working Order Tracking Screen
            Navigator.pushReplacementNamed(context, '/consumer/tracking');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _orderTotal;
    final cartItems = widget.appState.cart;

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
              // Delivery Address Card with Change Option
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivery Address',
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextButton.icon(
                    onPressed: _showChangeAddressSheet,
                    icon: const Icon(Icons.edit_location_alt_outlined, size: 16, color: AppColors.primary),
                    label: const Text(
                      'Change',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              InkWell(
                onTap: _showChangeAddressSheet,
                borderRadius: BorderRadius.circular(16),
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.location_on, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '$_deliveryTag • $_deliveryName',
                                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _deliveryAddress,
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textDark),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _deliveryPhone,
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Payment Method Options
              Text(
                'Payment Method',
                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),

              // UPI Parent Card
              _buildUpiPaymentOption(),

              const SizedBox(height: 8),

              // Cash on Delivery Option
              _buildCodPaymentOption(),

              const SizedBox(height: 20),

              // Order Summary
              Text('Order Summary', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),

              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (cartItems.isNotEmpty)
                      ...cartItems.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _buildSummaryRow(
                              '${c.product.name} (${c.quantityKg.toInt()} ${c.product.unit})',
                              '₹${c.itemTotal.toInt()}',
                            ),
                          ))
                    else ...[
                      _buildSummaryRow('Fresh Farm Tomatoes (2 kg)', '₹56'),
                      const SizedBox(height: 6),
                      _buildSummaryRow('Organic Potatoes (1 kg)', '₹24'),
                    ],
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
                          '₹${total.toStringAsFixed(2)}',
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
                        'Your order feeds into AgriConnect AI demand forecast, alerting local farmers to plant & supply more vegetables.',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              PrimaryButton(
                text: 'PLACE ORDER (₹${total.toInt()})',
                icon: Icons.check_circle_outline,
                onPressed: _handlePlaceOrder,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpiPaymentOption() {
    final isSelected = _paymentMethod == 'UPI';

    return InkWell(
      onTap: () => setState(() => _paymentMethod = 'UPI'),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF4FBF6) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UPI (Google Pay / PhonePe / Paytm)',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? AppColors.primary : AppColors.textNavy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Instant direct bank settlement to farmer',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Radio<String>(
                  value: 'UPI',
                  groupValue: _paymentMethod,
                  activeColor: AppColors.primary,
                  onChanged: (v) {
                    if (v != null) setState(() => _paymentMethod = v);
                  },
                ),
              ],
            ),

            if (isSelected) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildUpiAppChip(
                    label: 'PhonePe',
                    val: 'PhonePe',
                    iconEmoji: '🟣',
                    color: const Color(0xFF5F259F),
                  ),
                  const SizedBox(width: 8),
                  _buildUpiAppChip(
                    label: 'Google Pay',
                    val: 'Google Pay',
                    iconEmoji: '🟢',
                    color: const Color(0xFF1A73E8),
                  ),
                  const SizedBox(width: 8),
                  _buildUpiAppChip(
                    label: 'Paytm',
                    val: 'Paytm',
                    iconEmoji: '🔷',
                    color: const Color(0xFF002E6E),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUpiAppChip({
    required String label,
    required String val,
    required String iconEmoji,
    required Color color,
  }) {
    final isAppSelected = _selectedUpiApp == val;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedUpiApp = val),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isAppSelected ? color.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isAppSelected ? color : const Color(0xFFCBD5E1),
              width: isAppSelected ? 1.8 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(iconEmoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isAppSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isAppSelected ? color : AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodPaymentOption() {
    final isSelected = _paymentMethod == 'COD';

    return InkWell(
      onTap: () => setState(() => _paymentMethod = 'COD'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF4FBF6) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.payments_rounded, color: AppColors.primary, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cash on Delivery (Verified Hub Partner)',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pay on delivery to FPO delivery partner',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: 'COD',
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
        Text(price, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

/// 2-Second Authentic Payment & Order Placement Dialog
class _PaymentProcessingDialog extends StatefulWidget {
  final bool isUpi;
  final String upiApp;
  final double totalAmount;
  final String deliveryAddress;
  final VoidCallback onComplete;

  const _PaymentProcessingDialog({
    required this.isUpi,
    required this.upiApp,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.onComplete,
  });

  @override
  State<_PaymentProcessingDialog> createState() => _PaymentProcessingDialogState();
}

class _PaymentProcessingDialogState extends State<_PaymentProcessingDialog> {
  bool _isSuccess = false;
  Timer? _timerSuccess;
  Timer? _timerComplete;

  @override
  void initState() {
    super.initState();
    // Step 1: Processing for 1.1s
    _timerSuccess = Timer(const Duration(milliseconds: 1100), () {
      if (mounted) {
        setState(() => _isSuccess = true);
      }
    });

    // Step 2: Show Success state, then close and navigate at 2.2s
    _timerComplete = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _timerSuccess?.cancel();
    _timerComplete?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColor = widget.upiApp == 'PhonePe'
        ? const Color(0xFF5F259F)
        : (widget.upiApp == 'Google Pay' ? const Color(0xFF1A73E8) : AppColors.primary);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 16,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Status Graphic
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _isSuccess ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: appColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.5,
                          valueColor: AlwaysStoppedAnimation<Color>(appColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.isUpi
                        ? 'Authorizing with ${widget.upiApp}…'
                        : 'Confirming Cash on Delivery…',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Connecting to Secure UPI NPCI Gateway…',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              secondChild: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF16A34A),
                        size: 52,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.isUpi ? 'Payment Successful!' : 'Order Confirmed!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF166534),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.isUpi
                        ? '₹${widget.totalAmount.toInt()} Paid via ${widget.upiApp}'
                        : 'Pay ₹${widget.totalAmount.toInt()} upon Delivery',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 14),

            // Jan Dhan Direct Settlement Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: Color(0xFF16A34A), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '100% Direct Farmer Jan Dhan Payout (0% Middleman Commission)',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
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
