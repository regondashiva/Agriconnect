class SupplyContributor {
  final String farmerId;
  final String farmerName;
  final double quantityKg;
  final String location;
  final double payoutAmount;

  const SupplyContributor({
    required this.farmerId,
    required this.farmerName,
    required this.quantityKg,
    required this.location,
    required this.payoutAmount,
  });
}

class SupplyMatch {
  final String id;
  final String requirementId;
  final String cropName;
  final double requiredQuantityKg;
  final double matchedQuantityKg;
  final double matchScorePercent; // e.g. 92%
  final double qualityScore; // e.g. 87/100
  final double confidenceScore; // e.g. 91%
  final List<SupplyContributor> contributors;
  final String buyerName;
  final String deliveryLocation;
  final double totalEstimatedValue;
  final double totalDistanceKm;
  final String estimatedTravelTime;
  final String vehicleCapacity;

  const SupplyMatch({
    required this.id,
    required this.requirementId,
    required this.cropName,
    required this.requiredQuantityKg,
    required this.matchedQuantityKg,
    required this.matchScorePercent,
    required this.qualityScore,
    required this.confidenceScore,
    required this.contributors,
    required this.buyerName,
    required this.deliveryLocation,
    required this.totalEstimatedValue,
    this.totalDistanceKm = 34.5,
    this.estimatedTravelTime = '1 hr 45 min',
    this.vehicleCapacity = '1.2 Ton Mini-Truck',
  });

  bool get isFullyFulfilled => matchedQuantityKg >= requiredQuantityKg;
}
