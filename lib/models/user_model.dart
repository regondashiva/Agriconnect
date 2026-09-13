enum UserRole { farmer, fpo, bulkBuyer, consumer, deliveryPartner }

class User {
  final String id;
  final String name;
  final String phoneNumber;
  final UserRole role;
  final String location;
  final String? preferredLanguage;
  final String? fpoCluster;
  final String? businessName;
  final String? registrationId;
  final List<String>? primaryCrops;
  final double? landSizeAcres;
  final String? bankName;
  final String? upiId;
  final String? pincode;
  final String? businessType;
  final int? memberCount;
  final double? capacityTons;
  final double? monthlyVolumeTons;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? village;
  final String? district;
  final String? state;
  final double? latitude;
  final double? longitude;
  final List<String>? operatingDistricts;
  final double? coldStorageCapacityMt;
  final bool isNewUser;
  final bool isVerified;

  const User({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.role,
    required this.location,
    this.preferredLanguage = 'Telugu / English',
    this.fpoCluster,
    this.businessName,
    this.registrationId,
    this.primaryCrops,
    this.landSizeAcres,
    this.bankName,
    this.upiId,
    this.pincode,
    this.businessType,
    this.memberCount,
    this.capacityTons,
    this.monthlyVolumeTons,
    this.vehicleType,
    this.vehicleNumber,
    this.village,
    this.district,
    this.state,
    this.latitude,
    this.longitude,
    this.operatingDistricts,
    this.coldStorageCapacityMt,
    this.isNewUser = false,
    this.isVerified = true,
  });

  bool get isProfileComplete => name.trim().isNotEmpty;

  String get roleDisplayName {
    switch (role) {
      case UserRole.farmer:
        return 'Farmer';
      case UserRole.fpo:
        return 'FPO Coordinator';
      case UserRole.bulkBuyer:
        return 'Bulk Buyer';
      case UserRole.consumer:
        return 'Consumer';
      case UserRole.deliveryPartner:
        return 'Delivery Partner';
    }
  }

