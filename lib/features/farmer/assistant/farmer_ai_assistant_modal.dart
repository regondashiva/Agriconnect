import 'dart:async';
import 'package:flutter/material.dart';
import '../../../services/app_state.dart';

class FarmerAiAssistantModal extends StatefulWidget {
  final AppState appState;

  const FarmerAiAssistantModal({super.key, required this.appState});

  static void show(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FarmerAiAssistantModal(appState: appState),
    );
  }

  @override
  State<FarmerAiAssistantModal> createState() => _FarmerAiAssistantModalState();
}

class _FarmerAiAssistantModalState extends State<FarmerAiAssistantModal>
    with SingleTickerProviderStateMixin {
  String _selectedLang = 'Telugu'; // 'Telugu', 'Hindi', 'English'
  bool _isListening = false;
  bool _isProcessing = false;
  String? _lastSpokenQuery;
  String? _aiResponseText;
  String? _suggestedActionRoute;
  String? _suggestedActionLabel;

  late AnimationController _pulseController;
  Timer? _listeningTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.95,
      upperBound: 1.15,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _listeningTimer?.cancel();
    super.dispose();
  }

  void _handleSimulatedVoiceTap(String query, String response, {String? route, String? actionLabel}) {
    setState(() {
      _isListening = true;
      _isProcessing = false;
      _lastSpokenQuery = query;
      _aiResponseText = null;
      _suggestedActionRoute = null;
      _suggestedActionLabel = null;
    });

    _listeningTimer?.cancel();
    _listeningTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _isProcessing = true;
      });

      _listeningTimer = Timer(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
          _aiResponseText = response;
          _suggestedActionRoute = route;
          _suggestedActionLabel = actionLabel;
        });
      });
    });
  }

  void _startLiveMic() {
    final defaultQueries = {
      'Telugu': {
        'query': 'నా టొమాటోకి మంచి ధర ఎక్కడ ఉంది?',
        'response': 'మీ టొమాటోలకు ఫ్రెష్‌బాస్కెట్ మండి వద్ద కిలో ₹20 ధరతో 500 కిలోల బల్క్ డిమాండ్ ఉంది! మీ 100 కిలోల పంటకు ₹2,000 తక్షణ చెల్లింపు లభిస్తుంది.',
        'route': '/farmer/matches',
        'label': 'బయ్యర్ అవకాశాలను చూడండి (View Matches)',
      },
      'Hindi': {
        'query': 'मेरे टमाटर का अच्छा दाम कहाँ मिलेगा?',
        'response': 'आपके टमाटर के लिए फ्रेशबास्केट मंडी में ₹20/किलो पर 500 किलो की मांग है। आपके 100 किलो के लिए ₹2,000 का भुगतान तुरंत मिलेगा।',
        'route': '/farmer/matches',
        'label': 'खरीदार के सौदे देखें (View Matches)',
      },
      'English': {
        'query': 'Where can I get the best price for my tomatoes?',
        'response': 'FreshBasket Mandi has a 500 kg bulk demand at ₹20/kg! You have a 92% match score with estimated ₹2,000 payout.',
        'route': '/farmer/matches',
        'label': 'View Buyer Opportunities',
      },
    };

    final current = defaultQueries[_selectedLang] ?? defaultQueries['English']!;
    _handleSimulatedVoiceTap(
      current['query']!,
      current['response']!,
      route: current['route'],
      actionLabel: current['label'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.90,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Header with Farmer Assistant Branding & Language Switcher
                Row(
                  children: [
                    // Farmer AI avatar circle
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF15803D), width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A15803D),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/farmer_ai_agent.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.support_agent_rounded,
                            color: Color(0xFF15803D),
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AgriConnect Assistant',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            _selectedLang == 'Telugu'
                                ? 'వ్యవసాయ సహాయకుడు (AI Assistant)'
                                : (_selectedLang == 'Hindi'
                                    ? 'किसान मित्र (AI सहायक)'
                                    : 'Your Voice Agriculture Partner'),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF15803D),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Language Selector
                    _buildLanguagePills(),
                  ],
                ),

                const SizedBox(height: 16),

                // Main Interactive Voice Agent Box (Large accessible button)
                _buildVoiceAgentCard(),

                const SizedBox(height: 18),

                // AI Response / Live Output Box (if present)
                if (_lastSpokenQuery != null || _isListening || _isProcessing) ...[
                  _buildConversationalBubble(),
                  const SizedBox(height: 18),
                ],

                // 6 Fast Accessible Farmer Quick Actions
                const Text(
                  'Quick Actions (త్వరిత సేవలు)',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),
                _buildQuickActionGrid(),

                const SizedBox(height: 22),

                // "Have a doubt about AgriConnect?" / "Ask About AgriConnect"
                _buildDoubtExplanationSection(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguagePills() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _langChip('తెలుగు', 'Telugu'),
          _langChip('हिंदी', 'Hindi'),
          _langChip('Eng', 'English'),
        ],
      ),
    );
  }

  Widget _langChip(String label, String langKey) {
    final isSelected = _selectedLang == langKey;
    return InkWell(
      onTap: () => setState(() => _selectedLang = langKey),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF15803D) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceAgentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7), Color(0xFFE8F5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C15803D),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated Microphone Button
          GestureDetector(
            onTap: _startLiveMic,
            child: ScaleTransition(
              scale: _isListening ? _pulseController : const AlwaysStoppedAnimation(1.0),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _isListening ? const Color(0xFFDC2626) : const Color(0xFF15803D),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? const Color(0xFFDC2626) : const Color(0xFF15803D)).withValues(alpha: 0.35),
                      blurRadius: 16,
                      spreadRadius: _isListening ? 4 : 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            _isListening
                ? 'Listening to you... (వింటున్నాను...)'
                : (_isProcessing
                    ? 'Understanding your request... (విశ్లేషిస్తున్నాను...)'
                    : 'TAP TO SPEAK (మాట్లాడటానికి నొక్కండి)'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _isListening ? const Color(0xFFDC2626) : const Color(0xFF15803D),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          Text(
            _selectedLang == 'Telugu'
                ? 'ధరలు, బయ్యర్లు, పిక్‌అప్ లేదా ఆర్డర్ల వివరాలు మాట్లాడండి'
                : (_selectedLang == 'Hindi'
                    ? 'दाम, खरीदार, पिकअप या आर्डर के बारे में पूछें'
                    : 'Ask about prices, buyers, pickup, or order details naturally'),
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationalBubble() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Farmer's question
          if (_lastSpokenQuery != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5E7EB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 14, color: Color(0xFF4B5563)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"$_lastSpokenQuery"',
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
          ],

          // Assistant's response
          if (_isListening)
            const Row(
              children: [
                SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF15803D))),
                SizedBox(width: 8),
                Text('Listening to voice input...', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
            )
          else if (_isProcessing)
            const Row(
              children: [
                SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF15803D))),
                SizedBox(width: 8),
                Text('AI Assistant is finding the best answer for you...', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
            )
          else if (_aiResponseText != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eco_rounded, size: 14, color: Color(0xFF15803D)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _aiResponseText!,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF14532D),
                    ),
                  ),
                ),
              ],
            ),

            if (_suggestedActionRoute != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, _suggestedActionRoute!);
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text(_suggestedActionLabel ?? 'Open Screen', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.search_rounded,
                title: 'Find Buyers',
                subtitle: 'బయ్యర్లను వెతకండి',
                color: const Color(0xFF15803D),
                onTap: () {
                  _handleSimulatedVoiceTap(
                    'బయ్యర్ల డిమాండ్ ఎంత ఉంది? (Check Buyer Demand)',
                    'మీ ప్రాంతంలో టొమాటోలకు ఫ్రెష్‌బాస్కెట్ మండి వద్ద 500 కిలోల ఆర్డర్ సిద్ధంగా ఉంది. మ్యాచ్ స్కోర్: 92%.',
                    route: '/farmer/matches',
                    actionLabel: 'మ్యాచ్‌లను చూడండి (View Matches)',
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionTile(
                icon: Icons.trending_up_rounded,
                title: 'Market Price',
                subtitle: 'నేటి మార్కెట్ ధర',
                color: const Color(0xFFB45309),
                onTap: () {
                  _handleSimulatedVoiceTap(
                    'ఈ రోజు మార్కెట్ ధర ఎంత? (Today Market Price)',
                    'ఈ రోజు గ్రేడ్-A టొమాటో ధర కిలో ₹20 నుండి ₹23 వరకు ఉంది. రాబోయే 2 రోజుల్లో ధర +12% పెరిగే అవకాశం ఉంది.',
                    route: '/farmer/produce',
                    actionLabel: 'నా పంట వివరాలు (My Produce)',
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.add_business_rounded,
                title: 'Sell Produce',
                subtitle: 'పంటను అమ్మండి',
                color: const Color(0xFF0369A1),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/farmer/add-produce');
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionTile(
                icon: Icons.local_shipping_rounded,
                title: 'Pickup Status',
                subtitle: 'పిక్‌అప్ ట్రాకింగ్',
                color: const Color(0xFF7C3AED),
                onTap: () {
                  _handleSimulatedVoiceTap(
                    'నా ఆర్డర్ పిక్‌అప్ ఎప్పుడు వస్తుంది? (Pickup Status)',
                    'రవాణా వాహనం (MH-12-8802) మీ క్లస్టర్ వైపు వస్తోంది. అంచనా సమయం: ఉదయం 10:30 గంటలకు.',
                    route: '/coordination/tracking',
                    actionLabel: 'లైవ్ మ్యాప్ ట్రాక్ చేయండి (Track Route)',
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Payment Status',
                subtitle: 'బ్యాంక్ చెల్లింపు',
                color: const Color(0xFF0D9488),
                onTap: () {
                  _handleSimulatedVoiceTap(
                    'నా పేమెంట్ ఎప్పుడు వస్తుంది? (Payment Status)',
                    'ఆర్డర్ #AGR-1024 కి సంబంధించిన ₹2,000 మండి గేట్ వద్ద నాణ్యత తనిఖీ పూర్తవగానే మీ జన్ ధన్ బ్యాంక్ ఖాతాలో జమ అవుతుంది.',
                    route: '/coordination/settlement',
                    actionLabel: 'సెటిల్మెంట్ వివరాలు (View Settlement)',
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionTile(
                icon: Icons.receipt_long_rounded,
                title: 'My Orders',
                subtitle: 'నా ఆర్డర్లు',
                color: const Color(0xFF4B5563),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/farmer/orders');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoubtExplanationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCF0DF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.help_outline_rounded, color: Color(0xFF15803D), size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Have a doubt about AgriConnect?',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF14532D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap any question below to get simple answers in farmer language:',
            style: TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 12),

          _buildFaqAccordion(
            question: 'AgriConnect అంటే ఏమిటి? (What is AgriConnect?)',
            answer:
                'AgriConnect అనేది దళారులు లేకుండా మిమ్మల్ని నేరుగా పెద్ద బయ్యర్లతో మరియు వినియోగదారులతో కలిపే ఒక డిజిటల్ వ్యవసాయ వేదిక. దీని ద్వారా మీరు మీ పంటకు పూర్తి న్యాయమైన ధర పొందుతారు.',
          ),
          _buildFaqAccordion(
            question: 'నేను కేవలం 20 కిలోలు లేదా తక్కువ పరిమాణంలో అమ్మవచ్చా?',
            answer:
                'ఖచ్చితంగా అమ్మవచ్చు! మీ లాంటి చిన్న రైతుల పంటను మా FPO క్లస్టర్ ద్వారా కలిపి ఒక పెద్ద లాట్‌గా తయారు చేసి హోల్‌సేల్ బయ్యర్లకు విక్రయిస్తాము.',
          ),
          _buildFaqAccordion(
            question: 'నా పంటను ఎవరు సేకరిస్తారు? (How pickup works?)',
            answer:
                'మా స్మార్ట్ లాజిస్టిక్స్ వాహనం నేరుగా మీ గ్రామ ఎఫ్‌పిఓ హబ్‌కు లేదా మీ పొలం వద్దకు వచ్చి నిర్దేశిత సమయంలో పంటను లోడ్ చేసుకుంటుంది.',
          ),
          _buildFaqAccordion(
            question: 'డబ్బులు నాకు ఎలా వస్తాయి? (Payment safety)',
            answer:
                'మండి వద్ద నాణ్యత తనిఖీ పూర్తవగానే మీ డబ్బులు ఎలాంటి మధ్యవర్తుల కోత లేకుండా నేరుగా మీ జన్ ధన్ / బ్యాంక్ ఖాతాలో జమ చేయబడతాయి.',
          ),
          _buildFaqAccordion(
            question: 'AgriConnect ఎలా పనిచేస్తుంది? (Full Workflow)',
            answer:
                '1. పంట లిస్టింగ్ ➔ 2. AI బయ్యర్ మ్యాచింగ్ ➔ 3. FPO కలయిక ➔ 4. ఫార్మ్ గేట్ పిక్‌అప్ ➔ 5. నేరుగా బ్యాంక్ పేమెంట్.',
          ),
        ],
      ),
    );
  }

  Widget _buildFaqAccordion({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        iconColor: const Color(0xFF15803D),
        collapsedIconColor: const Color(0xFF6B7280),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        children: [
          Text(
            answer,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF374151),
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
