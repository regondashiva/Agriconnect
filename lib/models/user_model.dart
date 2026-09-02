enum UserRole { farmer, fpo, bulkBuyer, consumer }

class User {
  final String id;
  final String name;
  final String phoneNumber;
  final UserRole role;
  final String location;
  final String? preferredLanguage;
  final String? fpoCluster;
  final String? businessName;

  const User({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.role,
    required this.location,
    this.preferredLanguage = 'Telugu / English',
    this.fpoCluster,
    this.businessName,
  });

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
    }
  }
}
