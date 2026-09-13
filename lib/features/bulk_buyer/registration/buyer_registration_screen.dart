import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/user_model.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';

class BuyerRegistrationScreen extends StatefulWidget {
  final AppState appState;

  const BuyerRegistrationScreen({super.key, required this.appState});

  @override
  State<BuyerRegistrationScreen> createState() => _BuyerRegistrationScreenState();
}

class _BuyerRegistrationScreenState extends State<BuyerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _gstinController = TextEditingController();
  final _volumeController = TextEditingController();
  String _businessType = 'Wholesale Mandi Trader';
  bool _isSubmitting = false;

  void _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final business = _businessNameController.text.trim();
    final location = _locationController.text.trim();
    final gstin = _gstinController.text.trim();
    final volumeText = _volumeController.text.trim();
    final volume = double.tryParse(volumeText);

    setState(() => _isSubmitting = true);

    try {
      widget.appState.registerNewUser(
        name: name,
        role: UserRole.bulkBuyer,
        location: location,
        businessName: business,
        businessType: _businessType,
        registrationId: gstin.isNotEmpty ? gstin : null,
        monthlyVolumeTons: volume,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully. KYC pending admin approval.'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/buyer/home', (r) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _locationController.dispose();
    _gstinController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDFD),
      appBar: AppBar(
        title: const Text('Bulk Buyer Registration'),
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
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  'Register Bulk Buyer Account',
                  style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  'Source aggregated fresh farm produce with AI quality validation and direct dispatch.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 24),

                Text('Authorized Representative Name *', style: AppTypography.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Vikram Mehta / Rajesh Agarwal',
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter representative name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Text('Enterprise / Business / Mandi Firm Name *', style: AppTypography.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _businessNameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. FreshBasket Wholesale Pvt Ltd',
                    prefixIcon: Icon(Icons.store_mall_directory_outlined, color: AppColors.secondary),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter enterprise or firm name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Text('Business Type *', style: AppTypography.labelLarge),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant, width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _businessType,
                      items: const [
                        DropdownMenuItem(value: 'Wholesale Mandi Trader', child: Text('Wholesale Mandi Trader')),
                        DropdownMenuItem(value: 'Supermarket / Retail Chain', child: Text('Supermarket / Retail Chain')),
                        DropdownMenuItem(value: 'Food Processing Company', child: Text('Food Processing Company')),
                        DropdownMenuItem(value: 'Institutional / HoReCa Buyer', child: Text('Institutional / HoReCa Buyer')),
                        DropdownMenuItem(value: 'Exporter / Aggregator', child: Text('Exporter / Aggregator')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _businessType = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text('Verified Mobile Number', style: AppTypography.labelLarge),
                const SizedBox(height: 6),
                TextField(
                  enabled: false,
                  controller: TextEditingController(text: widget.appState.authPhoneNumber),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone_rounded, color: AppColors.primary),
                    suffixIcon: Icon(Icons.verified_rounded, color: AppColors.success),
                  ),
                ),
                const SizedBox(height: 16),

                Text('Receiving Hub / Mandi Warehouse Location *', style: AppTypography.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Kothapet Wholesale Mandi, Hyderabad, Telangana',
                    prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter receiving location address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('GSTIN / License (Optional)', style: AppTypography.labelLarge),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _gstinController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 36AABCF1234Z1ZX',
                              prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textNavy, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Monthly Vol. (Tons)', style: AppTypography.labelLarge),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _volumeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 50',
                              prefixIcon: Icon(Icons.scale_rounded, color: AppColors.harvestOrange, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                PrimaryButton(
                  text: _isSubmitting ? 'CREATING ACCOUNT…' : 'CREATE ACCOUNT & ENTER BUYER HOME',
                  icon: Icons.check_circle_outline,
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? () {} : _handleCreateAccount,
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
