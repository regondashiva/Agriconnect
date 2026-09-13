import 'produce_model.dart';

class BulkRequirement {
  final String id;
  final String buyerId;
  final String buyerName;
  final String cropName;
  final String variety;
  final double requiredQuantityKg;
  final QualityGrade qualityGrade;
  final String deliveryLocation;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final DateTime requiredDate;
  final double priceRangeMin;
  final double priceRangeMax;
  final String status;
  final DateTime createdAt;

  const BulkRequirement({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.cropName,
    this.variety = 'Hybrid Roma',
    required this.requiredQuantityKg,
    required this.qualityGrade,
    required this.deliveryLocation,
    this.deliveryLatitude = 18.5204,
    this.deliveryLongitude = 73.8567,
    required this.requiredDate,
    this.priceRangeMin = 0.0,
    required this.priceRangeMax,
    this.status = 'Matching',
    required this.createdAt,
  });

  String get gradeLabel {
    switch (qualityGrade) {
      case QualityGrade.gradeA:
        return 'Grade A';
      case QualityGrade.gradeB:
        return 'Grade B';
      case QualityGrade.gradeC:
        return 'Grade C';
    }
  }

  factory BulkRequirement.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    final location = data['delivery_address'] as String? ??
        json['delivery_address'] as String? ??
        'Secunderabad Market';

    return BulkRequirement(
      id: json['id']?.toString() ?? data['id']?.toString() ?? '',
      buyerId: json['buyer_id']?.toString() ?? data['buyer_id']?.toString() ?? '',
      buyerName: json['buyer_name'] as String? ?? data['buyer_name'] as String? ?? 'Buyer',
      cropName: data['crop_name'] as String? ?? json['crop_name'] as String? ?? '',
      variety: data['variety'] as String? ?? json['variety'] as String? ?? 'Standard',
      requiredQuantityKg: (data['required_quantity_kg'] as num?)?.toDouble() ??
          (json['required_quantity_kg'] as num?)?.toDouble() ??
          0.0,
      qualityGrade: QualityGrade.gradeA,
      deliveryLocation: location,
      deliveryLatitude: (data['delivery_latitude'] as num?)?.toDouble() ??
          (json['delivery_latitude'] as num?)?.toDouble() ??
          17.4399,
      deliveryLongitude: (data['delivery_longitude'] as num?)?.toDouble() ??
          (json['delivery_longitude'] as num?)?.toDouble() ??
          78.4983,
      requiredDate: (data['required_by_date'] != null
          ? DateTime.tryParse(data['required_by_date'] as String)
          : (json['required_by_date'] != null ? DateTime.tryParse(json['required_by_date'] as String) : null)) ??
          DateTime.now().add(const Duration(days: 3)),
      priceRangeMin: (data['target_price_min'] as num?)?.toDouble() ??
          (json['target_price_min'] as num?)?.toDouble() ??
          0.0,
      priceRangeMax: (data['target_price_max'] as num?)?.toDouble() ??
          (json['target_price_max'] as num?)?.toDouble() ??
          0.0,
      status: data['status'] as String? ?? json['status'] as String? ?? 'Matching',
      createdAt: (data['created_at'] != null
          ? DateTime.tryParse(data['created_at'] as String)
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null)) ??
          DateTime.now(),
    );
  }

  /// Exact contract payload for Module 2: POST /api/v1/buyer/requirements
  Map<String, dynamic> toContractJson({String? overrideBuyerId}) {
    final effectiveBuyerId = (overrideBuyerId != null && overrideBuyerId.isNotEmpty)
        ? overrideBuyerId
        : buyerId;
    return {
      'buyer_id': effectiveBuyerId,
      'data': {
        'crop_name': cropName.toLowerCase().split(' ').first,
        'required_quantity_kg': requiredQuantityKg,
        'target_price_min': priceRangeMin,
        'target_price_max': priceRangeMax,
        'required_by_date': requiredDate.toUtc().toIso8601String(),
        'delivery_city': deliveryLocation.split(',').first.trim(),
        'delivery_state': 'Telangana',
        'delivery_latitude': deliveryLatitude,
        'delivery_longitude': deliveryLongitude,
        'delivery_address': deliveryLocation,
      },
    };
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'buyer_id': buyerId,
        'buyer_name': buyerName,
        'crop_name': cropName,
        'variety': variety,
        'required_quantity_kg': requiredQuantityKg,
        'target_price_min': priceRangeMin,
        'target_price_max': priceRangeMax,
        'required_by_date': requiredDate.toUtc().toIso8601String(),
        'delivery_address': deliveryLocation,
        'delivery_latitude': deliveryLatitude,
        'delivery_longitude': deliveryLongitude,
        'status': status,
        'created_at': createdAt.toUtc().toIso8601String(),
      };
}