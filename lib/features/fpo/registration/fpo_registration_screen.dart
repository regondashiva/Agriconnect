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
  final _formKey = GlobalKey<FormState>();
  final _fpoNameController = TextEditingController();
  final _regIdController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _locationController = TextEditingController();
  final _operatingDistrictsController = TextEditingController();
  final _membersCountController = TextEditingController();
  final _capacityController = TextEditingController();
  final _coldStorageController = TextEditingController();
  bool _isSubmitting = false;

  void _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fpoName = _fpoNameController.text.trim();
    final contact = _contactPersonController.text.trim();
    final location = _locationController.text.trim();
    final regId = _regIdController.text.trim();
    final districtsText = _operatingDistrictsController.text.trim();
    final membersText = _membersCountController.text.trim();
    final capacityText = _capacityController.text.trim();
    final coldStorageText = _coldStorageController.text.trim();

    final opDistricts = districtsText.isNotEmpty
        ? districtsText.split(RegExp(r'[,;/]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList()
        : (location.isNotEmpty ? [location] : ['Medchal', 'Hyderabad']);
    final coldStorage = double.tryParse(coldStorageText) ?? double.tryParse(capacityText) ?? 50.0;

    setState(() => _isSubmitting = true);

    try {
      widget.appState.registerNewUser(
        name: contact,
        role: UserRole.fpo,
        location: location,
        businessName: fpoName,
        fpoCluster: fpoName,
        registrationId: regId.isNotEmpty ? regId : 'FPO-TS-2024-991',
        memberCount: int.tryParse(membersText),
        capacityTons: double.tryParse(capacityText),
        operatingDistricts: opDistricts,
        coldStorageCapacityMt: coldStorage,
        latitude: 17.6300,
        longitude: 78.4850,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully. KYC pending admin approval.'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/fpo/home', (r) => false);
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
    _fpoNameController.dispose();
    _regIdController.dispose();
    _contactPersonController.dispose();
    _locationController.dispose();
    _operatingDistrictsController.dispose();
    _membersCountController.dispose();
    _capacityController.dispose();
    _coldStorageController.dispose();
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

                Text('FPO / Cooperative Society Name *', style: AppTypography.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _fpoNameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Ranga Reddy Organic Producers FPO',
                    prefixIcon: Icon(Icons.business_rounded, color: AppColors.primary),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter FPO organization name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Text('Organization / Registration CIN Number', style: AppTypography.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _regIdController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. FPO-TS-RR-2026-089',
                    prefixIcon: Icon(Icons.badge_outlined, color: AppColors.secondary),
                  ),
                ),
                const SizedBox(height: 16),

                Text('Lead Coordinator / Director Name *', style: AppTypography.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _contactPersonController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Suresh Rao / Venkatesh Reddy',
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.textNavy),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter coordinator name';
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

                Text('Central Aggregation Hub / Office Location *', style: AppTypography.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Shabad Center, Hyderabad Rural, Telangana',
                    prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter central hub location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Text('Operating Districts (కార్యాచరణ జిల్లాలు)', style: AppTypography.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _operatingDistrictsController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Medchal, Hyderabad, Ranga Reddy',
                    prefixIcon: Icon(Icons.map_outlined, color: AppColors.secondary),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Member Farmers', style: AppTypography.labelLarge),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _membersCountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 50',
                              prefixIcon: Icon(Icons.groups_outlined, color: AppColors.primary, size: 20),
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
                          Text('Cold Storage (MT)', style: AppTypography.labelLarge),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _coldStorageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 50.0',
                              prefixIcon: Icon(Icons.ac_unit_rounded, color: AppColors.harvestOrange, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                PrimaryButton(
                  text: _isSubmitting ? 'REGISTERING FPO…' : 'CREATE ACCOUNT & ENTER FPO HOME',
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
