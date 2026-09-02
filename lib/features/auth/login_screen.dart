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
  String _selectedRoleName = 'Farmer (Ramesh)';
  IconData _selectedRoleIcon = Icons.agriculture_rounded;

  final List<Map<String, dynamic>> _demoProfiles = [
    {
      'label': 'Farmer (Ramesh)',
      'phone': '9876543210',
      'icon': Icons.agriculture_rounded,
      'subtitle': 'Sell produce, mandi advisory & payout',
    },
    {
      'label': 'FPO (Suresh)',
      'phone': '9876543211',
      'icon': Icons.hub_rounded,
      'subtitle': 'Aggregate supply & logistics dispatch',
    },
    {
      'label': 'Bulk Buyer (FreshBasket)',
      'phone': '9876543212',
      'icon': Icons.storefront_rounded,
      'subtitle': 'Bulk procurement & smart matching',
    },
    {
      'label': 'Consumer (Ananya)',
      'phone': '9876543213',
      'icon': Icons.shopping_basket_rounded,
      'subtitle': 'Farm-fresh grocery basket delivery',
    },
    {
      'label': 'New User / Guest',
      'phone': '9988776655',
      'icon': Icons.person_add_alt_1_rounded,
      'subtitle': 'Create new account after verification',
    },
  ];

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
    Future.delayed(const Duration(milliseconds: 350), () {
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

  void _openDemoProfilePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                  const SizedBox(height: 18),
                  const Text(
                    'Select Demo Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Quick-fill test credentials for rapid evaluation',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._demoProfiles.map((profile) {
                    final isSelected = _phoneController.text == profile['phone'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedRoleName = profile['label'];
                          _selectedRoleIcon = profile['icon'];
                          _phoneController.text = profile['phone'];
                        });
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF15803D) : const Color(0xFFE5E7EB),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFDCFCE7) : const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                profile['icon'] as IconData,
                                color: isSelected ? const Color(0xFF15803D) : const Color(0xFF4B5563),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile['label'] as String,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    profile['subtitle'] as String,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              profile['phone'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.maybePop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
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
          ),
        ),
        title: const Text(
          'Login',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // AgriConnect Green Squircle Leaf Badge Icon
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFF15803D),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x2E15803D),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Title: Welcome to AgriConnect
              const Text(
                'Welcome to AgriConnect',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F2617),
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 6),

              // Subtitle
              const Text(
                'Enter your 10-digit mobile number to access your workspace or register.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF4B5563),
                  height: 1.38,
                ),
              ),

              const SizedBox(height: 24),

              // Demo Quick-Fill Profiles Label
              const Text(
                'Demo Quick-Fill Profiles',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 8),

              // Demo Quick-Fill Selector Dropdown Box (Exact design)
              InkWell(
                onTap: _openDemoProfilePicker,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF15803D),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedRoleIcon,
                        color: const Color(0xFF15803D),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedRoleName,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF15803D),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Mobile Number Label
              const Text(
                'Mobile Number',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 8),

              // Mobile Number Input Box (Exact design with Flag +91 | Number Checkmark)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isValidPhone ? const Color(0xFF15803D) : const Color(0xFFD1D5DB),
                    width: _isValidPhone ? 1.5 : 1.2,
                  ),
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
                    // Country Code Section (clean, no inner box)
                    Padding(
                      padding: const EdgeInsets.only(left: 14, right: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🇮🇳', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 6),
                          const Text(
                            '+91',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Color(0xFF6B7280),
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

                    // Phone Text Field
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          fontSize: 16.5,
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 14),
                        ),
                      ),
                    ),

                    // Green Checkmark
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

              // Helper Info Note
              const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF6B7280)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'An OTP code will be sent to verify your number.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Action Button: GET OTP ->
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'GET OTP',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
