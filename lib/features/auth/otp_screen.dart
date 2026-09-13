import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/user_model.dart';
import '../../repositories/auth_repository.dart';
import '../../services/app_state.dart';
import '../../services/api_service.dart';
import '../../services/user_database_service.dart';
import '../../shared/widgets/app_buttons.dart';

class OtpScreen extends StatefulWidget {
  final AppState appState;
  final String phoneNumber;
  final String sessionId;
  final bool isLogin;
  final UserRole? selectedRole;

  const OtpScreen({
    super.key,
    required this.appState,
    required this.phoneNumber,
    required this.sessionId,
    this.isLogin = true,
    this.selectedRole,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late String _sessionId;
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorText;

  Timer? _cooldownTimer;
  int _resendCooldown = 60;

  @override
  void initState() {
    super.initState();
    _sessionId = widget.sessionId.isNotEmpty ? widget.sessionId : 'twilio-verify';
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].addListener(() {
        if (_otpControllers[i].text.length == 1 && i < 5) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
    _startCooldownTimer();
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    setState(() => _resendCooldown = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown > 1) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
        setState(() => _resendCooldown = 0);
      }
    });
  }

  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.farmer:
        return 'farmer';
      case UserRole.fpo:
        return 'fpo';
      case UserRole.bulkBuyer:
        return 'bulk_buyer';
      case UserRole.consumer:
        return 'consumer';
      case UserRole.deliveryPartner:
        return 'delivery_partner';
    }
  }

  String get _cleanDigits =>
      widget.phoneNumber.replaceAll(RegExp(r'\D'), '');

  String get _e164Phone {
    final digits = _cleanDigits;
    final last10 = digits.length >= 10 ? digits.substring(digits.length - 10) : digits;
    return '+91$last10';
  }

  String get _maskedPhone {
    final digits = _cleanDigits;
    if (digits.length >= 10) {
      final last10 = digits.substring(digits.length - 10);
      return '+91 ${last10.substring(0, 5)} ${last10.substring(5)}';
    }
    return '+91 ${widget.phoneNumber}';
  }

  String get _enteredOtp =>
      _otpControllers.map((c) => c.text.trim()).join();

  Future<void> _handleResendOtp() async {
    if (_resendCooldown > 0 || _isResending || _isLoading) return;

    setState(() {
      _isResending = true;
      _errorText = null;
    });

    try {
      final roleStr = _roleToString(widget.selectedRole ?? widget.appState.activeRole);
      final newSessionId = await AuthRepository.instance.sendOtp(
        phoneNumber: _e164Phone,
        role: roleStr,
        isLogin: widget.isLogin,
      );

      if (newSessionId.isNotEmpty) {
        _sessionId = newSessionId;
      }

      for (var c in _otpControllers) {
        c.clear();
      }
      if (_focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification code resent to $_maskedPhone'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 3),
        ),
      );

      _startCooldownTimer();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to resend code. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _enteredOtp;
    if (otp.length < 6) {
      setState(() => _errorText = 'Please enter the complete 6-digit OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final effectiveRole = widget.selectedRole ?? widget.appState.activeRole;

      var user = await AuthRepository.instance.verifyOtp(
        sessionId: _sessionId,
        phoneNumber: _e164Phone,
        otp: otp,
        defaultRole: effectiveRole,
      );

      // Check if user has previously registered locally on this device
      final localSavedUser = UserDatabaseService.instance.findUserByPhone(_e164Phone);
      if (localSavedUser != null && localSavedUser.name.trim().isNotEmpty) {
        user = User(
          id: user.id.isNotEmpty ? user.id : localSavedUser.id,
          name: localSavedUser.name,
          phoneNumber: _e164Phone,
          role: widget.selectedRole ?? localSavedUser.role,
          location: localSavedUser.location,
          preferredLanguage: localSavedUser.preferredLanguage,
          fpoCluster: localSavedUser.fpoCluster,
          businessName: localSavedUser.businessName,
          registrationId: localSavedUser.registrationId,
          primaryCrops: localSavedUser.primaryCrops,
          landSizeAcres: localSavedUser.landSizeAcres,
          bankName: localSavedUser.bankName,
          upiId: localSavedUser.upiId,
          pincode: localSavedUser.pincode,
          businessType: localSavedUser.businessType,
          memberCount: localSavedUser.memberCount,
          capacityTons: localSavedUser.capacityTons,
          monthlyVolumeTons: localSavedUser.monthlyVolumeTons,
          vehicleType: localSavedUser.vehicleType,
          vehicleNumber: localSavedUser.vehicleNumber,
          isNewUser: false,
          isVerified: true,
        );
      } else if (widget.selectedRole != null && user.role != widget.selectedRole) {
        user = User(
          id: user.id.isNotEmpty ? user.id : 'usr_${DateTime.now().millisecondsSinceEpoch}',
          name: user.name,
          phoneNumber: _e164Phone,
          role: widget.selectedRole!,
          location: user.location,
          preferredLanguage: user.preferredLanguage,
          fpoCluster: user.fpoCluster,
          businessName: user.businessName,
          registrationId: user.registrationId,
          primaryCrops: user.primaryCrops,
          landSizeAcres: user.landSizeAcres,
          bankName: user.bankName,
          upiId: user.upiId,
          pincode: user.pincode,
          businessType: user.businessType,
          memberCount: user.memberCount,
          capacityTons: user.capacityTons,
          monthlyVolumeTons: user.monthlyVolumeTons,
          vehicleType: user.vehicleType,
          vehicleNumber: user.vehicleNumber,
          isNewUser: user.isNewUser,
          isVerified: user.isVerified,
        );
      }

      // 1. Save user object in global state
      widget.appState.loginUser(user);

      if (!mounted) return;

      // Check if user requires onboarding/KYC per contract
      final bool needsRegistration = !user.isVerified ||
          user.isNewUser ||
          user.name.trim().isEmpty ||
          user.name.trim().toLowerCase() == 'new user';

      if (needsRegistration) {
        // Route to role-specific profile setup / KYC
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Mobile verified! Please complete your registration.'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ));

        switch (user.role) {
          case UserRole.farmer:
            Navigator.pushNamedAndRemoveUntil(context, '/farmer/onboarding', (r) => false);
            break;
          case UserRole.fpo:
            Navigator.pushNamedAndRemoveUntil(context, '/fpo/registration', (r) => false);
            break;
          case UserRole.bulkBuyer:
            Navigator.pushNamedAndRemoveUntil(context, '/buyer/registration', (r) => false);
            break;
          case UserRole.consumer:
            Navigator.pushNamedAndRemoveUntil(context, '/consumer/registration', (r) => false);
            break;
          case UserRole.deliveryPartner:
            Navigator.pushNamedAndRemoveUntil(context, '/delivery/registration', (r) => false);
            break;
        }
      } else {
        // Verified user -> Route to Dashboard
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Welcome back, ${user.name}!'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ));

        switch (user.role) {
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
          case UserRole.deliveryPartner:
            Navigator.pushNamedAndRemoveUntil(context, '/delivery/home', (r) => false);
            break;
        }
      }
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        // Contract: 401 Unauthorized -> Show red text label: "Incorrect OTP. Please try again."
        setState(() => _errorText = 'Incorrect OTP. Please try again.');
      } else if (e.statusCode == 403) {
        // Contract: 403 Forbidden -> Show snackbar: "OTP has expired. Please request a new one."
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('OTP has expired. Please request a new one.'),
            backgroundColor: AppColors.error,
          ));
        }
      } else {
        final msg = e.message.trim();
        setState(() => _errorText = msg.isNotEmpty && !msg.contains('Request failed with status')
            ? msg
            : 'Incorrect OTP. Please try again.');
      }
    } catch (e) {
      setState(() => _errorText = 'Incorrect OTP. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
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
            final availableW = constraints.maxWidth - 40;
            final boxW = ((availableW - (5 * 8)) / 6).clamp(38.0, 48.0);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.mark_email_read_rounded,
                        color: Color(0xFF15803D), size: 28),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'Verify your mobile number',
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.w800, fontSize: 22),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'We sent a 6-digit verification code to $_maskedPhone',
                    style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textMuted, fontSize: 13.5),
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
                          enabled: !_isLoading && !_isResending,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: (!_isLoading && !_isResending)
                                  ? const Color(0xFF164E2A)
                                  : AppColors.textMuted),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: (!_isLoading && !_isResending)
                                ? Colors.white
                                : const Color(0xFFF3F4F6),
                            contentPadding: EdgeInsets.zero,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFFC0C9BB), width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFF164E2A), width: 2),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB), width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: AppColors.error, width: 1.5),
                            ),
                          ),
                          onChanged: (val) {
                            if (val.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (val.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                            setState(() => _errorText = null);
                          },
                        ),
                      );
                    }),
                  ),

                  if (_errorText != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 16, color: AppColors.error),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _errorText!,
                            style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 18),

                  // Resend OTP Section with Cooldown Timer
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the code? ",
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        if (_resendCooldown > 0) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                size: 14,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Resend in ${_resendCooldown}s',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          GestureDetector(
                            onTap: (_isResending || _isLoading)
                                ? null
                                : _handleResendOtp,
                            child: _isResending
                                ? const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF164E2A)),
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Resending...',
                                        style: TextStyle(
                                          color: Color(0xFF164E2A),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'Resend OTP',
                                    style: TextStyle(
                                      color: Color(0xFF164E2A),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  PrimaryButton(
                    text: 'VERIFY & CONTINUE',
                    icon: Icons.check_circle_outline_rounded,
                    isLoading: _isLoading,
                    onPressed: _handleVerifyOtp,
                  ),

                  const SizedBox(height: 14),

                  Center(
                    child: TextButton.icon(
                      onPressed: (_isLoading || _isResending)
                          ? null
                          : () => Navigator.pop(context),
                      icon: const Icon(Icons.edit_outlined,
                          size: 16, color: Color(0xFF164E2A)),
                      label: const Text(
                        'Change Mobile Number',
                        style: TextStyle(
                            color: Color(0xFF164E2A),
                            fontWeight: FontWeight.w700,
                            fontSize: 13),
                      ),
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
