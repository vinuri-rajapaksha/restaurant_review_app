// location_helper.dart: all the GPS logic in one place
// Used by the Nearby screen to find the user's location
import 'package:geolocator/geolocator.dart';

// Gets the phone's location, or throws a friendly message if it can't
// Future = takes a moment, so the caller must await it
Future<Position> getMyLocation() async {
  // 1. Is location switched on in the phone?
  bool serviceOn = await Geolocator.isLocationServiceEnabled();
  if (!serviceOn) {
    // throw = stop and send this message back to the caller
    throw 'Location is turned off. Please turn it on and try again.';
  }

  // 2. Do we have permission? If not yet, ask (shows Android's pop-up)
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  // 3. The user said no this time
  if (permission == LocationPermission.denied) {
    throw 'Location permission was denied. Tap "Retry" to allow it.';
  }
  // The user blocked it completely (the app can't ask again)
  if (permission == LocationPermission.deniedForever) {
    throw 'Location is blocked. Please allow it in your phone Settings.';
  }

  try {
    // 4. Ask the GPS for the current position, but wait at most 10 seconds
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high, // Use the real GPS
        timeLimit: Duration(seconds: 10), // Never wait forever
      ),
    );
  } catch (e) {
    // 5. Backup plan: use the last position the phone remembers
    Position? lastPosition =
        await Geolocator.getLastKnownPosition(); // ? = might be empty
    if (lastPosition != null) {
      return lastPosition;
    }
    throw 'Could not find your location. Please try again.';
  }
}
