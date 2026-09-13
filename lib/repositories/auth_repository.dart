import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  /// Step 1: Send OTP to [phoneNumber] (and optional intended [role]).
  /// Returns the [sessionId] needed for [verifyOtp].
  Future<String> sendOtp({
    required String phoneNumber,
    String? role,
    bool isLogin = false,
  }) async {
    final data = await ApiService.instance.sendOtp(
      phoneNumber: phoneNumber,
      role: role,
      isLogin: isLogin,
    ) as Map<String, dynamic>;
    return (data['sessionId'] ?? data['session_id'] ?? '').toString();
  }

  /// Step 2: Verify OTP and return the authenticated [User].
  /// Automatically saves the JWT token in [ApiService] and persistent storage.
  Future<User> verifyOtp({
    String? sessionId,
    required String phoneNumber,
    required String otp,
    UserRole defaultRole = UserRole.farmer,
  }) async {
    final rawData = await ApiService.instance.verifyOtp(
      sessionId: sessionId,
      phoneNumber: phoneNumber,
      otp: otp,
    ) as Map<String, dynamic>;

    final nestedData = (rawData['data'] is Map<String, dynamic>)
        ? rawData['data'] as Map<String, dynamic>
        : rawData;

    // Save JWT for all subsequent requests
    final token = (nestedData['access_token'] ?? rawData['access_token']) as String?;
    final refreshToken = (nestedData['refresh_token'] ?? rawData['refresh_token']) as String?;
    if (token != null && token.isNotEmpty) {
      await ApiService.instance.setTokens(accessToken: token, refreshToken: refreshToken);
    }

    final isNewExplicit = (nestedData['is_new_user'] ??
        nestedData['new_user'] ??
        rawData['is_new_user'] ??
        rawData['new_user']) as bool?;

    final userJson = (nestedData['user'] ?? rawData['user']) as Map<String, dynamic>?;

    if (userJson != null && userJson.isNotEmpty) {
      final user = User.fromJson(userJson, isNewUser: isNewExplicit);
      final rawRole = (userJson['role'] ?? userJson['user_role'])?.toString().trim();
      final effectiveRole = (rawRole != null && rawRole.isNotEmpty)
          ? User.roleFromString(rawRole)
          : defaultRole;

      final isNameValid = user.name.trim().isNotEmpty &&
          !user.name.trim().toLowerCase().contains('new user');

      return User(
        id: user.id.isNotEmpty ? user.id : (rawData['user_id']?.toString() ?? ''),
        name: isNameValid ? user.name : '',
        phoneNumber: user.phoneNumber.isNotEmpty ? user.phoneNumber : phoneNumber,
        role: effectiveRole,
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
        isNewUser: !isNameValid || user.isNewUser,
        isVerified: user.isVerified,
      );
    }

    // No profile found in database -> brand new user
    return User(
      id: rawData['user_id']?.toString() ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: '',
      phoneNumber: phoneNumber,
      role: defaultRole,
      location: '',
      isNewUser: true,
      isVerified: false,
    );
  }
}