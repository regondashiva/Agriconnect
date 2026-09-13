import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/user_model.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';

class ConsumerRegistrationScreen extends StatefulWidget {
  final AppState appState;

  const ConsumerRegistrationScreen({super.key, required this.appState});

  @override
  State<ConsumerRegistrationScreen> createState() => _ConsumerRegistrationScreenState();
}

class _ConsumerRegistrationScreenState extends State<ConsumerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _localityController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  bool _isSubmitting = false;

  void _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final locality = _localityController.text.trim();
    final city = _cityController.text.trim();
    final pincode = _pincodeController.text.trim();

    // Construct unified delivery address
    final fullLocation = [
      address,
      if (locality.isNotEmpty) locality,
      if (city.isNotEmpty) city,
      if (pincode.isNotEmpty) 'PIN: $pincode',
    ].join(', ');

    setState(() => _isSubmitting = true);

    try {
      widget.appState.registerNewUser(
        name: name,
        role: UserRole.consumer,
        location: fullLocation,
        pincode: pincode.isNotEmpty ? pincode : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully. KYC pending admin approval.'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/consumer/home', (r) => false);
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
    _addressController.dispose();
    _localityController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDFD),
      appBar: AppBar(
        title: const Text('Household Registration'),
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
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFFD97706), size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  'Create Household Account',
                  style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  'Buy fresh farm produce directly from farmer clusters with zero middleman markup.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 24),

                Text('Your Full Name *', style: AppTypography.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Priya Sharma / Ramesh Rao',
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    if (val.trim().length < 2) {
                      return 'Name is too short';
                    }
                    return null;
                  },
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

                Text('House / Flat & Street Address *', style: AppTypography.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Flat 402, Green Meadows Apartment',
                    prefixIcon: Icon(Icons.home_outlined, color: AppColors.secondary),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your street address';
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
                          Text('Locality / Area', style: AppTypography.labelLarge),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _localityController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Madhapur',
                              prefixIcon: Icon(Icons.map_outlined, color: AppColors.textNavy, size: 20),
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
                          Text('City / District *', style: AppTypography.labelLarge),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Hyderabad',
                              prefixIcon: Icon(Icons.location_city_outlined, color: AppColors.primary, size: 20),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text('PIN Code *', style: AppTypography.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 500081',
                    prefixIcon: Icon(Icons.pin_drop_outlined, color: AppColors.primary),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().length < 6) {
                      return 'Please enter a valid 6-digit PIN code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                PrimaryButton(
                  text: _isSubmitting ? 'CREATING ACCOUNT…' : 'START SHOPPING FRESH PRODUCE',
                  icon: Icons.shopping_basket_outlined,
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
