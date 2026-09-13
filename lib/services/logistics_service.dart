import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/logistics_route_model.dart';
import 'api_service.dart';

class LogisticsService {
  // Centralized Demo Coordinates (Ranga Reddy rural cluster -> Hyderabad Mandi)
  static const LatLng farmALocation = LatLng(17.3060, 78.1360); // Chevella Village
  static const LatLng farmBLocation = LatLng(17.3450, 78.2380); // Shabad Center Farm
  static const LatLng buyerHubLocation = LatLng(17.3680, 78.5420); // Kothapet Wholesale Mandi

  // Consumer Delivery Demo Locations
  static const LatLng fpoHubLocation = LatLng(17.3200, 78.2000); // Ranga Reddy FPO Hub
  static const LatLng consumerLocation = LatLng(17.4483, 78.3915); // Madhapur, Hyderabad
  static const LatLng vehicleLiveLocation = LatLng(17.3850, 78.3100); // In transit near Gachibowli

  // Realistic Polyline Coordinates for Smart Route (Chevella -> Shabad -> ORR -> Kothapet Mandi = 68 km)
  static final List<LatLng> smartRoutePolyline = [
    const LatLng(17.3060, 78.1360), // Farm A (Ramesh)
    const LatLng(17.3120, 78.1520),
    const LatLng(17.3210, 78.1750),
    const LatLng(17.3320, 78.2050),
    const LatLng(17.3450, 78.2380), // Farm B (Suresh)
    const LatLng(17.3520, 78.2650),
    const LatLng(17.3600, 78.3000), // Appa Junction ORR
    const LatLng(17.3580, 78.3500), // Rajendranagar
    const LatLng(17.3550, 78.4000), // Aramghar
    const LatLng(17.3590, 78.4500), // Chandrayangutta
    const LatLng(17.3640, 78.5000), // LB Nagar Ring Road
    const LatLng(17.3680, 78.5420), // Urban Buyer Hub (Kothapet Mandi)
  ];

  // Consumer Delivery Polyline (FPO Hub -> Madhapur)
  static final List<LatLng> consumerOrderPolyline = [
    const LatLng(17.3200, 78.2000), // FPO Hub
    const LatLng(17.3400, 78.2500),
    const LatLng(17.3650, 78.2900),
    const LatLng(17.3850, 78.3100), // Current Vehicle Position
    const LatLng(17.4100, 78.3450), // Gachibowli junction
    const LatLng(17.4350, 78.3700), // Hitec City
    const LatLng(17.4483, 78.3915), // Consumer Home (Madhapur)
  ];

  /// Standard Google/OSRM Polyline Algorithm Decoder
  static List<LatLng> decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  /// Request dynamic route optimization from backend OSRM microservice
  static Future<SmartRouteData> getOptimizedRoute({
    LatLng? start,
    LatLng? end,
  }) async {
    final startPt = start ?? farmALocation;
    final endPt = end ?? buyerHubLocation;

    try {
      final res = await ApiService.instance.optimizeRoute(
        startCoords: '${startPt.latitude},${startPt.longitude}',
        endCoords: '${endPt.latitude},${endPt.longitude}',
      );

      if (res != null && res is Map) {
        final route = res['route'];
        if (route is Map) {
          final geometry = route['geometry'];
          List<LatLng> decodedPoints = [];
          if (geometry is String && geometry.isNotEmpty) {
            decodedPoints = decodePolyline(geometry);
          } else if (geometry is List) {
            decodedPoints = geometry.map((p) {
              if (p is List && p.length >= 2) {
                return LatLng((p[1] as num).toDouble(), (p[0] as num).toDouble());
              }
              return null;
            }).whereType<LatLng>().toList();
          }

          final distanceMeters = (route['distance'] as num?)?.toDouble() ?? 68000.0;
          final durationSecs = (route['duration'] as num?)?.toInt() ?? 15600;
          final durationHours = durationSecs ~/ 3600;
          final durationMins = (durationSecs % 3600) ~/ 60;

          return SmartRouteData(
            routeId: res['route_id']?.toString() ?? 'ROUTE-SR-7A',
            routeName: 'Route 7A - Farm Deliveries (Optimized)',
            totalDistanceKm: (distanceMeters / 1000.0).roundToDouble(),
            totalCapacityKg: 1000.0,
            estimatedDuration: '${durationHours}h ${durationMins}m',
            status: RouteStatus.optimized,
            currentVehiclePosition: vehicleLiveLocation,
            polylinePoints: decodedPoints.isNotEmpty ? decodedPoints : smartRoutePolyline,
            stops: [
              RouteStopPoint(
                id: 'stop_1',
                label: 'Farm A',
                personName: 'Cluster Farmer A',
                crop: 'Wheat / Tomato',
                quantityKg: 300.0,
                scheduledTime: '10:00 AM',
                location: startPt,
                type: StopType.farmPickup,
                isCompleted: false,
              ),
              const RouteStopPoint(
                id: 'stop_2',
                label: 'Farm B',
                personName: 'Cluster Farmer B',
                crop: 'Wheat / Tomato',
                quantityKg: 700.0,
                scheduledTime: '11:30 AM',
                location: farmBLocation,
                type: StopType.farmPickup,
                isCompleted: false,
              ),
              RouteStopPoint(
                id: 'stop_3',
                label: 'Urban Buyer Hub',
                personName: 'Vikram Mehta',
                crop: 'Produce Lot',
                quantityKg: 1000.0,
                scheduledTime: '2:20 PM',
                location: endPt,
                type: StopType.buyerDropoff,
                isCompleted: false,
              ),
            ],
          );
        }
      }
    } catch (e) {
      debugPrint('[LogisticsService] getOptimizedRoute error / fallback: $e');
    }

    return getDemoSmartRoute();
  }

  /// Standard SIH Smart Route Dataset
  static SmartRouteData getDemoSmartRoute() {
    return SmartRouteData(
      routeId: 'ROUTE-SR-7A',
      routeName: 'Route 7A - Farm Deliveries',
      totalDistanceKm: 68.0,
      totalCapacityKg: 1000.0,
      estimatedDuration: '4h 20m',
      status: RouteStatus.optimized,
      currentVehiclePosition: vehicleLiveLocation,
      polylinePoints: smartRoutePolyline,
      stops: const [
        RouteStopPoint(
          id: 'stop_1',
          label: 'Farm A',
          personName: 'Cluster Farmer A',
          crop: 'Wheat',
          quantityKg: 300.0,
          scheduledTime: '10:00 AM',
          location: farmALocation,
          type: StopType.farmPickup,
          isCompleted: false,
        ),
        RouteStopPoint(
          id: 'stop_2',
          label: 'Farm B',
          personName: 'Cluster Farmer B',
          crop: 'Wheat',
          quantityKg: 700.0,
          scheduledTime: '11:30 AM',
          location: farmBLocation,
          type: StopType.farmPickup,
          isCompleted: false,
        ),
        RouteStopPoint(
          id: 'stop_3',
          label: 'Urban Buyer Hub',
          personName: 'Vikram Mehta',
          crop: 'Wheat',
          quantityKg: 1000.0,
          scheduledTime: '2:20 PM',
          location: buyerHubLocation,
          type: StopType.buyerDropoff,
          isCompleted: false,
        ),
      ],
    );
  }
}
