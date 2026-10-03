import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

enum CityLocationProblem {
  denied,
  deniedForever,
  serviceDisabled,
  timedOut,
  unsupportedCity,
  unavailable,
}

class CityLocationException implements Exception {
  const CityLocationException(this.problem);
  final CityLocationProblem problem;
  String get message => switch (problem) {
    CityLocationProblem.denied => 'Nie udzielono zgody na lokalizację. Wybierz miasto ręcznie lub spróbuj ponownie.',
    CityLocationProblem.deniedForever => 'Dostęp do lokalizacji jest zablokowany w ustawieniach telefonu. Możesz wybrać miasto ręcznie.',
    CityLocationProblem.serviceDisabled => 'Lokalizacja telefonu jest wyłączona. Włącz ją w ustawieniach lub wybierz miasto ręcznie.',
    CityLocationProblem.timedOut => 'Nie udało się ustalić miasta w tym czasie. Spróbuj ponownie lub wybierz miasto ręcznie.',
    CityLocationProblem.unsupportedCity => 'Lokalizacja nie wskazuje miasta obsługiwanego w demo. Wybierz ręcznie Kraków lub Warszawę.',
    CityLocationProblem.unavailable => 'Nie udało się ustalić miasta. Wybór ręczny nadal działa. Możesz spróbować ponownie.',
  };
}

abstract interface class CityLocator {
  Future<String> locateCity();
}

// Coordinates exist only during this request. They are neither saved in the
// profile nor sent to our backend. The OS geocoder can use its network service.
class DeviceCityLocator implements CityLocator {
  @override
  Future<String> locateCity() async {
    if (kIsWeb ||
        ![
          TargetPlatform.android,
          TargetPlatform.iOS,
        ].contains(defaultTargetPlatform)) {
      throw const CityLocationException(CityLocationProblem.unavailable);
    }
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const CityLocationException(CityLocationProblem.serviceDisabled);
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw const CityLocationException(CityLocationProblem.deniedForever);
      }
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw const CityLocationException(CityLocationProblem.denied);
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 20),
        ),
      );
      final marks = await Geocoding()
          .placemarkFromCoordinates(
            position.latitude,
            position.longitude,
            locale: const Locale('pl', 'PL'),
          )
          .timeout(const Duration(seconds: 10));
      // Do not guess the closest city or confuse a district with a city.
      if (marks.isNotEmpty) {
        final city = supportedDemoCity(
          countryCode: marks.first.isoCountryCode,
          locality: marks.first.locality,
        );
        if (city != null) return city;
      }
      throw const CityLocationException(CityLocationProblem.unsupportedCity);
    } on CityLocationException {
      rethrow;
    } on TimeoutException {
      throw const CityLocationException(CityLocationProblem.timedOut);
    } on LocationServiceDisabledException {
      throw const CityLocationException(CityLocationProblem.serviceDisabled);
    } catch (_) {
      throw const CityLocationException(CityLocationProblem.unavailable);
    }
  }
}

String? supportedDemoCity({String? countryCode, String? locality}) {
  if (countryCode?.trim().toUpperCase() != 'PL') return null;
  return switch (locality?.trim().toLowerCase()) {
    'kraków' || 'krakow' || 'cracow' => 'krakow',
    'warszawa' || 'warsaw' => 'warsaw',
    _ => null,
  };
}
