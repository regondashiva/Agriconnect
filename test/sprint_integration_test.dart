import 'package:flutter_test/flutter_test.dart';
import 'package:agriconnect/core/constants/api_constants.dart';
import 'package:agriconnect/models/user_model.dart';
import 'package:agriconnect/models/produce_model.dart';
import 'package:agriconnect/models/requirement_model.dart';

void main() {
  group('Frontend Integration Guide (Sprint Update) Contract Tests', () {
    test('1. User Profile & KYC payload has required flattened schema', () {
      final user = User(
        id: 'usr_farmer_101',
        name: 'Ramesh Kumar',
        phoneNumber: '+919876543210',
        role: UserRole.farmer,
        location: 'Warangal, Telangana',
        preferredLanguage: 'te',
        primaryCrops: ['Paddy', 'Tomato'],
        landSizeAcres: 3.5,
        fpoCluster: 'Chevella Agro Cluster',
        upiId: 'ramesh@upi',
        bankName: 'State Bank of India',
        isNewUser: false,
        isVerified: true,
      );

      final payload = user.toProfilePayload();

      expect(payload['full_name'], equals('Ramesh Kumar'));
      expect(payload['preferred_language'], equals('te'));
      expect(payload['role'], equals('farmer'));
      expect(payload['location'], equals('Warangal, Telangana'));
      expect(payload['farm_location'], equals('Warangal, Telangana'));
      expect(payload['primary_crops'], equals(['Paddy', 'Tomato']));
      expect(payload['land_size_acres'], equals(3.5));
      expect(payload['fpo_cluster_assigned'], equals('Chevella Agro Cluster'));
      expect(payload['upi_id'], equals('ramesh@upi'));
      expect(payload['bank_name'], equals('State Bank of India'));
    });

    test('2. Farmer Produce POST has flattened structure', () {
      final produce = ProduceItem(
        id: 'PRD-001',
        farmerId: 'usr_farmer_101',
        farmerName: 'Ramesh Kumar',
        cropName: 'Tomato',
        variety: 'Desi Red',
        quantityKg: 500.0,
        availableQuantityKg: 500.0,
        grade: QualityGrade.gradeA,
        availableDate: DateTime.parse('2026-09-15T00:00:00Z'),
        location: 'Warangal, Telangana',
        pickupLatitude: 17.9689,
        pickupLongitude: 79.5941,
        expectedPricePerKg: 22.0,
      );

      final payload = produce.toContractJson();

      expect(payload['farmer_id'], equals('usr_farmer_101'));
      expect(payload['crop_name'], equals('tomato'));
      expect(payload['variety'], equals('Desi Red'));
      expect(payload['total_quantity_kg'], equals(500.0));
      expect(payload['available_quantity_kg'], equals(500.0));
      expect(payload['expected_price_per_kg'], equals(22.0));
      expect(payload['pickup_latitude'], equals(17.9689));
      expect(payload['pickup_longitude'], equals(79.5941));
      expect(payload['pickup_address'], equals('Warangal, Telangana'));
    });

    test('3. Buyer Requirements POST has flattened structure', () {
      final req = BulkRequirement(
        id: 'REQ-001',
        buyerId: 'usr_buyer_202',
        buyerName: 'BigBasket Wholesale',
        cropName: 'Tomato',
        variety: 'Desi Red',
        requiredQuantityKg: 1000.0,
        qualityGrade: QualityGrade.gradeA,
        deliveryLocation: 'Bowenpally Mandi, Hyderabad',
        deliveryLatitude: 17.4700,
        deliveryLongitude: 78.4800,
        requiredDate: DateTime.parse('2026-09-20T00:00:00Z'),
        priceRangeMin: 20.0,
        priceRangeMax: 26.0,
        createdAt: DateTime.now(),
      );

      final payload = req.toContractJson();

      expect(payload['buyer_id'], equals('usr_buyer_202'));
      expect(payload['crop_name'], equals('tomato'));
      expect(payload['required_quantity_kg'], equals(1000.0));
      expect(payload['target_price_min'], equals(20.0));
      expect(payload['target_price_max'], equals(26.0));
      expect(payload['delivery_city'], equals('Bowenpally Mandi'));
    });

    test('4. Smart Matching Engine endpoint and parameters', () {
      expect(ApiConstants.matchingFind, equals('https://agriconnect-api-fiz5.onrender.com/api/v1/matching/find'));
      final uri = ApiConstants.withQuery(ApiConstants.matchingFind, {
        'crop': 'Tomato',
        'quantity_kg': 200,
        'lat': 17.3,
        'lng': 78.1,
        'max_distance_km': 50,
      });

      expect(uri.queryParameters['crop'], equals('Tomato'));
      expect(uri.queryParameters['quantity_kg'], equals('200'));
      expect(uri.queryParameters['lat'], equals('17.3'));
      expect(uri.queryParameters['lng'], equals('78.1'));
      expect(uri.queryParameters['max_distance_km'], equals('50'));
    });

    test('5. Razorpay & Escrow endpoints match sprint guide', () {
      expect(ApiConstants.razorpayCreateOrder, equals('https://agriconnect-api-fiz5.onrender.com/api/v1/payments/razorpay/create-order'));
      expect(ApiConstants.razorpayVerify, equals('https://agriconnect-api-fiz5.onrender.com/api/v1/payments/razorpay/verify'));
      expect(ApiConstants.escrowRelease, equals('https://agriconnect-api-fiz5.onrender.com/api/v1/payments/escrow/release'));
    });

    test('6. Consumer E-Commerce endpoints match sprint guide', () {
      expect(ApiConstants.consumerProducts, equals('https://agriconnect-api-fiz5.onrender.com/api/v1/consumer/products'));
      expect(ApiConstants.consumerCartAdd, equals('https://agriconnect-api-fiz5.onrender.com/api/v1/consumer/cart/add'));
      expect(ApiConstants.consumerCart, equals('https://agriconnect-api-fiz5.onrender.com/api/v1/consumer/cart'));
      expect(ApiConstants.consumerOrdersCreate, equals('https://agriconnect-api-fiz5.onrender.com/api/v1/consumer/orders/create'));
      expect(ApiConstants.consumerOrders, equals('https://agriconnect-api-fiz5.onrender.com/api/v1/consumer/orders'));
    });

    test('7. Delivery Logistics endpoints match sprint guide', () {
      expect(ApiConstants.deliveryDutyToggle, equals('https://agriconnect-api-fiz5.onrender.com/api/v1/delivery/duty/toggle'));
      expect(ApiConstants.deliveryTripsAvailable, equals('https://agriconnect-api-fiz5.onrender.com/api/v1/delivery/trips/available'));
      expect(ApiConstants.deliveryTripAccept('TRIP-99'), equals('https://agriconnect-api-fiz5.onrender.com/api/v1/delivery/trips/TRIP-99/accept'));
      expect(ApiConstants.deliveryTripStep('TRIP-99'), equals('https://agriconnect-api-fiz5.onrender.com/api/v1/delivery/trips/TRIP-99/step'));
      expect(ApiConstants.deliveryTripVerifyChecklist('TRIP-99'), equals('https://agriconnect-api-fiz5.onrender.com/api/v1/delivery/trips/TRIP-99/verify-checklist'));
      expect(ApiConstants.deliveryTripVerifyOtp('TRIP-99'), equals('https://agriconnect-api-fiz5.onrender.com/api/v1/delivery/trips/TRIP-99/verify-otp'));
      expect(ApiConstants.deliveryWallet, equals('https://agriconnect-api-fiz5.onrender.com/api/v1/delivery/wallet'));
    });

    test('8. Module 7: Quality Assessment (Assess & Finalize contracts)', () {
      // Endpoint contract
      expect(ApiConstants.assessProduce, equals('https://agriconnect-api-fiz5.onrender.com/api/v1/farmer/produce/assess'));

      // Step 1: Draft Response parsing
      final draftJson = {
        'id': 'abc-123-draft-uuid',
        'farmer_id': 'usr_farmer_101',
        'predicted_grade': 'gradeA',
        'quality_score': '92.5',
        'confidence_score': '90.0',
        'status': 'draft',
      };
      final draftItem = ProduceItem.fromJson(draftJson);
      expect(draftItem.id, equals('abc-123-draft-uuid'));
      expect(draftItem.assessmentId, equals('abc-123-draft-uuid'));
      expect(draftItem.grade, equals(QualityGrade.gradeA));
      expect(draftItem.qualityScore, equals(92.5));
      expect(draftItem.confidenceScore, equals(90.0));

      // Step 2: Finalize Produce Payload serialization with assessment_id
      final finalizeProduce = ProduceItem(
        id: '',
        farmerId: 'usr_farmer_101',
        farmerName: 'Ramesh Kumar',
        cropName: 'Tomatoes',
        variety: 'Hybrid Roma',
        quantityKg: 500.0,
        expectedPricePerKg: 25.50,
        grade: QualityGrade.gradeA,
        availableDate: DateTime.parse('2026-09-15T00:00:00Z'),
        location: 'Farm 12, AP',
        pickupLatitude: 17.3850,
        pickupLongitude: 78.4867,
        assessmentId: 'abc-123-draft-uuid',
      );

      final payload = finalizeProduce.toContractJson();
      expect(payload['farmer_id'], equals('usr_farmer_101'));
      expect(payload['assessment_id'], equals('abc-123-draft-uuid'));
      expect(payload['base_price_per_kg'], equals(25.50));

      final dataEnvelope = payload['data'] as Map<String, dynamic>;
      expect(dataEnvelope['crop_name'], equals('tomatoes'));
      expect(dataEnvelope['quantity_kg'], equals(500.0));
      expect(dataEnvelope['base_price_per_kg'], equals(25.50));
      expect(dataEnvelope['pickup_latitude'], equals(17.3850));
      expect(dataEnvelope['pickup_longitude'], equals(78.4867));
      expect(dataEnvelope['pickup_address'], equals('Farm 12, AP'));
      expect(dataEnvelope['assessment_id'], equals('abc-123-draft-uuid'));

      // Backend finalize response parsing
      final finalizeResponse = {
        'id': 'new-inventory-uuid',
        'crop_name': 'Tomatoes',
        'quality_grade': 'gradeA',
        'status': 'available',
        'assessment_id': 'abc-123-draft-uuid',
      };
      final listedItem = ProduceItem.fromJson(finalizeResponse);
      expect(listedItem.id, equals('new-inventory-uuid'));
      expect(listedItem.grade, equals(QualityGrade.gradeA));
      expect(listedItem.status, equals('available'));
      expect(listedItem.assessmentId, equals('abc-123-draft-uuid'));
    });
  });
}
