import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../services/app_state.dart';
import '../../shared/widgets/app_buttons.dart';
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

  void _handleSendOtp() {
    final phone = _phoneController.text.trim();
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

  void _quickFill(String number) {
    setState(() {
      _phoneController.text = number;
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDFD),
      appBar: AppBar(
        title: const Text('Authentication'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand / Phone Icon Badge
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.phone_android_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),

              const SizedBox(height: 18),

              // Title & Subtitle as requested
              Text(
                'Welcome to AgriConnect',
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Continue securely with your mobile number.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 13.5,
                ),
              ),

              const SizedBox(height: 24),

              // Mobile Number Input Field
              Text(
                'Mobile Number',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outlineVariant, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
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
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      child: Text(
                        '+91 | ',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    hintText: 'Enter your 10-digit mobile number',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0,
                    ),
                    suffixIcon: Icon(Icons.verified_user_outlined, color: AppColors.secondary, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Supporting text
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF6B7280)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'New to AgriConnect? Your account will be created after verification.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF4B5563),
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // SEND OTP Button
              PrimaryButton(
                text: 'SEND OTP',
                icon: Icons.arrow_forward_rounded,
                isLoading: _isLoading,
                onPressed: _handleSendOtp,
              ),

              const SizedBox(height: 24),

              // Quick Test Demo Pickers for SIH evaluators
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceContainerHigh),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SIH Demo: Quick-fill existing test accounts',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildQuickFillChip('Farmer (Ramesh)', '9876543210'),
                        _buildQuickFillChip('FPO (Suresh)', '9876543211'),
                        _buildQuickFillChip('Buyer (FreshBasket)', '9876543212'),
                        _buildQuickFillChip('Consumer (Ananya)', '9876543213'),
                        _buildQuickFillChip('New User', '9988776655'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Security message banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF8F1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.shield_outlined, color: Color(0xFF15803D), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Secure OTP verification for Farmers, FPOs, Buyers & Households.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF14532D),
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFillChip(String label, String number) {
    final isSelected = _phoneController.text == number;
    return InkWell(
      onTap: () => _quickFill(number),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textNavy,
          ),
        ),
      ),
    );
  }
}
