/// API Constants for AgriConnect backend (Sprint Update Contract).
/// Base URL: https://agriconnect-api-fiz5.onrender.com
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://agriconnect-api-fiz5.onrender.com';

  // 1. User Profile & KYC (/api/v1/users)
  static const String userProfile = '$baseUrl/api/v1/users/profile';
  static const String requestOtp = '$baseUrl/api/v1/auth/request-otp';
  static const String sendOtp = '$baseUrl/api/v1/auth/send-otp';
  static const String verifyOtp = '$baseUrl/api/v1/auth/verify-otp';

  // 2. Farmer Produce & AI Quality Assessment (/api/v1/farmer/produce)
  static const String farmerProduce = '$baseUrl/api/v1/farmer/produce';
  static const String assessProduce = '$baseUrl/api/v1/farmer/produce/assess';

  // 3. Buyer Requirements (/api/v1/buyer/requirements)
  static const String buyerRequirements = '$baseUrl/api/v1/buyer/requirements';

  // 4. Smart Matching (/api/v1/matching/find)
  static const String matchingFind = '$baseUrl/api/v1/matching/find';

  // 5. Python FastAPI Voice AI Microservice
  static const String voiceAiBaseUrl = 'https://agriconnect-voice-ai.onrender.com';
  static const String voiceChat = '$voiceAiBaseUrl/api/v1/voice/chat';

  // 6. Market Insights (/api/v1/market-insights)
  static const String marketInsightsHistoricalDemand = '$baseUrl/api/v1/market-insights/historical-demand';

  // 7. Logistics & Routing (/api/v1/logistics)
  static const String optimizeRoute = '$baseUrl/api/v1/logistics/route/optimize';
  static const String tripLocation = '$baseUrl/api/v1/logistics/trip/location';

  // 8. Escrow & Payments (/api/v1/payments)
  static const String escrowAdvance = '$baseUrl/api/v1/payments/escrow/advance';
  static const String escrowRelease = '$baseUrl/api/v1/payments/escrow/release';
  static const String razorpayCreateOrder = '$baseUrl/api/v1/payments/razorpay/create-order';
  static const String razorpayVerify = '$baseUrl/api/v1/payments/razorpay/verify';

  // 9. Consumer E-Commerce (/api/v1/consumer)
  static const String consumerProducts = '$baseUrl/api/v1/consumer/products';
  static const String consumerCartAdd = '$baseUrl/api/v1/consumer/cart/add';
  static const String consumerCart = '$baseUrl/api/v1/consumer/cart';
  static const String consumerOrdersCreate = '$baseUrl/api/v1/consumer/orders/create';
  static const String consumerOrders = '$baseUrl/api/v1/consumer/orders';

  // 10. Delivery Logistics (/api/v1/delivery)
  static const String deliveryDutyToggle = '$baseUrl/api/v1/delivery/duty/toggle';
  static const String deliveryTripsAvailable = '$baseUrl/api/v1/delivery/trips/available';
  static String deliveryTripAccept(String tripId) => '$baseUrl/api/v1/delivery/trips/$tripId/accept';
  static String deliveryTripStep(String tripId) => '$baseUrl/api/v1/delivery/trips/$tripId/step';
  static String deliveryTripVerifyChecklist(String tripId) => '$baseUrl/api/v1/delivery/trips/$tripId/verify-checklist';
  static String deliveryTripVerifyOtp(String tripId) => '$baseUrl/api/v1/delivery/trips/$tripId/verify-otp';
  static const String deliveryWallet = '$baseUrl/api/v1/delivery/wallet';

  // Helper: build a Uri with query parameters
  static Uri withQuery(String endpoint, Map<String, dynamic> params) {
    final uri = Uri.parse(endpoint);
    return uri.replace(
      queryParameters: params.map((k, v) => MapEntry(k, v.toString())),
    );
  }
}