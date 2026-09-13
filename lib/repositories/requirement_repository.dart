import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agriconnect/models/requirement_model.dart';
import 'package:agriconnect/services/api_service.dart';

class RequirementRepository {
  RequirementRepository._();
  static final RequirementRepository instance = RequirementRepository._();

  static const String _storageKey = 'agriconnect_buyer_requirements_v2';

  Future<List<BulkRequirement>> getMyRequirements({String? buyerId}) async {
    // 1. Try remote backend
    try {
      final data = await ApiService.instance.getMyRequirements();
      final list = data is List
          ? data
          : (data is Map && data['requirements'] is List
              ? data['requirements'] as List
              : (data is Map && data['data'] is List ? data['data'] as List : []));
      if (list.isNotEmpty) {
        final remote = list
            .map((e) => BulkRequirement.fromJson(e as Map<String, dynamic>))
            .toList();
        await _saveToLocal(remote);
        return remote;
      }
    } catch (e) {
      debugPrint('[RequirementRepository] getMyRequirements remote error: $e');
    }

    // 2. Fallback to on-device persistent storage
    final local = await _loadFromLocal();
    if (buyerId != null && buyerId.isNotEmpty) {
      final filtered = local.where((r) => r.buyerId == buyerId || r.buyerId.isEmpty).toList();
      return filtered;
    }
    return local;
  }

  Future<BulkRequirement> postRequirement(BulkRequirement req, {String? buyerId}) async {
    final effectiveBuyerId = (buyerId != null && buyerId.isNotEmpty)
        ? buyerId
        : req.buyerId;

    BulkRequirement createdReq = req;

    // 1. Send exact contract envelope payload to PostgreSQL backend
    try {
      final payload = req.toContractJson(overrideBuyerId: effectiveBuyerId);
      final data = await ApiService.instance.postRequirement(payload);
      if (data is Map<String, dynamic>) {
        final raw = data['data'] ?? data['requirement'] ?? data;
        if (raw is Map<String, dynamic>) {
          createdReq = BulkRequirement.fromJson(raw);
        }
      }
      debugPrint('[RequirementRepository] Successfully posted requirement to PostgreSQL backend.');
    } catch (e) {
      debugPrint('[RequirementRepository] Backend post requirement error: $e (saved locally).');
    }

    // 2. Guarantee valid ID and buyer info
    final resolvedReq = BulkRequirement(
      id: createdReq.id.isNotEmpty
          ? createdReq.id
          : 'REQ-${DateTime.now().millisecondsSinceEpoch}',
      buyerId: effectiveBuyerId,
      buyerName: req.buyerName,
      cropName: req.cropName,
      variety: req.variety,
      requiredQuantityKg: req.requiredQuantityKg,
      qualityGrade: req.qualityGrade,
      deliveryLocation: req.deliveryLocation,
      deliveryLatitude: req.deliveryLatitude,
      deliveryLongitude: req.deliveryLongitude,
      requiredDate: req.requiredDate,
      priceRangeMin: req.priceRangeMin,
      priceRangeMax: req.priceRangeMax,
      status: 'Matching',
      createdAt: req.createdAt,
    );

    // 3. Persist locally
    final current = await _loadFromLocal();
    current.removeWhere((r) => r.id == resolvedReq.id);
    current.insert(0, resolvedReq);
    await _saveToLocal(current);

    return resolvedReq;
  }

  Future<List<BulkRequirement>> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((e) => BulkRequirement.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[RequirementRepository] Error loading from local storage: $e');
    }
    return [];
  }

  Future<void> _saveToLocal(List<BulkRequirement> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((e) => e.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('[RequirementRepository] Error saving to local storage: $e');
    }
  }
}