import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/user_model.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';

class FpoRegistrationScreen extends StatefulWidget {
  final AppState appState;

  const FpoRegistrationScreen({super.key, required this.appState});

  @override
  State<FpoRegistrationScreen> createState() => _FpoRegistrationScreenState();
}

class _FpoRegistrationScreenState extends State<FpoRegistrationScreen> {
  final _fpoNameController = TextEditingController(text: 'Ranga Reddy Farmers Producer Co-op');
  final _regIdController = TextEditingController(text: 'FPO-TS-RR-2026-089');
  final _contactPersonController = TextEditingController(text: 'Suresh Rao');
  final _locationController = TextEditingController(text: 'Shabad Center, Hyderabad Rural, Telangana');

  void _handleCreateAccount() {
    final fpoName = _fpoNameController.text.trim();
    final contact = _contactPersonController.text.trim();
    final location = _locationController.text.trim();

    if (fpoName.isEmpty || contact.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all mandatory fields'), backgroundColor: AppColors.error),
      );
      return;
    }

    widget.appState.registerNewUser(
      name: contact,
      role: UserRole.fpo,
      location: location,
      businessName: fpoName,
      fpoCluster: fpoName,
    );

    Navigator.pushNamedAndRemoveUntil(context, '/fpo/home', (r) => false);
  }

  @override
  void dispose() {
    _fpoNameController.dispose();
    _regIdController.dispose();
    _contactPersonController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDFD),
      appBar: AppBar(
        title: const Text('FPO Registration'),
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
                child: const Icon(Icons.hub_rounded, color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'Register FPO Coordinator Profile',
                style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                'Aggregate local farmer clusters and fulfill wholesale buyer contracts.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 24),

              Text('FPO / Cooperative Name', style: AppTypography.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: _fpoNameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Ranga Reddy Farmers Producer Co-op',
                  prefixIcon: Icon(Icons.business_rounded, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),

              Text('Organization / Registration ID', style: AppTypography.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: _regIdController,
                decoration: const InputDecoration(
                  hintText: 'e.g. FPO-TS-RR-2026-089',
                  prefixIcon: Icon(Icons.badge_outlined, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 16),

              Text('Contact Person (Coordinator Name)', style: AppTypography.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: _contactPersonController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Suresh Rao',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.textNavy),
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

              Text('Hub Location / Center Address', style: AppTypography.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Shabad Center, Hyderabad Rural',
                  prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                text: 'CREATE ACCOUNT & ENTER FPO HOME',
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
