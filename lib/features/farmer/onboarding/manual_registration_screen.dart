import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/app_state.dart';
import '../../../services/voice_service.dart';
import '../../../shared/widgets/app_buttons.dart';

class ManualRegistrationScreen extends StatefulWidget {
  final AppState appState;

  const ManualRegistrationScreen({super.key, required this.appState});

  @override
  State<ManualRegistrationScreen> createState() => _ManualRegistrationScreenState();
}

class _ManualRegistrationScreenState extends State<ManualRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _cropsController = TextEditingController();
  final _landSizeController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _upiController = TextEditingController();
  String _selectedLang = 'Telugu / English';
  bool _isSubmitting = false;
  bool _isListening = false;

  Future<void> _listenForField(TextEditingController controller, {int? step}) async {
    if (_isListening) {
      await VoiceService.instance.stopListening();
      setState(() => _isListening = false);
      return;
    }

    setState(() => _isListening = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Listening... speak now into the microphone'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );

    final lang = _selectedLang.contains('Hindi') ? 'Hindi' : 'Telugu';
    await VoiceService.instance.startListening(
      language: lang,
      onResult: (words) {
        if (mounted) {
          final ext = VoiceService.instance.extractFarmerProfileEntities(words, step: step);
          setState(() {
            if (step == 0) {
              controller.text = ext.name ?? words;
            } else if (step == 1) {
              controller.text = ext.location ?? words;
            } else if (step == 2) {
              controller.text = ext.crop ?? words;
            } else if (step == 3) {
              controller.text = ext.landSizeAcres?.toStringAsFixed(1) ?? words;
            } else {
              controller.text = words;
            }
          });
        }
      },
    );
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final location = _locationController.text.trim();
    final cropsText = _cropsController.text.trim();
    final landText = _landSizeController.text.trim();
    final bankName = _bankNameController.text.trim();
    final upiId = _upiController.text.trim();

    final cropList = cropsText.isNotEmpty
        ? cropsText.split(RegExp(r'[,;/]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList()
        : <String>[];

    final locParts = location.split(',').map((s) => s.trim()).toList();
    final village = locParts.isNotEmpty ? locParts[0] : location;
    final district = locParts.length > 1 ? locParts[1] : 'Medchal-Malkajgiri';
    final state = locParts.length > 2 ? locParts[2] : 'Telangana';

    setState(() => _isSubmitting = true);

    try {
      widget.appState.updateFarmerProfile(
        name: name,
        location: location,
        language: _selectedLang,
        crops: cropList.isNotEmpty ? cropList : null,
        landSize: double.tryParse(landText),
        bankName: bankName.isNotEmpty ? bankName : null,
        upiId: upiId.isNotEmpty ? upiId : null,
        village: village,
        district: district,
        state: state,
        pincode: '501401',
        latitude: 17.6294,
        longitude: 78.4828,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully. KYC pending admin approval.'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/farmer/home', (r) => false);
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
    _locationController.dispose();
    _cropsController.dispose();
    _landSizeController.dispose();
    _bankNameController.dispose();
    _upiController.dispose();
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete Your Farm Profile',
                  style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter your details to connect with local FPO aggregation clusters and direct buyers.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 24),

                Text('Farmer Full Name * (రైతు పేరు)', style: AppTypography.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Ramesh Reddy / రామిరెడ్డి',
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.mic_rounded, color: AppColors.primary, size: 20),
                      tooltip: 'Speak Name',
                      onPressed: () => _listenForField(_nameController, step: 0),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter farmer name';
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

                Text('Farm Village, Mandal & District * (గ్రామం, మండలం)', style: AppTypography.labelLarge),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Chevella Village, Ranga Reddy Dist, Telangana',
                    prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.mic_rounded, color: AppColors.primary, size: 20),
                      tooltip: 'Speak Village/Location',
                      onPressed: () => _listenForField(_locationController, step: 1),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter farm village and district';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Primary Crops Grown', style: AppTypography.labelLarge),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _cropsController,
                            decoration: InputDecoration(
                              hintText: 'e.g. Tomato, Cotton, Chilli',
                              prefixIcon: const Icon(Icons.eco_outlined, color: AppColors.secondary, size: 20),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.mic_rounded, color: AppColors.secondary, size: 20),
                                tooltip: 'Speak Crop',
                                onPressed: () => _listenForField(_cropsController, step: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Land (Acres)', style: AppTypography.labelLarge),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _landSizeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'e.g. 3.5',
                              prefixIcon: const Icon(Icons.landscape_outlined, color: AppColors.primary, size: 20),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.mic_rounded, color: AppColors.primary, size: 18),
                                tooltip: 'Speak Land Size',
                                onPressed: () => _listenForField(_landSizeController, step: 3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text('Preferred Communication Language', style: AppTypography.labelLarge),
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
                        DropdownMenuItem(value: 'Telugu / English', child: Text('Telugu / English (తెలుగు)')),
                        DropdownMenuItem(value: 'Hindi / English', child: Text('Hindi / English (हिन्दी)')),
                        DropdownMenuItem(value: 'English', child: Text('English Only')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedLang = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jan Dhan / Bank Name (Optional)', style: AppTypography.labelLarge),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _bankNameController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. SBI Jan Dhan / APGB',
                              prefixIcon: Icon(Icons.account_balance_outlined, color: AppColors.textNavy, size: 20),
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
                          Text('UPI ID for DBT (Optional)', style: AppTypography.labelLarge),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _upiController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. farmer@upi',
                              prefixIcon: Icon(Icons.payments_outlined, color: AppColors.harvestOrange, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                PrimaryButton(
                  text: _isSubmitting ? 'SAVING PROFILE…' : 'SAVE & ENTER FARMER HOME',
                  icon: Icons.check_circle_outline,
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? () {} : _handleSave,
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
