enum QualityGrade { gradeA, gradeB, gradeC }

class ProduceItem {
  final String id;
  final String farmerId;
  final String farmerName;
  final String cropName;
  final String variety;
  final double quantityKg;
  final double availableQuantityKg;
  final QualityGrade grade;
  final DateTime availableDate;
  final String location;
  final double pickupLatitude;
  final double pickupLongitude;
  final double qualityScore;
  final double confidenceScore;
  final List<String> observations;
  final String riskLevel;
  final int photoCount;
  final String status;
  final double expectedPricePerKg;
  final List<String> photoPaths;
  final String? imageUrl;
  final String? assessmentId;

  const ProduceItem({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.cropName,
    this.variety = 'Hybrid Roma',
    required this.quantityKg,
    double? availableQuantityKg,
    required this.grade,
    required this.availableDate,
    required this.location,
    this.pickupLatitude = 18.8268,
    this.pickupLongitude = 74.3788,
    this.qualityScore = 87.0,
    this.confidenceScore = 91.0,
    this.observations = const [
      'Good colour consistency',
      'Good size consistency',
      'Appearance acceptable',
      'Minor visible defects',
    ],
    this.riskLevel = 'LOW',
    this.photoCount = 0,
    this.status = 'Listed',
    this.expectedPricePerKg = 20.0,
    this.photoPaths = const [],
    this.imageUrl,
    this.assessmentId,
  }) : availableQuantityKg = availableQuantityKg ?? quantityKg;

  String get name => cropName;

  String get gradeLabel {
    switch (grade) {
      case QualityGrade.gradeA:
        return 'Grade A';
      case QualityGrade.gradeB:
        return 'Grade B';
      case QualityGrade.gradeC:
        return 'Grade C';
    }
  }

  factory ProduceItem.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    final qty = _parseDouble(data['total_quantity_kg'] ?? data['quantity_kg'] ?? json['total_quantity_kg'] ?? json['quantity_kg'], 0.0);
    final rawGrade = data['quality_grade'] as String? ??
        data['predicted_grade'] as String? ??
        json['quality_grade'] as String? ??
        json['predicted_grade'] as String? ??
        json['grade'] as String? ??
        'A';
    final assessmentId = json['assessment_id'] as String? ??
        data['assessment_id'] as String? ??
        (json['status'] == 'draft' ? json['id'] as String? : null);

    return ProduceItem(
      id: json['id']?.toString() ?? data['id']?.toString() ?? '',
      farmerId: json['farmer_id']?.toString() ?? data['farmer_id']?.toString() ?? '',
      farmerName: json['farmer_name'] as String? ?? data['farmer_name'] as String? ?? 'Farmer',
      cropName: data['crop_name'] as String? ?? json['crop_name'] as String? ?? json['name'] as String? ?? '',
      variety: data['variety'] as String? ?? json['variety'] as String? ?? 'Standard',
      quantityKg: qty,
      availableQuantityKg: _parseDouble(data['available_quantity_kg'] ?? json['available_quantity_kg'], qty),
      grade: _gradeFromString(rawGrade),
      availableDate: (data['harvest_date'] != null
          ? DateTime.tryParse(data['harvest_date'] as String)
          : (json['harvest_date'] != null ? DateTime.tryParse(json['harvest_date'] as String) : null)) ?? DateTime.now(),
      location: data['pickup_address'] as String? ?? json['pickup_address'] as String? ?? json['location'] as String? ?? '',
      pickupLatitude: _parseDouble(data['pickup_latitude'] ?? json['pickup_latitude'], 17.3850),
      pickupLongitude: _parseDouble(data['pickup_longitude'] ?? json['pickup_longitude'], 78.4867),
      qualityScore: _parseDouble(data['quality_score'] ?? json['quality_score'], 87.0),
      confidenceScore: _parseDouble(data['confidence_score'] ?? json['confidence_score'], 91.0),
      observations: ((data['observations'] ?? json['observations']) as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      riskLevel: data['risk_level'] as String? ?? json['risk_level'] as String? ?? 'LOW',
      photoCount: _parseInt(data['photo_count'] ?? json['photo_count'], 0),
      status: data['status'] as String? ?? json['status'] as String? ?? 'Listed',
      expectedPricePerKg: _parseDouble(
        data['base_price_per_kg'] ??
            data['expected_price_per_kg'] ??
            data['price_per_kg'] ??
            json['base_price_per_kg'] ??
            json['expected_price_per_kg'] ??
            json['price_per_kg'],
        20.0,
      ),
      imageUrl: data['image_url'] as String? ?? json['image_url'] as String?,
      assessmentId: assessmentId,
    );
  }

