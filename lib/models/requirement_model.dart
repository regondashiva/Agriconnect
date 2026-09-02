import 'produce_model.dart';

class BulkRequirement {
  final String id;
  final String buyerId;
  final String buyerName;
  final String cropName;
  final double requiredQuantityKg;
  final QualityGrade qualityGrade;
  final String deliveryLocation;
  final DateTime requiredDate;
  final double priceRangeMin;
  final double priceRangeMax;
  final String status; // 'Active', 'Matching', 'Fulfilled', 'Closed'
  final DateTime createdAt;

  const BulkRequirement({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.cropName,
    required this.requiredQuantityKg,
    required this.qualityGrade,
    required this.deliveryLocation,
    required this.requiredDate,
    required this.priceRangeMin,
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
}
