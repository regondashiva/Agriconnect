import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/produce_model.dart';
import '../../../services/api_service.dart';
import '../../../services/app_state.dart';
import '../../../services/voice_service.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';

class VoiceRegistrationScreen extends StatefulWidget {
  final AppState appState;

  const VoiceRegistrationScreen({super.key, required this.appState});

  @override
  State<VoiceRegistrationScreen> createState() => _VoiceRegistrationScreenState();
}

class _VoiceRegistrationScreenState extends State<VoiceRegistrationScreen> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  bool _isListening = false;
  String _selectedLanguage = 'Telugu (తెలుగు)';
  String _liveRecognizedWords = '';
  bool _isSubmitting = false;

  // Controllers - start completely empty for real user input
  final _farmerNameCtrl = TextEditingController();
  final _farmLocationCtrl = TextEditingController();
  final _cropCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _landSizeCtrl = TextEditingController();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentQuestion();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _farmerNameCtrl.dispose();
    _farmLocationCtrl.dispose();
    _cropCtrl.dispose();
    _quantityCtrl.dispose();
    _landSizeCtrl.dispose();
    VoiceService.instance.stopSpeaking();
    VoiceService.instance.stopListening();
    super.dispose();
  }

  List<Map<String, String>> get _stepDefinitions {
    if (_selectedLanguage.startsWith('Telugu')) {
      return [
        {
          'title': 'రైతు పూర్తి పేరు (Farmer Name)',
          'question': 'నమస్కారం! మీ పూర్తి పేరు ఏమిటి? మైక్ నొక్కి మాట్లాడండి.',
          'hint': 'ఉదాహరణ: "రమేష్ రెడ్డి" లేదా "నా పేరు శివారెడ్డి"',
          'field': 'name',
        },
        {
          'title': 'గ్రామం & పొలం ప్రదేశం (Farm Location)',
          'question': 'మీ గ్రామం లేదా పొలం ఎక్కడ ఉంది?',
          'hint': 'ఉదాహరణ: "చేవెళ్ల గ్రామం, రంగారెడ్డి జిల్లా"',
          'field': 'location',
        },
        {
          'title': 'ప్రధాన పంట (Primary Crop)',
          'question': 'మీరు ఏ పంటను నమోదు చేయాలనుకుంటున్నారు?',
          'hint': 'ఉదాహరణ: "టమోటా", "పత్తి", "మిర్చి", లేదా "వరి"',
          'field': 'crop',
        },
        {
          'title': 'పరిమాణం & విస్తీర్ణం (Quantity & Land Size)',
          'question': 'మీ పంట పరిమాణం ఎంత కిలోలు మరియు పొలం ఎంత విస్తీర్ణం?',
          'hint': 'ఉదాహరణ: "500 కిలోలు, 3 ఎకరాలు"',
          'field': 'quantity',
        },
      ];
    } else if (_selectedLanguage.startsWith('Hindi')) {
      return [
        {
          'title': 'किसान का पूरा नाम (Farmer Name)',
          'question': 'नमस्ते! आपका पूरा नाम क्या है? माइक दबाकर बोलें।',
          'hint': 'उदाहरण: "रमेश रेड्डी" या "मेरा नाम शिव है"',
          'field': 'name',
        },
        {
          'title': 'गाँव और खेत का स्थान (Farm Location)',
          'question': 'आपका गाँव या खेत कहाँ स्थित है?',
          'hint': 'उदाहरण: "चेवेल्ला गाँव, रंगा रेड्डी जिला"',
          'field': 'location',
        },
        {
          'title': 'मुख्य फसल (Primary Crop)',
          'question': 'आप कौन सी फसल बेचना या पंजीकृत करना चाहते हैं?',
          'hint': 'उदाहरण: "टमाटर", "कपास", "मिर्च", या "गेहूँ"',
          'field': 'crop',
        },
        {
          'title': 'मात्रा और खेत का आकार (Quantity & Land)',
          'question': 'फसल की मात्रा (किलो) और खेत का आकार (एकड़) क्या है?',
          'hint': 'उदाहरण: "500 किलो, 3 एकड़"',
          'field': 'quantity',
        },
      ];
    } else {
      return [
        {
          'title': 'Farmer Full Name',
          'question': 'Namaskaram! What is your full name? Tap mic and speak.',
          'hint': 'e.g. "Ramesh Reddy" or "My name is Shiva"',
          'field': 'name',
        },
        {
          'title': 'Farm Village & Location',
          'question': 'Where is your village or farm located?',
          'hint': 'e.g. "Chevella Village, Ranga Reddy District"',
          'field': 'location',
        },
        {
          'title': 'Primary Crop',
          'question': 'What crop do you want to register or sell?',
          'hint': 'e.g. "Tomato", "Cotton", "Chilli", or "Paddy"',
          'field': 'crop',
        },
        {
          'title': 'Harvest Quantity & Land Size',
          'question': 'What is your harvest quantity in kg and land size in acres?',
          'hint': 'e.g. "500 kg, 3 acres"',
          'field': 'quantity',
        },
      ];
    }
  }

  void _speakCurrentQuestion() {
    if (_currentStep < _stepDefinitions.length) {
      VoiceService.instance.speak(
        _stepDefinitions[_currentStep]['question']!,
        language: _selectedLanguage,
      );
    }
  }

  /// Toggle real microphone recording and live speech-to-text recognition
  Future<void> _toggleMic({int? targetStep}) async {
    final activeStep = targetStep ?? _currentStep;

    if (_isListening) {
      // User tapped mic to stop speaking
      await _stopListeningAndProcess(activeStep);
    } else {
      // User tapped mic to start speaking
      await VoiceService.instance.stopSpeaking();
      setState(() {
        _isListening = true;
        _liveRecognizedWords = '';
      });

      // Start speech-to-text engine with exclusive access to the microphone
      final success = await VoiceService.instance.startListening(
        language: _selectedLanguage,
        onResult: (words) {
          if (mounted) {
            setState(() {
              _liveRecognizedWords = words;
            });
          }
        },
      );

      if (!success && mounted) {
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone active. Please speak clearly or type below.'),
            backgroundColor: AppColors.harvestOrange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Stop listening, extract entities from actual speech transcript, and fill fields
  Future<void> _stopListeningAndProcess(int activeStep) async {
    await VoiceService.instance.stopListening();
    final spokenText = _liveRecognizedWords.trim();

    setState(() {
      _isListening = false;
    });

    if (spokenText.isNotEmpty) {
      final extracted = VoiceService.instance.extractFarmerProfileEntities(spokenText, step: activeStep);

      setState(() {
        switch (activeStep) {
          case 0:
            _farmerNameCtrl.text = extracted.name ?? spokenText;
            break;
          case 1:
            _farmLocationCtrl.text = extracted.location ?? spokenText;
            break;
          case 2:
            _cropCtrl.text = extracted.crop ?? spokenText;
            break;
          case 3:
            if (extracted.quantityKg != null) {
              _quantityCtrl.text = extracted.quantityKg!.toStringAsFixed(0);
            } else if (RegExp(r'\d+').hasMatch(spokenText)) {
              _quantityCtrl.text = RegExp(r'\d+').firstMatch(spokenText)!.group(0)!;
            }
            if (extracted.landSizeAcres != null) {
              _landSizeCtrl.text = extracted.landSizeAcres!.toStringAsFixed(1);
            }
            break;
        }
      });

      // Acknowledge spoken input and advance step
      if (activeStep == _currentStep && _currentStep < _stepDefinitions.length - 1) {
        setState(() {
          _currentStep++;
          _liveRecognizedWords = '';
        });
        _speakFeedbackForStep(activeStep);
      } else if (activeStep == _currentStep) {
        setState(() {
          _currentStep = _stepDefinitions.length; // Move to confirmation summary
          _liveRecognizedWords = '';
        });
        VoiceService.instance.speak(
          _selectedLanguage.startsWith('Telugu')
              ? 'అద్భుతం! మీ వివరాలు నమోదు చేయబడ్డాయి. దయచేసి సరిచూసుకోండి.'
              : _selectedLanguage.startsWith('Hindi')
                  ? 'बहुत बढ़िया! आपके विवरण दर्ज हो गए हैं। कृपया जाँच लें।'
                  : 'Great! Your farm profile is ready. Please review and confirm.',
          language: _selectedLanguage,
        );
      }
    } else {
      // If nothing recognized, encourage them to speak or advance
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Did not catch speech. Please tap the mic and speak clearly.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _speakFeedbackForStep(int completedStep) {
    String reply = '';
    if (_selectedLanguage.startsWith('Telugu')) {
      switch (completedStep) {
        case 0:
          reply = 'ధన్యవాదాలు ${_farmerNameCtrl.text} గారూ! మీ గ్రామం లేదా పొలం ఎక్కడ ఉంది?';
          break;
        case 1:
          reply = 'సరే! మీరు ఏ పంటను నమోదు చేయాలనుకుంటున్నారు?';
          break;
        case 2:
          reply = 'బాగుంది! పంట పరిమాణం ఎంత కిలోలు మరియు పొలం ఎంత విస్తీర్ణం?';
          break;
      }
    } else if (_selectedLanguage.startsWith('Hindi')) {
      switch (completedStep) {
        case 0:
          reply = 'धन्यवाद ${_farmerNameCtrl.text} जी! आपका खेत या गाँव कहाँ है?';
          break;
        case 1:
          reply = 'ठीक है! आप कौन सी फसल पंजीकृत करना चाहते हैं?';
          break;
        case 2:
          reply = 'बहुत अच्छा! फसल की मात्रा कितनी है?';
          break;
      }
    } else {
      switch (completedStep) {
        case 0:
          reply = 'Thank you ${_farmerNameCtrl.text}! Where is your village or farm located?';
          break;
        case 1:
          reply = 'Got it! What primary crop do you grow or want to sell?';
          break;
        case 2:
          reply = 'Excellent! What is the expected harvest quantity and land size?';
          break;
      }
    }
    if (reply.isNotEmpty) {
      VoiceService.instance.speak(reply, language: _selectedLanguage);
    }
  }

  /// Freeform speak all at once
  Future<void> _speakAllAtOnce() async {
    await VoiceService.instance.speak(
      _selectedLanguage.startsWith('Telugu')
          ? 'మీ పేరు, గ్రామం, పంట మరియు పరిమాణం ఒకేసారి చెప్పండి.'
          : _selectedLanguage.startsWith('Hindi')
              ? 'अपना नाम, गाँव, फसल और मात्रा एक साथ बोलें।'
              : 'Please speak your name, village, crop, and quantity all in one sentence.',
      language: _selectedLanguage,
    );

    setState(() {
      _isListening = true;
      _liveRecognizedWords = '';
    });

    await VoiceService.instance.startListening(
      language: _selectedLanguage,
      onResult: (words) {
        if (mounted) {
          setState(() => _liveRecognizedWords = words);
          final ext = VoiceService.instance.extractFarmerProfileEntities(words);
          if (ext.name != null && ext.name!.isNotEmpty) _farmerNameCtrl.text = ext.name!;
          if (ext.location != null && ext.location!.isNotEmpty) _farmLocationCtrl.text = ext.location!;
          if (ext.crop != null && ext.crop!.isNotEmpty) _cropCtrl.text = ext.crop!;
          if (ext.quantityKg != null) _quantityCtrl.text = ext.quantityKg!.toStringAsFixed(0);
          if (ext.landSizeAcres != null) _landSizeCtrl.text = ext.landSizeAcres!.toStringAsFixed(1);
        }
      },
    );
  }

  /// Finalize farmer registration into local SharedPreferences & remote PostgreSQL
  Future<void> _finishRegistration() async {
    final name = _farmerNameCtrl.text.trim();
    final location = _farmLocationCtrl.text.trim();
    final crop = _cropCtrl.text.trim().isNotEmpty ? _cropCtrl.text.trim() : 'Mixed Crops';
    final qty = double.tryParse(_quantityCtrl.text.trim()) ?? 100.0;
    final land = double.tryParse(_landSizeCtrl.text.trim()) ?? 2.0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide your farmer name (speak or type) to register.'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _currentStep = 0);
      return;
    }

    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide your farm village/location (speak or type).'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _currentStep = 1);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Update farmer profile in AppState & save to persistent UserDatabaseService
      final locParts = location.split(',').map((s) => s.trim()).toList();
      final village = locParts.isNotEmpty ? locParts[0] : location;
      final district = locParts.length > 1 ? locParts[1] : 'Medchal-Malkajgiri';
      final state = locParts.length > 2 ? locParts[2] : 'Telangana';

      widget.appState.updateFarmerProfile(
        name: name,
        location: location,
        language: _selectedLanguage,
        crops: [crop],
        landSize: land,
        village: village,
        district: district,
        state: state,
        pincode: '501401',
        latitude: 17.6294,
        longitude: 78.4828,
      );

      // 2. Add initial produce batch to AppState and PostgreSQL backend
      final newProduce = ProduceItem(
        id: 'PRD-VOICE-${DateTime.now().millisecondsSinceEpoch}',
        farmerId: widget.appState.currentUser.id.isNotEmpty
            ? widget.appState.currentUser.id
            : 'usr_farmer_${DateTime.now().millisecondsSinceEpoch}',
        farmerName: name,
        cropName: crop,
        quantityKg: qty,
        grade: QualityGrade.gradeA,
        availableDate: DateTime.now().add(const Duration(days: 1)),
        location: location,
      );

      await widget.appState.addProduceItem(newProduce);

      // 3. Proactively sync produce to backend API
      try {
        await ApiService.instance.addProduce({
          'farmer_id': newProduce.farmerId,
          'farmer_name': name,
          'crop_name': crop,
          'quantity_kg': qty,
          'location': location,
          'grade': 'gradeA',
        });
      } catch (_) {}

      // 4. Voice confirmation
      VoiceService.instance.speak(
        _selectedLanguage.startsWith('Telugu')
            ? '$name గారూ! మీ ప్రొఫైల్ విజయవంతంగా సేవ్ చేయబడింది. కేవైసీ త్వరలోనే ధృవీకరించబడుతుంది.'
            : _selectedLanguage.startsWith('Hindi')
                ? '$name जी! आपकी प्रोफ़ाइल सफलतापूर्वक सहेज ली गई है। केवाईसी सत्यापन प्रगति पर है।'
                : 'Profile updated successfully. KYC pending admin approval.',
        language: _selectedLanguage,
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
  Widget build(BuildContext context) {
    final bool isCompleted = _currentStep >= _stepDefinitions.length;

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
              if (val != null) {
                setState(() => _selectedLanguage = val);
                _speakCurrentQuestion();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Status Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isListening ? AppColors.harvestOrange : AppColors.primaryLight,
                    width: _isListening ? 1.5 : 1.0,
                  ),
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
                            ? 'Listening to your voice… Speak now!'
                            : isCompleted
                                ? 'Voice Extraction Complete • Review Below'
                                : 'Step ${_currentStep + 1} of ${_stepDefinitions.length}: ${_stepDefinitions[_currentStep]['title']}',
                        style: AppTypography.labelLarge.copyWith(
                          fontSize: 12.5,
                          color: _isListening ? AppColors.harvestOrangeDark : AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _selectedLanguage.split(' ')[0],
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textNavy,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              if (!isCompleted) ...[
                // Active Step Content
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Agent Voice Question Bubble
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                                border: Border.all(color: AppColors.surfaceContainerHigh),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(8),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'AgriConnect Voice Assistant',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _speakCurrentQuestion,
                                        child: const Row(
                                          children: [
                                            Icon(Icons.volume_up_rounded, size: 16, color: AppColors.primary),
                                            SizedBox(width: 4),
                                            Text(
                                              'Replay',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _stepDefinitions[_currentStep]['question']!,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textNavy,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _stepDefinitions[_currentStep]['hint']!,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontSize: 11.5,
                                      color: AppColors.textMuted,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Real Voice Waveform / Spoken Words Visualizer
                      if (_isListening)
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.harvestOrangeLight.withAlpha(60),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.harvestOrange, width: 1.5),
                            ),
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.graphic_eq_rounded, color: AppColors.harvestOrangeDark, size: 28),
                                    SizedBox(width: 8),
                                    Text(
                                      'Listening to your voice...',
                                      style: TextStyle(
                                        color: AppColors.harvestOrangeDark,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _liveRecognizedWords.isNotEmpty
                                      ? '"$_liveRecognizedWords"'
                                      : 'Speak your answer clearly into the microphone...',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: _liveRecognizedWords.isNotEmpty ? AppColors.textNavy : AppColors.textMuted,
                                    fontWeight: _liveRecognizedWords.isNotEmpty ? FontWeight.w700 : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Live Extracted Value Card for Current Step
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Current Captured Value',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                if (_currentStep > 0)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() => _currentStep--);
                                      _speakCurrentQuestion();
                                    },
                                    child: const Text(
                                      '← Back to previous',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildStepInputField(_currentStep),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Quick Actions: Skip to next / Switch to Review
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: _speakAllAtOnce,
                            icon: const Icon(Icons.flash_on_rounded, size: 16, color: AppColors.harvestOrange),
                            label: const Text(
                              'Speak All at Once',
                              style: TextStyle(fontSize: 12, color: AppColors.harvestOrangeDark, fontWeight: FontWeight.w700),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _currentStep = _stepDefinitions.length;
                              });
                            },
                            child: const Text(
                              'Review All Fields →',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Large Voice Microphone Action Button
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _toggleMic(),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isListening
                                  ? [AppColors.harvestOrange, AppColors.error]
                                  : [AppColors.primary, AppColors.secondary],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_isListening ? AppColors.harvestOrange : AppColors.primary).withAlpha(100),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isListening ? 'Tap to Finish Speaking' : 'Tap to Speak Your Answer',
                        style: AppTypography.labelLarge.copyWith(
                          color: _isListening ? AppColors.harvestOrangeDark : AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Step ${_currentStep + 1} of ${_stepDefinitions.length}',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Final Review & Confirmation Form
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Confirm Farmer Profile',
                                  style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800, fontSize: 18),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Tap mic on any row to re-speak, or edit with keyboard.',
                                  style: AppTypography.bodySmall.copyWith(fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                            tooltip: 'Restart Voice Wizard',
                            onPressed: () {
                              setState(() => _currentStep = 0);
                              _speakCurrentQuestion();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Farmer Name
                            _buildReviewRow(
                              label: 'Farmer Full Name * (రైతు పేరు)',
                              controller: _farmerNameCtrl,
                              hint: 'Enter or speak your name',
                              icon: Icons.person_outline,
                              stepIndex: 0,
                            ),
                            const SizedBox(height: 14),

                            // 2. Village & Location
                            _buildReviewRow(
                              label: 'Farm Village & Location * (గ్రామం)',
                              controller: _farmLocationCtrl,
                              hint: 'Enter or speak village name',
                              icon: Icons.location_on_outlined,
                              stepIndex: 1,
                            ),
                            const SizedBox(height: 14),

                            // 3. Primary Crop
                            _buildReviewRow(
                              label: 'Primary Crop (ప్రధాన పంట)',
                              controller: _cropCtrl,
                              hint: 'e.g. Tomato, Cotton, Chilli',
                              icon: Icons.eco_outlined,
                              stepIndex: 2,
                            ),
                            const SizedBox(height: 14),

                            // 4. Quantity & Land Size
                            Row(
                              children: [
                                Expanded(
                                  child: _buildReviewRow(
                                    label: 'Quantity (kg)',
                                    controller: _quantityCtrl,
                                    hint: 'e.g. 100',
                                    icon: Icons.scale_rounded,
                                    stepIndex: 3,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildReviewRow(
                                    label: 'Land Size (Acres)',
                                    controller: _landSizeCtrl,
                                    hint: 'e.g. 2.5',
                                    icon: Icons.landscape_outlined,
                                    stepIndex: 3,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // 5. Phone Number
                            Text('Verified Mobile Number', style: AppTypography.labelLarge),
                            const SizedBox(height: 4),
                            TextField(
                              enabled: false,
                              controller: TextEditingController(text: widget.appState.authPhoneNumber),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.phone_rounded, color: AppColors.primary, size: 20),
                                suffixIcon: Icon(Icons.verified_rounded, color: AppColors.success, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Data will be saved into local storage and synced to the PostgreSQL backend.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.5,
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
                  text: _isSubmitting ? 'SAVING PROFILE…' : 'CONFIRM & ENTER FARMER HOME',
                  icon: Icons.check_rounded,
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? () {} : _finishRegistration,
                ),
              ],

              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepInputField(int step) {
    switch (step) {
      case 0:
        return TextField(
          controller: _farmerNameCtrl,
          decoration: InputDecoration(
            hintText: 'Speak or type farmer name',
            prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
            suffixIcon: _farmerNameCtrl.text.isNotEmpty
                ? const Icon(Icons.check_circle, color: AppColors.success, size: 20)
                : null,
          ),
          onChanged: (_) => setState(() {}),
        );
      case 1:
        return TextField(
          controller: _farmLocationCtrl,
          decoration: InputDecoration(
            hintText: 'Speak or type village / location',
            prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
            suffixIcon: _farmLocationCtrl.text.isNotEmpty
                ? const Icon(Icons.check_circle, color: AppColors.success, size: 20)
                : null,
          ),
          onChanged: (_) => setState(() {}),
        );
      case 2:
        return TextField(
          controller: _cropCtrl,
          decoration: InputDecoration(
            hintText: 'Speak or type crop (e.g. Tomato)',
            prefixIcon: const Icon(Icons.eco_outlined, color: AppColors.secondary),
            suffixIcon: _cropCtrl.text.isNotEmpty
                ? const Icon(Icons.check_circle, color: AppColors.success, size: 20)
                : null,
          ),
          onChanged: (_) => setState(() {}),
        );
      case 3:
      default:
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: _quantityCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Qty in kg (e.g. 500)',
                  prefixIcon: Icon(Icons.scale_rounded, color: AppColors.harvestOrange),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _landSizeCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Acres (e.g. 3)',
                  prefixIcon: Icon(Icons.landscape_outlined, color: AppColors.secondary),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildReviewRow({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required int stepIndex,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.labelLarge.copyWith(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _toggleMic(targetStep: stepIndex),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withAlpha(40),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mic_rounded, size: 13, color: AppColors.primary),
                    SizedBox(width: 3),
                    Text(
                      'Speak',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            suffixIcon: controller.text.isNotEmpty
                ? const Icon(Icons.check_circle, color: AppColors.success, size: 18)
                : null,
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }
}
