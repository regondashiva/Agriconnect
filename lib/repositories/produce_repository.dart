import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agriconnect/models/produce_model.dart';
import 'package:agriconnect/services/api_service.dart';

class ProduceRepository {
  ProduceRepository._();
  static final ProduceRepository instance = ProduceRepository._();

  static const String _storageKey = 'agriconnect_farmer_produce_v2';

  Future<List<ProduceItem>> getMyProduce({String? farmerId}) async {
    // 1. Try remote backend
    try {
      final data = await ApiService.instance.getMyProduce();
      final list = data is List
          ? data
          : (data is Map && data['produce'] is List
              ? data['produce'] as List
              : (data is Map && data['data'] is List ? data['data'] as List : []));
      if (list.isNotEmpty) {
        final remoteItems = list
            .map((e) => ProduceItem.fromJson(e as Map<String, dynamic>))
            .toList();
        await _saveToLocal(remoteItems);
        return remoteItems;
      }
    } catch (e) {
      debugPrint('[ProduceRepository] getMyProduce remote error: $e');
    }

    // 2. Fallback to on-device persistent storage for this farmer
    final localItems = await _loadFromLocal();
    if (farmerId != null && farmerId.isNotEmpty) {
      final filtered = localItems.where((p) => p.farmerId == farmerId || p.farmerId.isEmpty).toList();
      return filtered;
    }
    return localItems;
  }

  Future<ProduceItem> addProduce(ProduceItem item, {String? farmerId}) async {
    final effectiveFarmerId = (farmerId != null && farmerId.isNotEmpty)
        ? farmerId
        : item.farmerId;

    ProduceItem createdItem = item;

    // 1. Send exact contract envelope payload to PostgreSQL backend
    try {
      final payload = item.toContractJson(overrideFarmerId: effectiveFarmerId);
      final data = await ApiService.instance.addProduce(payload);
      if (data is Map<String, dynamic>) {
        final rawProduce = data['data'] ?? data['produce'] ?? data;
        if (rawProduce is Map<String, dynamic>) {
          createdItem = ProduceItem.fromJson(rawProduce);
        }
      }
      debugPrint('[ProduceRepository] Successfully registered produce on backend PostgreSQL.');
    } catch (e) {
      debugPrint('[ProduceRepository] Backend register error: $e (saved to local inventory).');
    }

    // 2. Guarantee item has valid ID and farmer information
    final resolvedItem = ProduceItem(
      id: createdItem.id.isNotEmpty
          ? createdItem.id
          : 'PRD-${DateTime.now().millisecondsSinceEpoch}',
      farmerId: effectiveFarmerId,
      farmerName: item.farmerName,
      cropName: item.cropName,
      variety: item.variety,
      quantityKg: item.quantityKg,
      availableQuantityKg: item.availableQuantityKg,
      grade: item.grade,
      availableDate: item.availableDate,
      location: item.location,
      pickupLatitude: item.pickupLatitude,
      pickupLongitude: item.pickupLongitude,
      qualityScore: item.qualityScore,
      confidenceScore: item.confidenceScore,
      observations: item.observations,
      riskLevel: item.riskLevel,
      photoCount: item.photoCount,
      photoPaths: item.photoPaths,
      imageUrl: item.imageUrl,
      status: 'Listed',
      expectedPricePerKg: item.expectedPricePerKg,
    );

    // 3. Persist to on-device storage
    final current = await _loadFromLocal();
    current.removeWhere((p) => p.id == resolvedItem.id);
    current.insert(0, resolvedItem);
    await _saveToLocal(current);

    return resolvedItem;
  }

  Future<List<ProduceItem>> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((e) => ProduceItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[ProduceRepository] Error loading from local storage: $e');
    }
    return [];
  }

  Future<void> _saveToLocal(List<ProduceItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((e) => e.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('[ProduceRepository] Error saving to local storage: $e');
    }
  }
}