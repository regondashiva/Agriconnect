import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/user_model.dart';
import '../../services/app_state.dart';
import '../../shared/widgets/app_buttons.dart';

class OtpScreen extends StatefulWidget {
  final AppState appState;
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.appState,
    required this.phoneNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController(text: (index + 1).toString()));
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;

  String get _maskedPhone {
    final raw = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (raw.length >= 10) {
      final last10 = raw.substring(raw.length - 10);
      return '+91 ${last10.substring(0, 5)} ${last10.substring(5)}';
    }
    return '+91 ${widget.phoneNumber}';
  }

  void _handleVerifyOtp() {
    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final existingUser = widget.appState.findUserByPhone(widget.phoneNumber);

      if (existingUser != null) {
        // EXISTING USER: Directly log in and open their role-specific home
        widget.appState.loginExistingUser(existingUser);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${existingUser.name}! Logging into ${existingUser.roleDisplayName} Workspace.'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );

        switch (existingUser.role) {
          case UserRole.farmer:
            Navigator.pushNamedAndRemoveUntil(context, '/farmer/home', (r) => false);
            break;
          case UserRole.fpo:
            Navigator.pushNamedAndRemoveUntil(context, '/fpo/home', (r) => false);
            break;
          case UserRole.bulkBuyer:
            Navigator.pushNamedAndRemoveUntil(context, '/buyer/home', (r) => false);
            break;
          case UserRole.consumer:
            Navigator.pushNamedAndRemoveUntil(context, '/consumer/home', (r) => false);
            break;
        }
      } else {
        // NEW USER: Set pending phone and route to Role Selection
        widget.appState.setPendingAuthPhone(widget.phoneNumber);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mobile verified! Select your role to complete registration.'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushNamed(context, '/role-selection');
      }
    });
  }

  @override
  void dispose() {
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDFD),
      appBar: AppBar(
        title: const Text('OTP Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Compute dynamic block width so 6 boxes never overflow
            final availableW = constraints.maxWidth - 40; // 20 padding each side
            final boxW = ((availableW - (5 * 8)) / 6).clamp(38.0, 48.0);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verification Lock Icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.mark_email_read_rounded,
                      color: Color(0xFF15803D),
                      size: 28,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'Verify your mobile number',
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'We sent a 6-digit verification code to $_maskedPhone',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 13.5,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 6-Digit OTP Boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: boxW,
                        height: 54,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF164E2A),
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.zero,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFC0C9BB), width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF164E2A), width: 2),
                            ),
                          ),
                          onChanged: (val) {
                            if (val.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (val.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // VERIFY & CONTINUE Button
                  PrimaryButton(
                    text: 'VERIFY & CONTINUE',
                    icon: Icons.check_circle_outline_rounded,
                    isLoading: _isLoading,
                    onPressed: _handleVerifyOtp,
                  ),

                  const SizedBox(height: 14),

                  // Change Mobile Number
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF164E2A)),
                      label: const Text(
                        'Change Mobile Number',
                        style: TextStyle(
                          color: Color(0xFF164E2A),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // OTP auto-filled hint for SIH Demo
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceContainerHigh),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.bolt_rounded, color: AppColors.harvestOrange, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'SIH Demo: Verification code (123456) pre-filled for rapid evaluation.',
                            style: TextStyle(fontSize: 11, color: AppColors.textNavy, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
