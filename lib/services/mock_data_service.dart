import '../models/user_model.dart';
import '../models/produce_model.dart';
import '../models/requirement_model.dart';
import '../models/match_model.dart';
import '../models/order_model.dart';
import '../models/consumer_product_model.dart';
import '../models/notification_model.dart';

class MockDataService {
  // Pre-configured Demo Users (for SIH 2026 passwordless OTP matching)
  static const User demoFarmer = User(
    id: 'farmer_001',
    name: 'Ramesh Reddy',
    phoneNumber: '+91 98765 43210',
    role: UserRole.farmer,
    location: 'Chevella Village, Ranga Reddy Dist',
    preferredLanguage: 'Telugu / English',
    fpoCluster: 'Ranga Reddy Organic Producers FPO',
  );

  static const User demoFpo = User(
    id: 'fpo_001',
    name: 'Suresh Rao (Coordinator)',
    phoneNumber: '+91 98765 43211',
    role: UserRole.fpo,
    location: 'Shabad Center, Hyderabad Rural',
    businessName: 'Ranga Reddy Farmers Producer Org',
  );

  static const User demoBuyer = User(
    id: 'buyer_001',
    name: 'Hyderabadi Mart & Co-op',
    phoneNumber: '+91 98765 43212',
    role: UserRole.bulkBuyer,
    location: 'Kothapet Wholesale Mandi, Hyderabad',
    businessName: 'FreshBasket Wholesale Pvt Ltd',
  );

  static const User demoConsumer = User(
    id: 'consumer_001',
    name: 'Ananya Sharma',
    phoneNumber: '+91 98765 43213',
    role: UserRole.consumer,
    location: 'Madhapur, Hyderabad',
  );

  static List<User> get initialUsers => [
    demoFarmer,
    demoFpo,
    demoBuyer,
    demoConsumer,
  ];

  // Standard SIH Demo Produce
  static final List<ProduceItem> initialProduceList = [
    ProduceItem(
      id: 'PROD-TOM-01',
      farmerId: 'farmer_001',
      farmerName: 'Ramesh Reddy (You)',
      cropName: 'Tomato (Hybrid Red)',
      quantityKg: 100.0,
      grade: QualityGrade.gradeA,
      availableDate: DateTime.now().add(const Duration(days: 1)),
      location: 'Chevella (12 km from FPO Hub)',
      qualityScore: 87.0,
      confidenceScore: 91.0,
      observations: const [
        '✓ Good colour consistency',
        '✓ Good size consistency',
        '✓ Appearance acceptable',
        '⚠ Minor visible surface marks',
      ],
      riskLevel: 'LOW',
      photoCount: 4,
      status: 'Listed',
      expectedPricePerKg: 20.0,
    ),
    ProduceItem(
      id: 'PROD-POT-02',
      farmerId: 'farmer_001',
      farmerName: 'Ramesh Reddy (You)',
      cropName: 'Potato (Jyoti)',
      quantityKg: 250.0,
      grade: QualityGrade.gradeA,
      availableDate: DateTime.now().add(const Duration(days: 2)),
      location: 'Chevella',
      qualityScore: 89.0,
      confidenceScore: 94.0,
      observations: const [
        '✓ Firm skin texture',
        '✓ Uniform oval sizing',
        '✓ Low moisture loss',
      ],
      riskLevel: 'LOW',
      photoCount: 3,
      status: 'Listed',
      expectedPricePerKg: 18.0,
    ),
  ];

  // Standard SIH Demo Bulk Requirement (500 kg Tomato)
  static final BulkRequirement demoTomatoRequirement = BulkRequirement(
    id: 'REQ-TOM-500',
    buyerId: 'buyer_001',
    buyerName: 'FreshBasket Wholesale Mandi',
    cropName: 'Tomato (Grade A)',
    requiredQuantityKg: 500.0,
    qualityGrade: QualityGrade.gradeA,
    deliveryLocation: 'Kothapet Mandi, Hyderabad',
    requiredDate: DateTime.now().add(const Duration(days: 1)),
    priceRangeMin: 19.0,
    priceRangeMax: 22.0,
    status: 'Matching',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  );

