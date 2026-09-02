enum QualityGrade { gradeA, gradeB, gradeC }

class ProduceItem {
  final String id;
  final String farmerId;
  final String farmerName;
  final String cropName;
  final double quantityKg;
  final QualityGrade grade;
  final DateTime availableDate;
  final String location;
  final double qualityScore; // e.g. 87 / 100
  final double confidenceScore; // e.g. 91%
  final List<String> observations;
  final String riskLevel; // LOW, MEDIUM, HIGH
  final int photoCount;
  final String status; // 'Listed', 'Matched', 'In Aggregation', 'Sold'
  final double expectedPricePerKg;

  const ProduceItem({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.cropName,
    required this.quantityKg,
    required this.grade,
    required this.availableDate,
    required this.location,
    this.qualityScore = 87.0,
    this.confidenceScore = 91.0,
    this.observations = const [
      'Good colour consistency',
      'Good size consistency',
      'Appearance acceptable',
      'Minor visible defects',
    ],
    this.riskLevel = 'LOW',
    this.photoCount = 4,
    this.status = 'Listed',
    this.expectedPricePerKg = 20.0,
  });

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
}
