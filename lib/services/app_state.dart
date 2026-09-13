import 'package:flutter/material.dart';
import 'package:agriconnect/models/user_model.dart';
import 'package:agriconnect/models/produce_model.dart';
import 'package:agriconnect/models/requirement_model.dart';
import 'package:agriconnect/models/match_model.dart';
import 'package:agriconnect/models/consumer_product_model.dart';
import 'package:agriconnect/models/notification_model.dart';
import 'package:agriconnect/models/order_model.dart';
import 'package:agriconnect/repositories/produce_repository.dart';
import 'package:agriconnect/repositories/requirement_repository.dart';
import 'package:agriconnect/repositories/matching_repository.dart';
import 'package:agriconnect/services/api_service.dart';
import 'package:agriconnect/services/socket_service.dart';
import 'package:agriconnect/services/user_database_service.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _initSocket();
    _loadStoredUsers();
    restoreSession();
  }

  void _loadStoredUsers() {
    final stored = UserDatabaseService.instance.getAllUsers();
    _userDirectory.addAll(stored);
  }

  void restoreSession() {
    final lastPhone = UserDatabaseService.instance.getLastAuthPhone();
    if (lastPhone != null && ApiService.instance.isAuthenticated) {
      final user = findUserByPhone(lastPhone);
      if (user != null && user.name.trim().isNotEmpty) {
        loginUser(user);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Loading & Error States
  // ---------------------------------------------------------------------------
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Auth State
  // ---------------------------------------------------------------------------
  bool _isLoggedIn = false;
  UserRole _activeRole = UserRole.farmer;
  User _currentUser = const User(
    id: '',
    name: '',
    phoneNumber: '',
    role: UserRole.farmer,
    location: '',
  );
  String _authPhoneNumber = '';
  String _pendingSessionId = '';

  static final Map<String, User> _seedUsers = {
    '9876543210': const User(
      id: 'usr_farmer_001',
      name: 'Ramesh Reddy',
      phoneNumber: '+919876543210',
      role: UserRole.farmer,
      location: 'Chevella Village, Ranga Reddy Dist, Telangana',
      preferredLanguage: 'Telugu / English',
      fpoCluster: 'Ranga Reddy Organic Producers FPO',
      isNewUser: false,
    ),
    '9876543211': const User(
      id: 'usr_fpo_001',
      name: 'Suresh Rao',
      phoneNumber: '+919876543211',
      role: UserRole.fpo,
      businessName: 'Ranga Reddy Farmers Producer Co-op',
      location: 'Shabad Center, Hyderabad Rural, Telangana',
      preferredLanguage: 'Telugu / English',
      fpoCluster: 'Ranga Reddy Organic Producers FPO',
      isNewUser: false,
    ),
    '9876543212': const User(
      id: 'usr_buyer_001',
      name: 'Vikram Mehta',
      phoneNumber: '+919876543212',
      role: UserRole.bulkBuyer,
      businessName: 'FreshBasket Wholesale Mandi Pvt Ltd',
      location: 'Kothapet Wholesale Mandi, Hyderabad, Telangana',
      preferredLanguage: 'English / Hindi',
      isNewUser: false,
    ),
    '9876543213': const User(
      id: 'usr_consumer_001',
      name: 'Ananya Sharma',
      phoneNumber: '+919876543213',
      role: UserRole.consumer,
      location: 'Flat 402, Green Meadows, Madhapur, Hyderabad - 500081',
      preferredLanguage: 'English',
      isNewUser: false,
    ),
    '9876543214': const User(
      id: 'usr_farmer_002',
      name: 'Suresh Patil',
      phoneNumber: '+919876543214',
      role: UserRole.farmer,
      location: 'Shabad North Cluster, Ranga Reddy Dist, Telangana',
      preferredLanguage: 'Telugu / English',
      fpoCluster: 'Ranga Reddy Organic Producers FPO',
      isNewUser: false,
    ),
    '9876543215': const User(
      id: 'usr_farmer_003',
      name: 'Ravi Patel',
      phoneNumber: '+919876543215',
      role: UserRole.farmer,
      location: 'Moinabad Cluster, Ranga Reddy Dist, Telangana',
      preferredLanguage: 'Telugu / Hindi',
      fpoCluster: 'Ranga Reddy Organic Producers FPO',
      isNewUser: false,
    ),
    '9876500112': const User(
      id: 'usr_driver_001',
      name: 'Mahesh Goud',
      phoneNumber: '+919876500112',
      role: UserRole.deliveryPartner,
      location: 'Hub 4, Shabad Center, Telangana',
      preferredLanguage: 'Telugu / Hindi / English',
      fpoCluster: 'Ranga Reddy Organic Producers FPO',
      registrationId: 'TS07-20230048192',
      vehicleType: 'EV Cargo Scooter (300kg)',
      vehicleNumber: 'TS 07 EA 4821',
      bankName: 'State Bank of India (Jan Dhan)',
      upiId: 'mahesh.goud@sbi',
      isNewUser: false,
    ),
  };

  late final Map<String, User> _userDirectory = Map.from(_seedUsers);

  User getSeedUserForRole(UserRole role) {
    switch (role) {
      case UserRole.farmer:
        return _seedUsers['9876543210']!;
      case UserRole.fpo:
        return _seedUsers['9876543211']!;
      case UserRole.bulkBuyer:
        return _seedUsers['9876543212']!;
      case UserRole.consumer:
        return _seedUsers['9876543213']!;
      case UserRole.deliveryPartner:
        return _seedUsers['9876500112']!;
    }
  }

  bool get isLoggedIn => _isLoggedIn;
  UserRole get activeRole => _activeRole;
  User get currentUser => _currentUser;
  String get authPhoneNumber => _authPhoneNumber;
  String get pendingSessionId => _pendingSessionId;

  String _normalizeDigits(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10 ? digits.substring(digits.length - 10) : digits;
  }

  User? findUserByPhone(String phone) {
    final key = _normalizeDigits(phone);
    if (key.isEmpty) return null;
    return _userDirectory[key];
  }

  void setPendingAuthPhone(String rawPhone) {
    final digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    _authPhoneNumber = digits.length >= 10
        ? '+91${digits.substring(digits.length - 10)}'
        : (digits.isNotEmpty ? '+91$digits' : '');
    notifyListeners();
  }

  void setPendingSessionId(String sessionId) {
    _pendingSessionId = sessionId;
  }

  void loginUser(User user) {
    _currentUser = user;
    _activeRole = user.role;
    _authPhoneNumber = user.phoneNumber;
    _isLoggedIn = true;

    if (user.name.trim().isNotEmpty) {
      final key = _normalizeDigits(user.phoneNumber);
      if (key.isNotEmpty) {
        _userDirectory[key] = user;
      }
    }

    // Join buyer socket room if buyer
    if (user.role == UserRole.bulkBuyer && user.id.isNotEmpty) {
      SocketService.instance.joinBuyerRoom(user.id);
    }

    notifyListeners();
  }

  void loginExistingUser(User user) => loginUser(user);

  void registerNewUser({
    required String name,
    required UserRole role,
    required String location,
    String? phoneNumber,
    String? businessName,
    String? fpoCluster,
    String? preferredLanguage,
    String? registrationId,
    List<String>? primaryCrops,
    double? landSizeAcres,
    String? bankName,
    String? upiId,
    String? pincode,
    String? businessType,
    int? memberCount,
    double? capacityTons,
    double? monthlyVolumeTons,
    String? vehicleType,
    String? vehicleNumber,
    String? village,
    String? district,
    String? state,
    double? latitude,
    double? longitude,
    List<String>? operatingDistricts,
    double? coldStorageCapacityMt,
  }) {
    final resolvedPhone = (phoneNumber != null && phoneNumber.isNotEmpty)
        ? phoneNumber
        : _authPhoneNumber;
    final existingId = _currentUser.id.isNotEmpty
        ? _currentUser.id
        : (_userDirectory[_normalizeDigits(resolvedPhone)]?.id ?? '');
    final userId = existingId.isNotEmpty
        ? existingId
        : 'usr_${User.roleToString(role)}_${DateTime.now().millisecondsSinceEpoch}';

    final user = User(
      id: userId,
      name: name,
      phoneNumber: resolvedPhone,
      role: role,
      location: location,
      businessName: businessName,
      fpoCluster: fpoCluster,
      preferredLanguage: preferredLanguage,
      registrationId: registrationId,
      primaryCrops: primaryCrops,
      landSizeAcres: landSizeAcres,
      bankName: bankName,
      upiId: upiId,
      pincode: pincode,
      businessType: businessType,
      memberCount: memberCount,
      capacityTons: capacityTons,
      monthlyVolumeTons: monthlyVolumeTons,
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      village: village,
      district: district,
      state: state,
      latitude: latitude,
      longitude: longitude,
      operatingDistricts: operatingDistricts,
      coldStorageCapacityMt: coldStorageCapacityMt,
      isNewUser: false,
      isVerified: true,
    );
    final key = _normalizeDigits(_authPhoneNumber);
    if (key.isNotEmpty) {
      _userDirectory[key] = user;
    }
    // Save to persistent on-device database and sync to backend
    UserDatabaseService.instance.saveUser(user);
    loginUser(user);
  }

  void updateFarmerProfile({
    required String name,
    required String location,
    required String language,
    List<String>? crops,
    double? landSize,
    String? bankName,
    String? upiId,
    String? village,
    String? district,
    String? state,
    String? pincode,
    double? latitude,
    double? longitude,
  }) {
    registerNewUser(
      name: name,
      role: UserRole.farmer,
      location: location,
      preferredLanguage: language,
      primaryCrops: crops,
      landSizeAcres: landSize,
      bankName: bankName,
      upiId: upiId,
      village: village,
      district: district,
      state: state,
      pincode: pincode,
      latitude: latitude,
      longitude: longitude,
    );
  }

  void logout() {
    _isLoggedIn = false;
    _authPhoneNumber = '';
    _pendingSessionId = '';
    _currentUser = const User(
      id: '',
      name: '',
      phoneNumber: '',
      role: UserRole.farmer,
      location: '',
      isNewUser: true,
      isVerified: false,
    );
    _produceList = [];
    _requirements = [];
    _matches = [];
    _cart.clear();
    ApiService.instance.clearAuthToken();
    notifyListeners();
  }

  void selectRole(UserRole role) {
    _activeRole = role;
    if (_isLoggedIn && _currentUser.id.isNotEmpty) {
      _currentUser = User(
        id: _currentUser.id,
        name: _currentUser.name,
        phoneNumber: _currentUser.phoneNumber,
        role: role,
        location: _currentUser.location,
        preferredLanguage: _currentUser.preferredLanguage,
        fpoCluster: _currentUser.fpoCluster,
        businessName: _currentUser.businessName,
        registrationId: _currentUser.registrationId,
        primaryCrops: _currentUser.primaryCrops,
        landSizeAcres: _currentUser.landSizeAcres,
        bankName: _currentUser.bankName,
        upiId: _currentUser.upiId,
        pincode: _currentUser.pincode,
        businessType: _currentUser.businessType,
        memberCount: _currentUser.memberCount,
        capacityTons: _currentUser.capacityTons,
        monthlyVolumeTons: _currentUser.monthlyVolumeTons,
        vehicleType: _currentUser.vehicleType,
        vehicleNumber: _currentUser.vehicleNumber,
        isNewUser: _currentUser.isNewUser,
        isVerified: _currentUser.isVerified,
      );
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Farmer: Produce Inventory
  // ---------------------------------------------------------------------------
  List<ProduceItem> _produceList = [];
  List<ProduceItem> get produceList => _produceList;

  ProduceItem? _selectedProduceItem;
  ProduceItem? get selectedProduceItem =>
      _selectedProduceItem ?? (_produceList.isNotEmpty ? _produceList.first : null);

  void setSelectedProduceItem(ProduceItem item) {
    _selectedProduceItem = item;
    notifyListeners();
  }

  Future<void> fetchProduceList() async {
    _setLoading(true);
    _setError(null);
    try {
      final items = await ProduceRepository.instance.getMyProduce(farmerId: _currentUser.id);
      _produceList = items;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addProduceItem(ProduceItem item) async {
    _setLoading(true);
    _setError(null);
    try {
      final created = await ProduceRepository.instance.addProduce(item, farmerId: _currentUser.id);
      _produceList.removeWhere((p) => p.id == created.id);
      _produceList.insert(0, created);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Bulk Buyer: Requirements
  // ---------------------------------------------------------------------------
  List<BulkRequirement> _requirements = [];
  List<BulkRequirement> get requirements => _requirements;

  Future<void> fetchRequirements() async {
    _setLoading(true);
    _setError(null);
    try {
      _requirements = await RequirementRepository.instance.getMyRequirements(buyerId: _currentUser.id);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createBulkRequirement({
    required String cropName,
    required double quantityKg,
    required QualityGrade grade,
    required String location,
    required double priceMin,
    required double priceMax,
    DateTime? requiredDate,
    double deliveryLat = 17.4399,
    double deliveryLng = 78.4983,
  }) async {
    final req = BulkRequirement(
      id: '',
      buyerId: _currentUser.id,
      buyerName: _currentUser.name.isNotEmpty ? _currentUser.name : 'Bulk Buyer',
      cropName: cropName,
      requiredQuantityKg: quantityKg,
      qualityGrade: grade,
      deliveryLocation: location,
      deliveryLatitude: deliveryLat,
      deliveryLongitude: deliveryLng,
      requiredDate: requiredDate ?? DateTime.now().add(const Duration(days: 2)),
      priceRangeMin: priceMin,
      priceRangeMax: priceMax,
      createdAt: DateTime.now(),
    );
    _setLoading(true);
    _setError(null);
    try {
      final created = await RequirementRepository.instance.postRequirement(req, buyerId: _currentUser.id);
      _requirements.removeWhere((r) => r.id == created.id);
      _requirements.insert(0, created);
      await fetchMatches(
        crop: cropName,
        quantityKg: quantityKg,
        lat: deliveryLat,
        lng: deliveryLng,
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Bulk Buyer: AI Semantic Matching
  // ---------------------------------------------------------------------------
  List<SupplyMatch> _matches = [];
  List<SupplyMatch> get matches => _matches;

  SupplyMatch? get activeMatch => _matches.isNotEmpty ? _matches.first : null;

  Future<void> fetchMatches({
    required String crop,
    required double quantityKg,
    required double lat,
    required double lng,
    double maxDistanceKm = 50,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      _matches = await MatchingRepository.instance.findMatches(
        crop: crop,
        quantityKg: quantityKg,
        lat: lat,
        lng: lng,
        maxDistanceKm: maxDistanceKm,
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Orders, Logistics & Escrow Progress
  // ---------------------------------------------------------------------------
  bool _isEscrowAdvancePaid = false;
  bool _isEscrowSettled = false;
  final String _deliveryOtp = '459012';
  String? _advanceTransactionId;

  bool get isEscrowAdvancePaid => _isEscrowAdvancePaid;
  bool get isEscrowSettled => _isEscrowSettled;
  String get deliveryOtp => _deliveryOtp;
  String? get advanceTransactionId => _advanceTransactionId;

  OrderModel _currentBulkOrder = _buildDefaultBulkOrder();
  OrderModel _currentConsumerOrder = _buildDefaultConsumerOrder();
  final List<OrderModel> _consumerOrders = _buildInitialConsumerOrders();

  OrderModel get currentBulkOrder => _currentBulkOrder;
  OrderModel get currentConsumerOrder => _currentConsumerOrder;
  List<OrderModel> get consumerOrders => List.unmodifiable(_consumerOrders);

  /// Lock 20% Advance payment into smart escrow contract upon placing order
  Future<bool> payEscrowAdvance({
    required String orderId,
    required double totalAmount,
    String? buyerId,
  }) async {
    _setLoading(true);
    _setError(null);
    final advanceAmount = totalAmount * 0.20;

    try {
      final res = await ApiService.instance.payEscrowAdvance(
        orderId: orderId,
        buyerId: buyerId ?? (_currentUser.id.isNotEmpty ? _currentUser.id : 'usr_buyer_001'),
        amount: advanceAmount,
      );

      _isEscrowAdvancePaid = true;
      _advanceTransactionId = (res is Map && res['transaction_id'] != null)
          ? res['transaction_id'].toString()
          : 'ESCROW-ADV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      _currentBulkOrder = _buildDefaultBulkOrder(
        isDelivered: false,
        orderId: orderId,
        cropName: activeMatch?.cropName,
        totalAmount: totalAmount,
        totalQuantityKg: activeMatch?.matchedQuantityKg ?? 500.0,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to lock escrow advance: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verify 6-digit delivery OTP and release remaining 80% escrow directly to farmers
  Future<bool> verifyDeliveryAndReleaseEscrow({
    required String orderId,
    required String otp,
  }) async {
    _setLoading(true);
    _setError(null);

    // Strict 6-digit OTP verification: match current OTP or default 459012
    if (otp.trim() != _deliveryOtp.trim() && otp.trim() != '459012') {
      _setError('Invalid Delivery OTP. Please enter valid 6-digit verification code.');
      _setLoading(false);
      return false;
    }

    try {
      final res = await ApiService.instance.releaseEscrow(
        orderId: orderId,
        otp: otp.trim(),
      );
      debugPrint('[AppState] Escrow released result: $res');

      _isEscrowSettled = true;
      markOrderAsDelivered();
      return true;
    } catch (e) {
      _setError('Escrow release failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void markOrderAsDelivered() {
    _isEscrowSettled = true;
    _currentBulkOrder = _buildDefaultBulkOrder(
      isDelivered: true,
      orderId: _currentBulkOrder.orderId,
      cropName: _currentBulkOrder.cropName,
      totalAmount: _currentBulkOrder.totalAmount,
      totalQuantityKg: _currentBulkOrder.totalQuantityKg,
    );
    notifyListeners();
  }

  void resetOrderProgress() {
    _isEscrowAdvancePaid = false;
    _isEscrowSettled = false;
    _advanceTransactionId = null;
    _currentBulkOrder = _buildDefaultBulkOrder(isDelivered: false);
    _currentConsumerOrder = _buildDefaultConsumerOrder(isDelivered: false);
    notifyListeners();
  }

  static OrderModel _buildDefaultBulkOrder({
    bool isDelivered = false,
    String? orderId,
    String? cropName,
    double? totalAmount,
    double? totalQuantityKg,
  }) {
    final finalAmount = totalAmount ?? 10000.0;
    final finalKg = totalQuantityKg ?? 500.0;
    final crop = cropName ?? 'Tomato (Hybrid Roma)';
    final oid = orderId ?? 'AGR-1024';

    return OrderModel(
      orderId: oid,
      type: OrderType.bulkCoordination,
      cropName: crop,
      totalQuantityKg: finalKg,
      totalAmount: finalAmount,
      buyerName: 'FreshBasket Wholesale Mandi',
      deliveryAddress: 'Kothapet Wholesale Mandi, Hyderabad, Telangana',
      currentStatusText: isDelivered ? 'Delivered & 100% Settled' : 'In Transit (20% Escrow Locked)',
      timeline: [
        const TimelineStep(
          stage: OrderStage.orderCreated,
          title: 'Order Created',
          subtitle: 'Bulk requirement published and verified',
          isCompleted: true,
        ),
        const TimelineStep(
          stage: OrderStage.supplyMatched,
          title: 'Supply Matched',
          subtitle: 'AI matched with nearby farmer cluster',
          isCompleted: true,
        ),
        const TimelineStep(
          stage: OrderStage.supplyAggregated,
          title: 'Aggregation Completed',
          subtitle: 'FPO hub aggregated produce lot',
          isCompleted: true,
        ),
        TimelineStep(
          stage: OrderStage.inTransit,
          title: 'Escrow Locked & In Transit',
          subtitle: '20% advance locked, mini-truck en route to Mandi',
          isCompleted: true,
          isCurrent: !isDelivered,
        ),
        TimelineStep(
          stage: OrderStage.delivered,
          title: 'Delivered & 80% Released',
          subtitle: isDelivered ? 'OTP verified: ₹${(finalAmount * 0.8).toInt()} released' : 'Awaiting 6-digit OTP delivery verification',
          isCompleted: isDelivered,
          isCurrent: isDelivered,
        ),
      ],
      settlements: [
        FarmerSettlement(
          farmerName: 'Primary Cluster Farm',
          quantityKg: (finalKg * 0.4).roundToDouble(),
          amount: (finalAmount * 0.44).roundToDouble(),
          status: isDelivered ? 'Completed' : 'Locked in Escrow',
        ),
        FarmerSettlement(
          farmerName: 'Verified Cluster Partner 1',
          quantityKg: (finalKg * 0.3).roundToDouble(),
          amount: (finalAmount * 0.28).roundToDouble(),
          status: isDelivered ? 'Completed' : 'Locked in Escrow',
        ),
        FarmerSettlement(
          farmerName: 'Verified Cluster Partner 2',
          quantityKg: (finalKg * 0.3).roundToDouble(),
          amount: (finalAmount * 0.28).roundToDouble(),
          status: isDelivered ? 'Completed' : 'Locked in Escrow',
        ),
      ],
    );
  }

  static OrderModel _buildDefaultConsumerOrder({bool isDelivered = false}) {
    return OrderModel(
      orderId: 'AGR-2048',
      type: OrderType.householdConsumer,
      cropName: 'Fresh Produce Basket',
      totalQuantityKg: 5.0,
      totalAmount: 320.0,
      buyerName: 'Priya Sharma',
      deliveryAddress: 'Flat 402, Green Acres, Pune',
      currentStatusText: isDelivered ? 'Delivered' : 'Out for Delivery',
      orderDate: DateTime.now().subtract(const Duration(minutes: 42)),
      timeline: [
        const TimelineStep(
          stage: OrderStage.orderCreated,
          title: 'Order Placed',
          subtitle: 'Payment verified',
          isCompleted: true,
        ),
        TimelineStep(
          stage: OrderStage.inTransit,
          title: 'Out for Delivery',
          subtitle: 'Driver on the way',
          isCompleted: true,
          isCurrent: !isDelivered,
        ),
        TimelineStep(
          stage: OrderStage.delivered,
          title: 'Delivered',
          subtitle: isDelivered ? 'Handed to customer' : 'Expected in 20 mins',
          isCompleted: isDelivered,
          isCurrent: isDelivered,
        ),
      ],
      itemsSummary: const [
        'Fresh Farm Tomatoes (2 kg)',
        'Organic Jyoti Potatoes (2 kg)',
        'Nashik Red Onions (1 kg)',
      ],
    );
  }

  static List<OrderModel> _buildInitialConsumerOrders() {
    return [
      _buildDefaultConsumerOrder(isDelivered: false),
      OrderModel(
        orderId: 'AGR-1892',
        type: OrderType.householdConsumer,
        cropName: 'Organic Kitchen Vegetables',
        totalQuantityKg: 4.5,
        totalAmount: 245.0,
        buyerName: 'Priya Sharma',
        deliveryAddress: 'Flat 402, Green Acres, Pune',
        currentStatusText: 'Delivered',
        orderDate: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        paymentMethod: 'UPI (PhonePe)',
        itemsSummary: const [
          'Organic Jyoti Potatoes (2.5 kg)',
          'Fresh Farm Tomatoes (2 kg)',
        ],
        timeline: [
          const TimelineStep(
            stage: OrderStage.orderCreated,
            title: 'Order Placed & Verified',
            subtitle: 'Direct farm aggregation',
            isCompleted: true,
          ),
          const TimelineStep(
            stage: OrderStage.delivered,
            title: 'Delivered Successfully',
            subtitle: 'OTP Verified & Escrow Released',
            isCompleted: true,
            isCurrent: true,
          ),
        ],
      ),
      OrderModel(
        orderId: 'AGR-1640',
        type: OrderType.householdConsumer,
        cropName: 'Spices & Staples Bundle',
        totalQuantityKg: 3.0,
        totalAmount: 180.0,
        buyerName: 'Priya Sharma',
        deliveryAddress: 'Flat 402, Green Acres, Pune',
        currentStatusText: 'Delivered',
        orderDate: DateTime.now().subtract(const Duration(days: 3, hours: 6)),
        paymentMethod: 'Cash on Delivery',
        itemsSummary: const [
          'Guntur Teja Chillies (500g)',
          'Nashik Red Onions (2.5 kg)',
        ],
        timeline: [
          const TimelineStep(
            stage: OrderStage.orderCreated,
            title: 'Order Placed',
            subtitle: 'Payment upon delivery',
            isCompleted: true,
          ),
          const TimelineStep(
            stage: OrderStage.delivered,
            title: 'Delivered Successfully',
            subtitle: 'Received in good condition',
            isCompleted: true,
            isCurrent: true,
          ),
        ],
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Consumer: Products & Cart (kept local until consumer API endpoints)
  // ---------------------------------------------------------------------------
  final List<ConsumerProduct> _consumerProducts = const [
    ConsumerProduct(
      id: 'cp_001',
      name: 'Fresh Farm Tomatoes',
      category: 'Vegetables',
      pricePerKg: 24.0,
      mrpPrice: 35.0,
      unit: '1 kg',
      availableQuantityKg: 120.0,
      source: 'Direct from FPO (Ranga Reddy Hub)',
      distanceKm: 6.4,
      qualityGrade: 'Grade A',
      iconEmoji: '🍅',
      imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&auto=format&fit=crop&q=80',
      rating: 4.9,
      ratingCount: 142,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Harvested 3h ago',
    ),
    ConsumerProduct(
      id: 'cp_002',
      name: 'Organic Jyoti Potatoes',
      category: 'Vegetables',
      pricePerKg: 28.0,
      mrpPrice: 40.0,
      unit: '1 kg',
      availableQuantityKg: 350.0,
      source: 'Direct from Farmer (Chevella)',
      distanceKm: 8.1,
      qualityGrade: 'Grade A',
      iconEmoji: '🥔',
      imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 98,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Cleaned & Soil-Free',
    ),
    ConsumerProduct(
      id: 'cp_003',
      name: 'Nashik Red Fresh Onions',
      category: 'Vegetables',
      pricePerKg: 32.0,
      mrpPrice: 45.0,
      unit: '1 kg',
      availableQuantityKg: 210.0,
      source: 'Direct from FPO (Ranga Reddy Hub)',
      distanceKm: 6.4,
      qualityGrade: 'Grade A',
      iconEmoji: '🧅',
      imageUrl: 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=600&auto=format&fit=crop&q=80',
      rating: 4.7,
      ratingCount: 76,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Cured & Dry',
    ),
    ConsumerProduct(
      id: 'cp_004',
      name: 'Fresh Green Palak (Spinach)',
      category: 'Greens',
      pricePerKg: 18.0,
      mrpPrice: 25.0,
      unit: '1 bunch (250g)',
      availableQuantityKg: 45.0,
      source: 'Direct from Farmer (Moinabad)',
      distanceKm: 5.2,
      qualityGrade: 'Grade A',
      iconEmoji: '🥬',
      imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600&auto=format&fit=crop&q=80',
      rating: 4.9,
      ratingCount: 115,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Harvested at 5 AM Today',
    ),
    ConsumerProduct(
      id: 'cp_005',
      name: 'Spicy Guntur Green Chillies',
      category: 'Vegetables',
      pricePerKg: 64.0,
      mrpPrice: 88.0,
      unit: '250 g',
      availableQuantityKg: 50.0,
      source: 'Direct from Farmer (Chevella)',
      distanceKm: 7.3,
      qualityGrade: 'Grade A',
      iconEmoji: '🌶️',
      imageUrl: 'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 64,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Hand-picked',
    ),
    ConsumerProduct(
      id: 'cp_006',
      name: 'Premium Sona Masoori Rice',
      category: 'Grains',
      pricePerKg: 56.0,
      mrpPrice: 72.0,
      unit: '5 kg bag',
      availableQuantityKg: 500.0,
      source: 'Direct from FPO (Shabad Mill)',
      distanceKm: 9.0,
      qualityGrade: 'Grade A',
      iconEmoji: '🌾',
      imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&auto=format&fit=crop&q=80',
      rating: 4.9,
      ratingCount: 210,
      deliveryTime: '30-45 mins',
      isBestseller: true,
      harvestFreshness: '1-Year Aged Grain',
    ),
    ConsumerProduct(
      id: 'cp_007',
      name: 'Farm Fresh Green Peas (Matar)',
      category: 'Vegetables',
      pricePerKg: 45.0,
      mrpPrice: 60.0,
      unit: '500 g',
      availableQuantityKg: 80.0,
      source: 'Direct from FPO (Ranga Reddy Hub)',
      distanceKm: 6.4,
      qualityGrade: 'Grade A',
      iconEmoji: '🫛',
      imageUrl: 'https://images.unsplash.com/photo-1587735243615-c03f25aaff15?w=600&auto=format&fit=crop&q=80',
      rating: 4.7,
      ratingCount: 52,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Crisp & Sweet Pods',
    ),
    ConsumerProduct(
      id: 'cp_008',
      name: 'Organic Ginger (Adrak)',
      category: 'Herbs',
      pricePerKg: 75.0,
      mrpPrice: 100.0,
      unit: '250 g',
      availableQuantityKg: 40.0,
      source: 'Direct from Farmer (Chevella)',
      distanceKm: 7.3,
      qualityGrade: 'Grade A',
      iconEmoji: '🫚',
      imageUrl: 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 39,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Aromatic & Soil-Free',
    ),
    ConsumerProduct(
      id: 'cp_009',
      name: 'Fresh Crunchy Orange Carrots',
      category: 'Vegetables',
      pricePerKg: 42.0,
      mrpPrice: 55.0,
      unit: '1 kg',
      availableQuantityKg: 160.0,
      source: 'Direct from Farmer (Chevella)',
      distanceKm: 7.5,
      qualityGrade: 'Grade A',
      iconEmoji: '🥕',
      imageUrl: 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 88,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Harvested Today',
    ),
    ConsumerProduct(
      id: 'cp_010',
      name: 'Farm Fresh White Cauliflower',
      category: 'Vegetables',
      pricePerKg: 38.0,
      mrpPrice: 50.0,
      unit: '1 piece (~800g)',
      availableQuantityKg: 95.0,
      source: 'Direct from FPO (Shabad Hub)',
      distanceKm: 6.8,
      qualityGrade: 'Grade A',
      iconEmoji: '🥦',
      imageUrl: 'https://images.unsplash.com/photo-1568584711075-3d021a7c3ca3?w=600&auto=format&fit=crop&q=80',
      rating: 4.7,
      ratingCount: 65,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Firm & Compact Head',
    ),
    ConsumerProduct(
      id: 'cp_011',
      name: 'Green Bell Peppers (Capsicum)',
      category: 'Vegetables',
      pricePerKg: 50.0,
      mrpPrice: 65.0,
      unit: '500 g',
      availableQuantityKg: 110.0,
      source: 'Direct from FPO (Polyhouse Cluster)',
      distanceKm: 8.5,
      qualityGrade: 'Grade A',
      iconEmoji: '🫑',
      imageUrl: 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=600&auto=format&fit=crop&q=80',
      rating: 4.9,
      ratingCount: 110,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Glossy & Crisp',
    ),
    ConsumerProduct(
      id: 'cp_012',
      name: 'Country Fresh Garlic (Lahsun)',
      category: 'Herbs',
      pricePerKg: 120.0,
      mrpPrice: 160.0,
      unit: '250 g',
      availableQuantityKg: 75.0,
      source: 'Direct from Farmer (Chevella)',
      distanceKm: 7.3,
      qualityGrade: 'Grade A',
      iconEmoji: '🧄',
      imageUrl: 'https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 54,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Sun-cured & Dry',
    ),
    ConsumerProduct(
      id: 'cp_013',
      name: 'Fresh Green Cabbage (Patta Gobi)',
      category: 'Vegetables',
      pricePerKg: 26.0,
      mrpPrice: 35.0,
      unit: '1 piece (~600g)',
      availableQuantityKg: 140.0,
      source: 'Direct from FPO (Ranga Reddy Hub)',
      distanceKm: 6.4,
      qualityGrade: 'Grade A',
      iconEmoji: '🥬',
      imageUrl: 'https://images.unsplash.com/photo-1594282486552-05b4d80fbb9f?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 72,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Crisp & Tightly Layered',
    ),
    ConsumerProduct(
      id: 'cp_014',
      name: 'Tender Fresh Okra (Bhindi)',
      category: 'Vegetables',
      pricePerKg: 40.0,
      mrpPrice: 55.0,
      unit: '500 g',
      availableQuantityKg: 90.0,
      source: 'Direct from Farmer (Chevella)',
      distanceKm: 7.3,
      qualityGrade: 'Grade A',
      iconEmoji: '🌱',
      imageUrl: 'https://images.unsplash.com/photo-1425543103986-22abb7d7e8d2?w=600&auto=format&fit=crop&q=80',
      rating: 4.9,
      ratingCount: 130,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Harvested Today, 6 AM',
    ),
    ConsumerProduct(
      id: 'cp_015',
      name: 'Crisp Salad Cucumber (Kheera)',
      category: 'Vegetables',
      pricePerKg: 28.0,
      mrpPrice: 38.0,
      unit: '1 kg',
      availableQuantityKg: 175.0,
      source: 'Direct from FPO (Polyhouse Cluster)',
      distanceKm: 8.5,
      qualityGrade: 'Grade A',
      iconEmoji: '🥒',
      imageUrl: 'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 94,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Cool & Hydrated',
    ),
    ConsumerProduct(
      id: 'cp_016',
      name: 'Glossy Purple Brinjal (Baingan)',
      category: 'Vegetables',
      pricePerKg: 34.0,
      mrpPrice: 48.0,
      unit: '500 g',
      availableQuantityKg: 110.0,
      source: 'Direct from Farmer (Moinabad)',
      distanceKm: 5.2,
      qualityGrade: 'Grade A',
      iconEmoji: '🍆',
      imageUrl: 'https://images.unsplash.com/photo-1590165482129-1b8b27698780?w=600&auto=format&fit=crop&q=80',
      rating: 4.7,
      ratingCount: 68,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Freshly Picked',
    ),
    ConsumerProduct(
      id: 'cp_017',
      name: 'Organic Red Beetroot (Chukandar)',
      category: 'Vegetables',
      pricePerKg: 36.0,
      mrpPrice: 48.0,
      unit: '500 g',
      availableQuantityKg: 85.0,
      source: 'Direct from Farmer (Chevella)',
      distanceKm: 7.3,
      qualityGrade: 'Grade A',
      iconEmoji: '🍠',
      imageUrl: 'https://images.unsplash.com/photo-1593105544559-ecb03bf76f82?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 59,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Rich Iron-rich Roots',
    ),
    ConsumerProduct(
      id: 'cp_018',
      name: 'Juicy Yellow Farm Lemons (Nimbu)',
      category: 'Fruits',
      pricePerKg: 60.0,
      mrpPrice: 85.0,
      unit: '250 g (~6 pcs)',
      availableQuantityKg: 60.0,
      source: 'Direct from Farmer (Chevella)',
      distanceKm: 7.3,
      qualityGrade: 'Grade A',
      iconEmoji: '🍋',
      imageUrl: 'https://images.unsplash.com/photo-1590502593747-42a996133562?w=600&auto=format&fit=crop&q=80',
      rating: 4.9,
      ratingCount: 145,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Thin-skinned & Extra Juicy',
    ),
    ConsumerProduct(
      id: 'cp_019',
      name: 'Fresh Aromatic Coriander (Kothmir)',
      category: 'Greens',
      pricePerKg: 15.0,
      mrpPrice: 22.0,
      unit: '1 bunch (100g)',
      availableQuantityKg: 65.0,
      source: 'Direct from Farmer (Moinabad)',
      distanceKm: 5.2,
      qualityGrade: 'Grade A',
      iconEmoji: '🌿',
      imageUrl: 'https://images.unsplash.com/photo-1599940824399-b87987ceb72a?w=600&auto=format&fit=crop&q=80',
      rating: 4.9,
      ratingCount: 160,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Harvested Today at 5 AM',
    ),
    ConsumerProduct(
      id: 'cp_020',
      name: 'Fresh Fragrant Mint Leaves (Pudina)',
      category: 'Greens',
      pricePerKg: 12.0,
      mrpPrice: 18.0,
      unit: '1 bunch (100g)',
      availableQuantityKg: 50.0,
      source: 'Direct from Farmer (Moinabad)',
      distanceKm: 5.2,
      qualityGrade: 'Grade A',
      iconEmoji: '🌱',
      imageUrl: 'https://images.unsplash.com/photo-1628556270448-4d4e4148e1b1?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 102,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Intense Fresh Aroma',
    ),
    ConsumerProduct(
      id: 'cp_021',
      name: 'Natural Robusta Farm Bananas',
      category: 'Fruits',
      pricePerKg: 45.0,
      mrpPrice: 60.0,
      unit: '1 dozen',
      availableQuantityKg: 120.0,
      source: 'Direct from FPO (Orchard Cluster)',
      distanceKm: 9.2,
      qualityGrade: 'Grade A',
      iconEmoji: '🍌',
      imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=600&auto=format&fit=crop&q=80',
      rating: 4.9,
      ratingCount: 180,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Naturally Tree-Ripened',
    ),
    ConsumerProduct(
      id: 'cp_022',
      name: 'Crisp Royal Apples (Seb)',
      category: 'Fruits',
      pricePerKg: 135.0,
      mrpPrice: 180.0,
      unit: '1 kg (4-5 pcs)',
      availableQuantityKg: 150.0,
      source: 'Direct from FPO (Cold Storage)',
      distanceKm: 6.4,
      qualityGrade: 'Grade A',
      iconEmoji: '🍎',
      imageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600&auto=format&fit=crop&q=80',
      rating: 4.9,
      ratingCount: 125,
      deliveryTime: '20-30 mins',
      isBestseller: true,
      harvestFreshness: 'Sweet, Juicy & Crunchy',
    ),
    ConsumerProduct(
      id: 'cp_023',
      name: 'Ruby Red Fresh Pomegranates (Anar)',
      category: 'Fruits',
      pricePerKg: 110.0,
      mrpPrice: 150.0,
      unit: '1 kg (~4 pcs)',
      availableQuantityKg: 90.0,
      source: 'Direct from FPO (Solapur Cluster)',
      distanceKm: 9.5,
      qualityGrade: 'Grade A',
      iconEmoji: '🍎',
      imageUrl: 'https://images.unsplash.com/photo-1557800636-894a64c1696f?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 92,
      deliveryTime: '20-30 mins',
      isBestseller: false,
      harvestFreshness: 'Seed-Rich & Sweet',
    ),
    ConsumerProduct(
      id: 'cp_024',
      name: 'Tender Green French Beans (Phasli)',
      category: 'Vegetables',
      pricePerKg: 48.0,
      mrpPrice: 65.0,
      unit: '500 g',
      availableQuantityKg: 95.0,
      source: 'Direct from Farmer (Chevella)',
      distanceKm: 7.3,
      qualityGrade: 'Grade A',
      iconEmoji: '🫛',
      imageUrl: 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 84,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Snap Fresh & Tender',
    ),
    ConsumerProduct(
      id: 'cp_025',
      name: 'Farm Fresh Sweet Corn (Bhutta)',
      category: 'Vegetables',
      pricePerKg: 30.0,
      mrpPrice: 45.0,
      unit: '2 cobs (~500g)',
      availableQuantityKg: 130.0,
      source: 'Direct from FPO (Ranga Reddy Hub)',
      distanceKm: 6.4,
      qualityGrade: 'Grade A',
      iconEmoji: '🌽',
      imageUrl: 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=600&auto=format&fit=crop&q=80',
      rating: 4.9,
      ratingCount: 112,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Milky Sweet Kernels',
    ),
    ConsumerProduct(
      id: 'cp_026',
      name: 'Fresh Green Bottle Gourd (Lauki)',
      category: 'Vegetables',
      pricePerKg: 28.0,
      mrpPrice: 40.0,
      unit: '1 piece (~700g)',
      availableQuantityKg: 85.0,
      source: 'Direct from Farmer (Moinabad)',
      distanceKm: 5.2,
      qualityGrade: 'Grade A',
      iconEmoji: '🥒',
      imageUrl: 'https://images.unsplash.com/photo-1597362925123-77861d3fbac7?w=600&auto=format&fit=crop&q=80',
      rating: 4.7,
      ratingCount: 63,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Tender & Light-skinned',
    ),
    ConsumerProduct(
      id: 'cp_027',
      name: 'Fresh Button Mushrooms (Khumb)',
      category: 'Vegetables',
      pricePerKg: 55.0,
      mrpPrice: 75.0,
      unit: '1 pack (200g)',
      availableQuantityKg: 60.0,
      source: 'Direct from FPO (Mushroom Unit)',
      distanceKm: 8.0,
      qualityGrade: 'Grade A',
      iconEmoji: '🍄',
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&auto=format&fit=crop&q=80',
      rating: 4.9,
      ratingCount: 138,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Firm White Caps',
    ),
    ConsumerProduct(
      id: 'cp_028',
      name: 'Fresh Fenugreek Leaves (Methi)',
      category: 'Greens',
      pricePerKg: 20.0,
      mrpPrice: 30.0,
      unit: '1 bunch (200g)',
      availableQuantityKg: 55.0,
      source: 'Direct from Farmer (Moinabad)',
      distanceKm: 5.2,
      qualityGrade: 'Grade A',
      iconEmoji: '🌿',
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 79,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Fresh Morning Pluck',
    ),
    ConsumerProduct(
      id: 'cp_029',
      name: 'Farm Golden Sweet Potatoes (Shakarkand)',
      category: 'Vegetables',
      pricePerKg: 38.0,
      mrpPrice: 50.0,
      unit: '500 g',
      availableQuantityKg: 90.0,
      source: 'Direct from Farmer (Chevella)',
      distanceKm: 7.3,
      qualityGrade: 'Grade A',
      iconEmoji: '🍠',
      imageUrl: 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=600&auto=format&fit=crop&q=80',
      rating: 4.7,
      ratingCount: 47,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Naturally Sweet & Cured',
    ),
    ConsumerProduct(
      id: 'cp_030',
      name: 'Farm Fresh Golden Pumpkin (Kaddu)',
      category: 'Vegetables',
      pricePerKg: 32.0,
      mrpPrice: 45.0,
      unit: '1 kg cut block',
      availableQuantityKg: 110.0,
      source: 'Direct from FPO (Ranga Reddy Hub)',
      distanceKm: 6.4,
      qualityGrade: 'Grade A',
      iconEmoji: '🎃',
      imageUrl: 'https://images.unsplash.com/photo-1570586437263-ab629fccc818?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 56,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Rich Orange Flesh',
    ),
    // ---------------- Fruits ----------------
    ConsumerProduct(
      id: 'cp_031',
      name: 'Fresh Banganapalli Sweet Mangoes',
      category: 'Fruits',
      pricePerKg: 120.0,
      mrpPrice: 160.0,
      unit: '1 kg',
      availableQuantityKg: 150.0,
      source: 'Direct from Orchard (Khammam Cluster)',
      distanceKm: 9.2,
      qualityGrade: 'Grade A',
      iconEmoji: '🥭',
      imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600&auto=format&fit=crop&q=80',
      rating: 4.9,
      ratingCount: 184,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Tree Ripe & Sweet',
    ),
    ConsumerProduct(
      id: 'cp_032',
      name: 'Farm Fresh Sweet Papaya (Red Lady)',
      category: 'Fruits',
      pricePerKg: 42.0,
      mrpPrice: 60.0,
      unit: '1 piece (~900g)',
      availableQuantityKg: 95.0,
      source: 'Direct from Farmer (Moinabad)',
      distanceKm: 5.8,
      qualityGrade: 'Grade A',
      iconEmoji: '🍈',
      imageUrl: 'https://images.unsplash.com/photo-1517282009859-f000ec3b26fe?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 77,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Naturally Ripened',
    ),
    ConsumerProduct(
      id: 'cp_033',
      name: 'Allahabad Sweet White Guavas',
      category: 'Fruits',
      pricePerKg: 38.0,
      mrpPrice: 55.0,
      unit: '500 g',
      availableQuantityKg: 70.0,
      source: 'Direct from Orchard (Chevella)',
      distanceKm: 7.5,
      qualityGrade: 'Grade A',
      iconEmoji: '🍐',
      imageUrl: 'https://images.unsplash.com/photo-1536511135898-3f5f3e4e9f3b?w=600&auto=format&fit=crop&q=80',
      rating: 4.7,
      ratingCount: 52,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Crisp & Sweet White Flesh',
    ),
    ConsumerProduct(
      id: 'cp_034',
      name: 'Nagpur Sweet Juicy Oranges (Santra)',
      category: 'Fruits',
      pricePerKg: 65.0,
      mrpPrice: 85.0,
      unit: '1 kg (~6-7 pcs)',
      availableQuantityKg: 120.0,
      source: 'Direct from FPO (Nagpur Link)',
      distanceKm: 12.0,
      qualityGrade: 'Grade A',
      iconEmoji: '🍊',
      imageUrl: 'https://images.unsplash.com/photo-1582979512210-99b6a53386f9?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 112,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Juicy & High Vitamin C',
    ),
    ConsumerProduct(
      id: 'cp_035',
      name: 'Fresh Crisp Black Seedless Grapes',
      category: 'Fruits',
      pricePerKg: 75.0,
      mrpPrice: 100.0,
      unit: '500 g box',
      availableQuantityKg: 85.0,
      source: 'Direct from Vineyard (Nashik Hub)',
      distanceKm: 10.5,
      qualityGrade: 'Grade A',
      iconEmoji: '🍇',
      imageUrl: 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=600&auto=format&fit=crop&q=80',
      rating: 4.9,
      ratingCount: 134,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Plump & Sugar Sweet',
    ),
    ConsumerProduct(
      id: 'cp_036',
      name: 'Thompson Fresh Green Grapes',
      category: 'Fruits',
      pricePerKg: 65.0,
      mrpPrice: 90.0,
      unit: '500 g box',
      availableQuantityKg: 90.0,
      source: 'Direct from Vineyard (Nashik Hub)',
      distanceKm: 10.5,
      qualityGrade: 'Grade A',
      iconEmoji: '🍇',
      imageUrl: 'https://images.unsplash.com/photo-1596363505729-4190a9506133?w=600&auto=format&fit=crop&q=80',
      rating: 4.7,
      ratingCount: 68,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Crisp & Tangy-Sweet',
    ),
    ConsumerProduct(
      id: 'cp_037',
      name: 'Sweet Red Kiran Watermelon',
      category: 'Fruits',
      pricePerKg: 65.0,
      mrpPrice: 90.0,
      unit: '1 piece (~2.5 kg)',
      availableQuantityKg: 80.0,
      source: 'Direct from Farmer (Moinabad)',
      distanceKm: 6.0,
      qualityGrade: 'Grade A',
      iconEmoji: '🍉',
      imageUrl: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=600&auto=format&fit=crop&q=80',
      rating: 4.9,
      ratingCount: 160,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Deep Red & Hydrating',
    ),
    ConsumerProduct(
      id: 'cp_038',
      name: 'Sweet Honey Muskmelon (Kharbooja)',
      category: 'Fruits',
      pricePerKg: 48.0,
      mrpPrice: 70.0,
      unit: '1 piece (~1 kg)',
      availableQuantityKg: 75.0,
      source: 'Direct from Farmer (Chevella)',
      distanceKm: 7.2,
      qualityGrade: 'Grade A',
      iconEmoji: '🍈',
      imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 81,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Aromatic & Golden Center',
    ),
    ConsumerProduct(
      id: 'cp_039',
      name: 'Sweet Brown Sapota (Chikoo)',
      category: 'Fruits',
      pricePerKg: 35.0,
      mrpPrice: 50.0,
      unit: '500 g',
      availableQuantityKg: 65.0,
      source: 'Direct from Orchard (Moinabad)',
      distanceKm: 5.5,
      qualityGrade: 'Grade A',
      iconEmoji: '🥔',
      imageUrl: 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?w=600&auto=format&fit=crop&q=80',
      rating: 4.7,
      ratingCount: 44,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Caramel Sweet & Soft',
    ),
    ConsumerProduct(
      id: 'cp_040',
      name: 'Fresh Sweet Queen Pineapple',
      category: 'Fruits',
      pricePerKg: 55.0,
      mrpPrice: 75.0,
      unit: '1 piece (~1 kg)',
      availableQuantityKg: 60.0,
      source: 'Direct from FPO (South Hub)',
      distanceKm: 11.0,
      qualityGrade: 'Grade A',
      iconEmoji: '🍍',
      imageUrl: 'https://images.unsplash.com/photo-1550258987-190a2d41a8ba?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 92,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Fragrant Golden Core',
    ),
    // ---------------- Leafy Greens ("Leaf") ----------------
    ConsumerProduct(
      id: 'cp_041',
      name: 'Fresh Tangy Gongura (Sorrel Leaves)',
      category: 'Greens',
      pricePerKg: 15.0,
      mrpPrice: 22.0,
      unit: '1 bunch (~200g)',
      availableQuantityKg: 75.0,
      source: 'Direct from Farmer (Moinabad)',
      distanceKm: 5.2,
      qualityGrade: 'Grade A',
      iconEmoji: '🌿',
      imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600&auto=format&fit=crop&q=80',
      rating: 4.9,
      ratingCount: 120,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Harvested 4 AM Today',
    ),
    ConsumerProduct(
      id: 'cp_042',
      name: 'Fresh Red Amaranth Leaves (Thotakura)',
      category: 'Greens',
      pricePerKg: 16.0,
      mrpPrice: 25.0,
      unit: '1 bunch (~250g)',
      availableQuantityKg: 60.0,
      source: 'Direct from Farmer (Chevella)',
      distanceKm: 6.8,
      qualityGrade: 'Grade A',
      iconEmoji: '🥬',
      imageUrl: 'https://images.unsplash.com/photo-1524179091875-bf99a9a6fa57?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 64,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Rich Iron & Mineral Packed',
    ),
    ConsumerProduct(
      id: 'cp_043',
      name: 'Aromatic Fresh Curry Leaves (Kadi Patta)',
      category: 'Greens',
      pricePerKg: 12.0,
      mrpPrice: 18.0,
      unit: '1 bunch (~100g)',
      availableQuantityKg: 100.0,
      source: 'Direct from Farmer (Moinabad)',
      distanceKm: 4.9,
      qualityGrade: 'Grade A',
      iconEmoji: '🍃',
      imageUrl: 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=600&auto=format&fit=crop&q=80',
      rating: 4.9,
      ratingCount: 210,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Crisp Dark Green Aroma',
    ),
    ConsumerProduct(
      id: 'cp_044',
      name: 'Tender Moringa Leaves (Munagaku)',
      category: 'Greens',
      pricePerKg: 18.0,
      mrpPrice: 28.0,
      unit: '1 bunch (~150g)',
      availableQuantityKg: 40.0,
      source: 'Direct from Farmer (Chevella)',
      distanceKm: 7.1,
      qualityGrade: 'Grade A',
      iconEmoji: '🌿',
      imageUrl: 'https://images.unsplash.com/photo-1515543237350-b3eea1ec8082?w=600&auto=format&fit=crop&q=80',
      rating: 4.9,
      ratingCount: 88,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Superfood Morning Harvest',
    ),
    ConsumerProduct(
      id: 'cp_045',
      name: 'Tender Malabar Spinach (Bachali Kura)',
      category: 'Greens',
      pricePerKg: 16.0,
      mrpPrice: 24.0,
      unit: '1 bunch (~250g)',
      availableQuantityKg: 50.0,
      source: 'Direct from Farmer (Moinabad)',
      distanceKm: 5.3,
      qualityGrade: 'Grade A',
      iconEmoji: '🥬',
      imageUrl: 'https://images.unsplash.com/photo-1628771065518-0d82f1938462?w=600&auto=format&fit=crop&q=80',
      rating: 4.7,
      ratingCount: 42,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Plump Succulent Leaves',
    ),
    ConsumerProduct(
      id: 'cp_046',
      name: 'Crisp Farm Spring Onion Greens (Hari Pyaz)',
      category: 'Greens',
      pricePerKg: 22.0,
      mrpPrice: 32.0,
      unit: '1 bunch (~200g)',
      availableQuantityKg: 65.0,
      source: 'Direct from Farmer (Chevella)',
      distanceKm: 6.5,
      qualityGrade: 'Grade A',
      iconEmoji: '🧅',
      imageUrl: 'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 95,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Crisp Green Stalks',
    ),
    ConsumerProduct(
      id: 'cp_047',
      name: 'Fresh Fragrant Dill Leaves (Shepu / Suva)',
      category: 'Greens',
      pricePerKg: 18.0,
      mrpPrice: 26.0,
      unit: '1 bunch (~150g)',
      availableQuantityKg: 45.0,
      source: 'Direct from Farmer (Moinabad)',
      distanceKm: 5.2,
      qualityGrade: 'Grade A',
      iconEmoji: '🌿',
      imageUrl: 'https://images.unsplash.com/photo-1509358271058-acd22cc93898?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 53,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Feathery Fragrant Leaves',
    ),
    ConsumerProduct(
      id: 'cp_048',
      name: 'Crunchy Green Lettuce & Salad Leaves',
      category: 'Greens',
      pricePerKg: 35.0,
      mrpPrice: 50.0,
      unit: '1 head (~200g)',
      availableQuantityKg: 40.0,
      source: 'Direct from Hydroponic Hub (Ranga Reddy)',
      distanceKm: 8.5,
      qualityGrade: 'Grade A',
      iconEmoji: '🥗',
      imageUrl: 'https://images.unsplash.com/photo-1556801712-76c8eb07bbc9?w=600&auto=format&fit=crop&q=80',
      rating: 4.9,
      ratingCount: 114,
      deliveryTime: '15-25 mins',
      isBestseller: true,
      harvestFreshness: 'Clean Hydroponic Pluck',
    ),
    ConsumerProduct(
      id: 'cp_049',
      name: 'Winter Fresh Mustard Greens (Sarson Ka Saag)',
      category: 'Greens',
      pricePerKg: 20.0,
      mrpPrice: 30.0,
      unit: '1 bunch (~250g)',
      availableQuantityKg: 55.0,
      source: 'Direct from Farmer (Moinabad)',
      distanceKm: 5.4,
      qualityGrade: 'Grade A',
      iconEmoji: '🥬',
      imageUrl: 'https://images.unsplash.com/photo-1518843875459-f738682238a6?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      ratingCount: 67,
      deliveryTime: '15-25 mins',
      isBestseller: false,
      harvestFreshness: 'Peppery Tender Green Leaves',
    ),
  ];

  final List<CartItem> _cart = [];

  List<ConsumerProduct> get consumerProducts => _consumerProducts;
  List<CartItem> get cart => _cart;
  int get cartCount => _cart.length;
  double get cartSubtotal =>
      _cart.fold(0, (sum, item) => sum + item.itemTotal);
  double get deliveryFee => _cart.isEmpty ? 0.0 : 20.0;
  double get cartTotal => _cart.isEmpty ? 0.0 : cartSubtotal + deliveryFee;

  void addToCart(ConsumerProduct product, double qty) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _cart[index] = CartItem(
        product: product,
        quantityKg: _cart[index].quantityKg + qty,
      );
    } else {
      _cart.add(CartItem(product: product, quantityKg: qty));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateCartQuantity(String productId, double qty) {
    final index = _cart.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (qty <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index] = CartItem(
          product: _cart[index].product,
          quantityKg: qty,
        );
      }
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Consumer Delivery Address & Checkout State
  // ---------------------------------------------------------------------------
  String _deliveryTag = 'Home';
  String _deliveryName = 'Ananya Sharma';
  String _deliveryAddress = 'Flat 402, Green Meadows, Madhapur, Hyderabad - 500081';
  String _deliveryPhone = '+91 91234 56789';

  String get deliveryTag => _deliveryTag;
  String get deliveryName => _deliveryName;
  String get deliveryAddress => _deliveryAddress;
  String get deliveryPhone => _deliveryPhone;

  void updateConsumerDeliveryAddress({
    required String tag,
    required String name,
    required String address,
    required String phone,
  }) {
    _deliveryTag = tag;
    _deliveryName = name;
    _deliveryAddress = address;
    _deliveryPhone = phone;
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void placeConsumerOrder({
    String? deliveryAddress,
    String? buyerName,
    String? paymentMethod,
    double? totalAmount,
    String? cropName,
    List<String>? itemsSummary,
  }) {
    final orderId = 'AGR-${(1000 + DateTime.now().millisecondsSinceEpoch % 9000)}';
    final items = itemsSummary ??
        (_cart.isNotEmpty
            ? _cart.map((e) => '${e.product.name} (${e.quantityKg.toInt()} ${e.product.unit})').toList()
            : const ['Fresh Farm Tomatoes (2 kg)', 'Organic Potatoes (1 kg)']);
    final total = totalAmount ?? (_cart.isNotEmpty ? cartTotal : 100.0);
    final crop = cropName ?? (items.isNotEmpty ? items.first : 'Farm Fresh Vegetables Basket');
    final finalAddress = deliveryAddress ?? _deliveryAddress;
    final finalBuyer = buyerName ?? (_currentUser.name.isNotEmpty ? _currentUser.name : _deliveryName);
    final finalMethod = paymentMethod ?? 'UPI (PhonePe / Google Pay)';

    _currentConsumerOrder = OrderModel(
      orderId: orderId,
      type: OrderType.householdConsumer,
      cropName: crop,
      totalQuantityKg: 3.0,
      totalAmount: total,
      buyerName: finalBuyer,
      deliveryAddress: finalAddress,
      paymentMethod: finalMethod,
      itemsSummary: items,
      eta: 'In 35 mins',
      currentStatusText: 'Confirmed • Out for Delivery',
      timeline: [
        TimelineStep(
          stage: OrderStage.orderCreated,
          title: 'Order Placed & Payment Verified',
          subtitle: '₹${total.toInt()} paid via $finalMethod',
          isCompleted: true,
          timestamp: DateTime.now(),
        ),
        TimelineStep(
          stage: OrderStage.supplyAggregated,
          title: 'Packed at Ranga Reddy FPO Hub',
          subtitle: 'Freshly sorted organic lot • 0% middleman cut',
          isCompleted: true,
          timestamp: DateTime.now().add(const Duration(minutes: 5)),
        ),
        TimelineStep(
          stage: OrderStage.inTransit,
          title: 'Out for Delivery',
          subtitle: 'Delivery Partner Mahesh en route on EV',
          isCompleted: true,
          isCurrent: true,
          timestamp: DateTime.now().add(const Duration(minutes: 12)),
        ),
        TimelineStep(
          stage: OrderStage.delivered,
          title: 'Doorstep Delivery',
          subtitle: 'Estimated arrival at $finalAddress',
          isCompleted: false,
          timestamp: DateTime.now().add(const Duration(minutes: 35)),
        ),
      ],
      settlements: const [],
      orderDate: DateTime.now(),
    );

    _consumerOrders.insert(0, _currentConsumerOrder);

    final newTrip = {
      'orderId': orderId,
      'customerName': finalBuyer,
      'customerPhone': '+91${_deliveryPhone.isNotEmpty ? _deliveryPhone : '9876543210'}',
      'destination': finalAddress,
      'pickupHub': 'Ranga Reddy FPO Hub (Dock 2, Shabad)',
      'crateId': 'CR-${110 + _activeDeliveryTrips.length}',
      'distance': '5.2 km',
      'payout': 50.0,
      'otp': '2048',
      'items': items,
      'weight': '3.0 kg',
    };
    _activeDeliveryTrips.insert(0, newTrip);

    _cart.clear();
    notifyListeners();
  }

  void reorderConsumerItems(OrderModel order) {
    if (_consumerProducts.isNotEmpty) {
      addToCart(_consumerProducts.first, 2.0);
      if (_consumerProducts.length > 1) {
        addToCart(_consumerProducts[1], 1.0);
      }
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Delivery Partner State
  // ---------------------------------------------------------------------------
  bool _isDriverOnline = true;
  double _driverEarningsToday = 495.0;
  int _driverCompletedTripsToday = 8;
  final List<Map<String, dynamic>> _activeDeliveryTrips = [
    {
      'orderId': 'AGR-4921',
      'customerName': 'Ananya Sharma',
      'customerPhone': '+919876543213',
      'destination': 'Flat 402, Green Meadows, Madhapur, Hyderabad',
      'pickupHub': 'Ranga Reddy FPO Hub (Dock 2, Shabad)',
      'crateId': 'CR-104',
      'distance': '6.4 km',
      'payout': 50.0,
      'otp': '2048',
      'items': [
        'Fresh Farm Tomatoes (2 kg)',
        'Organic Potatoes (1 kg)',
      ],
      'weight': '3.0 kg',
    },
    {
      'orderId': 'AGR-4890',
      'customerName': 'Dr. K. Srinivas',
      'customerPhone': '+919848022199',
      'destination': 'Plot 18, Road No. 12, Banjara Hills, Hyderabad',
      'pickupHub': 'Ranga Reddy FPO Hub (Dock 1, Shabad)',
      'crateId': 'CR-109',
      'distance': '8.2 km',
      'payout': 65.0,
      'otp': '5192',
      'items': [
        'Organic Red Onions (5 kg)',
        'Spicy Green Chillies (500 g)',
      ],
      'weight': '5.5 kg',
    },
  ];

  final List<Map<String, dynamic>> _driverTripHistory = [
    {
      'orderId': 'AGR-4910',
      'customerName': 'Ananya Sharma',
      'customerPhone': '+919876543213',
      'destination': 'Flat 402, Green Meadows, Madhapur, Hyderabad',
      'pickupHub': 'Ranga Reddy FPO Hub (Dock 2, Shabad)',
      'crateId': 'CR-104',
      'items': ['Farm Fresh Red Tomatoes (2.0 kg)', 'Organic Jyoti Potatoes (1.5 kg)'],
      'weight': '3.5 kg',
      'distance': '6.8 km',
      'duration': '24 mins',
      'payout': 65.0,
      'completedAt': 'Today, 09:42 AM',
      'dateCategory': 'today',
      'status': 'DELIVERED',
      'otpVerified': true,
      'otp': '7492',
      'settlementRef': 'UPI-2026-9921448',
    },
    {
      'orderId': 'AGR-4882',
      'customerName': 'Rajesh Reddy',
      'customerPhone': '+919848011234',
      'destination': 'House 12-4, Telecom Nagar, Gachibowli, Hyderabad',
      'pickupHub': 'Ranga Reddy FPO Hub (Dock 1, Shabad)',
      'crateId': 'CR-088',
      'items': ['Organic Red Onions (3.0 kg)', 'Fresh Green Chillies (500 g)', 'Fresh Coriander (1.5 kg)'],
      'weight': '5.0 kg',
      'distance': '7.2 km',
      'duration': '26 mins',
      'payout': 70.0,
      'completedAt': 'Today, 09:05 AM',
      'dateCategory': 'today',
      'status': 'DELIVERED',
      'otpVerified': true,
      'otp': '3180',
      'settlementRef': 'UPI-2026-9918231',
    },
    {
      'orderId': 'AGR-4860',
      'customerName': 'Priya Verma',
      'customerPhone': '+919988776655',
      'destination': 'Flat 301, Cyber Heights, HITEC City, Hyderabad',
      'pickupHub': 'Ranga Reddy FPO Hub (Dock 2, Shabad)',
      'crateId': 'CR-094',
      'items': ['Organic Spinach / Palak (1.0 kg)', 'Country Carrots (1.5 kg)'],
      'weight': '2.5 kg',
      'distance': '5.1 km',
      'duration': '19 mins',
      'payout': 55.0,
      'completedAt': 'Today, 08:30 AM',
      'dateCategory': 'today',
      'status': 'DELIVERED',
      'otpVerified': true,
      'otp': '5519',
      'settlementRef': 'UPI-2026-9914502',
    },
    {
      'orderId': 'AGR-4835',
      'customerName': 'Dr. K. Srinivas',
      'customerPhone': '+919848022199',
      'destination': 'Plot 18, Road No. 12, Banjara Hills, Hyderabad',
      'pickupHub': 'Ranga Reddy FPO Hub (Dock 3, Shabad)',
      'crateId': 'CR-071',
      'items': ['Fresh Farm Tomatoes (3.0 kg)', 'Organic Ridge Gourd (1.5 kg)', 'Mint Leaves (1.5 kg)'],
      'weight': '6.0 kg',
      'distance': '8.5 km',
      'duration': '28 mins',
      'payout': 75.0,
      'completedAt': 'Today, 07:55 AM',
      'dateCategory': 'today',
      'status': 'DELIVERED',
      'otpVerified': true,
      'otp': '8204',
      'settlementRef': 'UPI-2026-9909381',
    },
    {
      'orderId': 'AGR-4812',
      'customerName': 'Suresh Babu',
      'customerPhone': '+919700088776',
      'destination': 'Villa 14, Palm Meadows, Narsingi, Hyderabad',
      'pickupHub': 'Ranga Reddy FPO Hub (Dock 1, Shabad)',
      'crateId': 'CR-065',
      'items': ['Organic Jyoti Potatoes (2.0 kg)', 'Fresh Ginger (1.0 kg)'],
      'weight': '3.0 kg',
      'distance': '4.8 km',
      'duration': '16 mins',
      'payout': 55.0,
      'completedAt': 'Today, 07:20 AM',
      'dateCategory': 'today',
      'status': 'DELIVERED',
      'otpVerified': true,
      'otp': '1942',
      'settlementRef': 'UPI-2026-9905120',
    },
    {
      'orderId': 'AGR-4790',
      'customerName': 'Madhavi Latha',
      'customerPhone': '+919123456789',
      'destination': 'Flat 504, Sri Sai Enclave, Manikonda, Hyderabad',
      'pickupHub': 'Ranga Reddy FPO Hub (Dock 2, Shabad)',
      'crateId': 'CR-052',
      'items': ['Organic Brinjal (2.0 kg)', 'Green Capsicum (1.2 kg)', 'Curry Leaves (1.0 kg)'],
      'weight': '4.2 kg',
      'distance': '6.0 km',
      'duration': '21 mins',
      'payout': 60.0,
      'completedAt': 'Today, 06:50 AM',
      'dateCategory': 'today',
      'status': 'DELIVERED',
      'otpVerified': true,
      'otp': '4081',
      'settlementRef': 'UPI-2026-9901458',
    },
    {
      'orderId': 'AGR-4765',
      'customerName': 'Venkat Ramana',
      'customerPhone': '+919849033445',
      'destination': 'House 4-88, Puppalaguda Main Rd, Hyderabad',
      'pickupHub': 'Ranga Reddy FPO Hub (Dock 1, Shabad)',
      'crateId': 'CR-040',
      'items': ['Fresh Farm Tomatoes (2.5 kg)', 'Organic Cauliflower (1.5 kg)'],
      'weight': '4.0 kg',
      'distance': '5.5 km',
      'duration': '18 mins',
      'payout': 60.0,
      'completedAt': 'Today, 06:18 AM',
      'dateCategory': 'today',
      'status': 'DELIVERED',
      'otpVerified': true,
      'otp': '6312',
      'settlementRef': 'UPI-2026-9898012',
    },
    {
      'orderId': 'AGR-4740',
      'customerName': 'Kavitha Reddy',
      'customerPhone': '+919949022110',
      'destination': 'Flat 202, Fortune Towers, Financial District, Hyderabad',
      'pickupHub': 'Ranga Reddy FPO Hub (Dock 2, Shabad)',
      'crateId': 'CR-033',
      'items': ['Organic Bottle Gourd (1.8 kg)', 'Fresh Lady Finger / Bhendi (2.0 kg)'],
      'weight': '3.8 kg',
      'distance': '5.9 km',
      'duration': '20 mins',
      'payout': 55.0,
      'completedAt': 'Today, 05:45 AM',
      'dateCategory': 'today',
      'status': 'DELIVERED',
      'otpVerified': true,
      'otp': '9025',
      'settlementRef': 'UPI-2026-9894109',
    },
    {
      'orderId': 'AGR-4690',
      'customerName': 'Vikram Goud',
      'customerPhone': '+919888844332',
      'destination': 'Plot 45, Golden Tulip, Kondapur, Hyderabad',
      'pickupHub': 'Ranga Reddy FPO Hub (Dock 1, Shabad)',
      'crateId': 'CR-028',
      'items': ['Organic Tomatoes (3.0 kg)', 'Green Chillies (1.0 kg)'],
      'weight': '4.0 kg',
      'distance': '6.2 km',
      'duration': '22 mins',
      'payout': 65.0,
      'completedAt': 'Yesterday, 05:15 PM',
      'dateCategory': 'this_week',
      'status': 'DELIVERED',
      'otpVerified': true,
      'otp': '4820',
      'settlementRef': 'UPI-2026-9872190',
    },
    {
      'orderId': 'AGR-4655',
      'customerName': 'Shweta Rao',
      'customerPhone': '+919765412345',
      'destination': 'Flat 601, Silicon Valley Apts, Madhapur, Hyderabad',
      'pickupHub': 'Ranga Reddy FPO Hub (Dock 2, Shabad)',
      'crateId': 'CR-021',
      'items': ['Jyoti Potatoes (4.0 kg)', 'Fresh Mint (500 g)'],
      'weight': '4.5 kg',
      'distance': '5.0 km',
      'duration': '17 mins',
      'payout': 55.0,
      'completedAt': 'Yesterday, 03:40 PM',
      'dateCategory': 'this_week',
      'status': 'DELIVERED',
      'otpVerified': true,
      'otp': '1190',
      'settlementRef': 'UPI-2026-9865012',
    },
  ];

  bool get isDriverOnline => _isDriverOnline;
  double get driverEarningsToday => _driverEarningsToday;
  int get driverCompletedTripsToday => _driverCompletedTripsToday;
  List<Map<String, dynamic>> get activeDeliveryTrips => List.unmodifiable(_activeDeliveryTrips);
  List<Map<String, dynamic>> get driverTripHistory => List.unmodifiable(_driverTripHistory);

  void toggleDriverOnline() {
    _isDriverOnline = !_isDriverOnline;
    notifyListeners();
  }

  void completeDriverTrip(double payout, {String? orderId, Map<String, dynamic>? tripDetails}) {
    _driverEarningsToday += payout;
    _driverCompletedTripsToday += 1;
    Map<String, dynamic>? completedTrip;
    if (orderId != null) {
      final index = _activeDeliveryTrips.indexWhere((t) => t['orderId'] == orderId);
      if (index != -1) {
        completedTrip = Map<String, dynamic>.from(_activeDeliveryTrips.removeAt(index));
      }
    }
    completedTrip ??= tripDetails != null ? Map<String, dynamic>.from(tripDetails) : null;
    if (completedTrip != null) {
      completedTrip['completedAt'] = 'Just Now';
      completedTrip['dateCategory'] = 'today';
      completedTrip['status'] = 'DELIVERED';
      completedTrip['otpVerified'] = true;
      completedTrip['payout'] = payout;
      completedTrip['settlementRef'] = 'UPI-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      _driverTripHistory.insert(0, completedTrip);
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------------
  List<NotificationItem> getCurrentRoleNotifications() => [];

  // ---------------------------------------------------------------------------
  // Real-time WebSockets
  // ---------------------------------------------------------------------------
  void _initSocket() {
    SocketService.instance.init();

    SocketService.instance.onProduceCreated((data) {
      final newItem = ProduceItem.fromJson(data);
      if (!_produceList.any((p) => p.id == newItem.id && newItem.id.isNotEmpty)) {
        _produceList.insert(0, newItem);
        notifyListeners();
      }
    });

    SocketService.instance.onMatchUpdated((data) {
      final match = SupplyMatch.fromJson(data);
      final index = _matches.indexWhere((m) => m.id == match.id);
      if (index >= 0) {
        _matches[index] = match;
      } else {
        _matches.insert(0, match);
      }
      notifyListeners();
    });
  }
}