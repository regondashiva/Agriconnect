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
    final qty = (data['total_quantity_kg'] as num?)?.toDouble() ??
        (data['quantity_kg'] as num?)?.toDouble() ??
        (json['total_quantity_kg'] as num?)?.toDouble() ??
        0.0;
    return ProduceItem(
      id: json['id']?.toString() ?? data['id']?.toString() ?? '',
      farmerId: json['farmer_id']?.toString() ?? data['farmer_id']?.toString() ?? '',
      farmerName: json['farmer_name'] as String? ?? data['farmer_name'] as String? ?? 'Farmer',
      cropName: data['crop_name'] as String? ?? json['crop_name'] as String? ?? json['name'] as String? ?? '',
      variety: data['variety'] as String? ?? json['variety'] as String? ?? 'Standard',
      quantityKg: qty,
      availableQuantityKg: (data['available_quantity_kg'] as num?)?.toDouble() ??
          (json['available_quantity_kg'] as num?)?.toDouble() ??
          qty,
      grade: _gradeFromString(data['quality_grade'] as String? ?? json['quality_grade'] as String? ?? json['grade'] as String? ?? 'A'),
      availableDate: (data['harvest_date'] != null
          ? DateTime.tryParse(data['harvest_date'] as String)
          : (json['harvest_date'] != null ? DateTime.tryParse(json['harvest_date'] as String) : null)) ?? DateTime.now(),
      location: data['pickup_address'] as String? ?? json['pickup_address'] as String? ?? json['location'] as String? ?? '',
      pickupLatitude: (data['pickup_latitude'] as num?)?.toDouble() ?? (json['pickup_latitude'] as num?)?.toDouble() ?? 17.3850,
      pickupLongitude: (data['pickup_longitude'] as num?)?.toDouble() ?? (json['pickup_longitude'] as num?)?.toDouble() ?? 78.4867,
      qualityScore: (data['quality_score'] as num?)?.toDouble() ?? (json['quality_score'] as num?)?.toDouble() ?? 87.0,
      confidenceScore: (data['confidence_score'] as num?)?.toDouble() ?? (json['confidence_score'] as num?)?.toDouble() ?? 91.0,
      observations: ((data['observations'] ?? json['observations']) as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      riskLevel: data['risk_level'] as String? ?? json['risk_level'] as String? ?? 'LOW',
      photoCount: (data['photo_count'] as num?)?.toInt() ?? (json['photo_count'] as num?)?.toInt() ?? 0,
      status: data['status'] as String? ?? json['status'] as String? ?? 'Listed',
      expectedPricePerKg: (data['expected_price_per_kg'] as num?)?.toDouble() ??
          (data['price_per_kg'] as num?)?.toDouble() ??
          (json['expected_price_per_kg'] as num?)?.toDouble() ??
          (json['price_per_kg'] as num?)?.toDouble() ??
          20.0,
      imageUrl: data['image_url'] as String? ?? json['image_url'] as String?,
    );
  }

  /// Exact contract payload for Module 2: POST /api/v1/farmer/produce
  Map<String, dynamic> toContractJson({String? overrideFarmerId}) {
    final effectiveFarmerId = (overrideFarmerId != null && overrideFarmerId.isNotEmpty)
        ? overrideFarmerId
        : farmerId;
    return {
      'farmer_id': effectiveFarmerId,
      'data': {
        'crop_name': cropName.toLowerCase().split(' ').first,
        'variety': variety.isNotEmpty ? variety : 'Standard',
        'total_quantity_kg': quantityKg,
        'available_quantity_kg': availableQuantityKg,
        'expected_price_per_kg': expectedPricePerKg,
        'harvest_date': availableDate.toUtc().toIso8601String(),
        'pickup_latitude': pickupLatitude,
        'pickup_longitude': pickupLongitude,
        'pickup_address': location.isNotEmpty ? location : 'Farm Location',
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
        'total_quantity_kg': quantityKg,
        'quantity_kg': quantityKg,
        'available_quantity_kg': availableQuantityKg,
        'pickup_address': location,
        'location': location,
        'pickup_latitude': pickupLatitude,
        'pickup_longitude': pickupLongitude,
        'harvest_date': availableDate.toUtc().toIso8601String(),
        'quality_grade': grade == QualityGrade.gradeA
            ? 'A'
            : (grade == QualityGrade.gradeB ? 'B' : 'C'),
        'grade': gradeLabel,
        'photo_count': photoPaths.isNotEmpty ? photoPaths.length : photoCount,
        if (imageUrl != null) 'image_url': imageUrl,
      };

  static QualityGrade _gradeFromString(String s) {
    switch (s.toUpperCase()) {
      case 'B':
      case 'GRADE B':
        return QualityGrade.gradeB;
      case 'C':
      case 'GRADE C':
        return QualityGrade.gradeC;
      default:
        return QualityGrade.gradeA;
    }
  }

  static final List<ProduceItem> seedFarmerProduce = [
    ProduceItem(
      id: 'prod_tomato_001',
      farmerId: 'usr_farmer_001',
      farmerName: 'Cluster Verified Farmer',
      cropName: 'Tomato',
      variety: 'Hybrid Roma',
      quantityKg: 100.0,
      availableQuantityKg: 100.0,
      expectedPricePerKg: 20.0,
      grade: QualityGrade.gradeA,
      qualityScore: 89.4,
      confidenceScore: 93.8,
      riskLevel: 'LOW',
      photoCount: 4,
      observations: const [
        'High color consistency across produce batch',
        'Uniform fruit size distribution (60-70mm)',
        'No visible pest punctures or rot detected',
        'Firm skin with optimal sugar-to-acid balance',
      ],
      availableDate: DateTime(2026, 9, 8),
      location: 'Chevella Village, Ranga Reddy Dist, Telangana',
      pickupLatitude: 17.3075,
      pickupLongitude: 78.1362,
      status: 'Listed',
      imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&auto=format&fit=crop&q=80',
    ),
    ProduceItem(
      id: 'prod_potato_001',
      farmerId: 'usr_farmer_001',
      farmerName: 'Cluster Verified Farmer',
      cropName: 'Potato',
      variety: 'Kufri Jyoti',
      quantityKg: 250.0,
      availableQuantityKg: 250.0,
      expectedPricePerKg: 18.0,
      grade: QualityGrade.gradeA,
      qualityScore: 91.2,
      confidenceScore: 94.5,
      riskLevel: 'LOW',
      photoCount: 4,
      observations: const [
        'Smooth skin with shallow eyes and uniform shape',
        'Zero greening or sprouting observed across lot',
        'Optimal dry matter content suitable for retail and processing',
        'Firm unblemished tubers with minimal soil residue',
      ],
      availableDate: DateTime(2026, 9, 7),
      location: 'Chevella Village, Ranga Reddy Dist, Telangana',
      pickupLatitude: 17.3075,
      pickupLongitude: 78.1362,
      status: 'Listed',
      imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&auto=format&fit=crop&q=80',
    ),
    ProduceItem(
      id: 'prod_onion_001',
      farmerId: 'usr_farmer_001',
      farmerName: 'Cluster Verified Farmer',
      cropName: 'Onion',
      variety: 'Nashik Red',
      quantityKg: 300.0,
      availableQuantityKg: 300.0,
      expectedPricePerKg: 24.0,
      grade: QualityGrade.gradeA,
      qualityScore: 88.0,
      confidenceScore: 92.0,
      riskLevel: 'LOW',
      photoCount: 3,
      observations: const [
        'Well-cured tight outer scales with deep red luster',
        'Uniform 50-60mm medium bulb diameter',
        'Zero bottlenecking or double bulb defects',
        'Dry neck closure indicating high storage life',
      ],
      availableDate: DateTime(2026, 9, 6),
      location: 'Chevella Village, Ranga Reddy Dist, Telangana',
      pickupLatitude: 17.3075,
      pickupLongitude: 78.1362,
      status: 'Listed',
      imageUrl: 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=600&auto=format&fit=crop&q=80',
    ),
    ProduceItem(
      id: 'prod_chilli_001',
      farmerId: 'usr_farmer_001',
      farmerName: 'Cluster Verified Farmer',
      cropName: 'Green Chillies',
      variety: 'Guntur Teja',
      quantityKg: 80.0,
      availableQuantityKg: 80.0,
      expectedPricePerKg: 42.0,
      grade: QualityGrade.gradeA,
      qualityScore: 90.5,
      confidenceScore: 93.0,
      riskLevel: 'LOW',
      photoCount: 4,
      observations: const [
        'Vibrant glossy emerald green color',
        'Crisp fresh green calyx firmly attached',
        'High pungent aroma with firm pod turgidity',
        'Zero sunscald, anthracnose, or pest marks',
      ],
      availableDate: DateTime(2026, 9, 8),
      location: 'Chevella Village, Ranga Reddy Dist, Telangana',
      pickupLatitude: 17.3075,
      pickupLongitude: 78.1362,
      status: 'Listed',
      imageUrl: 'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=600&auto=format&fit=crop&q=80',
    ),
    ProduceItem(
      id: 'prod_capsicum_001',
      farmerId: 'usr_farmer_001',
      farmerName: 'Cluster Verified Farmer',
      cropName: 'Capsicum',
      variety: 'Indra Green',
      quantityKg: 120.0,
      availableQuantityKg: 120.0,
      expectedPricePerKg: 35.0,
      grade: QualityGrade.gradeA,
      qualityScore: 89.0,
      confidenceScore: 91.5,
      riskLevel: 'LOW',
      photoCount: 5,
      observations: const [
        'Thick glossy dark-green wall thickness (> 6mm)',
        'Uniform 4-lobed blocky bell pepper shape',
        'High turgidity with fresh stout green stalk',
        'Zero pesticide residue marks or bruising',
      ],
      availableDate: DateTime(2026, 9, 8),
      location: 'Chevella Village, Ranga Reddy Dist, Telangana',
      pickupLatitude: 17.3075,
      pickupLongitude: 78.1362,
      status: 'Listed',
      imageUrl: 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=600&auto=format&fit=crop&q=80',
    ),
  ];
}