class ConsumerProduct {
  final String id;
  final String name;
  final String category; // 'Vegetables', 'Fruits', 'Grains', 'Greens', 'Herbs', 'Staples'
  final double pricePerKg;
  final double mrpPrice;
  final String unit; // e.g. '1 kg', '500 g', '1 bunch', '250 g', '5 kg'
  final double availableQuantityKg;
  final String source; // 'Direct from FPO (Ranga Reddy)' / 'Direct from Farmer (Chevella)'
  final double distanceKm;
  final String qualityGrade;
  final String iconEmoji;
  final String? imageUrl;
  final double rating;
  final int ratingCount;
  final String deliveryTime;
  final bool isBestseller;
  final String harvestFreshness; // e.g. 'Harvested 3h ago', 'Freshly Picked'

  const ConsumerProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.pricePerKg,
    required this.mrpPrice,
    this.unit = '1 kg',
    required this.availableQuantityKg,
    required this.source,
    required this.distanceKm,
    this.qualityGrade = 'Grade A',
    required this.iconEmoji,
    this.imageUrl,
    this.rating = 4.8,
    this.ratingCount = 85,
    this.deliveryTime = '15-25 mins',
    this.isBestseller = false,
    this.harvestFreshness = 'Harvested Today',
  });

  int get discountPercentage {
    if (mrpPrice > pricePerKg && mrpPrice > 0) {
      return (((mrpPrice - pricePerKg) / mrpPrice) * 100).round();
    }
    return 0;
  }

  factory ConsumerProduct.fromJson(Map<String, dynamic> json) {
    return ConsumerProduct(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'Vegetables',
      pricePerKg: (json['price_per_kg'] as num?)?.toDouble() ?? 0.0,
      mrpPrice: (json['mrp_price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '1 kg',
      availableQuantityKg: (json['available_quantity_kg'] as num?)?.toDouble() ?? 0.0,
      source: json['source'] as String? ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      qualityGrade: json['quality_grade'] as String? ?? 'Grade A',
      iconEmoji: json['icon_emoji'] as String? ?? '🥦',
      imageUrl: json['image_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 80,
      deliveryTime: json['delivery_time'] as String? ?? '15-25 mins',
      isBestseller: json['is_bestseller'] as bool? ?? false,
      harvestFreshness: json['harvest_freshness'] as String? ?? 'Harvested Today',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'price_per_kg': pricePerKg,
        'mrp_price': mrpPrice,
        'unit': unit,
        'available_quantity_kg': availableQuantityKg,
        'source': source,
        'distance_km': distanceKm,
        'quality_grade': qualityGrade,
        'icon_emoji': iconEmoji,
        if (imageUrl != null) 'image_url': imageUrl,
        'rating': rating,
        'rating_count': ratingCount,
        'delivery_time': deliveryTime,
        'is_bestseller': isBestseller,
        'harvest_freshness': harvestFreshness,
      };
}

class CartItem {
  final ConsumerProduct product;
  double quantityKg;

  CartItem({
    required this.product,
    required this.quantityKg,
  });

  double get itemTotal => product.pricePerKg * quantityKg;
}
