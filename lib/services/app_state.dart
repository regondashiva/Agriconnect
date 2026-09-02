import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/produce_model.dart';
import '../models/requirement_model.dart';
import '../models/match_model.dart';
import '../models/order_model.dart';
import '../models/consumer_product_model.dart';
import '../models/notification_model.dart';
import 'mock_data_service.dart';

class AppState extends ChangeNotifier {
  // Authentication & Directory
  bool _isLoggedIn = false;
  UserRole _activeRole = UserRole.farmer;
  User _currentUser = MockDataService.demoFarmer;
  String _authPhoneNumber = '+91 98765 43210';
  
  // User Registry mapped by normalized 10-digit phone
  final Map<String, User> _userDirectory = {
    for (var u in MockDataService.initialUsers)
      _normalizeDigits(u.phoneNumber): u,
  };

  static String _normalizeDigits(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10) {
      return digits.substring(digits.length - 10);
    }
    return digits;
  }

  bool get isLoggedIn => _isLoggedIn;
  UserRole get activeRole => _activeRole;
  User get currentUser => _currentUser;
  String get authPhoneNumber => _authPhoneNumber;
  Map<String, User> get userDirectory => _userDirectory;

  // Domain Data Lists
  List<ProduceItem> _produceList = List.from(MockDataService.initialProduceList);
  List<BulkRequirement> _requirements = [MockDataService.demoTomatoRequirement];
  SupplyMatch _activeMatch = MockDataService.demoTomatoMatch;
  OrderModel _currentBulkOrder = MockDataService.getDemoBulkOrder(isDelivered: false);
  OrderModel _currentConsumerOrder = MockDataService.getConsumerDemoOrder(isDelivered: false);
  
  // Consumer Store & Cart
  final List<ConsumerProduct> _consumerProducts = List.from(MockDataService.consumerProducts);
  final List<CartItem> _cart = [
    CartItem(product: MockDataService.consumerProducts[0], quantityKg: 2.0), // 2 kg Tomato = ₹56
    CartItem(product: MockDataService.consumerProducts[1], quantityKg: 1.0), // 1 kg Potato = ₹24
  ];

  // Feedback Loop Demand Trend
  double _tomatoDemandTrendPercent = 18.0;

  // Getters
  List<ProduceItem> get produceList => _produceList;
  List<BulkRequirement> get requirements => _requirements;
  SupplyMatch get activeMatch => _activeMatch;
  OrderModel get currentBulkOrder => _currentBulkOrder;
  OrderModel get currentConsumerOrder => _currentConsumerOrder;
  List<ConsumerProduct> get consumerProducts => _consumerProducts;
  List<CartItem> get cart => _cart;
  double get tomatoDemandTrendPercent => _tomatoDemandTrendPercent;
  int get cartCount => _cart.length;

  double get cartSubtotal => _cart.fold(0, (sum, item) => sum + item.itemTotal);
  double get deliveryFee => _cart.isEmpty ? 0.0 : 20.0;
  double get cartTotal => _cart.isEmpty ? 0.0 : cartSubtotal + deliveryFee;

  // --- Auth & Role Actions ---

  /// Check if phone number belongs to an existing user
  User? findUserByPhone(String rawPhone) {
    final key = _normalizeDigits(rawPhone);
    return _userDirectory[key];
  }

  /// Store pending verified phone during OTP
  void setPendingAuthPhone(String rawPhone) {
    final digits = _normalizeDigits(rawPhone);
    _authPhoneNumber = digits.isNotEmpty ? '+91 $digits' : '+91 98765 43210';
    notifyListeners();
  }

  /// Log in an existing user directly and restore their saved role
  void loginExistingUser(User user) {
    _currentUser = user;
    _activeRole = user.role;
    _authPhoneNumber = user.phoneNumber;
    _isLoggedIn = true;
    notifyListeners();
  }

  /// Register a new user and add to directory
  void registerNewUser({
    required String name,
    required UserRole role,
    required String location,
    String? preferredLanguage,
    String? businessName,
    String? fpoCluster,
  }) {
    final id = '${role.name}_${DateTime.now().millisecondsSinceEpoch}';
    final newUser = User(
      id: id,
      name: name.isNotEmpty ? name : 'AgriConnect User',
      phoneNumber: _authPhoneNumber,
      role: role,
      location: location.isNotEmpty ? location : 'Telangana / Hyderabad',
      preferredLanguage: preferredLanguage ?? 'Telugu / English',
      businessName: businessName,
      fpoCluster: fpoCluster ?? (role == UserRole.farmer ? 'Ranga Reddy Organic Producers FPO' : null),
    );

    final key = _normalizeDigits(_authPhoneNumber);
    _userDirectory[key] = newUser;
    _currentUser = newUser;
    _activeRole = role;
    _isLoggedIn = true;
    notifyListeners();
  }

  void loginWithPhone(String phone) {
    setPendingAuthPhone(phone);
    final user = findUserByPhone(phone);
    if (user != null) {
      loginExistingUser(user);
    } else {
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  void selectRole(UserRole role) {
    _activeRole = role;
    switch (role) {
      case UserRole.farmer:
        _currentUser = MockDataService.demoFarmer;
        break;
      case UserRole.fpo:
        _currentUser = MockDataService.demoFpo;
        break;
      case UserRole.bulkBuyer:
        _currentUser = MockDataService.demoBuyer;
        break;
      case UserRole.consumer:
        _currentUser = MockDataService.demoConsumer;
        break;
    }
    notifyListeners();
  }

  void updateFarmerProfile({
    required String name,
    required String location,
    required String language,
  }) {
    registerNewUser(
      name: name,
      role: UserRole.farmer,
      location: location,
      preferredLanguage: language,
    );
  }

  // --- Farmer Actions ---

  void addProduceItem(ProduceItem newItem) {
    _produceList.insert(0, newItem);
    notifyListeners();
  }

  // --- Bulk Buyer Actions ---

  void createBulkRequirement({
    required String cropName,
    required double quantityKg,
    required QualityGrade grade,
    required String location,
    required double priceMin,
    required double priceMax,
  }) {
    final newReq = BulkRequirement(
      id: 'REQ-${DateTime.now().millisecondsSinceEpoch}',
      buyerId: _currentUser.id,
      buyerName: _currentUser.name,
      cropName: cropName,
      requiredQuantityKg: quantityKg,
      qualityGrade: grade,
      deliveryLocation: location,
      requiredDate: DateTime.now().add(const Duration(days: 1)),
      priceRangeMin: priceMin,
      priceRangeMax: priceMax,
      createdAt: DateTime.now(),
    );
    _requirements.insert(0, newReq);
    notifyListeners();
  }

  // --- Coordination Order Progression ---

  void markOrderAsDelivered() {
    _currentBulkOrder = MockDataService.getDemoBulkOrder(isDelivered: true);
    notifyListeners();
  }

  void resetOrderProgress() {
    _currentBulkOrder = MockDataService.getDemoBulkOrder(isDelivered: false);
    _currentConsumerOrder = MockDataService.getConsumerDemoOrder(isDelivered: false);
    notifyListeners();
  }

  // --- Consumer Cart Actions ---

  void addToCart(ConsumerProduct product, double qty) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _cart[index].quantityKg += qty;
    } else {
      _cart.add(CartItem(product: product, quantityKg: qty));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    final index = _cart.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_cart[index].quantityKg > 1.0) {
        _cart[index].quantityKg -= 1.0;
      } else {
        _cart.removeAt(index);
      }
      notifyListeners();
    }
  }

  void updateCartQuantity(String productId, double newQty) {
    if (newQty <= 0) {
      _cart.removeWhere((item) => item.product.id == productId);
    } else {
      final item = _cart.firstWhere((i) => i.product.id == productId);
      item.quantityKg = newQty;
    }
    notifyListeners();
  }

  void placeConsumerOrder() {
    // Increment AI demand feedback loop
    _tomatoDemandTrendPercent += 1.5;
    _cart.clear();
    _currentConsumerOrder = MockDataService.getConsumerDemoOrder(isDelivered: false);
    notifyListeners();
  }

  List<NotificationItem> getCurrentRoleNotifications() {
    return MockDataService.getNotifications(_activeRole);
  }
}
