class HistoricalPricePoint {
  final DateTime recordedAt;
  final double modalPrice;

  const HistoricalPricePoint({
    required this.recordedAt,
    required this.modalPrice,
  });

  factory HistoricalPricePoint.fromJson(Map<String, dynamic> json) {
    return HistoricalPricePoint(
      recordedAt: DateTime.tryParse(json['recorded_at']?.toString() ?? '') ?? DateTime.now(),
      modalPrice: double.tryParse(json['modal_price']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'recorded_at': recordedAt.toIso8601String(),
        'modal_price': modalPrice.toString(),
      };
}

class SearchVolumePoint {
  final DateTime createdAt;
  final double requiredQuantityKg;

  const SearchVolumePoint({
    required this.createdAt,
    required this.requiredQuantityKg,
  });

  factory SearchVolumePoint.fromJson(Map<String, dynamic> json) {
    return SearchVolumePoint(
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      requiredQuantityKg: double.tryParse(json['required_quantity_kg']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'created_at': createdAt.toIso8601String(),
        'required_quantity_kg': requiredQuantityKg.toString(),
      };
}

class MarketInsightsData {
  final String crop;
  final List<HistoricalPricePoint> historicalPrices;
  final List<SearchVolumePoint> searchVolume;

  const MarketInsightsData({
    required this.crop,
    required this.historicalPrices,
    required this.searchVolume,
  });

  factory MarketInsightsData.fromJson(Map<String, dynamic> json) {
    final cropName = json['crop']?.toString() ?? 'tomato';
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;

    final pricesRaw = data['historical_prices'] as List? ?? [];
    final prices = pricesRaw
        .map((e) => HistoricalPricePoint.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final volumeRaw = data['search_volume'] as List? ?? [];
    final volume = volumeRaw
        .map((e) => SearchVolumePoint.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return MarketInsightsData(
      crop: cropName,
      historicalPrices: prices,
      searchVolume: volume,
    );
  }

  double get latestModalPrice {
    if (historicalPrices.isEmpty) return 25.0;
    return historicalPrices.last.modalPrice;
  }

  double get initialModalPrice {
    if (historicalPrices.isEmpty) return 22.0;
    return historicalPrices.first.modalPrice;
  }

  double get priceChangePercent {
    if (initialModalPrice <= 0) return 0.0;
    return ((latestModalPrice - initialModalPrice) / initialModalPrice) * 100;
  }

  bool get isDemandRising => priceChangePercent >= 0;

  double get totalSearchVolumeKg {
    return searchVolume.fold(0.0, (sum, point) => sum + point.requiredQuantityKg);
  }

  double get maxPrice {
    if (historicalPrices.isEmpty) return 30.0;
    return historicalPrices.map((e) => e.modalPrice).reduce((a, b) => a > b ? a : b);
  }

  double get minPrice {
    if (historicalPrices.isEmpty) return 15.0;
    return historicalPrices.map((e) => e.modalPrice).reduce((a, b) => a < b ? a : b);
  }

  String get recommendationText =>
      'The official government Mandi price today is ₹${latestModalPrice.toInt()}/kg. We recommend listing near this price.';

  /// Generate structured dynamic fallback data adhering to the contract in case API is offline
  factory MarketInsightsData.generateBenchmark(String crop) {
    final now = DateTime.now();
    final List<HistoricalPricePoint> prices = [];
    final List<SearchVolumePoint> volume = [];

    // Base price per crop
    double base = 25.0;
    final lower = crop.toLowerCase().trim();
    if (lower.contains('tomato')) {
      base = 24.5;
    } else if (lower.contains('onion')) {
      base = 32.0;
    } else if (lower.contains('potato')) {
      base = 22.0;
    } else if (lower.contains('chilli')) {
      base = 45.0;
    } else if (lower.contains('cotton')) {
      base = 72.0;
    } else if (lower.contains('wheat')) {
      base = 28.0;
    } else if (lower.contains('rice')) {
      base = 34.0;
    } else if (lower.contains('carrot')) {
      base = 30.0;
    } else {
      base = 25.0;
    }

    // Generate 30 days of gradual upward trend matching demand spikes
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final trend = (29 - i) * 0.15;
      final variance = ((i % 5) - 2) * 0.3;
      final price = double.parse((base + trend + variance).toStringAsFixed(1));
      prices.add(HistoricalPricePoint(recordedAt: date, modalPrice: price));

      if (i % 3 == 0) {
        final qty = 400.0 + ((29 - i) * 20.0) + ((i % 4) * 50.0);
        volume.add(SearchVolumePoint(createdAt: date, requiredQuantityKg: qty));
      }
    }

    return MarketInsightsData(
      crop: crop,
      historicalPrices: prices,
      searchVolume: volume,
    );
  }
}