  factory User.fromJson(Map<String, dynamic> json, {bool? isNewUser}) {
    final resolvedName = (json['full_name'] ?? json['name'] ?? '') as String;
    final resolvedNew = isNewUser ??
        (json['is_new_user'] as bool? ??
            json['new_user'] as bool? ??
            resolvedName.trim().isEmpty);

    List<String>? crops;
    if (json['primary_crops'] is List) {
      crops = (json['primary_crops'] as List).map((e) => e.toString()).toList();
    }

    final resolvedVerified = json['is_verified'] as bool? ??
        (resolvedName.trim().isNotEmpty && !resolvedNew);

    final farmerProf = json['farmer_profile'] as Map<String, dynamic>?;
    final fpoProf = json['fpo_profile'] as Map<String, dynamic>?;
    final driverProf = json['driver_profile'] as Map<String, dynamic>?;
    final buyerProf = json['buyer_profile'] as Map<String, dynamic>?;

    List<String>? opDistricts;
    if (fpoProf?['operating_districts'] is List) {
      opDistricts = (fpoProf!['operating_districts'] as List).map((e) => e.toString()).toList();
    }

    return User(
      id: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      name: resolvedName,
      phoneNumber: json['phone_number'] as String? ?? '',
      role: roleFromString((json['role'] ?? json['user_role'] ?? json['role_type'] ?? '') as String),
      location: (json['location'] ??
              farmerProf?['village'] ??
              json['delivery_address'] ??
              json['farm_location'] ??
              json['hub_location'] ??
              '') as String,
      preferredLanguage: (json['preferred_language'] ?? json['language']) as String?,
      fpoCluster: (json['fpo_cluster'] ?? json['fpo_cluster_assigned']) as String?,
      businessName: (json['business_name'] ?? buyerProf?['business_name'] ?? (json['role'] == 'fpo' ? resolvedName : null)) as String?,
      registrationId: (json['registration_id'] ??
              fpoProf?['registration_number'] ??
              buyerProf?['gstin'] ??
              json['verified_id'] ??
              json['gstin']) as String?,
      primaryCrops: crops,
      landSizeAcres: (farmerProf?['land_size_acres'] as num?)?.toDouble() ?? (json['land_size_acres'] as num?)?.toDouble(),
      bankName: json['bank_name'] as String?,
      upiId: (json['upi_id'] ?? driverProf?['upi_id']) as String?,
      pincode: (farmerProf?['pincode'] ?? json['pincode']) as String?,
      businessType: (buyerProf?['business_type'] ?? json['business_type']) as String?,
      memberCount: (json['member_count'] as num?)?.toInt(),
      capacityTons: (json['capacity_tons'] as num?)?.toDouble(),
      monthlyVolumeTons: (buyerProf?['monthly_volume_tons'] as num?)?.toDouble() ?? (json['monthly_volume_tons'] as num?)?.toDouble(),
      vehicleType: (driverProf?['vehicle_type'] ?? json['vehicle_type']) as String?,
      vehicleNumber: (driverProf?['vehicle_number'] ?? json['vehicle_number']) as String?,
      village: farmerProf?['village'] as String?,
      district: farmerProf?['district'] as String?,
      state: farmerProf?['state'] as String?,
      latitude: (farmerProf?['latitude'] ?? fpoProf?['hub_latitude'] ?? json['latitude'] as num?)?.toDouble(),
      longitude: (farmerProf?['longitude'] ?? fpoProf?['hub_longitude'] ?? json['longitude'] as num?)?.toDouble(),
      operatingDistricts: opDistricts,
      coldStorageCapacityMt: (fpoProf?['cold_storage_capacity_mt'] as num?)?.toDouble(),
      isNewUser: resolvedNew,
      isVerified: resolvedVerified,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'full_name': name,
        'phone_number': phoneNumber,
        'role': roleToString(role),
        'location': location,
        'is_verified': isVerified,
        if (preferredLanguage != null) 'preferred_language': preferredLanguage,
        if (fpoCluster != null) 'fpo_cluster': fpoCluster,
        if (businessName != null) 'business_name': businessName,
        if (registrationId != null) 'registration_id': registrationId,
        if (primaryCrops != null) 'primary_crops': primaryCrops,
        if (landSizeAcres != null) 'land_size_acres': landSizeAcres,
        if (bankName != null) 'bank_name': bankName,
        if (upiId != null) 'upi_id': upiId,
        if (pincode != null) 'pincode': pincode,
        if (businessType != null) 'business_type': businessType,
        if (memberCount != null) 'member_count': memberCount,
        if (capacityTons != null) 'capacity_tons': capacityTons,
        if (monthlyVolumeTons != null) 'monthly_volume_tons': monthlyVolumeTons,
        if (vehicleType != null) 'vehicle_type': vehicleType,
        if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
        if (village != null) 'village': village,
        if (district != null) 'district': district,
        if (state != null) 'state': state,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (operatingDistricts != null) 'operating_districts': operatingDistricts,
        if (coldStorageCapacityMt != null) 'cold_storage_capacity_mt': coldStorageCapacityMt,
      };

  /// Generates the exact JSON contract payload specified in Module 6: User Profiles & FPO Onboarding
  /// Endpoint: PATCH /api/v1/users/profile
  Map<String, dynamic> toProfilePayload() {
    final langCode = _langCode(preferredLanguage);
    final payload = <String, dynamic>{
      'full_name': name,
      'preferred_language': langCode,
      'role': User.roleToString(role),
      'location': location,
      'farm_location': location,
      if (primaryCrops != null && primaryCrops!.isNotEmpty) 'primary_crops': primaryCrops,
      if (landSizeAcres != null) 'land_size_acres': landSizeAcres,
      if (fpoCluster != null && fpoCluster!.isNotEmpty) 'fpo_cluster_assigned': fpoCluster,
      if (upiId != null && upiId!.isNotEmpty) 'upi_id': upiId,
      if (bankName != null && bankName!.isNotEmpty) 'bank_name': bankName,
    };

    switch (role) {
      case UserRole.farmer:
        final locParts = location.split(',').map((s) => s.trim()).toList();
        final v = village ?? (locParts.isNotEmpty ? locParts[0] : 'Medchal');
        final d = district ?? (locParts.length > 1 ? locParts[1] : 'Medchal-Malkajgiri');
        final s = state ?? (locParts.length > 2 ? locParts[2] : 'Telangana');
        payload['farmer_profile'] = {
          'village': v,
          'district': d,
          'state': s,
          'pincode': pincode ?? '501401',
          'latitude': latitude ?? 17.6294,
          'longitude': longitude ?? 78.4828,
          'land_size_acres': landSizeAcres ?? 2.5,
        };
        break;

      case UserRole.fpo:
        final opDistricts = operatingDistricts ??
            (location.isNotEmpty
                ? location.split(',').map((s) => s.trim()).toList()
                : ['Medchal', 'Hyderabad']);
        payload['fpo_profile'] = {
          'registration_number': registrationId ?? 'FPO-TS-2024-991',
          'operating_districts': opDistricts,
          'cold_storage_capacity_mt': coldStorageCapacityMt ?? capacityTons ?? 50.0,
          'hub_latitude': latitude ?? 17.6300,
          'hub_longitude': longitude ?? 78.4850,
        };
        break;

      case UserRole.bulkBuyer:
        payload['buyer_profile'] = {
          'business_name': businessName ?? name,
          'gstin': registrationId ?? '',
          'monthly_volume_tons': monthlyVolumeTons ?? 10.0,
          'delivery_location': location,
        };
        break;

      case UserRole.deliveryPartner:
        payload['driver_profile'] = {
          'vehicle_type': vehicleType ?? 'EV Cargo Scooter',
          'vehicle_number': vehicleNumber ?? 'TS 07 EA 4821',
          'upi_id': upiId ?? '',
          'is_available': true,
        };
        break;

      case UserRole.consumer:
        payload['consumer_profile'] = {
          'address': location,
          'pincode': pincode ?? '500081',
        };
        break;
    }

    return payload;
  }

  static String _langCode(String? lang) {
    if (lang == null) return 'te';
    final l = lang.toLowerCase();
    if (l.contains('te') || l.contains('telugu')) return 'te';
    if (l.contains('hi') || l.contains('hindi')) return 'hi';
    if (l.contains('mr') || l.contains('marathi')) return 'mr';
    if (l.contains('gu') || l.contains('gujarati')) return 'gu';
    return 'en';
  }

  static UserRole roleFromString(String s) {
    final clean = s.trim().toLowerCase().replaceAll(RegExp(r'[\s\-_]'), '');
    if (clean.contains('fpo') || clean.contains('coordinator')) {
      return UserRole.fpo;
    }
    if (clean.contains('buyer') || clean.contains('bulk') || clean.contains('trader') || clean.contains('wholesale')) {
      return UserRole.bulkBuyer;
    }
    if (clean.contains('consumer') || clean.contains('household') || clean.contains('retail')) {
      return UserRole.consumer;
    }
    if (clean.contains('delivery') || clean.contains('driver') || clean.contains('rider') || clean.contains('logistics')) {
      return UserRole.deliveryPartner;
    }
    return UserRole.farmer;
  }

  static String roleToString(UserRole r) {
    switch (r) {
      case UserRole.farmer:
        return 'farmer';
      case UserRole.fpo:
        return 'fpo';
      case UserRole.bulkBuyer:
        return 'bulk_buyer';
      case UserRole.consumer:
        return 'consumer';
      case UserRole.deliveryPartner:
        return 'driver';
    }
  }
}
