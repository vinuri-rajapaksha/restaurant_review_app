import 'package:geolocator/geolocator.dart';

// Gets the phone's location, or throws a friendly message if it can't
Future<Position> getMyLocation() async {
  bool serviceOn = await Geolocator.isLocationServiceEnabled();
  if (!serviceOn) {
    throw 'Location is turned off. Please turn it on and try again.';
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied) {
    throw 'Location permission was denied. Tap "Try again" to allow it.';
  }
  if (permission == LocationPermission.deniedForever) {
    throw 'Location is blocked. Please allow it in your phone Settings.';
  }

  try {
    // Ask the GPS, but only wait up to 10 seconds
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high ,
        timeLimit: Duration(seconds: 10),
      ),
    );
  } catch (e) {
    // Backup plan: use the last position the phone remembers
    Position? lastPosition = await Geolocator.getLastKnownPosition();
    if (lastPosition != null) {
      return lastPosition;
    }
    throw 'Could not find your location. Please try again.';
  }
}