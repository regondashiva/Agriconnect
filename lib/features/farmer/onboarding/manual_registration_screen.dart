import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';

class ManualRegistrationScreen extends StatefulWidget {
  final AppState appState;

  const ManualRegistrationScreen({super.key, required this.appState});

  @override
  State<ManualRegistrationScreen> createState() => _ManualRegistrationScreenState();
}

class _ManualRegistrationScreenState extends State<ManualRegistrationScreen> {
  final _nameController = TextEditingController(text: 'Ramesh Reddy');
  final _locationController = TextEditingController(text: 'Chevella Village, Ranga Reddy Dist');
  final _cropsController = TextEditingController(text: 'Tomato, Potato, Chillies');
  String _selectedLang = 'Telugu / English';

  void _handleSave() {
    widget.appState.updateFarmerProfile(
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      language: _selectedLang,
    );
    Navigator.pushNamedAndRemoveUntil(context, '/farmer/home', (r) => false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _cropsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manual Farm Registration'),
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
              Text(
                'Complete Your Profile',
                style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                'Help local FPOs and wholesale buyers discover your produce.',
                style: AppTypography.bodySmall,
              ),

              const SizedBox(height: 24),

              Text('Full Name', style: AppTypography.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Enter farmer name'),
              ),

              const SizedBox(height: 16),

              Text('Mobile Number', style: AppTypography.labelLarge),
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

              Text('Farm Location & Village', style: AppTypography.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'Village, Mandal, District',
                  prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 16),

              Text('Primary Harvest Crops', style: AppTypography.labelLarge),
              const SizedBox(height: 6),
              TextField(
                controller: _cropsController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Tomato, Potato, Onion',
                  prefixIcon: Icon(Icons.eco_outlined, color: AppColors.secondary),
                ),
              ),

              const SizedBox(height: 16),

              Text('Preferred Language', style: AppTypography.labelLarge),
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
                    value: _selectedLang,
                    items: const [
                      DropdownMenuItem(value: 'Telugu / English', child: Text('Telugu / English')),
                      DropdownMenuItem(value: 'Hindi / English', child: Text('Hindi / English')),
                      DropdownMenuItem(value: 'English', child: Text('English Only')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedLang = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              PrimaryButton(
                text: 'SAVE & ENTER FARMER HOME',
                icon: Icons.check_circle_outline,
                onPressed: _handleSave,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
