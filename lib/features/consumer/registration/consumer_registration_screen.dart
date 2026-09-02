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
  final _nameController = TextEditingController(text: 'Ananya Sharma');
  final _addressController = TextEditingController(text: 'Flat 402, Green Meadows, Madhapur, Hyderabad');

  void _handleCreateAccount() {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name and delivery address'), backgroundColor: AppColors.error),
      );
      return;
    }

    widget.appState.registerNewUser(
      name: name,
      role: UserRole.consumer,
      location: address,
    );

    Navigator.pushNamedAndRemoveUntil(context, '/consumer/home', (r) => false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
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

              Text('Your Full Name', style: AppTypography.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Ananya Sharma',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
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

              Text('Home Delivery Address', style: AppTypography.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Flat/House No, Apartment/Street, City, Pincode',
                  prefixIcon: Icon(Icons.home_outlined, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                text: 'START SHOPPING FRESH PRODUCE',
                icon: Icons.shopping_basket_outlined,
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