  static double _parseDouble(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    if (val is String) {
      return double.tryParse(val) ?? fallback;
    }
    return fallback;
  }

  static int _parseInt(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    if (val is num) return val.toInt();
    if (val is String) {
      return int.tryParse(val) ?? fallback;
    }
    return fallback;
  }

  /// Exact contract payload for Module 7 (API Endpoint 2) & Sprint Update: POST /api/v1/farmer/produce
  Map<String, dynamic> toContractJson({String? overrideFarmerId}) {
    final effectiveFarmerId = (overrideFarmerId != null && overrideFarmerId.isNotEmpty)
        ? overrideFarmerId
        : farmerId;
    final cleanCrop = cropName.toLowerCase().split(' ').first;
    final contractGrade = grade == QualityGrade.gradeA
        ? 'gradeA'
        : (grade == QualityGrade.gradeB ? 'gradeB' : 'gradeC');

    return {
      'farmer_id': effectiveFarmerId,
      'crop_name': cleanCrop,
      'crop': cleanCrop,
      'variety': variety.isNotEmpty ? variety : 'Standard',
      'total_quantity_kg': quantityKg,
      'quantity_kg': quantityKg,
      'available_quantity_kg': availableQuantityKg,
      'expected_price_per_kg': expectedPricePerKg,
      'price_per_kg': expectedPricePerKg,
      'base_price_per_kg': expectedPricePerKg,
      'harvest_date': availableDate.toUtc().toIso8601String(),
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'pickup_address': location.isNotEmpty ? location : 'Farm Location',
      'location': location.isNotEmpty ? location : 'Farm Location',
      if (assessmentId != null && assessmentId!.isNotEmpty) 'assessment_id': assessmentId,
      'quality_grade': contractGrade,
      'grade': gradeLabel,
      // Exact Module 7 API Endpoint 2 nested data envelope:
      'data': {
        'crop_name': cleanCrop,
        'variety': variety.isNotEmpty ? variety : 'Standard',
        'quantity_kg': quantityKg,
        'total_quantity_kg': quantityKg,
        'available_quantity_kg': availableQuantityKg,
        'base_price_per_kg': expectedPricePerKg,
        'expected_price_per_kg': expectedPricePerKg,
        'harvest_date': availableDate.toUtc().toIso8601String(),
        'pickup_latitude': pickupLatitude,
        'pickup_longitude': pickupLongitude,
        'pickup_address': location.isNotEmpty ? location : 'Farm Location',
        if (assessmentId != null && assessmentId!.isNotEmpty) 'assessment_id': assessmentId,
      },
    };
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'farmer_id': farmerId,
        'farmer_name': farmerName,
        'crop_name': cropName,
        'name': cropName,
        'variety': variety,
        'expected_price_per_kg': expectedPricePerKg,
        'price_per_kg': expectedPricePerKg,
        'base_price_per_kg': expectedPricePerKg,
        'total_quantity_kg': quantityKg,
        'quantity_kg': quantityKg,
        'available_quantity_kg': availableQuantityKg,
        'pickup_address': location,
        'location': location,
        'pickup_latitude': pickupLatitude,
        'pickup_longitude': pickupLongitude,
        'harvest_date': availableDate.toUtc().toIso8601String(),
        'quality_grade': grade == QualityGrade.gradeA
            ? 'gradeA'
            : (grade == QualityGrade.gradeB ? 'gradeB' : 'gradeC'),
        'grade': gradeLabel,
        'photo_count': photoPaths.isNotEmpty ? photoPaths.length : photoCount,
        if (imageUrl != null) 'image_url': imageUrl,
        if (assessmentId != null) 'assessment_id': assessmentId,
        'quality_score': qualityScore,
        'confidence_score': confidenceScore,
        'risk_level': riskLevel,
        'status': status,
      };

  static QualityGrade _gradeFromString(String s) {
    final clean = s.toUpperCase().replaceAll(' ', '').replaceAll('_', '');
    if (clean.contains('GRADEB') || clean == 'B') {
      return QualityGrade.gradeB;
    }
    if (clean.contains('GRADEC') || clean == 'C') {
      return QualityGrade.gradeC;
    }
    return QualityGrade.gradeA;
  }

  /// No hardcoded mock produce. All produce is dynamically fetched from the cloud backend.
  static const List<ProduceItem> seedFarmerProduce = [];
}