  // Standard SIH Demo 3-Farmer Aggregated Match
  static final SupplyMatch demoTomatoMatch = SupplyMatch(
    id: 'MATCH-1024',
    requirementId: 'REQ-TOM-500',
    cropName: 'Tomato',
    requiredQuantityKg: 500.0,
    matchedQuantityKg: 500.0,
    matchScorePercent: 92.0,
    qualityScore: 87.0,
    confidenceScore: 91.0,
    contributors: const [
      SupplyContributor(
        farmerId: 'farmer_001',
        farmerName: 'Farmer A (Ramesh - You)',
        quantityKg: 100.0,
        location: 'Chevella Hub',
        payoutAmount: 2000.0,
      ),
      SupplyContributor(
        farmerId: 'farmer_002',
        farmerName: 'Farmer B (Suresh)',
        quantityKg: 150.0,
        location: 'Shabad Farm',
        payoutAmount: 3000.0,
      ),
      SupplyContributor(
        farmerId: 'farmer_003',
        farmerName: 'Farmer C (Ravi)',
        quantityKg: 250.0,
        location: 'Moinabad Cluster',
        payoutAmount: 5000.0,
      ),
    ],
    buyerName: 'FreshBasket Wholesale Mandi',
    deliveryLocation: 'Kothapet Mandi, Hyderabad',
    totalEstimatedValue: 10000.0,
    totalDistanceKm: 38.4,
    estimatedTravelTime: '1 hr 30 min',
    vehicleCapacity: '1.5 Ton Bolero Pickup',
  );

  // Standard SIH Demo Order AGR-1024
  static OrderModel getDemoBulkOrder({bool isDelivered = false}) {
    return OrderModel(
      orderId: 'AGR-1024',
      type: OrderType.bulkCoordination,
      cropName: 'Tomato (500 kg Aggregated)',
      totalQuantityKg: 500.0,
      totalAmount: 10000.0,
      buyerName: 'FreshBasket Wholesale Mandi',
      deliveryAddress: 'Plot 42, Kothapet Wholesale Hub, Hyderabad',
      timeline: [
        const TimelineStep(
          stage: OrderStage.orderCreated,
          title: 'Order Created',
          subtitle: 'Buyer confirmed 500 kg requirement',
          isCompleted: true,
        ),
        const TimelineStep(
          stage: OrderStage.supplyMatched,
          title: 'Supply Matched',
          subtitle: '92% match score across 3 local farmers',
          isCompleted: true,
        ),
        const TimelineStep(
          stage: OrderStage.supplyAggregated,
          title: 'Supply Aggregated',
          subtitle: '100kg + 150kg + 250kg = 500kg fulfilled',
          isCompleted: true,
        ),
        const TimelineStep(
          stage: OrderStage.qualityEvidence,
          title: 'Quality Evidence Verified',
          subtitle: 'AI-Assisted Assessment: 87/100 (91% confidence)',
          isCompleted: true,
        ),
        TimelineStep(
          stage: OrderStage.pickupScheduled,
          title: 'Pickup Scheduled',
          subtitle: 'Vehicle: AP 28 TA 4512 (Bolero 1.5T)',
          isCompleted: true,
          isCurrent: !isDelivered,
        ),
        TimelineStep(
          stage: OrderStage.inTransit,
          title: 'In Transit',
          subtitle: 'En route to Kothapet Delivery Point',
          isCompleted: isDelivered,
          isCurrent: false,
        ),
        TimelineStep(
          stage: OrderStage.delivered,
          title: 'Delivered',
          subtitle: 'Received at Wholesale Gate #3',
          isCompleted: isDelivered,
        ),
        TimelineStep(
          stage: OrderStage.settlementCompleted,
          title: 'Settlement Completed',
          subtitle: '₹10,000 distributed to 3 farmers',
          isCompleted: isDelivered,
        ),
      ],
      settlements: const [
        FarmerSettlement(
          farmerName: 'Farmer A (Ramesh - You)',
          quantityKg: 100.0,
          amount: 2000.0,
        ),
        FarmerSettlement(
          farmerName: 'Farmer B (Suresh)',
          quantityKg: 150.0,
          amount: 3000.0,
        ),
        FarmerSettlement(
          farmerName: 'Farmer C (Ravi)',
          quantityKg: 250.0,
          amount: 5000.0,
        ),
      ],
      eta: isDelivered ? 'Delivered' : 'Today, 4:30 PM',
      currentStatusText: isDelivered ? 'Settlement Completed' : 'In Transit (Pickup complete)',
    );
  }

