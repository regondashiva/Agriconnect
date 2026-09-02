import 'package:latlong2/latlong.dart';

enum StopType {
  farmPickup,
  buyerDropoff,
  fpoHub,
  consumerDelivery,
}

enum RouteStatus {
  optimized,
  pickupStarted,
  inTransit,
  arrivedAtBuyer,
  delivered,
}

class RouteStopPoint {
  final String id;
  final String label;
  final String personName;
  final String crop;
  final double quantityKg;
  final String scheduledTime;
  final LatLng location;
  final StopType type;
  final bool isCompleted;

  const RouteStopPoint({
    required this.id,
    required this.label,
    required this.personName,
    required this.crop,
    required this.quantityKg,
    required this.scheduledTime,
    required this.location,
    required this.type,
    this.isCompleted = false,
  });

  String get displayName => personName.isNotEmpty ? '$label ($personName)' : label;
  String get actionText => type == StopType.buyerDropoff ? 'Dropoff: ${quantityKg.toInt()}kg Total' : 'Pickup: ${quantityKg.toInt()}kg $crop';
}

class SmartRouteData {
  final String routeId;
  final String routeName;
  final double totalDistanceKm;
  final double totalCapacityKg;
  final String estimatedDuration;
  final RouteStatus status;
  final List<RouteStopPoint> stops;
  final List<LatLng> polylinePoints;
  final LatLng currentVehiclePosition;

  const SmartRouteData({
    required this.routeId,
    required this.routeName,
    required this.totalDistanceKm,
    required this.totalCapacityKg,
    required this.estimatedDuration,
    required this.status,
    required this.stops,
    required this.polylinePoints,
    required this.currentVehiclePosition,
  });

  String get statusDisplay {
    switch (status) {
      case RouteStatus.optimized:
        return 'Optimized';
      case RouteStatus.pickupStarted:
        return 'Pickup Started';
      case RouteStatus.inTransit:
        return 'In Transit';
      case RouteStatus.arrivedAtBuyer:
        return 'Arrived at Buyer';
      case RouteStatus.delivered:
        return 'Delivered';
    }
  }

  SmartRouteData copyWith({
    RouteStatus? status,
    LatLng? currentVehiclePosition,
  }) {
    return SmartRouteData(
      routeId: routeId,
      routeName: routeName,
      totalDistanceKm: totalDistanceKm,
      totalCapacityKg: totalCapacityKg,
      estimatedDuration: estimatedDuration,
      status: status ?? this.status,
      stops: stops,
      polylinePoints: polylinePoints,
      currentVehiclePosition: currentVehiclePosition ?? this.currentVehiclePosition,
    );
  }
}
