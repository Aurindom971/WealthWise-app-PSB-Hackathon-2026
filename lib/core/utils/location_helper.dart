import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';

class LocationResult {
  final Position? position;
  final String? city;
  final String? state;
  final String? country;
  final String? error;
  final bool isSuccess;

  LocationResult({
    this.position,
    this.city,
    this.state,
    this.country,
    this.error,
    required this.isSuccess,
  });
}

class LocationHelper {
  /// Requests permission and fetches the current location.
  /// Returns a [LocationResult] containing either coordinates/address or an error.
  static Future<LocationResult> getMandatoryLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          isSuccess: false,
          error: 'Location services are disabled. Please enable GPS to proceed.',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult(
            isSuccess: false,
            error: 'Location permission denied. This app requires location for security.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          isSuccess: false,
          error: 'Location permissions are permanently denied. Please enable them in settings.',
        );
      }

      // Fetch Position with a strict timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Fetch AddressDetails with a very short timeout (Reverse Geocoding)
      String? city;
      String? state;
      String? country;

      try {
        final List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 3));
        
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          city = place.locality ?? place.subAdministrativeArea;
          state = place.administrativeArea;
          country = place.country;
        }
      } catch (e) {
        debugPrint('Geocoding Timeout or Error: $e');
        // Fallback: We have the position, so we proceed even if address resolution fails
      }

      return LocationResult(
        isSuccess: true,
        position: position,
        city: city ?? 'Locating...',
        state: state ?? 'Locating...',
        country: country ?? 'Locating...',
      );
    } catch (e) {
      return LocationResult(
        isSuccess: false,
        error: 'Security Error: Could not verify location ($e)',
      );
    }
  }
}
