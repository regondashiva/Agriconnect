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
