import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/market_insights_model.dart';
import '../services/api_service.dart';

class MarketInsightsRepository {
  MarketInsightsRepository._();
  static final MarketInsightsRepository instance = MarketInsightsRepository._();

  static const String _storagePrefix = 'agriconnect_market_insights_';

  /// In-memory cache for speed
  final Map<String, MarketInsightsData> _cache = {};

  Future<MarketInsightsData> getHistoricalDemand(String crop) async {
    final normalizedCrop = crop.toLowerCase().trim();

    if (_cache.containsKey(normalizedCrop)) {
      return _cache[normalizedCrop]!;
    }

    // 1. Try remote API endpoint (GET /api/v1/market-insights/historical-demand?crop=...)
    try {
      final remoteRes = await ApiService.instance.getHistoricalDemand(normalizedCrop);
      if (remoteRes != null && remoteRes is Map) {
        final data = MarketInsightsData.fromJson(Map<String, dynamic>.from(remoteRes));
        if (data.historicalPrices.isNotEmpty) {
          _cache[normalizedCrop] = data;
          await _saveToLocal(normalizedCrop, remoteRes);
          return data;
        }
      }
    } catch (e) {
      debugPrint('[MarketInsightsRepository] remote fetch note: $e');
    }

    // 2. Try local storage cache
    final localData = await _loadFromLocal(normalizedCrop);
    if (localData != null) {
      _cache[normalizedCrop] = localData;
      return localData;
    }

    // 3. Generate dynamic realistic Agmarknet benchmark based on current market trends
    final benchmark = MarketInsightsData.generateBenchmark(normalizedCrop);
    _cache[normalizedCrop] = benchmark;
    return benchmark;
  }

  Future<void> _saveToLocal(String crop, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_storagePrefix$crop', jsonEncode(data));
    } catch (e) {
      debugPrint('[MarketInsightsRepository] save local error: $e');
    }
  }

  Future<MarketInsightsData?> _loadFromLocal(String crop) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_storagePrefix$crop');
      if (raw != null) {
        final map = jsonDecode(raw);
        if (map is Map<String, dynamic>) {
          return MarketInsightsData.fromJson(map);
        }
      }
    } catch (e) {
      debugPrint('[MarketInsightsRepository] load local error: $e');
    }
    return null;
  }
}
