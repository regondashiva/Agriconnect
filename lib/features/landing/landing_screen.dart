import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/user_model.dart';
import '../../services/app_state.dart';
import '../../shared/widgets/role_switcher_sheet.dart';

class LandingScreen extends StatelessWidget {
  final AppState? appState;

  const LandingScreen({super.key, this.appState});

  void _openProfile(BuildContext context) {
    if (appState != null) {
      _showProfileBottomSheet(context, appState!);
    } else {
      Navigator.pushNamed(context, '/login');
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
                      backgroundColor: const Color(0xFF1B5E20),
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
                              const Icon(Icons.verified, color: Color(0xFF2E7D32), size: 16),
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
                                color: Color(0xFF1B5E20),
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
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF164E2A),
                          side: const BorderSide(color: Color(0xFF164E2A)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                        label: const Text('Switch Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          RoleSwitcherSheet.show(context, state);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF164E2A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.dashboard_rounded, size: 18),
                        label: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          switch (state.activeRole) {
                            case UserRole.farmer:
                              Navigator.pushNamed(context, '/farmer/home');
                              break;
                            case UserRole.fpo:
                              Navigator.pushNamed(context, '/fpo/home');
                              break;
                            case UserRole.bulkBuyer:
                              Navigator.pushNamed(context, '/buyer/home');
                              break;
                            case UserRole.consumer:
                              Navigator.pushNamed(context, '/consumer/home');
                              break;
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6B7280)),
          const SizedBox(width: 8),
          Text('$label:', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
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
                const SizedBox(height: 14),
                Text(
                  'How AgriConnect Works',
                  style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  'AgriConnect is an end-to-end coordination engine bridging farmers, FPOs, wholesale buyers, and urban households.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 14),
                _buildModalStep('1', 'Supply & Demand Gathering', 'Farmers list produce (via voice/form) and bulk buyers post requirements.', Icons.input_rounded),
                _buildModalStep('2', 'AI Smart Multi-Farmer Matching', 'Algorithm matches 500kg requirements across smallholder farm clusters.', Icons.auto_awesome),
                _buildModalStep('3', 'Quality Confidence & Logistics', 'Quality scoring and route-optimized multi-pickup dispatch planning.', Icons.local_shipping_outlined),
                _buildModalStep('4', 'Direct Payout & Settlement', 'Transparent digital payout directly to farmers with zero middlemen deduction.', Icons.payments_outlined),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF164E2A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('GOT IT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalStep(String step, String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B5E20),
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(desc, style: AppTypography.bodySmall.copyWith(fontSize: 11.5)),
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
      backgroundColor: const Color(0xFFFCFDFD),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER WITH PROFILE TAP
              _buildTopHeader(context),

              const SizedBox(height: 12),

              // 2. HERO SECTION
              _buildHeroSection(context),

              const SizedBox(height: 28),

              // 3. HOW AGRICONNECT WORKS SECTION
              _buildHowItWorksSection(context),

              const SizedBox(height: 28),

              // 4. WHY CHOOSE AGRICONNECT SECTION
              _buildWhyChooseSection(context),

              const SizedBox(height: 24),

              // 5. EMPOWERING AGRICULTURE & BOTTOM BANNER
              _buildEmpoweringAgricultureSection(context),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. TOP HEADER (NO OVERFLOW ON ANY SCREEN)
  // ==========================================
  Widget _buildTopHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Brand Name (Flexible to prevent any right overflow)
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF164E2A),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33164E2A),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'AGRICONNECT',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: Color(0xFF164E2A),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          fontSize: 15.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Connecting Farms to Opportunities',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Header Right: Tappable SIH 2026 Badge with Profile trigger
          InkWell(
            onTap: () => _openProfile(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE68A).withAlpha(190),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF59E0B).withAlpha(100)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'SIH 2026',
                    style: TextStyle(
                      color: Color(0xFF92400E),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. HERO SECTION WITH EXACT FARMER ASSET
  // ==========================================
  Widget _buildHeroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tagline pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFC8E6C9)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.eco_rounded, size: 12, color: Color(0xFF2E7D32)),
                SizedBox(width: 5),
                Text(
                  'Empowering Farmers. Enriching Lives.',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Main Hero Layout: Left text/buttons, Right Farmer Image Arch & Floating Chips
          LayoutBuilder(
            builder: (context, constraints) {
              final double screenW = constraints.maxWidth;
              final double rightVisualW = (screenW * 0.46).clamp(150.0, 200.0);
              final double leftContentW = screenW - rightVisualW - 6;

              return SizedBox(
                height: 315,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Right Side: Beautiful Indian Farmer with turban in green field + Floating Badges
                    Positioned(
                      right: 0,
                      top: 0,
                      width: rightVisualW,
                      height: 310,
                      child: _buildHeroRightVisual(context, width: rightVisualW, height: 310),
                    ),

                    // Left Side: Headline, Subtitle, Buttons, Social Proof
                    Positioned(
                      left: 0,
                      top: 0,
                      width: leftContentW,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeadlineAndSubtitle(),
                          const SizedBox(height: 14),
                          _buildHeroButtons(context),
                          const SizedBox(height: 12),
                          _buildSocialProofRow(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeadlineAndSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 25,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(text: 'Sell ', style: TextStyle(color: Color(0xFF111827))),
              TextSpan(text: 'Smarter.', style: TextStyle(color: Color(0xFF164E2A))),
              TextSpan(text: '\nConnect ', style: TextStyle(color: Color(0xFF111827))),
              TextSpan(text: 'Directly.', style: TextStyle(color: Color(0xFF164E2A))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'AgriConnect connects farmers and FPOs with suitable buyers through intelligent matching, demand insights and coordinated logistics.',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF4B5563),
            height: 1.38,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroButtons(BuildContext context) {
    return Column(
      children: [
        // GET STARTED Pill Button
        InkWell(
          onTap: () => Navigator.pushNamed(context, '/login'),
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF164E2A),
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40164E2A),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(3.5),
                  decoration: const BoxDecoration(
                    color: Color(0x2EFFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eco_rounded, color: Color(0xFF90D689), size: 13),
                ),
                const Text(
                  'GET STARTED',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                    letterSpacing: 0.4,
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 15),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        // WATCH DEMO Pill Button
        InkWell(
          onTap: () => _showHowItWorksModal(context),
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF164E2A), width: 1.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.play_circle_outline_rounded, color: Color(0xFF164E2A), size: 16),
                SizedBox(width: 5),
                Text(
                  'WATCH DEMO',
                  style: TextStyle(
                    color: Color(0xFF164E2A),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialProofRow() {
    return Row(
      children: [
        SizedBox(
          width: 72,
          height: 26,
          child: Stack(
            children: [
              _buildAvatarCircle('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=60', 0, const Color(0xFF2E7D32)),
              _buildAvatarCircle('https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&auto=format&fit=crop&q=60', 15, const Color(0xFF1B5E20)),
              _buildAvatarCircle('https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=100&auto=format&fit=crop&q=60', 30, const Color(0xFF0D5328)),
              _buildAvatarCircle('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=60', 45, const Color(0xFF004D20)),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '10K+',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: Color(0xFF111827),
                height: 1.1,
              ),
            ),
            Text(
              'Farmers & Buyers\ntrust AgriConnect',
              style: TextStyle(
                fontSize: 9,
                color: Color(0xFF6B7280),
                height: 1.15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatarCircle(String imgUrl, double left, Color fallbackBg) {
    return Positioned(
      left: left,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: ClipOval(
          child: Image.network(
            imgUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: fallbackBg,
              child: const Icon(Icons.person, color: Colors.white, size: 12),
            ),
          ),
        ),
      ),
    );
  }

  // Right Visual Arch with Indian Farmer Asset & Floating Badges
  Widget _buildHeroRightVisual(BuildContext context, {required double width, required double height}) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Arch clipped container with generated Indian Farmer Asset
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            left: 8,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(100),
                topRight: Radius.circular(100),
                bottomLeft: Radius.circular(80),
                bottomRight: Radius.circular(24),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFEF3C7), Color(0xFFD1FAE5), Color(0xFF15803D)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Image.asset(
                  'assets/images/hero_farmer.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, __, ___) => Image.network(
                    'https://images.unsplash.com/photo-1595278069441-2cf29f8005a4?w=600&auto=format&fit=crop&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildFarmerVectorGraphic(),
                  ),
                ),
              ),
            ),
          ),

          // Floating Chip 1: Best Price (Top Right)
          Positioned(
            right: 2,
            top: 14,
            child: _buildFloatingGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Best Price', style: TextStyle(fontSize: 7.5, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMiniSparkline(),
                      const SizedBox(width: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text('₹27.50 /kg', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                          Text('+12% ↑', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w800, color: Color(0xFF15803D))),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Floating Chip 2: New Demand (Middle Right)
          Positioned(
            right: 0,
            top: 86,
            child: _buildFloatingGlassCard(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF166534), size: 12),
                  ),
                  const SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('New Demand', style: TextStyle(fontSize: 7.5, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
                      Text('500 Ton', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                      Text('Wheat • Maharashtra', style: TextStyle(fontSize: 7, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Floating Chip 3: Logistics (Bottom Right)
          Positioned(
            right: 0,
            bottom: 18,
            child: _buildFloatingGlassCard(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(Icons.local_shipping_outlined, color: Color(0xFF166534), size: 12),
                  ),
                  const SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('Logistics', style: TextStyle(fontSize: 7.5, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
                      Text('3 Nearby', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                      Text('Pick-up Points', style: TextStyle(fontSize: 7, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4.5),
      decoration: BoxDecoration(
        color: const Color(0xF5FFFFFF),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildMiniSparkline() {
    return SizedBox(
      width: 24,
      height: 12,
      child: CustomPaint(
        painter: _SparklinePainter(),
      ),
    );
  }

  Widget _buildFarmerVectorGraphic() {
    return Container(
      color: const Color(0xFF86EFAC),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.person, size: 50, color: Color(0xFF15803D)),
          SizedBox(height: 4),
          Icon(Icons.phone_android, size: 24, color: Color(0xFF166534)),
        ],
      ),
    );
  }

  // ==========================================
  // 3. HOW AGRICONNECT WORKS SECTION
  // ==========================================
  Widget _buildHowItWorksSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Section Title: Leaves + Text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.eco_rounded, color: Color(0xFF166534), size: 15),
              SizedBox(width: 6),
              Text(
                'How AgriConnect Works',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.eco_rounded, color: Color(0xFF166534), size: 15),
            ],
          ),

          const SizedBox(height: 18),

          // 3 Flow Stages with connecting arrows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Node 1: Farmer / FPO (Supply)
              _buildWorksNode(
                title: 'Farmer / FPO',
                subtitle: 'Supply',
                imageAssetPath: 'assets/images/how_tractor.jpg',
                fallbackIcon: Icons.agriculture_rounded,
                bgColor: const Color(0xFFEFF8F1),
              ),

              // Arrow 1: Sync / Bidirectional
              Column(
                children: const [
                  Icon(Icons.swap_horiz_rounded, color: Color(0xFFE67E22), size: 22),
                  SizedBox(height: 16),
                ],
              ),

              // Node 2: Bulk Buyer (Demand)
              _buildWorksNode(
                title: 'Bulk Buyer',
                subtitle: 'Demand',
                imageAssetPath: 'assets/images/how_mandi.jpg',
                fallbackIcon: Icons.storefront_rounded,
                bgColor: const Color(0xFFEFF6FF),
              ),

              // Arrow 2: Right Arrow
              Column(
                children: const [
                  Icon(Icons.arrow_forward_rounded, color: Color(0xFF15803D), size: 18),
                  SizedBox(height: 16),
                ],
              ),

              // Node 3: Consumer (Fresh)
              _buildWorksNode(
                title: 'Consumer',
                subtitle: 'Fresh',
                imageAssetPath: null,
                customWidget: _buildFreshProduceBasketIcon(),
                fallbackIcon: Icons.shopping_basket_rounded,
                bgColor: const Color(0xFFFEF3C7),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Bottom Pill: AI Smart Matching & Multi-Pickup Logistics
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8.5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.auto_awesome, color: Color(0xFFF59E0B), size: 14),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'AI Smart Matching & Multi-Pickup Logistics',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF164E2A),
                      fontSize: 11,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorksNode({
    required String title,
    required String subtitle,
    String? imageAssetPath,
    Widget? customWidget,
    required IconData fallbackIcon,
    required Color bgColor,
  }) {
    return Column(
      children: [
        Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: customWidget ??
                (imageAssetPath != null
                    ? Image.asset(
                        imageAssetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(fallbackIcon, color: const Color(0xFF15803D), size: 30),
                      )
                    : Icon(fallbackIcon, color: const Color(0xFFD97706), size: 30)),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 9.5,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFreshProduceBasketIcon() {
    return Container(
      color: const Color(0xFFFEF3C7),
      padding: const EdgeInsets.all(8),
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Icon(Icons.shopping_basket_rounded, color: Color(0xFFD97706), size: 34),
          Positioned(
            top: 6,
            child: Icon(Icons.eco_rounded, color: Color(0xFF15803D), size: 14),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. WHY CHOOSE AGRICONNECT SECTION
  // ==========================================
  Widget _buildWhyChooseSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Section Title with underline bar
          Column(
            children: [
              const Text(
                'Why Choose AgriConnect?',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: 36,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF15803D),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 4-Column Feature Highlights (Cleanly spaced for all mobile screens)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFeatureColumn(
                  icon: Icons.track_changes_rounded,
                  title: 'Smart Matching',
                  desc: 'AI-powered matching connects you with the right buyers.',
                ),
              ),
              Container(width: 1, height: 85, color: const Color(0xFFF3F4F6)),
              Expanded(
                child: _buildFeatureColumn(
                  icon: Icons.bar_chart_rounded,
                  title: 'Demand Insights',
                  desc: 'Real-time market demand and price insights.',
                ),
              ),
              Container(width: 1, height: 85, color: const Color(0xFFF3F4F6)),
              Expanded(
                child: _buildFeatureColumn(
                  icon: Icons.local_shipping_rounded,
                  title: 'Multi-Pickup Logistics',
                  desc: 'Efficient pickup coordination for faster deliveries.',
                ),
              ),
              Container(width: 1, height: 85, color: const Color(0xFFF3F4F6)),
              Expanded(
                child: _buildFeatureColumn(
                  icon: Icons.verified_user_rounded,
                  title: 'Trusted & Secure',
                  desc: 'Verified users, transparent deals and secure transactions.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureColumn({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF15803D), size: 20),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 10,
              color: Color(0xFF111827),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8,
              color: Color(0xFF6B7280),
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 5. EMPOWERING AGRICULTURE & BOTTOM BANNER
  // ==========================================
  Widget _buildEmpoweringAgricultureSection(BuildContext context) {
    return Column(
      children: [
        // Scenic Harvest Card (Cleanly styled without broken backdrop)
        Container(
          width: double.infinity,
          height: 155,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFFFEF3C7), Color(0xFFE8F5E9), Color(0xFFDCFCE7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Right side decorative agricultural harvest vector artwork
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Opacity(
                    opacity: 0.45,
                    child: Icon(
                      Icons.agriculture_rounded,
                      size: 130,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                ),
                // Text overlay content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                          children: [
                            TextSpan(text: 'Empowering ', style: TextStyle(color: Color(0xFF111827))),
                            TextSpan(text: 'Agriculture.', style: TextStyle(color: Color(0xFF15803D))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Building Connections. Creating Value.',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const SizedBox(
                        width: 200,
                        child: Text(
                          'Join thousands of farmers and buyers already growing with AgriConnect.',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF4B5563),
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Icon(Icons.eco_rounded, color: Color(0xFF15803D), size: 15),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Large CTA Button: JOIN AGRICONNECT TODAY
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/login'),
            borderRadius: BorderRadius.circular(28),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF164E2A),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4D164E2A),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.groups_rounded, color: Colors.white, size: 20),
                  Text(
                    'JOIN AGRICONNECT TODAY',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Subtext / Footer slogan
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.verified_user_rounded, color: Color(0xFF15803D), size: 13),
            SizedBox(width: 5),
            Text(
              'Be a part of the future of agriculture.',
              style: TextStyle(
                fontSize: 10.5,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 5),
            Icon(Icons.eco_rounded, color: Color(0xFF15803D), size: 13),
          ],
        ),
      ],
    );
  }
}

// Custom Painter for the Sparkline on the "Best Price" badge
class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF15803D)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0, size.height * 0.75)
      ..lineTo(size.width * 0.25, size.height * 0.8)
      ..lineTo(size.width * 0.45, size.height * 0.3)
      ..lineTo(size.width * 0.65, size.height * 0.45)
      ..lineTo(size.width * 0.85, size.height * 0.1)
      ..lineTo(size.width, size.height * 0.2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
