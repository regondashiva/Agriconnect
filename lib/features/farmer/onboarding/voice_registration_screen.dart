import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';

class VoiceRegistrationScreen extends StatefulWidget {
  final AppState appState;

  const VoiceRegistrationScreen({super.key, required this.appState});

  @override
  State<VoiceRegistrationScreen> createState() => _VoiceRegistrationScreenState();
}

class _VoiceRegistrationScreenState extends State<VoiceRegistrationScreen> {
  int _currentStep = 0;
  bool _isListening = false;
  String _selectedLanguage = 'Telugu (తెలుగు)';

  final List<Map<String, dynamic>> _dialogueSteps = [
    {
      'agent': 'Namaskaram! What crop do you want to register or sell?',
      'farmerAudio': 'Tomatoes (టమోటా)',
      'extractedKey': 'Primary Crop',
      'extractedVal': 'Tomato (Hybrid Red)',
    },
    {
      'agent': 'How much produce do you expect to harvest?',
      'farmerAudio': '100 kilos from Chevella field',
      'extractedKey': 'Quantity & Location',
      'extractedVal': '100 kg • Chevella Village',
    },
    {
      'agent': 'Great! What quality grade is the produce?',
      'farmerAudio': 'Fresh Grade A, clean red color',
      'extractedKey': 'Quality Grade',
      'extractedVal': 'Grade A (Low defect risk)',
    },
  ];

  Map<String, String> get _extractedSummary => {
    'Farmer Name': 'Ramesh Reddy',
    'Mobile': widget.appState.authPhoneNumber,
    'Primary Crop': 'Tomato (Hybrid Red)',
    'Expected Quantity': '100 kg',
    'Farm Location': 'Chevella Village, Ranga Reddy',
    'Preferred Language': _selectedLanguage,
  };

  void _triggerVoiceResponse() {
    setState(() => _isListening = true);

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() {
        _isListening = false;
        if (_currentStep < _dialogueSteps.length - 1) {
          _currentStep++;
        } else {
          _currentStep = _dialogueSteps.length; // Summary state
        }
      });
    });
  }

  void _finishRegistration() {
    widget.appState.updateFarmerProfile(
      name: 'Ramesh Reddy',
      location: 'Chevella Village, Ranga Reddy',
      language: _selectedLanguage,
    );
    Navigator.pushNamedAndRemoveUntil(context, '/farmer/home', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = _currentStep >= _dialogueSteps.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Voice Agent Registration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          DropdownButton<String>(
            value: _selectedLanguage,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'Telugu (తెలుగు)', child: Text('తెలుగు')),
              DropdownMenuItem(value: 'Hindi (हिन्दी)', child: Text('हिन्दी')),
              DropdownMenuItem(value: 'English', child: Text('English')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedLanguage = val);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Voice Visualizer Status Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryLight),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _isListening ? AppColors.harvestOrange : AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isListening
                            ? 'Listening to Farmer Voice…'
                            : isCompleted
                                ? 'Voice Extraction Complete'
                                : 'AgriConnect Voice Assistant Active',
                        style: AppTypography.labelLarge.copyWith(
                          fontSize: 12.5,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _selectedLanguage.split(' ')[0],
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textNavy,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              if (!isCompleted) ...[
                // Active Conversation Bubbles
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Agent Prompt Bubble
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primaryContainer,
                            child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(14),
                                  bottomLeft: Radius.circular(14),
                                  bottomRight: Radius.circular(14),
                                ),
                                border: Border.all(color: AppColors.surfaceContainerHigh),
                              ),
                              child: Text(
                                _dialogueSteps[_currentStep]['agent'] as String,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textNavy,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Farmer Response (if answered or spoken)
                      if (_isListening)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.graphic_eq_rounded, color: AppColors.harvestOrange, size: 24),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Speaking: "${_dialogueSteps[_currentStep]['farmerAudio']}"',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.harvestOrangeDark,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),

                      // Live Extracted Field Preview
                      AppCard(
                        backgroundColor: AppColors.surfaceContainer,
                        borderColor: AppColors.primaryLight,
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'AI Extraction: ',
                              style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 11),
                            ),
                            Expanded(
                              child: Text(
                                '${_dialogueSteps[_currentStep]['extractedKey']} → ${_dialogueSteps[_currentStep]['extractedVal']}',
                                style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Voice Mic Button
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _isListening ? null : _triggerVoiceResponse,
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(80),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isListening ? 'Listening…' : 'Tap to Speak Answer',
                        style: AppTypography.labelLarge.copyWith(color: AppColors.primary, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Step ${_currentStep + 1} of ${_dialogueSteps.length}',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Final Extracted Summary Card
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      Text(
                        'Extracted Farmer Profile',
                        style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Verify the details captured from your voice interaction before proceeding.',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11.5),
                      ),
                      const SizedBox(height: 14),
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: _extractedSummary.entries.map((e) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 110,
                                    child: Text(
                                      e.key,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      e.value,
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textNavy,
                                        fontSize: 12.5,
                                      ),
                                      textAlign: TextAlign.end,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Account verified and ready to match with wholesale buyers.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                PrimaryButton(
                  text: 'CONFIRM & ENTER FARMER HOME',
                  icon: Icons.check_rounded,
                  onPressed: _finishRegistration,
                ),
              ],

              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
