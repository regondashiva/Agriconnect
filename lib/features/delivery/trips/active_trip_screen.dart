import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';

class ActiveTripScreen extends StatefulWidget {
  final AppState appState;
  final Map<String, dynamic> tripData;

  const ActiveTripScreen({
    super.key,
    required this.appState,
    required this.tripData,
  });

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  int _currentStep = 0; // 0: Heading to Hub, 1: At Hub (Pickup), 2: En Route, 3: Customer Doorstep
  bool _isItemChecked1 = true;
  bool _isItemChecked2 = true;
  bool _isSealChecked = true;
  final _otpController = TextEditingController();
  bool _isVerifyingOtp = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      if (_currentStep < 3) {
        _currentStep++;
      }
    });
  }

  void _verifyDeliveryOtp() async {
    final enteredOtp = _otpController.text.trim();
    final expectedOtp = (widget.tripData['otp'] ?? '2048').toString();

    if (enteredOtp != expectedOtp && enteredOtp != '2048') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP! Please ask customer for the 4-digit delivery PIN (2048)'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isVerifyingOtp = true);
    await Future.delayed(const Duration(milliseconds: 900));

    final payout = (widget.tripData['payout'] as num?)?.toDouble() ?? 50.0;
    widget.appState.completeDriverTrip(
      payout,
      orderId: widget.tripData['orderId'] as String?,
      tripDetails: widget.tripData,
    );

    if (!mounted) return;
    setState(() => _isVerifyingOtp = false);

    _showSuccessPayoutDialog(payout);
  }

  void _showSuccessPayoutDialog(double payout) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 56),
            ),
            const SizedBox(height: 16),
            Text(
              'Trip Successfully Completed!',
              textAlign: TextAlign.center,
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${payout.toInt()} Payout Credited',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD0EBD8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_balance_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Direct Transfer to ${widget.appState.currentUser.upiId ?? "Jan Dhan UPI"}',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'BACK TO DASHBOARD',
              icon: Icons.arrow_back,
              onPressed: () {
                Navigator.pop(ctx); // close dialog
                Navigator.pop(context); // back to driver home
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.tripData['orderId'] ?? 'AGR-4921';
    final customerName = widget.tripData['customerName'] ?? 'Ananya Sharma';
    final customerPhone = widget.tripData['customerPhone'] ?? '+919876543213';
    final destination = widget.tripData['destination'] ??
        'Flat 402, Green Meadows, Madhapur, Hyderabad';
    final pickupHub = widget.tripData['pickupHub'] ??
        'Ranga Reddy Organic Producers FPO Hub (Shabad)';
    final crateId = widget.tripData['crateId'] ?? 'CR-104';
    final payout = (widget.tripData['payout'] as num?)?.toDouble() ?? 50.0;
    final items = (widget.tripData['items'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        ['Fresh Farm Tomatoes (2 kg)', 'Organic Potatoes (1 kg)'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: Text('Trip #$orderId'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.currency_rupee, size: 14, color: AppColors.primary),
                Text(
                  '${payout.toInt()} Earn',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar / Stepper
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildStepNode(0, 'To Hub', Icons.location_on_outlined),
                  _buildStepDivider(0),
                  _buildStepNode(1, 'Pickup', Icons.inventory_2_outlined),
                  _buildStepDivider(1),
                  _buildStepNode(2, 'Transit', Icons.electric_moped_outlined),
                  _buildStepDivider(2),
                  _buildStepNode(3, 'Delivered', Icons.done_all_rounded),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentStep == 0) ...[
                      _buildStage1ToHub(pickupHub, crateId),
                    ] else if (_currentStep == 1) ...[
                      _buildStage2Pickup(pickupHub, crateId, items),
                    ] else if (_currentStep == 2) ...[
                      _buildStage3Transit(customerName, customerPhone, destination, items),
                    ] else ...[
                      _buildStage4Doorstep(customerName, destination, items),
                    ],

                    const SizedBox(height: 18),

                    // Order Summary Card
                    _buildTripSummaryCard(orderId, items, payout),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: _buildBottomButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepNode(int index, String label, IconData icon) {
    final isDone = _currentStep > index;
    final isCurrent = _currentStep == index;

    Color bg;
    Color fg;
    if (isDone) {
      bg = AppColors.primary;
      fg = Colors.white;
    } else if (isCurrent) {
      bg = const Color(0xFFE8F5E9);
      fg = AppColors.primary;
    } else {
      bg = Colors.grey.shade100;
      fg = Colors.grey.shade400;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: isCurrent ? Border.all(color: AppColors.primary, width: 2) : null,
          ),
          child: Icon(
            isDone ? Icons.check : icon,
            size: 17,
            color: fg,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? AppColors.primary : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(int index) {
    final isDone = _currentStep > index;
    return Expanded(
      child: Container(
        height: 2.5,
        margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
        color: isDone ? AppColors.primary : Colors.grey.shade300,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Stage 1: Heading to Hub
  // ---------------------------------------------------------------------------
  Widget _buildStage1ToHub(String hub, String crateId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.hub_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STEP 1: PROCEED TO FPO HUB',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hub,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.qr_code_2_rounded, size: 20, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                'Pickup Crate Tag: #$crateId',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'READY AT DOCK 2',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAF9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Colors.black54),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'The FPO operator has already cleaned, sorted, and weighed this crate.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Stage 2: Hub Pickup Verification
  // ---------------------------------------------------------------------------
  Widget _buildStage2Pickup(String hub, String crateId, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STEP 2: CONFIRM CRATE PICKUP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Verify Items & Sealed Package',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Driver Inspection Checklist:',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _isItemChecked1,
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primary,
            title: Text(items.isNotEmpty ? items[0] : 'Vegetables Verified',
                style: const TextStyle(fontSize: 13)),
            onChanged: (val) => setState(() => _isItemChecked1 = val ?? false),
          ),
          if (items.length > 1)
            CheckboxListTile(
              value: _isItemChecked2,
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: Text(items[1], style: const TextStyle(fontSize: 13)),
              onChanged: (val) => setState(() => _isItemChecked2 = val ?? false),
            ),
          CheckboxListTile(
            value: _isSealChecked,
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primary,
            title: Text('FPO Organic Quality Seal & Barcode #$crateId Intact',
                style: const TextStyle(fontSize: 13)),
            onChanged: (val) => setState(() => _isSealChecked = val ?? false),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Stage 3: En Route to Customer
  // ---------------------------------------------------------------------------
  Widget _buildStage3Transit(
    String name,
    String phone,
    String destination,
    List<String> items,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.navigation_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STEP 3: EN ROUTE TO CUSTOMER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Navigation & Customer Contact',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Delivery ETA badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3FBF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCCE8D4)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer_outlined, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Estimated Time: 18 mins',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                Text(
                  '6.2 km',
                  style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Customer details
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.person, color: AppColors.primary),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(destination, style: const TextStyle(fontSize: 12.5)),
            trailing: IconButton(
              icon: const Icon(Icons.phone, color: AppColors.primary),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Calling customer $name at $phone...')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Stage 4: Customer Doorstep & OTP Verification
  // ---------------------------------------------------------------------------
  Widget _buildStage4Doorstep(String name, String destination, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.pin_drop_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STEP 4: CUSTOMER DOORSTEP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Enter Delivery Confirmation OTP',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Deliver package to $name at $destination.',
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAF9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8E4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter 4-Digit Customer OTP:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Demo PIN is 2048 (Provided in customer tracking screen)',
                  style: TextStyle(fontSize: 11.5, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '• • • •',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Trip Summary Card
  // ---------------------------------------------------------------------------
  Widget _buildTripSummaryCard(String orderId, List<String> items, double payout) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cargo & Contents',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                'Payout: ₹${payout.toInt()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.eco_outlined, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(item, style: const TextStyle(fontSize: 12.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dynamic Bottom Button depending on step
  // ---------------------------------------------------------------------------
  Widget _buildBottomButton() {
    switch (_currentStep) {
      case 0:
        return PrimaryButton(
          text: 'I HAVE ARRIVED AT HUB',
          icon: Icons.store_mall_directory_outlined,
          onPressed: _nextStep,
        );
      case 1:
        final canProceed = _isItemChecked1 && _isSealChecked;
        return PrimaryButton(
          text: 'CONFIRM PICKUP & START DELIVERY',
          icon: Icons.electric_moped_outlined,
          onPressed: canProceed
              ? _nextStep
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please check and verify all crate items and seals first!'),
                    ),
                  );
                },
        );
      case 2:
        return PrimaryButton(
          text: 'I HAVE ARRIVED AT CUSTOMER',
          icon: Icons.home_outlined,
          onPressed: _nextStep,
        );
      case 3:
      default:
        return PrimaryButton(
          text: 'VERIFY OTP & COMPLETE DELIVERY',
          icon: Icons.verified_outlined,
          isLoading: _isVerifyingOtp,
          onPressed: _verifyDeliveryOtp,
        );
    }
  }
}
