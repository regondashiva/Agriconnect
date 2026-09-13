import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/user_model.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';

class DeliveryRegistrationScreen extends StatefulWidget {
  final AppState appState;

  const DeliveryRegistrationScreen({super.key, required this.appState});

  @override
  State<DeliveryRegistrationScreen> createState() => _DeliveryRegistrationScreenState();
}

class _DeliveryRegistrationScreenState extends State<DeliveryRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final _dlController = TextEditingController();
  final _plateController = TextEditingController();
  final _upiController = TextEditingController();

  String _selectedVehicle = 'EV Cargo Scooter (300kg)';
  String _selectedFpo = 'Ranga Reddy Organic Producers FPO (Shabad)';
  bool _isSubmitting = false;

  final List<String> _vehicleOptions = [
    'EV Cargo Scooter (300kg)',
    '3-Wheeler Auto (600kg)',
    'Tata Ace / Mini Truck (1.5T)',
  ];

  final List<String> _fpoOptions = [
    'Ranga Reddy Organic Producers FPO (Shabad)',
    'Chevella Primary Aggregation Hub',
    'Moinabad Rural Farmers Center',
  ];

  @override
  void initState() {
    super.initState();
    final current = widget.appState.currentUser;
    _nameController = TextEditingController(
      text: current.name.isNotEmpty && current.name != 'New User' ? current.name : '',
    );
    _phoneController = TextEditingController(
      text: widget.appState.authPhoneNumber.isNotEmpty
          ? widget.appState.authPhoneNumber
          : current.phoneNumber,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dlController.dispose();
    _plateController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final dl = _dlController.text.trim();
      final plate = _plateController.text.trim();
      final upi = _upiController.text.trim();

      widget.appState.registerNewUser(
        name: name,
        phoneNumber: phone,
        role: UserRole.deliveryPartner,
        location: _selectedFpo,
        fpoCluster: _selectedFpo,
        registrationId: dl,
        businessType: _selectedVehicle,
        vehicleType: _selectedVehicle,
        vehicleNumber: plate,
        upiId: upi,
        bankName: 'Direct Bank / UPI Account',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully. KYC pending admin approval.'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/delivery/home', (r) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDFD),
      appBar: AppBar(
        title: const Text('Delivery Partner Registration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Highlight Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F5132), Color(0xFF1E7E34)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.electric_moped_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Join FPO Farm-to-Doorstep Fleet',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Earn ₹40–₹70 per drop • Daily Jan Dhan direct payouts • 100% genuine farm produce',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  'Driver & Identity Details',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),

                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name (as on Aadhaar/DL) *',
                    hintText: 'e.g. Mahesh Goud',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Please enter your full name' : null,
                ),
                const SizedBox(height: 14),

                // Phone Number
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number *',
                    hintText: '9876500112',
                    prefixIcon: Icon(Icons.phone_outlined),
                    prefixText: '+91 ',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter mobile number';
                    if (val.trim().length < 10) return 'Enter valid 10-digit number';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Driving License
                TextFormField(
                  controller: _dlController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Driving License (DL) Number *',
                    hintText: 'e.g. TS07-20230048192',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Enter driving license number' : null,
                ),

                const SizedBox(height: 24),

                Text(
                  'Vehicle & Operating Hub',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),

                // Vehicle Type selector
                Text(
                  'Vehicle Type',
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _vehicleOptions.map((v) {
                    final isSel = _selectedVehicle == v;
                    return ChoiceChip(
                      label: Text(v),
                      selected: isSel,
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: isSel ? AppColors.primary : Colors.black87,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12.5,
                      ),
                      onSelected: (sel) {
                        if (sel) setState(() => _selectedVehicle = v);
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 14),

                // Vehicle Plate
                TextFormField(
                  controller: _plateController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Registration Number *',
                    hintText: 'e.g. TS 07 EA 4821',
                    prefixIcon: Icon(Icons.pin_outlined),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Enter vehicle plate number' : null,
                ),

                const SizedBox(height: 14),

                // Assigned FPO Hub
                DropdownButtonFormField<String>(
                  initialValue: _selectedFpo,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Assigned FPO Cluster Hub *',
                    prefixIcon: Icon(Icons.hub_outlined),
                  ),
                  items: _fpoOptions.map((fpo) {
                    return DropdownMenuItem(
                      value: fpo,
                      child: Text(
                        fpo,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedFpo = val);
                  },
                ),

                const SizedBox(height: 24),

                Text(
                  'Daily Payout Direct Account',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Trip payments are instantly credited to this Jan Dhan UPI account upon customer delivery confirmation OTP.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),

                // Jan Dhan UPI
                TextFormField(
                  controller: _upiController,
                  decoration: const InputDecoration(
                    labelText: 'UPI ID / Jan Dhan VPA *',
                    hintText: 'e.g. mahesh.goud@sbi',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Enter UPI ID for payouts' : null,
                ),

                const SizedBox(height: 18),

                // Security & Guarantee Badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4FAF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD3EED8)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'KYC Verified via Telangana Transport & PM-Jan Dhan Yojana. 0% Commission deducted.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade900,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                PrimaryButton(
                  text: 'ACTIVATE DRIVER PROFILE',
                  icon: Icons.check_circle_outline,
                  isLoading: _isSubmitting,
                  onPressed: _handleRegister,
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