  // Consumer Catalog Products
  static final List<ConsumerProduct> consumerProducts = [
    const ConsumerProduct(
      id: 'c_prod_01',
      name: 'Fresh Farm Tomatoes',
      category: 'Vegetables',
      pricePerKg: 28.0,
      availableQuantityKg: 120.0,
      source: 'Direct from FPO (Ranga Reddy)',
      distanceKm: 4.2,
      qualityGrade: 'Grade A',
      iconEmoji: '🍅',
    ),
    const ConsumerProduct(
      id: 'c_prod_02',
      name: 'Organic Potatoes',
      category: 'Vegetables',
      pricePerKg: 24.0,
      availableQuantityKg: 200.0,
      source: 'Direct from Farmer (Chevella)',
      distanceKm: 5.1,
      qualityGrade: 'Grade A',
      iconEmoji: '🥔',
    ),
    const ConsumerProduct(
      id: 'c_prod_03',
      name: 'Fresh Red Onions',
      category: 'Vegetables',
      pricePerKg: 30.0,
      availableQuantityKg: 180.0,
      source: 'Direct from FPO Hub',
      distanceKm: 3.8,
      qualityGrade: 'Grade A',
      iconEmoji: '🧅',
    ),
    const ConsumerProduct(
      id: 'c_prod_04',
      name: 'Fresh Spinach (Palak)',
      category: 'Greens',
      pricePerKg: 20.0,
      availableQuantityKg: 45.0,
      source: 'Direct from Local Farmer',
      distanceKm: 2.5,
      qualityGrade: 'Farm Fresh',
      iconEmoji: '🥬',
    ),
    const ConsumerProduct(
      id: 'c_prod_05',
      name: 'Sona Masoori Rice (Unpolished)',
      category: 'Grains',
      pricePerKg: 54.0,
      availableQuantityKg: 500.0,
      source: 'Direct from FPO Co-op',
      distanceKm: 6.0,
      qualityGrade: 'Premium',
      iconEmoji: '🌾',
    ),
  ];

  // Consumer Order AGR-2048
  static OrderModel getConsumerDemoOrder({bool isDelivered = false}) {
    return OrderModel(
      orderId: 'AGR-2048',
      type: OrderType.householdConsumer,
      cropName: 'Fresh Tomatoes (2 kg) + Potatoes (1 kg)',
      totalQuantityKg: 3.0,
      totalAmount: 100.0,
      buyerName: 'Ananya Sharma',
      deliveryAddress: 'Flat 402, Green Meadows, Madhapur, Hyderabad',
      timeline: [
        const TimelineStep(
          stage: OrderStage.orderCreated,
          title: 'Order Confirmed',
          subtitle: 'Direct farm order received',
          isCompleted: true,
        ),
        const TimelineStep(
          stage: OrderStage.supplyMatched,
          title: 'Preparing at Hub',
          subtitle: 'Cleaned & packed from Ranga Reddy FPO',
          isCompleted: true,
        ),
        TimelineStep(
          stage: OrderStage.pickupScheduled,
          title: 'Picked Up by Delivery Partner',
          subtitle: 'Agent: Mahesh (+91 98765 00112)',
          isCompleted: true,
          isCurrent: !isDelivered,
        ),
        TimelineStep(
          stage: OrderStage.inTransit,
          title: 'Out for Delivery',
          subtitle: 'Estimated within 25 minutes',
          isCompleted: isDelivered,
        ),
        TimelineStep(
          stage: OrderStage.delivered,
          title: 'Delivered',
          subtitle: 'Handed over at doorstep',
          isCompleted: isDelivered,
        ),
      ],
      eta: isDelivered ? 'Delivered' : 'In 25 minutes',
      currentStatusText: isDelivered ? 'Delivered' : 'Out for Delivery',
    );
  }

