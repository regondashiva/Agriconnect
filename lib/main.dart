import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_strings.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/app_state.dart';
import 'services/user_database_service.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await UserDatabaseService.instance.init();
  await ApiService.instance.init();

  runApp(const AgriConnectApp());
}

class AgriConnectApp extends StatefulWidget {
  const AgriConnectApp({super.key});

  @override
  State<AgriConnectApp> createState() => _AgriConnectAppState();
}

class _AgriConnectAppState extends State<AgriConnectApp> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.addListener(() {
      setState(() {});
    });

    // Global 401 Token Expiration Interceptor (Contract requirement)
    ApiService.instance.onUnauthorized = () {
      _appState.logout();
      rootNavigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (r) => false);
      final ctx = rootNavigatorKey.currentContext;
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please sign in again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    };
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) => AppRoutes.generateRoute(settings, _appState),
    );
  }
}
