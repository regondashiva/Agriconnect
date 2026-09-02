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

class _LandingScreenState extends State<LandingScreen> {
  int _currentNavIndex = 0;

  void _openProfile(BuildContext context) {
    if (widget.appState != null) {
      _showProfileBottomSheet(context, widget.appState!);
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
                          foregroundColor: const Color(0xFF1B5E20),
                          side: const BorderSide(color: Color(0xFF1B5E20)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pushNamed(context, '/login');
                        },
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: const Text('Change User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
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
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              _buildModalStep(
                number: '1',
                title: 'Farmers & FPOs List Produce',
                desc: 'Upload harvest details via Voice AI or quick form with verified quality standards.',
              ),
              _buildModalStep(
                number: '2',
                title: 'Smart Matching & Aggregation',
                desc: 'AI algorithms match farmer supplies with bulk buyers and household demand clusters.',
              ),
              _buildModalStep(
                number: '3',
                title: 'Multi-Pickup Logistics & Fast Payout',
                desc: 'Optimized logistics pick up crops directly from farm hubs with escrow payout security.',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Get Started with AgriConnect', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalStep({required String number, required String title, required String desc}) {
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

  void _handleBottomNavTap(int index) {
    setState(() => _currentNavIndex = index);
    if (index == 1) {
      Navigator.pushNamed(context, '/buyer/home');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/farmer/orders');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/notifications');
    } else if (index == 4) {
      _openProfile(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER (Brand & SIH 2026 Badge)
              _buildTopHeader(context),

              const SizedBox(height: 12),

              // 2. HERO CARD CONTAINER (Combined layout matching reference image)
              _buildCombinedHeroCard(context),

              const SizedBox(height: 14),

              // 3. TRUST & SOCIAL PROOF BAR
              _buildTrustSocialProofBar(context),

              const SizedBox(height: 26),

              // 4. HOW AGRICONNECT WORKS SECTION
              _buildHowItWorksSection(context),

              const SizedBox(height: 28),

              // 5. WHY CHOOSE AGRICONNECT SECTION
              _buildWhyChooseSection(context),

              const SizedBox(height: 24),

              // 6. BOTTOM BANNER
              _buildEmpoweringAgricultureSection(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: _handleBottomNavTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF15803D),
          unselectedItemColor: const Color(0xFF9CA3AF),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Marketplace',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none_rounded),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 1. TOP HEADER (BRAND & SIH 2026 BADGE)
  // ==========================================
  Widget _buildTopHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Brand Name
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'AgriConnect',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Connecting Farms to Opportunities',
                        style: TextStyle(
                          fontSize: 11,
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

          // SIH 2026 Pill Badge
          InkWell(
            onTap: () => _openProfile(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Text(
                'SIH 2026',
                style: TextStyle(
                  color: Color(0xFF92400E),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. HERO CARD CONTAINER (COMBINED EXACT DESIGN)
  // ==========================================
  Widget _buildCombinedHeroCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double screenW = constraints.maxWidth;
          final double rightVisualW = (screenW * 0.46).clamp(145.0, 185.0);
          final double leftContentW = screenW - rightVisualW - 10;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Content Column
              SizedBox(
                width: leftContentW,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Empowering Farmers Tagline Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDCFCE7)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color(0xFFDCFCE7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.eco_rounded, size: 12, color: Color(0xFF15803D)),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Empowering Farmers.',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF15803D),
                                    height: 1.1,
                                  ),
                                ),
                                Text(
                                  'Enriching Lives.',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF15803D),
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Main Title
                    const Text(
                      'Sell Smarter.\nConnect Directly.',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F2617),
                        height: 1.15,
                        letterSpacing: -0.4,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle / Description
                    const Text(
                      'AgriConnect connects farmers and FPOs with suitable buyers through intelligent matching, demand insights and coordinated logistics.',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF4B5563),
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Action Buttons Row (or wrapped column if narrow)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        // Get Started ->
                        InkWell(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF15803D),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Get Started',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10.5,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 12),
                              ],
                            ),
                          ),
                        ),

                        // Watch Demo
                        InkWell(
                          onTap: () => _showHowItWorksModal(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.play_circle_outline_rounded, color: Color(0xFF111827), size: 13),
                                SizedBox(width: 4),
                                Text(
                                  'Watch Demo',
                                  style: TextStyle(
                                    color: Color(0xFF111827),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Right Farmer Visual with 3 Floating Glass Chips
              SizedBox(
                width: rightVisualW,
                height: 260,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Farmer Image Container
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
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
                      right: 4,
                      top: 10,
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
                                    Text('₹27.50 /kg', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
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
                      right: 4,
                      top: 80,
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
                              child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF166534), size: 11),
                            ),
                            const SizedBox(width: 4),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text('New Demand', style: TextStyle(fontSize: 7, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
                                Text('500 Ton', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                                Text('Wheat • MH', style: TextStyle(fontSize: 6.5, color: Color(0xFF9CA3AF))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Floating Chip 3: Logistics (Bottom Right)
                    Positioned(
                      right: 4,
                      bottom: 12,
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
                              child: const Icon(Icons.local_shipping_outlined, color: Color(0xFF166534), size: 11),
                            ),
                            const SizedBox(width: 4),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text('Logistics', style: TextStyle(fontSize: 7, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
                                Text('3 Nearby', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                                Text('Pick-up Points', style: TextStyle(fontSize: 6.5, color: Color(0xFF9CA3AF))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // 3. TRUST & SOCIAL PROOF BAR
  // ==========================================
  Widget _buildTrustSocialProofBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Overlapping Avatars
          SizedBox(
            width: 80,
            height: 28,
            child: Stack(
              children: [
                _buildAvatarCircle('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=60', 0, const Color(0xFF2E7D32)),
                _buildAvatarCircle('https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&auto=format&fit=crop&q=60', 16, const Color(0xFF1B5E20)),
                _buildAvatarCircle('https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=100&auto=format&fit=crop&q=60', 32, const Color(0xFF0D5328)),
                _buildAvatarCircle('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=60', 48, const Color(0xFF004D20)),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Text
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 11,
                  color: Color(0xFF4B5563),
                  height: 1.25,
                ),
                children: [
                  TextSpan(
                    text: '10K+  ',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: Color(0xFF111827),
                    ),
                  ),
                  TextSpan(text: 'Farmers & Buyers trust\nAgriConnect'),
                ],
              ),
            ),
          ),

          // Green Shield Check Badge
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF8F1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Color(0xFF15803D),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCircle(String imgUrl, double left, Color fallbackBg) {
    return Positioned(
      left: left,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: ClipOval(
          child: Image.network(
            imgUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: fallbackBg,
              child: const Icon(Icons.person, color: Colors.white, size: 14),
            ),
          ),
        ),
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
      width: 22,
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
          Icon(Icons.person, size: 40, color: Color(0xFF15803D)),
          SizedBox(height: 4),
          Icon(Icons.phone_android, size: 20, color: Color(0xFF166534)),
        ],
      ),
    );
  }

  // ==========================================
  // 4. HOW AGRICONNECT WORKS SECTION
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
              Icon(Icons.eco_rounded, color: Color(0xFF166534), size: 16),
              SizedBox(width: 6),
              Text(
                'How AgriConnect Works',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.eco_rounded, color: Color(0xFF166534), size: 16),
            ],
          ),

          const SizedBox(height: 20),

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

              // Arrow 1
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF86EFAC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF15803D), size: 14),
              ),

              // Node 2: Bulk Buyer (Demand)
              _buildWorksNode(
                title: 'Bulk Buyer',
                subtitle: 'Demand',
                imageAssetPath: 'assets/images/how_mandi.jpg',
                fallbackIcon: Icons.storefront_rounded,
                bgColor: const Color(0xFFEFF6FF),
              ),

              // Arrow 2
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF86EFAC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF15803D), size: 14),
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

          const SizedBox(height: 18),

          // Bottom Pill: AI Smart Matching & Multi-Pickup Logistics
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFDCFCE7)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.auto_awesome, color: Color(0xFF15803D), size: 15),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'AI Smart Matching & Multi-Pickup Logistics',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF166534),
                      fontSize: 12,
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
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
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
                        errorBuilder: (_, __, ___) => Icon(fallbackIcon, color: const Color(0xFF15803D), size: 32),
                      )
                    : Icon(fallbackIcon, color: const Color(0xFFD97706), size: 32)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11.5,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10,
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
          Icon(Icons.shopping_basket_rounded, color: Color(0xFFD97706), size: 36),
          Positioned(
            top: 6,
            child: Icon(Icons.eco_rounded, color: Color(0xFF15803D), size: 14),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 5. WHY CHOOSE AGRICONNECT SECTION
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
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  letterSpacing: -0.3,
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

          const SizedBox(height: 20),

          // 4-Column Feature Highlights (Clean modern layout)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.track_changes_rounded,
                  title: 'Smart Matching',
                  desc: 'AI-powered matching connects you with the right buyers.',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.bar_chart_rounded,
                  title: 'Demand Insights',
                  desc: 'Real-time market demand and price updates.',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.local_shipping_rounded,
                  title: 'Multi-Pickup Logistics',
                  desc: 'Efficient pickup coordination for faster deliveries.',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.verified_user_rounded,
                  title: 'Trusted & Secure',
                  desc: 'Verified users, transparent deals and data security.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF15803D), size: 18),
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 4),
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
  // 6. EMPOWERING AGRICULTURE & BOTTOM BANNER
  // ==========================================
  Widget _buildEmpoweringAgricultureSection(BuildContext context) {
    return Column(
      children: [
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
                color: const Color(0xFF15803D),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x3315803D),
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