  // Role-specific notifications
  static List<NotificationItem> getNotifications(UserRole role) {
    switch (role) {
      case UserRole.farmer:
        return const [
          NotificationItem(
            id: 'n_f_1',
            targetRole: UserRole.farmer,
            title: 'New High-Match Buyer Opportunity!',
            body: 'Wholesale Buyer requires 500 kg Tomato. Your 100 kg is matched at 92% score.',
            timeAgo: '10 min ago',
            type: NotificationType.opportunity,
          ),
          NotificationItem(
            id: 'n_f_2',
            targetRole: UserRole.farmer,
            title: 'Supply Aggregated with 2 other farmers',
            body: 'Batch completed (500/500 kg). Logistics dispatching soon.',
            timeAgo: '1 hr ago',
            type: NotificationType.aggregation,
          ),
          NotificationItem(
            id: 'n_f_3',
            targetRole: UserRole.farmer,
            title: 'Pickup Scheduled for Tomorrow 7:00 AM',
            body: 'Vehicle AP 28 TA 4512 will stop at Chevella Hub.',
            timeAgo: '2 hrs ago',
            type: NotificationType.logistics,
          ),
          NotificationItem(
            id: 'n_f_4',
            targetRole: UserRole.farmer,
            title: 'Settlement Completed: ₹2,000',
            body: 'Direct transfer to Bank Account for Order AGR-1024.',
            timeAgo: 'Yesterday',
            type: NotificationType.settlement,
          ),
        ];

      case UserRole.fpo:
        return const [
          NotificationItem(
            id: 'n_fpo_1',
            targetRole: UserRole.fpo,
            title: 'New Bulk Requirement: 500 kg Tomato',
            body: 'FreshBasket Wholesale Mandi placed a demand request in Hyderabad.',
            timeAgo: '15 min ago',
            type: NotificationType.opportunity,
          ),
          NotificationItem(
            id: 'n_fpo_2',
            targetRole: UserRole.fpo,
            title: '3 Member Farmers Ready for Aggregation',
            body: 'Ramesh (100kg), Suresh (150kg), Ravi (250kg) ready for batching.',
            timeAgo: '45 min ago',
            type: NotificationType.aggregation,
          ),
          NotificationItem(
            id: 'n_fpo_3',
            targetRole: UserRole.fpo,
            title: 'Multi-Stop Pickup Route Dispatched',
            body: 'Logistics mini-truck started route from Shabad center.',
            timeAgo: '2 hrs ago',
            type: NotificationType.logistics,
          ),
        ];

      case UserRole.bulkBuyer:
        return const [
          NotificationItem(
            id: 'n_b_1',
            targetRole: UserRole.bulkBuyer,
            title: 'Supply Match Found: 92% Match Score',
            body: '500 kg Tomato matched via 3 verified FPO farmers.',
            timeAgo: '5 min ago',
            type: NotificationType.opportunity,
          ),
          NotificationItem(
            id: 'n_b_2',
            targetRole: UserRole.bulkBuyer,
            title: 'AI Quality Evidence Verified (87/100)',
            body: 'Multi-batch photo assessment shows low defect risk & consistent sizing.',
            timeAgo: '30 min ago',
            type: NotificationType.orderUpdate,
          ),
          NotificationItem(
            id: 'n_b_3',
            targetRole: UserRole.bulkBuyer,
            title: 'Order AGR-1024 In Transit',
            body: 'Expected arrival at Kothapet Gate #3 today by 4:30 PM.',
            timeAgo: '1 hr ago',
            type: NotificationType.logistics,
          ),
        ];

      case UserRole.consumer:
        return const [
          NotificationItem(
            id: 'n_c_1',
            targetRole: UserRole.consumer,
            title: 'Order AGR-2048 Picked Up!',
            body: 'Your farm-fresh produce is on the way from Ranga Reddy FPO.',
            timeAgo: '5 min ago',
            type: NotificationType.orderUpdate,
          ),
          NotificationItem(
            id: 'n_c_2',
            targetRole: UserRole.consumer,
            title: 'Farmer Support Impact',
            body: 'Your purchase directly supported Ramesh Reddy & Ranga Reddy FPO.',
            timeAgo: '1 day ago',
            type: NotificationType.opportunity,
          ),
        ];
    }
  }
}
