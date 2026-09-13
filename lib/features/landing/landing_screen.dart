import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/app_state.dart';

class LandingScreen extends StatefulWidget {
  final AppState? appState;

  const LandingScreen({super.key, this.appState});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToAuth() {
    Navigator.pushNamed(context, '/login');
  }

  void _onCtaPressed() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToAuth();
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Botanical Leaf Watermarks at bottom corners (matching reference)
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _BotanicalLeafPainter(),
              ),
            ),
          ),

          // Main Onboarding PageView
          SafeArea(
            child: Column(
              children: [
                // Top Action Bar with Logo & Skip Button
                _buildTopBar(),

                // 3 Swipeable Carousel Screens
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      _buildScreenOne(),
                      _buildScreenTwo(),
                      _buildScreenThree(),
                    ],
                  ),
                ),

                // Bottom Action Area: Pill CTA + Interactive Pagination Dots
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TOP BAR (AgriConnect Branding on Left, Skip on Right)
  // ===========================================================================
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Screen 1 shows full logo + tagline; Screens 2 & 3 show subtle brand mark
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF15803D),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF15803D).withValues(alpha: 0.22),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
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
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'AgriConnect',
                        style: GoogleFonts.inter(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F2617),
                          letterSpacing: -0.4,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_currentPage == 0)
                        Text(
                          'PEOPLE • PRODUCE • PROSPER',
                          style: GoogleFonts.inter(
                            fontSize: 7.2,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6B7280),
                            letterSpacing: 1.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Skip Button
          TextButton(
            onPressed: _navigateToAuth,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF15803D),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Skip',
              style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF15803D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SCREEN 1: INTRODUCTION
  // "Good Produce Finds Better Opportunities"
  // ===========================================================================
  Widget _buildScreenOne() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Multi-line headline with "Opportunities" highlighted in vivid green
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 31,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                          height: 1.15,
                          letterSpacing: -0.8,
                        ),
                        children: const [
                          TextSpan(text: 'Good\nProduce\nFinds Better\n'),
                          TextSpan(
                            text: 'Opportunities',
                            style: TextStyle(
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Short supporting text
                    Text(
                      'Connecting farmers, buyers and consumers for a stronger, fairer tomorrow.',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: const Color(0xFF4B5563),
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Visual Area with Farmer Image + Calligraphy Badge
                    Expanded(
                      child: Stack(
                        children: [
                          // Farmer in field image with gentle curve & soft bottom blend
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    'assets/images/onboarding_farmer.jpg',
                                    fit: BoxFit.cover,
                                    alignment: const Alignment(0, -0.2),
                                    errorBuilder: (_, __, ___) => Image.asset(
                                      'assets/images/hero_farmer_connect.jpg',
                                      fit: BoxFit.cover,
                                      alignment: const Alignment(0, -0.2),
                                    ),
                                  ),
                                  // Soft vignette overlay at bottom to ensure flawless button readability
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    height: 90,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withValues(alpha: 0.0),
                                            Colors.white.withValues(alpha: 0.75),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Floating Artistic Tag: "Farmers Grow We Connect"
                          Positioned(
                            top: 24,
                            left: 14,
                            child: Transform.rotate(
                              angle: -0.09,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Farmers Grow',
                                      style: GoogleFonts.caveat(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF2E5E3A),
                                        height: 1.1,
                                      ),
                                    ),
                                    Text(
                                      'We Connect',
                                      style: GoogleFonts.caveat(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF15803D),
                                        height: 1.1,
                                      ),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 2.2,
                                      margin: const EdgeInsets.only(top: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF16A34A),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // SCREEN 2: DIRECT CONNECTION
  // "Direct Connections"
  // ===========================================================================
  Widget _buildScreenTwo() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Multi-line headline
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 31,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                          height: 1.15,
                          letterSpacing: -0.8,
                        ),
                        children: const [
                          TextSpan(text: 'Direct\n'),
                          TextSpan(
                            text: 'Connections',
                            style: TextStyle(
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Short supporting text
                    Text(
                      'Bringing farmers and buyers together, removing middlemen for fairer prices.',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: const Color(0xFF4B5563),
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Visual Area with Handshake + Circular Flow & Floating Card
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Handshake Image
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    'assets/images/onboarding_handshake.jpg',
                                    fit: BoxFit.cover,
                                    alignment: const Alignment(0, -0.3),
                                  ),
                                  // Soft bottom gradient
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    height: 110,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withValues(alpha: 0.0),
                                            Colors.white.withValues(alpha: 0.75),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Floating Connection Flow Overlay: Farmers <--> Leaf <--> Buyers
                          Positioned(
                            top: constraints.maxHeight * 0.22,
                            left: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  // Farmers Node
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFDCFCE7),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.person_rounded,
                                          color: Color(0xFF15803D),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Farmers',
                                        style: GoogleFonts.inter(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Dotted / Hub connector
                                  Row(
                                    children: [
                                      Container(
                                        width: 14,
                                        height: 2,
                                        color: const Color(0xFF16A34A).withValues(alpha: 0.5),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF16A34A),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF16A34A).withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.eco_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        width: 14,
                                        height: 2,
                                        color: const Color(0xFF16A34A).withValues(alpha: 0.5),
                                      ),
                                    ],
                                  ),

                                  // Buyers Node
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFEF3C7),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.shopping_cart_rounded,
                                          color: Color(0xFFD97706),
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Buyers',
                                        style: GoogleFonts.inter(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Floating Card near bottom: "Better Prices for Better Lives >"
                          Positioned(
                            bottom: 18,
                            left: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.bar_chart_rounded,
                                      color: Color(0xFF15803D),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Better Prices\nfor Better Lives',
                                      style: GoogleFonts.inter(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF111827),
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Color(0xFF6B7280),
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // SCREEN 3: SMART AGRICULTURE
  // "Fresh Produce Brighter Futures"
  // ===========================================================================
  Widget _buildScreenThree() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Multi-line headline
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 31,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                          height: 1.15,
                          letterSpacing: -0.8,
                        ),
                        children: const [
                          TextSpan(text: 'Fresh Produce\nBrighter\n'),
                          TextSpan(
                            text: 'Futures',
                            style: TextStyle(
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Short supporting text
                    Text(
                      'From farms to homes, we enable a sustainable and prosperous food ecosystem.',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: const Color(0xFF4B5563),
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Visual Area with Farm Produce Crate + 3 Floating Benefit Pills
                    Expanded(
                      child: Stack(
                        children: [
                          // Wooden produce crate image
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    'assets/images/onboarding_produce.jpg',
                                    fit: BoxFit.cover,
                                    alignment: const Alignment(0, 0.1),
                                  ),
                                  // Soft bottom gradient
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    height: 100,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withValues(alpha: 0.0),
                                            Colors.white.withValues(alpha: 0.75),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 3 Floating Benefit Chips Stacked on the Right
                          Positioned(
                            top: 20,
                            right: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildBenefitChip(
                                  icon: Icons.eco_rounded,
                                  iconColor: const Color(0xFF15803D),
                                  iconBg: const Color(0xFFDCFCE7),
                                  label: 'Quality\nProduce',
                                ),
                                const SizedBox(height: 10),
                                _buildBenefitChip(
                                  icon: Icons.local_shipping_rounded,
                                  iconColor: const Color(0xFFB45309),
                                  iconBg: const Color(0xFFFEF3C7),
                                  label: 'Faster\nDelivery',
                                ),
                                const SizedBox(height: 10),
                                _buildBenefitChip(
                                  icon: Icons.groups_rounded,
                                  iconColor: const Color(0xFF0284C7),
                                  iconBg: const Color(0xFFE0F2FE),
                                  label: 'Stronger\nCommunities',
                                ),
                              ],
                            ),
                          ),

                          // Farm Fresh Crate Stamped Badge overlay at bottom left of crate
                          Positioned(
                            bottom: 24,
                            left: 18,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.eco_rounded, color: Colors.white, size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    'FARM FRESH DIRECT',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Floating benefit chip for Screen 3
  Widget _buildBenefitChip({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BOTTOM CONTROLS (Pill CTA Button + Interactive Pagination Dots)
  // ===========================================================================
  Widget _buildBottomControls() {
    final String ctaText;
    switch (_currentPage) {
      case 0:
        ctaText = 'Get Started →';
        break;
      case 1:
        ctaText = 'Continue →';
        break;
      case 2:
      default:
        ctaText = "Let's Get Started →";
        break;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary CTA Capsule Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _onCtaPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15803D),
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: Text(
                ctaText,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // 3 Interactive Pagination Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final bool isActive = index == _currentPage;
              return GestureDetector(
                onTap: () => _goToPage(index),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: isActive ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF15803D)
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// BOTANICAL LEAF WATERMARK PAINTER (Matches bottom corner flourishes in image)
// =============================================================================
class _BotanicalLeafPainter extends CustomPainter {
  const _BotanicalLeafPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF86EFAC).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    // Bottom-Left Organic Foliage
    final pathLeft = Path();
    pathLeft.moveTo(-10, size.height + 10);
    pathLeft.quadraticBezierTo(
      size.width * 0.12,
      size.height - 70,
      size.width * 0.18,
      size.height - 85,
    );
    pathLeft.quadraticBezierTo(
      size.width * 0.14,
      size.height - 40,
      size.width * 0.08,
      size.height + 10,
    );
    pathLeft.close();
    canvas.drawPath(pathLeft, paint);

    // Second smaller leaf on bottom left
    final pathLeft2 = Path();
    pathLeft2.moveTo(0, size.height + 10);
    pathLeft2.quadraticBezierTo(
      size.width * 0.08,
      size.height - 35,
      size.width * 0.12,
      size.height - 40,
    );
    pathLeft2.quadraticBezierTo(
      size.width * 0.08,
      size.height - 15,
      0,
      size.height + 10,
    );
    pathLeft2.close();
    canvas.drawPath(
      pathLeft2,
      Paint()
        ..color = const Color(0xFF4ADE80).withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );

    // Bottom-Right Organic Foliage
    final pathRight = Path();
    pathRight.moveTo(size.width + 10, size.height + 10);
    pathRight.quadraticBezierTo(
      size.width * 0.88,
      size.height - 75,
      size.width * 0.82,
      size.height - 90,
    );
    pathRight.quadraticBezierTo(
      size.width * 0.86,
      size.height - 45,
      size.width * 0.92,
      size.height + 10,
    );
    pathRight.close();
    canvas.drawPath(pathRight, paint);

    // Second smaller leaf on bottom right
    final pathRight2 = Path();
    pathRight2.moveTo(size.width, size.height + 10);
    pathRight2.quadraticBezierTo(
      size.width * 0.92,
      size.height - 40,
      size.width * 0.88,
      size.height - 45,
    );
    pathRight2.quadraticBezierTo(
      size.width * 0.92,
      size.height - 20,
      size.width,
      size.height + 10,
    );
    pathRight2.close();
    canvas.drawPath(
      pathRight2,
      Paint()
        ..color = const Color(0xFF4ADE80).withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
