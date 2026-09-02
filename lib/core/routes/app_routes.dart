import 'package:flutter/material.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/landing/landing_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/role_selection/role_selection_screen.dart';
import '../../features/farmer/onboarding/farmer_onboarding_screen.dart';
import '../../features/farmer/onboarding/voice_registration_screen.dart';
import '../../features/farmer/onboarding/manual_registration_screen.dart';
import '../../features/farmer/home/farmer_home_screen.dart';
import '../../features/farmer/produce/add_produce_screen.dart';
import '../../features/farmer/produce/my_produce_screen.dart';
import '../../features/farmer/produce/produce_details_screen.dart';
import '../../features/farmer/matches/farmer_matches_screen.dart';
import '../../features/farmer/orders/farmer_orders_screen.dart';
import '../../features/bulk_buyer/registration/buyer_registration_screen.dart';
import '../../features/bulk_buyer/home/buyer_home_screen.dart';
import '../../features/bulk_buyer/requirements/create_requirement_screen.dart';
import '../../features/bulk_buyer/matches/matched_supply_screen.dart';
import '../../features/bulk_buyer/orders/buyer_orders_screen.dart';
import '../../features/coordination/smart_aggregation_screen.dart';
import '../../features/coordination/quality_trust_screen.dart';
import '../../features/coordination/smart_logistics_screen.dart';
import '../../features/coordination/order_tracking_screen.dart';
import '../../features/coordination/settlement_screen.dart';
import '../../features/fpo/registration/fpo_registration_screen.dart';
import '../../features/fpo/home/fpo_home_screen.dart';
import '../../features/fpo/farmers/manage_farmers_screen.dart';
import '../../features/fpo/supply/aggregate_supply_screen.dart';
import '../../features/consumer/registration/consumer_registration_screen.dart';
import '../../features/consumer/home/consumer_home_screen.dart';
import '../../features/consumer/products/consumer_product_details_screen.dart';
import '../../features/consumer/cart/consumer_cart_screen.dart';
import '../../features/consumer/checkout/consumer_checkout_screen.dart';
import '../../features/consumer/orders/consumer_tracking_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../models/consumer_product_model.dart';
import '../../services/app_state.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings, AppState appState) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => SplashScreen(appState: appState));

      case '/landing':
        return MaterialPageRoute(builder: (_) => LandingScreen(appState: appState));

      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen(appState: appState));

      case '/otp':
        final phone = (settings.arguments as String?) ?? appState.authPhoneNumber;
        return MaterialPageRoute(builder: (_) => OtpScreen(appState: appState, phoneNumber: phone));

      case '/role-selection':
        return MaterialPageRoute(builder: (_) => RoleSelectionScreen(appState: appState));

      // Farmer Flow
      case '/farmer/onboarding':
        return MaterialPageRoute(builder: (_) => const FarmerOnboardingScreen());

      case '/farmer/voice-registration':
        return MaterialPageRoute(builder: (_) => VoiceRegistrationScreen(appState: appState));

      case '/farmer/manual-registration':
        return MaterialPageRoute(builder: (_) => ManualRegistrationScreen(appState: appState));

      case '/farmer/home':
        return MaterialPageRoute(builder: (_) => FarmerHomeScreen(appState: appState));

      case '/farmer/add-produce':
        return MaterialPageRoute(builder: (_) => AddProduceScreen(appState: appState));

      case '/farmer/produce':
        return MaterialPageRoute(builder: (_) => MyProduceScreen(appState: appState));

      case '/farmer/produce/detail':
        return MaterialPageRoute(builder: (_) => ProduceDetailsScreen(appState: appState));

      case '/farmer/matches':
        return MaterialPageRoute(builder: (_) => FarmerMatchesScreen(appState: appState));

      case '/farmer/matches/detail':
        return MaterialPageRoute(builder: (_) => SmartAggregationScreen(appState: appState));

      case '/farmer/orders':
        return MaterialPageRoute(builder: (_) => FarmerOrdersScreen(appState: appState));

      // Coordination & Pipeline
      case '/coordination/aggregation':
        return MaterialPageRoute(builder: (_) => SmartAggregationScreen(appState: appState));

      case '/coordination/quality':
        return MaterialPageRoute(builder: (_) => const QualityTrustScreen());

      case '/coordination/logistics':
        return MaterialPageRoute(builder: (_) => SmartLogisticsScreen(appState: appState));

      case '/coordination/tracking':
        return MaterialPageRoute(builder: (_) => OrderTrackingScreen(appState: appState));

      case '/coordination/settlement':
        return MaterialPageRoute(builder: (_) => SettlementScreen(appState: appState));

      // Bulk Buyer Flow
      case '/buyer/registration':
        return MaterialPageRoute(builder: (_) => BuyerRegistrationScreen(appState: appState));

      case '/buyer/home':
        return MaterialPageRoute(builder: (_) => BulkBuyerHomeScreen(appState: appState));

      case '/buyer/create-requirement':
        return MaterialPageRoute(builder: (_) => CreateRequirementScreen(appState: appState));

      case '/buyer/matches':
        return MaterialPageRoute(builder: (_) => MatchedSupplyScreen(appState: appState));

      case '/buyer/orders':
        return MaterialPageRoute(builder: (_) => BuyerOrdersScreen(appState: appState));

      // FPO Flow
      case '/fpo/registration':
        return MaterialPageRoute(builder: (_) => FpoRegistrationScreen(appState: appState));

      case '/fpo/home':
        return MaterialPageRoute(builder: (_) => FpoHomeScreen(appState: appState));

      case '/fpo/farmers':
        return MaterialPageRoute(builder: (_) => ManageFarmersScreen(appState: appState));

      case '/fpo/supply':
        return MaterialPageRoute(builder: (_) => AggregateSupplyScreen(appState: appState));

      // Consumer Flow
      case '/consumer/registration':
        return MaterialPageRoute(builder: (_) => ConsumerRegistrationScreen(appState: appState));

      case '/consumer/home':
        return MaterialPageRoute(builder: (_) => ConsumerHomeScreen(appState: appState));

      case '/consumer/product':
        final product = settings.arguments as ConsumerProduct? ??
            appState.consumerProducts.first;
        return MaterialPageRoute(
          builder: (_) => ConsumerProductDetailsScreen(appState: appState, product: product),
        );

      case '/consumer/cart':
        return MaterialPageRoute(builder: (_) => ConsumerCartScreen(appState: appState));

      case '/consumer/checkout':
        return MaterialPageRoute(builder: (_) => ConsumerCheckoutScreen(appState: appState));

      case '/consumer/tracking':
        return MaterialPageRoute(builder: (_) => ConsumerTrackingScreen(appState: appState));

      // Notifications
      case '/notifications':
        return MaterialPageRoute(builder: (_) => NotificationsScreen(appState: appState));

      default:
        return MaterialPageRoute(builder: (_) => LandingScreen(appState: appState));
    }
  }
}
