import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../services/app_state.dart';
import '../../shared/widgets/role_switcher_sheet.dart';

class LandingScreen extends StatefulWidget {
  final AppState? appState;

  const LandingScreen({super.key, this.appState});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late Animation<double> _heroScaleAnimation;
  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (500-700ms)
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _heroFadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );

    _heroScaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuad),
      ),
    );

    _fadeController.forward();

    // 2. Very subtle gentle floating effect (subtle, non-distracting)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
      lowerBound: -2.0,
      upperBound: 2.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _navigateToAuth() {
    Navigator.pushNamed(context, '/login');
  }

  void _openProfile(BuildContext context) {
    if (widget.appState != null) {
      _showProfileBottomSheet(context, widget.appState!);
    } else {
      _navigateToAuth();
    }
  }

  void _showProfileBottomSheet(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF15803D),
                      child: Text(
                        state.currentUser.name.isNotEmpty
                            ? state.currentUser.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  state.currentUser.name,
                                  style: AppTypography.headlineSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified, color: Color(0xFF15803D), size: 16),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              state.currentUser.roleDisplayName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 4),
                _buildProfileDetailRow(Icons.phone_rounded, 'Phone', state.currentUser.phoneNumber),
                _buildProfileDetailRow(Icons.location_on_rounded, 'Location', state.currentUser.location),
                _buildProfileDetailRow(Icons.language_rounded, 'Language', state.currentUser.preferredLanguage ?? 'Telugu / English'),
                _buildProfileDetailRow(Icons.verified_user_rounded, 'SIH Tag', 'SIH-2026-AGR-VERIFIED'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => RoleSwitcherSheet(appState: state),
                          );
                        },
                        icon: const Icon(Icons.swap_horiz, size: 18),
                        label: const Text('Switch Role'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF15803D),
                          side: const BorderSide(color: Color(0xFF15803D)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _navigateToAuth();
                        },
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: const Text('Change User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF15803D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6B7280)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showHowItWorksModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'How AgriConnect Works',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 14),
              _buildModalStepItem(
                number: '1',
                title: 'Farmer / FPO Lists Produce',
                desc: 'Upload crop details via Voice AI or manual input with verified quality standards.',
              ),
              _buildModalStepItem(
                number: '2',
                title: 'AI Matches Demand',
                desc: 'Smart algorithms match supplies with bulk buyers and household purchase orders.',
              ),
              _buildModalStepItem(
                number: '3',
                title: 'FPO Smart Aggregation',
                desc: 'Combines multiple smallholder farmer batches into wholesale commercial lots.',
              ),
              _buildModalStepItem(
                number: '4',
                title: 'Optimized Logistics & Payout',
                desc: 'Multi-stop pickup routes collect produce directly with instant Jan Dhan bank settlement.',
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _navigateToAuth();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Get Started with AgriConnect',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalStepItem({required String number, required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF15803D), fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFF111827))),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563), height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. COMPACT HEADER (Clean Branding + SIH 2026 Badge)
              _buildCompactHeader(context),

              const SizedBox(height: 10),

              // 2. LARGE FARMER HERO VISUAL (Main Focus with Entrance & Float Animation)
              _buildLargeHeroVisual(context),

              const SizedBox(height: 18),

              // 3. HERO CONTENT & CALL TO ACTION
              _buildHeroContent(context),

              const SizedBox(height: 24),

              // 4. AGRICONNECT COMPACT VALUE STRIP
              _buildValueStrip(context),

              const SizedBox(height: 28),

              // 5. HOW AGRICONNECT WORKS (Mobile-Friendly Clean Flow)
              _buildHowAgriConnectWorks(context),

              const SizedBox(height: 28),

              // 6. FINAL CALL TO ACTION CARD
              _buildFinalCtaSection(context),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. COMPACT HEADER (LEFT: LOGO, RIGHT: SIH BADGE)
  // ==========================================
  Widget _buildCompactHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Logo + Wordmark
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF15803D),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'AgriConnect',
                style: TextStyle(
                  color: Color(0xFF0F2617),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),

          // Right: SIH 2026 Pill Badge
          InkWell(
            onTap: () => _openProfile(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Text(
                'SIH 2026',
                style: TextStyle(
                  color: Color(0xFF92400E),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. LARGE FARMER HERO VISUAL
  // ==========================================
  Widget _buildLargeHeroVisual(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Opacity(
          opacity: _heroFadeAnimation.value,
          child: Transform.scale(
            scale: _heroScaleAnimation.value,
            child: SizedBox(
              width: double.infinity,
              height: 280,
              child: Image.asset(
                'assets/images/hero_farmer_connect.jpg',
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/hero_farmer.jpg',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 240,
                    color: const Color(0xFFDCFCE7),
                    child: const Center(
                      child: Icon(Icons.agriculture_rounded, size: 60, color: Color(0xFF15803D)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // 3. HERO CONTENT & CALL TO ACTION
  // ==========================================
  Widget _buildHeroContent(BuildContext context) {
    return SlideTransition(
      position: _contentSlideAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Heading
            const Text(
              'Sell Smarter.\nConnect Directly.',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F2617),
                height: 1.15,
                letterSpacing: -0.6,
              ),
            ),

            const SizedBox(height: 8),

            // Short Supporting Subtitle
            const Text(
              'AI-powered connections between farmers, buyers and consumers.',
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF4B5563),
                height: 1.35,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 18),

            // Primary CTA Button: GET STARTED
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _navigateToAuth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF15803D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'GET STARTED',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Secondary Action: Learn How It Works ->
            Center(
              child: InkWell(
                onTap: () => _showHowItWorksModal(context),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Learn How It Works',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF15803D)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 4. AGRICONNECT VALUE STRIP (COMPACT & CLEAN)
  // ==========================================
  Widget _buildValueStrip(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildValueItem(
                  icon: Icons.eco_rounded,
                  iconColor: const Color(0xFF15803D),
                  iconBg: const Color(0xFFDCFCE7),
                  title: 'Better Prices',
                  subtitle: 'Direct farmer-to-buyer deals',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildValueItem(
                  icon: Icons.handshake_rounded,
                  iconColor: const Color(0xFF0369A1),
                  iconBg: const Color(0xFFE0F2FE),
                  title: 'Smart Matching',
                  subtitle: 'AI finds relevant demand',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildValueItem(
                  icon: Icons.local_shipping_rounded,
                  iconColor: const Color(0xFFB45309),
                  iconBg: const Color(0xFFFEF3C7),
                  title: 'Smart Logistics',
                  subtitle: 'Efficient pickup & delivery',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildValueItem(
                  icon: Icons.shopping_basket_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  iconBg: const Color(0xFFF3E8FF),
                  title: 'Fresh for Consumers',
                  subtitle: 'Direct access to fresh produce',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 17),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6B7280),
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 5. HOW AGRICONNECT WORKS (CLEAN STEP WORKFLOW)
  // ==========================================
  Widget _buildHowAgriConnectWorks(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'How AgriConnect Works',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'End-to-end transparent supply chain from farm gate to market.',
            style: TextStyle(
              fontSize: 11.5,
              color: Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 16),

          // Clean Vertical Step Flow
          _buildWorkflowStep(
            stepNumber: '1',
            title: 'Farmer / FPO',
            description: 'Farmers list produce with verified harvest & quality standards.',
            isLast: false,
          ),
          _buildWorkflowStep(
            stepNumber: '2',
            title: 'List Produce',
            description: 'Upload produce details with AI photo grading or vernacular Voice AI.',
            isLast: false,
          ),
          _buildWorkflowStep(
            stepNumber: '3',
            title: 'AI Demand Matching',
            description: 'Algorithms automatically match supply batches with bulk buyers.',
            isLast: false,
          ),
          _buildWorkflowStep(
            stepNumber: '4',
            title: 'Smart Aggregation',
            description: 'FPOs bundle multiple smallholder lots into wholesale consignments.',
            isLast: false,
          ),
          _buildWorkflowStep(
            stepNumber: '5',
            title: 'Optimized Logistics',
            description: 'Coordinated multi-stop pickup trucks collect produce from hubs.',
            isLast: false,
          ),
          _buildWorkflowStep(
            stepNumber: '6',
            title: 'Buyer / Consumer',
            description: 'Guaranteed quality delivery with instant direct Jan Dhan settlement.',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowStep({
    required String stepNumber,
    required String title,
    required String description,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left timeline node + vertical line
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFF15803D),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDCFCE7), width: 2),
              ),
              child: Center(
                child: Text(
                  stepNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: const Color(0xFFDCFCE7),
              ),
          ],
        ),

        const SizedBox(width: 12),

        // Right content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4B5563),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 6. FINAL CALL TO ACTION CARD
  // ==========================================
  Widget _buildFinalCtaSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2617),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F2617),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ready to connect\nyour farm to opportunity?',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Join thousands of farmers, FPOs, and buyers on AgriConnect.',
            style: TextStyle(
              fontSize: 11.5,
              color: Color(0xFF9CA3AF),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _navigateToAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: const Color(0xFF0F2617),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'GET STARTED',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
