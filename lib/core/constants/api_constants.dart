/// API Constants for AgriConnect backend (Phase 1 Architecture).
/// Base URL: https://agriconnect-api-fiz5.onrender.com
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://agriconnect-api-fiz5.onrender.com';

  // 1. Authentication (/api/v1/auth)
  static const String requestOtp = '$baseUrl/api/v1/auth/request-otp';
  static const String sendOtp = '$baseUrl/api/v1/auth/send-otp';
  static const String verifyOtp = '$baseUrl/api/v1/auth/verify-otp';

  // 2. Farmer Produce (/api/v1/farmer/produce)
  static const String farmerProduce = '$baseUrl/api/v1/farmer/produce';

  // 3. Buyer Requirements (/api/v1/buyer/requirements)
  static const String buyerRequirements = '$baseUrl/api/v1/buyer/requirements';

  // 4. Smart Matching (/api/v1/matching or /api/matching)
  static const String matchingFind = '$baseUrl/api/v1/matching/find';

  // 5. Python FastAPI Voice AI Microservice
  static const String voiceAiBaseUrl = 'https://agriconnect-voice-ai.onrender.com';
  static const String voiceChat = '$voiceAiBaseUrl/api/v1/voice/chat';

  // 6. Market Insights (/api/v1/market-insights)
  static const String marketInsightsHistoricalDemand = '$baseUrl/api/v1/market-insights/historical-demand';

  // 7. Logistics & Routing (/api/v1/logistics)
  static const String optimizeRoute = '$baseUrl/api/v1/logistics/route/optimize';
  static const String tripLocation = '$baseUrl/api/v1/logistics/trip/location';

  // 8. Escrow & Payments (/api/v1/payments/escrow & /api/v1/payments/razorpay)
  static const String escrowAdvance = '$baseUrl/api/v1/payments/escrow/advance';
  static const String escrowRelease = '$baseUrl/api/v1/payments/escrow/release';
  static const String razorpayCreateOrder = '$baseUrl/api/v1/payments/razorpay/create-order';
  static const String razorpayVerify = '$baseUrl/api/v1/payments/razorpay/verify';

  // Helper: build a Uri with query parameters
  static Uri withQuery(String endpoint, Map<String, dynamic> params) {
    final uri = Uri.parse(endpoint);
    return uri.replace(
      queryParameters: params.map((k, v) => MapEntry(k, v.toString())),
    );
  }
}