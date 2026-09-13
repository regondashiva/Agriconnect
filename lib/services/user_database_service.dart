import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

/// Persistent storage service for user accounts.
/// Maintains user accounts in on-device storage (SharedPreferences)
/// and synchronizes registration details to the remote PostgreSQL database.
class UserDatabaseService {
  UserDatabaseService._();
  static final UserDatabaseService instance = UserDatabaseService._();

  static const String _usersKey = 'agriconnect_registered_users_v2';
  static const String _lastAuthKey = 'agriconnect_last_auth_phone_v2';

  SharedPreferences? _prefs;
  final Map<String, User> _storedUsers = {};

  /// Initialize persistent storage on app startup
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadUsersFromDisk();
    } catch (e) {
      debugPrint('[UserDatabaseService] Init error: $e');
    }
  }

  void _loadUsersFromDisk() {
    if (_prefs == null) return;
    final jsonStr = _prefs!.getString(_usersKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          final phoneKey = entry.key;
          final userMap = entry.value as Map<String, dynamic>;
          _storedUsers[phoneKey] = User.fromJson(userMap, isNewUser: false);
        }
        debugPrint('[UserDatabaseService] Loaded ${_storedUsers.length} user(s) from persistent storage.');
      } catch (e) {
        debugPrint('[UserDatabaseService] Failed to parse stored users: $e');
      }
    }
  }

  /// Get all registered users from database
  Map<String, User> getAllUsers() => Map.unmodifiable(_storedUsers);

  /// Find a registered user by phone number
  User? findUserByPhone(String rawPhone) {
    final digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    final last10 = digits.length >= 10 ? digits.substring(digits.length - 10) : digits;
    if (last10.isEmpty) return null;
    return _storedUsers[last10];
  }

  /// Save a user profile into local persistent database and synchronize with backend
  Future<void> saveUser(User user) async {
    final digits = user.phoneNumber.replaceAll(RegExp(r'\D'), '');
    final last10 = digits.length >= 10 ? digits.substring(digits.length - 10) : digits;
    if (last10.isEmpty) return;

    // 1. Update in-memory map
    _storedUsers[last10] = user;

    // 2. Persist to on-device SharedPreferences
    if (_prefs != null) {
      try {
        final jsonMap = <String, dynamic>{};
        for (final entry in _storedUsers.entries) {
          jsonMap[entry.key] = entry.value.toJson();
        }
        await _prefs!.setString(_usersKey, jsonEncode(jsonMap));
        await _prefs!.setString(_lastAuthKey, user.phoneNumber);
        debugPrint('[UserDatabaseService] Persisted user ${user.name} (+91 $last10) to database.');
      } catch (e) {
        debugPrint('[UserDatabaseService] Error saving to SharedPreferences: $e');
      }
    }

    // 3. Synchronize with remote PostgreSQL backend
    syncToRemoteBackend(user);
  }

  /// Synchronize registration payload to remote backend per Module 6 Contract
  Future<void> syncToRemoteBackend(User user) async {
    try {
      // 1. Primary: Module 6 KYC & Profile Update Contract (PATCH /api/v1/users/profile)
      final profilePayload = user.toProfilePayload();
      await ApiService.instance.updateProfile(profilePayload);

      // 2. Compatibility Sync: Complete registration schema
      await ApiService.instance.registerUserProfile(
        id: user.id,
        phoneNumber: user.phoneNumber,
        role: User.roleToString(user.role),
        fullName: user.name,
        businessName: user.businessName,
        location: user.location,
        preferredLanguage: user.preferredLanguage,
        fpoCluster: user.fpoCluster,
        verifiedId: user.registrationId,
        primaryCrops: user.primaryCrops,
        bankName: user.bankName,
        upiId: user.upiId,
        landSizeAcres: user.landSizeAcres,
      );
      debugPrint('[UserDatabaseService] Successfully synchronized ${user.name} (${user.roleDisplayName}) to backend.');
    } catch (e) {
      debugPrint('[UserDatabaseService] Backend sync note (persisted locally): $e');
    }
  }

  /// Get last authenticated phone number
  String? getLastAuthPhone() {
    return _prefs?.getString(_lastAuthKey);
  }
}
