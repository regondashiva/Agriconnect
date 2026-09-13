enum OrderType { bulkCoordination, householdConsumer }

enum OrderStage {
  orderCreated,
  supplyMatched,
  supplyAggregated,
  qualityEvidence,
  pickupScheduled,
  inTransit,
  delivered,
  settlementCompleted,
}

class TimelineStep {
  final OrderStage stage;
  final String title;
  final String subtitle;
  final DateTime? timestamp;
  final bool isCompleted;
  final bool isCurrent;

  const TimelineStep({
    required this.stage,
    required this.title,
    required this.subtitle,
    this.timestamp,
    this.isCompleted = false,
    this.isCurrent = false,
  });
}

class FarmerSettlement {
  final String farmerName;
  final double quantityKg;
  final double amount;
  final String status; // 'Completed', 'Processing'

  const FarmerSettlement({
    required this.farmerName,
    required this.quantityKg,
    required this.amount,
    this.status = 'Completed',
  });
}

class OrderModel {
  final String orderId; // e.g. 'AGR-1024' or 'AGR-2048'
  final OrderType type;
  final String cropName;
  final double totalQuantityKg;
  final double totalAmount;
  final String buyerName;
  final String deliveryAddress;
  final List<TimelineStep> timeline;
  final List<FarmerSettlement> settlements;
  final String eta;
  final String currentStatusText;
  final String paymentMethod;
  final List<String> itemsSummary;
  final DateTime? orderDate;

  const OrderModel({
    required this.orderId,
    required this.type,
    required this.cropName,
    required this.totalQuantityKg,
    required this.totalAmount,
    required this.buyerName,
    required this.deliveryAddress,
    required this.timeline,
    this.settlements = const [],
    this.eta = 'Today, 4:30 PM',
    required this.currentStatusText,
    this.paymentMethod = 'UPI (Google Pay / PhonePe)',
    this.itemsSummary = const ['Fresh Farm Tomatoes (2 kg)', 'Organic Potatoes (1 kg)'],
    this.orderDate,
  });
}
