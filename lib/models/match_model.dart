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

  factory SupplyContributor.fromJson(Map<String, dynamic> json) {
    return SupplyContributor(
      farmerId: json['farmer_id']?.toString() ?? '',
      farmerName: json['farmer_name'] as String? ?? '',
      quantityKg: (json['quantity_kg'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] as String? ?? '',
      payoutAmount: (json['payout_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SupplyMatch {
  final String id;
  final String requirementId;
  final String cropName;
  final double requiredQuantityKg;
  final double matchedQuantityKg;
  final double matchScorePercent;
  final double qualityScore;
  final double confidenceScore;
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

  factory SupplyMatch.fromJson(Map<String, dynamic> json) {
    final contributorsList = (json['contributors'] as List<dynamic>? ?? [])
        .map((c) => SupplyContributor.fromJson(c as Map<String, dynamic>))
        .toList();

    final matched = contributorsList.fold<double>(
        0.0, (sum, c) => sum + c.quantityKg);

    return SupplyMatch(
      id: json['id']?.toString() ?? '',
      requirementId: json['requirement_id']?.toString() ?? '',
      cropName: json['crop'] as String? ?? '',
      requiredQuantityKg: (json['quantity_kg'] as num?)?.toDouble() ?? 0.0,
      matchedQuantityKg: (json['matched_quantity_kg'] as num?)?.toDouble() ?? matched,
      matchScorePercent:
          (json['match_score_percent'] as num?)?.toDouble() ?? 0.0,
      qualityScore: (json['quality_score'] as num?)?.toDouble() ?? 87.0,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 91.0,
      contributors: contributorsList,
      buyerName: json['buyer_name'] as String? ?? '',
      deliveryLocation: json['delivery_location'] as String? ?? '',
      totalEstimatedValue:
          (json['total_estimated_value'] as num?)?.toDouble() ?? 0.0,
      totalDistanceKm:
          (json['total_distance_km'] as num?)?.toDouble() ?? 34.5,
      estimatedTravelTime:
          json['estimated_travel_time'] as String? ?? '',
      vehicleCapacity: json['vehicle_capacity'] as String? ?? '',
    );
  }
}
