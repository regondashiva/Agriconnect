class ConsumerProduct {
  final String id;
  final String name;
  final String category; // 'Vegetables', 'Fruits', 'Grains', 'Greens'
  final double pricePerKg;
  final double availableQuantityKg;
  final String source; // 'Direct from FPO' / 'Direct from Farmer'
  final double distanceKm;
  final String qualityGrade;
  final String iconEmoji;

  const ConsumerProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.pricePerKg,
    required this.availableQuantityKg,
    required this.source,
    required this.distanceKm,
    this.qualityGrade = 'Grade A',
    required this.iconEmoji,
  });
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
