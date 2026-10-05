import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class UserLocation {
  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.label,
    this.isGps = false,
  });

  final double latitude;
  final double longitude;
  final String label;
  final bool isGps;

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'label': label,
    'isGps': isGps,
  };

  factory UserLocation.fromJson(Map<String, dynamic> j) => UserLocation(
    latitude: (j['latitude'] as num).toDouble(),
    longitude: (j['longitude'] as num).toDouble(),
    label: (j['label'] ?? '').toString(),
    isGps: j['isGps'] == true,
  );
}

class PhilippineHubs {
  static const taguig = UserLocation(
    latitude: 14.5547,
    longitude: 121.0244,
    label: 'Taguig / BGC',
  );
  static const makati = UserLocation(
    latitude: 14.5583,
    longitude: 121.0183,
    label: 'Makati City',
  );
  static const manila = UserLocation(
    latitude: 14.5995,
    longitude: 120.9842,
    label: 'City of Manila',
  );
  static const quezonCity = UserLocation(
    latitude: 14.6760,
    longitude: 121.0437,
    label: 'Quezon City',
  );
  static const cebu = UserLocation(
    latitude: 10.3297,
    longitude: 123.9063,
    label: 'Cebu IT Park',
  );
  static const davao = UserLocation(
    latitude: 7.0707,
    longitude: 125.6087,
    label: 'Davao City',
  );
  static const clark = UserLocation(
    latitude: 15.1450,
    longitude: 120.5887,
    label: 'Clark / Angeles',
  );
  static const iloilo = UserLocation(
    latitude: 10.7202,
    longitude: 122.5621,
    label: 'Iloilo City',
  );

  static const defaultHub = taguig;
  static const all = [taguig, makati, manila, quezonCity, cebu, davao, clark, iloilo];
}

double computeHaversineDistanceKm(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const earthRadiusKm = 6371.0;
  final dLat = (lat2 - lat1) * (pi / 180.0);
  final dLon = (lon2 - lon1) * (pi / 180.0);
  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * (pi / 180.0)) *
          cos(lat2 * (pi / 180.0)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusKm * c;
}

String resolveClosestHub(double lat, double lon) {
  UserLocation? nearest;
  double minDistance = double.infinity;
  for (final hub in PhilippineHubs.all) {
    final d = computeHaversineDistanceKm(lat, lon, hub.latitude, hub.longitude);
    if (d < minDistance) {
      minDistance = d;
      nearest = hub;
    }
  }
  if (nearest != null && minDistance < 40.0) {
    return nearest.label;
  }
  return '${lat.toStringAsFixed(2)}°, ${lon.toStringAsFixed(2)}°';
}

class LocationService {
  const LocationService();

  Future<UserLocation?> detectCoarseLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 4),
        ),
      );

      final closest = resolveClosestHub(position.latitude, position.longitude);
      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        label: closest,
        isGps: true,
      );
    } catch (e) {
      debugPrint('Location detection exception: $e');
      return null;
    }
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return const LocationService();
});

class UserLocationNotifier extends Notifier<UserLocation?> {
  @override
  UserLocation? build() => null;

  void setLocation(UserLocation location) {
    state = location;
  }

  void clear() {
    state = null;
  }

  Future<bool> detectLocation() async {
    final service = ref.read(locationServiceProvider);
    final loc = await service.detectCoarseLocation();
    if (loc != null) {
      state = loc;
      return true;
    }
    return false;
  }
}

final userLocationProvider = NotifierProvider<UserLocationNotifier, UserLocation?>(
  UserLocationNotifier.new,
);
