import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../repositories/auth_repository.dart';
import '../../services/api_service.dart';
import '../../services/app_state.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  final AppState appState;

  const LoginScreen({super.key, required this.appState});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedRole = 'farmer';
  bool _isLoading = false;

  bool get _isValidPhone {
    final clean = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    return clean.length == 10;
  }

  @override
  void initState() {
    super.initState();
    _selectedRole = User.roleToString(widget.appState.activeRole);
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid phone number format. Please enter a 10-digit mobile number.'),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final fullPhone = '+91$phone';
      widget.appState.setPendingAuthPhone(phone);

      final sessionId = await AuthRepository.instance.sendOtp(
        phoneNumber: fullPhone,
        role: _selectedRole,
      );
      widget.appState.setPendingSessionId(sessionId);

      final targetRole = User.roleFromString(_selectedRole);
      widget.appState.selectRole(targetRole);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            appState: widget.appState,
            phoneNumber: phone,
            sessionId: sessionId,
            selectedRole: targetRole,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.statusCode == 400
            ? 'Invalid phone number format. Please include a valid +91 mobile number.'
            : e.message),
        backgroundColor: AppColors.error,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send OTP: $e'),
        backgroundColor: AppColors.error,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF164E2A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo / Header
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.eco_rounded, color: Color(0xFF15803D), size: 32),
              ),
              const SizedBox(height: 20),
              const Text(
                'Passwordless Sign In\n& Registration',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF164E2A),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your 10-digit mobile number. We will send a secure 6-digit OTP to verify your identity.',
                style: TextStyle(fontSize: 13.5, color: Color(0xFF6B7280), height: 1.35),
              ),
              const SizedBox(height: 28),

              // Role Selector
              const Text(
                'I am participating as:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
              ),
              const SizedBox(height: 10),
              _buildRoleSelector(),

              const SizedBox(height: 28),

              // Phone Field
              const Text(
                'Mobile Number',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                enabled: !_isLoading,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '10-digit mobile number',
                  hintStyle: const TextStyle(fontWeight: FontWeight.normal, color: Color(0xFF9CA3AF)),
                  prefixText: '+91  ',
                  prefixStyle: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF164E2A), fontSize: 17),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF164E2A), width: 2),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Send OTP Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_isValidPhone && !_isLoading) ? _handleSendOtp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF164E2A),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFD1D5DB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sms_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'SEND VERIFICATION OTP',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.6),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF9CA3AF)),
                    SizedBox(width: 6),
                    Text(
                      'Secured by Twilio SMS & PostgreSQL Auth',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    final roles = [
      {'value': 'farmer', 'label': 'Farmer', 'icon': Icons.agriculture_rounded},
      {'value': 'fpo', 'label': 'FPO', 'icon': Icons.hub_rounded},
      {'value': 'bulk_buyer', 'label': 'Bulk Buyer', 'icon': Icons.storefront_rounded},
      {'value': 'consumer', 'label': 'Consumer', 'icon': Icons.shopping_basket_rounded},
      {'value': 'delivery_partner', 'label': 'Delivery Partner', 'icon': Icons.electric_moped_rounded},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: roles.map((r) {
        final isSelected = _selectedRole == r['value'];
        return GestureDetector(
          onTap: () {
            setState(() => _selectedRole = r['value'] as String);
            widget.appState.selectRole(User.roleFromString(_selectedRole));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF164E2A) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? const Color(0xFF164E2A) : const Color(0xFFD1D5DB),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(r['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : const Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Text(
                  r['label'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
