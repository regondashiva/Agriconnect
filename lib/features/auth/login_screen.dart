import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/app_state.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  final AppState appState;

  const LoginScreen({super.key, required this.appState});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController(text: '9876543210');
  bool _isLoading = false;
  String? _selectedRoleName;

  bool get _isValidPhone {
    final clean = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    return clean.length == 10;
  }

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() {});
    });
  }

  void _handleSendOtp() {
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      widget.appState.setPendingAuthPhone(phone);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            appState: widget.appState,
            phoneNumber: phone,
          ),
        ),
      );
    });
  }

  void _selectRole(String roleName, String phoneNumber) {
    setState(() {
      _selectedRoleName = roleName;
      _phoneController.text = phoneNumber;
    });
    Navigator.pop(context);
  }

  void _openRolePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: SafeArea(
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
                const SizedBox(height: 18),
                const Text(
                  'Select Your Role',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose a profile to quick-fill demo credentials or set role',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 16),
                _buildRoleOptionItem(
                  icon: Icons.agriculture_rounded,
                  title: 'Farmer',
                  subtitle: 'Sell crops, get mandi advisory & instant payouts',
                  accountNote: 'Demo: Ramesh Kumar (9876543210)',
                  phoneNumber: '9876543210',
                  color: const Color(0xFF15803D),
                ),
                _buildRoleOptionItem(
                  icon: Icons.groups_rounded,
                  title: 'FPO / Aggregator',
                  subtitle: 'Aggregate supply, bulk contracts & logistics',
                  accountNote: 'Demo: Sahyadri FPO (9876543211)',
                  phoneNumber: '9876543211',
                  color: const Color(0xFF0369A1),
                ),
                _buildRoleOptionItem(
                  icon: Icons.storefront_rounded,
                  title: 'Bulk Buyer / Processor',
                  subtitle: 'Procure high-grade produce at verified pricing',
                  accountNote: 'Demo: FreshBasket Corp (9876543212)',
                  phoneNumber: '9876543212',
                  color: const Color(0xFFB45309),
                ),
                _buildRoleOptionItem(
                  icon: Icons.shopping_basket_rounded,
                  title: 'Household Consumer',
                  subtitle: 'Farm-fresh organic baskets directly delivered',
                  accountNote: 'Demo: Ananya Sharma (9876543213)',
                  phoneNumber: '9876543213',
                  color: const Color(0xFF7C3AED),
                ),
                _buildRoleOptionItem(
                  icon: Icons.person_add_alt_1_rounded,
                  title: 'New User / Guest',
                  subtitle: 'Create a new account from scratch',
                  accountNote: 'Phone: 9988776655',
                  phoneNumber: '9988776655',
                  color: const Color(0xFF4B5563),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String accountNote,
    required String phoneNumber,
    required Color color,
  }) {
    final isSelected = _phoneController.text == phoneNumber;
    return InkWell(
      onTap: () => _selectRole(title, phoneNumber),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF15803D) : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.check_circle, color: Color(0xFF15803D), size: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    accountNote,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F6),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Top Hero Illustration & Welcome Section
              _buildTopHeroSection(context),

              // White Content Card (Overlapping sheet design)
              Transform.translate(
                offset: const Offset(0, -18),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 16,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Center Phone + Shield Badge Icon
                      Center(
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF8F1),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.phone_android_rounded,
                                color: Color(0xFF1B6E32),
                                size: 30,
                              ),
                              Positioned(
                                right: 10,
                                bottom: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEFF8F1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.verified_user_rounded,
                                    color: Color(0xFF2E7D32),
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Card Title
                      const Center(
                        child: Text(
                          'Continue with your mobile number',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Card Subtitle
                      const Center(
                        child: Text(
                          "We'll send you an OTP to verify your number.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // "Mobile Number" Label
                      const Text(
                        'Mobile Number',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Input Box Container
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF1B6E32),
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x08000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Country Flag + Code + Dropdown
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Indian Flag Icon
                                  Container(
                                    width: 22,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: Column(
                                        children: [
                                          Expanded(child: Container(color: const Color(0xFFFF9933))),
                                          Expanded(
                                            child: Container(
                                              color: Colors.white,
                                              child: Center(
                                                child: Container(
                                                  width: 4,
                                                  height: 4,
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFF000080),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(child: Container(color: const Color(0xFF138808))),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '+91',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 18,
                                    color: Color(0xFF4B5563),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 1,
                                    height: 22,
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                ],
                              ),
                            ),

                            // Phone Text Input
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: Color(0xFF111827),
                                ),
                                decoration: const InputDecoration(
                                  hintText: '9876543210',
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF9CA3AF),
                                    letterSpacing: 0.5,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                                ),
                              ),
                            ),

                            // Checkmark Icon (Green circle with check)
                            Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: _isValidPhone
                                  ? Container(
                                      width: 22,
                                      height: 22,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF15803D),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    )
                                  : const SizedBox(width: 22),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Supporting Information Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 15,
                            color: Color(0xFF4B5563),
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'New to AgriConnect? Your account will be created after verification.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4B5563),
                                height: 1.35,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // SEND OTP Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B6E32),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.send_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'SEND OTP',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const Spacer(),
                                    Opacity(
                                      opacity: 0.35,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        child: const Icon(
                                          Icons.eco_rounded,
                                          size: 28,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // "Login as" Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Login as',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // "Select your role" Dropdown Card
                      InkWell(
                        onTap: _openRolePickerSheet,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEFF8F1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  color: Color(0xFF1B6E32),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedRoleName ?? 'Select your role',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: _selectedRoleName != null ? FontWeight.w700 : FontWeight.w600,
                                    color: _selectedRoleName != null ? const Color(0xFF111827) : const Color(0xFF374151),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF111827),
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Security is our priority Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3FAF4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFDCF0DF),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Shield Lock Graphic
                            Stack(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
                                  ),
                                  child: const Icon(
                                    Icons.shield_outlined,
                                    color: Color(0xFF15803D),
                                    size: 26,
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF86EFAC),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.eco,
                                      size: 10,
                                      color: Color(0xFF14532D),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Your security is our priority',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF14532D),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Secure OTP verification for Farmers,\nFPOs, Buyers & Households.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      height: 1.3,
                                      color: Color(0xFF4B5563),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF15803D),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF1F6F0),
      child: Stack(
        children: [
          // Background Painter (Sunny sky, birds, windmill, barn, fields)
          Positioned.fill(
            child: CustomPaint(
              painter: _AuthLandscapePainter(),
            ),
          ),

          // Illustration overlay: Indian Farmer with smartphone & pagri
          Positioned(
            right: 0,
            bottom: 12,
            child: CustomPaint(
              size: const Size(180, 210),
              painter: _FarmerIllustrationPainter(),
            ),
          ),

          // Content Column (AppBar + Texts + Badge)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 44, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Back Button + "Authentication" Title
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.maybePop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Authentication',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // "Welcome to"
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                    letterSpacing: -0.2,
                  ),
                ),

                const SizedBox(height: 2),

                // "AgriConnect" with leaf over 'o'
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'AgriC',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F2617),
                        letterSpacing: -0.8,
                      ),
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Text(
                          'o',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F2617),
                            letterSpacing: -0.8,
                          ),
                        ),
                        Positioned(
                          top: -6,
                          right: -3,
                          child: Transform.rotate(
                            angle: 0.3,
                            child: const Icon(
                              Icons.eco,
                              size: 16,
                              color: Color(0xFF22C55E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'nnect',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F2617),
                        letterSpacing: -0.8,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Subtitle
                SizedBox(
                  width: 220,
                  child: const Text(
                    'Your trusted partner for a\nsmarter agricultural future.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Pill Tag: [ 🛡️ Secure • Simple • Reliable ]
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF86EFAC), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: Color(0xFF15803D),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Secure • Simple • Reliable',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter to render the scenic farm landscape with sky, windmill, silo, crops, and birds
class _AuthLandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Soft sky gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFCFDF9),
          Color(0xFFF1F6ED),
          Color(0xFFE2EFE1),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Birds in the sky (top right)
    final birdPaint = Paint()
      ..color = const Color(0xFF6B7280).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    _drawBird(canvas, birdPaint, Offset(size.width * 0.72, 50), 6);
    _drawBird(canvas, birdPaint, Offset(size.width * 0.78, 42), 8);
    _drawBird(canvas, birdPaint, Offset(size.width * 0.85, 58), 5);
    _drawBird(canvas, birdPaint, Offset(size.width * 0.65, 80), 7);

    // Distant soft hills (warm amber-green)
    final hillPaint1 = Paint()..color = const Color(0xFFE4EAD7);
    final hillPath1 = Path();
    hillPath1.moveTo(size.width * 0.45, size.height * 0.65);
    hillPath1.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.52,
      size.width,
      size.height * 0.58,
    );
    hillPath1.lineTo(size.width, size.height);
    hillPath1.lineTo(size.width * 0.45, size.height);
    hillPath1.close();
    canvas.drawPath(hillPath1, hillPaint1);

    // Farm Silo & Barn silhouette in distance
    final farmPaint = Paint()..color = const Color(0xFFC7D7BC);
    // Silo dome & cylinder
    final siloRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(size.width * 0.53, size.height * 0.52, 18, 30),
      topLeft: const Radius.circular(9),
      topRight: const Radius.circular(9),
    );
    canvas.drawRRect(siloRect, farmPaint);
    // Barn
    final barnPath = Path();
    barnPath.moveTo(size.width * 0.58, size.height * 0.62);
    barnPath.lineTo(size.width * 0.61, size.height * 0.54);
    barnPath.lineTo(size.width * 0.64, size.height * 0.62);
    barnPath.close();
    canvas.drawPath(barnPath, farmPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.58, size.height * 0.62, size.width * 0.06, 18), farmPaint);

    // Windmill
    final windmillPaint = Paint()
      ..color = const Color(0xFFA8BE99)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    // Tower
    canvas.drawLine(
      Offset(size.width * 0.63, size.height * 0.62),
      Offset(size.width * 0.63, size.height * 0.48),
      windmillPaint,
    );
    // Blades
    final bladeCenter = Offset(size.width * 0.63, size.height * 0.48);
    for (int i = 0; i < 4; i++) {
      final angle = (i * 3.14159 / 2) + 0.3;
      canvas.drawLine(
        bladeCenter,
        Offset(bladeCenter.dx + 11 * (angle == 0 ? 1 : (angle > 1.5 ? -0.8 : 0.8)),
            bladeCenter.dy + 11 * (angle < 3 ? -0.7 : 0.7)),
        windmillPaint..strokeWidth = 1.2,
      );
    }

    // Midground golden-green field
    final fieldPaint1 = Paint()..color = const Color(0xFFD3E6B4);
    final fieldPath1 = Path();
    fieldPath1.moveTo(size.width * 0.4, size.height * 0.68);
    fieldPath1.quadraticBezierTo(
      size.width * 0.68,
      size.height * 0.60,
      size.width,
      size.height * 0.64,
    );
    fieldPath1.lineTo(size.width, size.height);
    fieldPath1.lineTo(size.width * 0.4, size.height);
    fieldPath1.close();
    canvas.drawPath(fieldPath1, fieldPaint1);

    // Foreground lush crop field
    final cropPaint = Paint()..color = const Color(0xFF65A30D);
    final cropPath = Path();
    cropPath.moveTo(size.width * 0.35, size.height * 0.78);
    cropPath.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.72,
      size.width,
      size.height * 0.76,
    );
    cropPath.lineTo(size.width, size.height);
    cropPath.lineTo(size.width * 0.35, size.height);
    cropPath.close();
    canvas.drawPath(cropPath, cropPaint);

    // Lush green leafy foliage at bottom left
    _drawForegroundLeaves(canvas, size);
  }

  void _drawBird(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    path.moveTo(center.dx - size, center.dy);
    path.quadraticBezierTo(center.dx - size / 2, center.dy - size * 0.6, center.dx, center.dy);
    path.quadraticBezierTo(center.dx + size / 2, center.dy - size * 0.6, center.dx + size, center.dy);
    canvas.drawPath(path, paint);
  }

  void _drawForegroundLeaves(Canvas canvas, Size size) {
    final leafPaint = Paint()
      ..color = const Color(0xFF22C55E).withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final leafPath = Path();
    // Leaf 1
    leafPath.moveTo(size.width * 0.42, size.height * 0.88);
    leafPath.quadraticBezierTo(size.width * 0.48, size.height * 0.74, size.width * 0.52, size.height * 0.78);
    leafPath.quadraticBezierTo(size.width * 0.48, size.height * 0.88, size.width * 0.42, size.height * 0.88);

    // Leaf 2
    leafPath.moveTo(size.width * 0.45, size.height * 0.92);
    leafPath.quadraticBezierTo(size.width * 0.54, size.height * 0.80, size.width * 0.58, size.height * 0.85);
    leafPath.quadraticBezierTo(size.width * 0.52, size.height * 0.94, size.width * 0.45, size.height * 0.92);

    canvas.drawPath(leafPath, leafPaint);

    final darkLeafPaint = Paint()
      ..color = const Color(0xFF15803D).withOpacity(0.9)
      ..style = PaintingStyle.fill;
    final leafPath2 = Path();
    leafPath2.moveTo(size.width * 0.40, size.height * 0.95);
    leafPath2.quadraticBezierTo(size.width * 0.46, size.height * 0.82, size.width * 0.50, size.height * 0.86);
    leafPath2.quadraticBezierTo(size.width * 0.45, size.height * 0.98, size.width * 0.40, size.height * 0.95);
    canvas.drawPath(leafPath2, darkLeafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter to render the Indian farmer from behind/side with green turban and smartphone
class _FarmerIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Center coordinates for farmer
    final centerX = w * 0.62;
    final headY = h * 0.28;

    // 1. Farmer White Kurta Body / Back
    final kurtaPaint = Paint()..color = const Color(0xFFF3F4F6);
    final kurtaShadePaint = Paint()..color = const Color(0xFFE5E7EB);

    final bodyPath = Path();
    bodyPath.moveTo(centerX - 36, headY + 36);
    bodyPath.lineTo(centerX + 36, headY + 36);
    bodyPath.lineTo(centerX + 50, h);
    bodyPath.lineTo(centerX - 42, h);
    bodyPath.close();
    canvas.drawPath(bodyPath, kurtaPaint);

    // Kurta fold lines
    final foldPaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(centerX - 5, headY + 38), Offset(centerX - 10, h), foldPaint);
    canvas.drawLine(Offset(centerX + 15, headY + 45), Offset(centerX + 20, h), foldPaint);

    // 2. Left Arm raised holding phone
    final skinPaint = Paint()..color = const Color(0xFFD97706);
    final armPath = Path();
    armPath.moveTo(centerX - 24, headY + 45);
    armPath.quadraticBezierTo(centerX - 48, headY + 65, centerX - 42, headY + 42);
    armPath.lineTo(centerX - 35, headY + 35);
    armPath.close();
    canvas.drawPath(armPath, kurtaShadePaint);

    // Forearm & Hand holding phone
    final handPath = Path();
    handPath.moveTo(centerX - 46, headY + 48);
    handPath.lineTo(centerX - 40, headY + 20);
    handPath.lineTo(centerX - 30, headY + 22);
    handPath.lineTo(centerX - 35, headY + 48);
    handPath.close();
    canvas.drawPath(handPath, skinPaint);

    // 3. Green Smartphone
    final phonePaint = Paint()..color = const Color(0xFF166534);
    final phoneScreenPaint = Paint()..color = const Color(0xFFDCFCE7);
    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX - 52, headY + 0, 16, 28),
      const Radius.circular(3),
    );
    canvas.drawRRect(phoneRect, phonePaint);
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX - 50, headY + 2, 12, 24),
      const Radius.circular(2),
    );
    canvas.drawRRect(screenRect, phoneScreenPaint);

    // Smartphone mini UI lines
    final uiPaint = Paint()
      ..color = const Color(0xFF16A34A)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(centerX - 48, headY + 7), Offset(centerX - 40, headY + 7), uiPaint);
    canvas.drawLine(Offset(centerX - 48, headY + 12), Offset(centerX - 43, headY + 12), uiPaint);

    // 4. Farmer Head & Skin (Seen from back/side)
    final headRect = Rect.fromCircle(center: Offset(centerX, headY), radius: 18);
    canvas.drawOval(headRect, skinPaint);

    // Ear (left side visible)
    canvas.drawCircle(Offset(centerX - 16, headY + 2), 4, skinPaint);

    // 5. Green Pagri / Turban (Rich emerald green)
    final turbanBasePaint = Paint()..color = const Color(0xFF15803D);
    final turbanHighlight = Paint()..color = const Color(0xFF22C55E);
    final turbanDark = Paint()..color = const Color(0xFF14532D);

    // Main Turban Wrap
    final turbanPath = Path();
    turbanPath.moveTo(centerX - 24, headY - 4);
    turbanPath.quadraticBezierTo(centerX - 26, headY - 26, centerX, headY - 26);
    turbanPath.quadraticBezierTo(centerX + 26, headY - 26, centerX + 24, headY - 4);
    turbanPath.quadraticBezierTo(centerX, headY - 8, centerX - 24, headY - 4);
    turbanPath.close();
    canvas.drawPath(turbanPath, turbanBasePaint);

    // Turban folds and pleats
    final pleat1 = Path();
    pleat1.moveTo(centerX - 22, headY - 8);
    pleat1.quadraticBezierTo(centerX, headY - 22, centerX + 22, headY - 8);
    pleat1.quadraticBezierTo(centerX, headY - 14, centerX - 22, headY - 8);
    canvas.drawPath(pleat1, turbanHighlight);

    final pleat2 = Path();
    pleat2.moveTo(centerX - 18, headY - 16);
    pleat2.quadraticBezierTo(centerX + 4, headY - 30, centerX + 20, headY - 16);
    pleat2.quadraticBezierTo(centerX + 2, headY - 22, centerX - 18, headY - 16);
    canvas.drawPath(pleat2, turbanDark);

    // Turban knot top
    canvas.drawCircle(Offset(centerX + 4, headY - 24), 8, turbanBasePaint);

    // Hanging Turban Tail at back
    final tailPath = Path();
    tailPath.moveTo(centerX + 16, headY - 4);
    tailPath.quadraticBezierTo(centerX + 26, headY + 18, centerX + 24, headY + 38);
    tailPath.lineTo(centerX + 18, headY + 36);
    tailPath.quadraticBezierTo(centerX + 20, headY + 16, centerX + 12, headY);
    tailPath.close();
    canvas.drawPath(tailPath, turbanBasePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
