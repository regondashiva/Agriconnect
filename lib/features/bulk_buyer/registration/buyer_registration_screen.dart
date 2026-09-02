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
  final _nameController = TextEditingController(text: 'Vikram Mehta');
  final _businessNameController = TextEditingController(text: 'FreshBasket Wholesale Mandi');
  final _locationController = TextEditingController(text: 'Kothapet Wholesale Mandi, Hyderabad');
  String _businessType = 'Wholesale Mandi Trader';

  void _handleCreateAccount() {
    final name = _nameController.text.trim();
    final business = _businessNameController.text.trim();
    final location = _locationController.text.trim();

    if (name.isEmpty || business.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.error),
      );
      return;
    }

    widget.appState.registerNewUser(
      name: name,
      role: UserRole.bulkBuyer,
      location: location,
      businessName: business,
    );

    Navigator.pushNamedAndRemoveUntil(context, '/buyer/home', (r) => false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _locationController.dispose();
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

              Text('Authorized Representative Name', style: AppTypography.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Vikram Mehta',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),

              Text('Business / Organization Name', style: AppTypography.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: _businessNameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. FreshBasket Wholesale Pvt Ltd',
                  prefixIcon: Icon(Icons.store_mall_directory_outlined, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 16),

              Text('Business Type', style: AppTypography.labelLarge),
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
                  prefixIcon: Icon(Icons.phone_rounded, color: AppColors.textMuted),
                  suffixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 16),

              Text('Receiving Hub / Delivery Mandi Location', style: AppTypography.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Kothapet Wholesale Mandi, Hyderabad',
                  prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                text: 'CREATE ACCOUNT & ENTER BUYER HOME',
                icon: Icons.check_circle_outline,
                onPressed: _handleCreateAccount,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
