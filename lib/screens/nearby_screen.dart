// NearbyScreen (tab 2): uses GPS to sort restaurants from closest to furthest
// If location fails, it still shows every restaurant with a message
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart'; // For distanceBetween
import '../models/resturant.dart';
import '../widgets/restaurant_card.dart';
import '../location_helper.dart'; // getMyLocation()

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  List<Restaurant> nearby =
      []; // Restaurants to show (sorted by distance when possible)
  bool loading = true; // Show the spinner while working
  String note = ''; // Message shown when something went wrong ('' = none)

  // Runs once when the tab opens
  @override
  void initState() {
    super.initState();
    loadNearby();
  }

  // Gets restaurants + location, then sorts by distance
  // Also runs when the user taps refresh or Retry
  void loadNearby() async {
    // Show the spinner and clear the old message
    setState(() {
      loading = true;
      note = '';
    });

    List<Restaurant> list = [];
    String newNote = '';

    // 1. READ: get all restaurants from Firebase (once, not live)
    try {
      DataSnapshot snapshot = await FirebaseDatabase.instance
          .ref('restaurants')
          .get();
      if (snapshot.value != null) {
        Map data = snapshot.value as Map;
        data.forEach((key, value) {
          list.add(restaurantFromFirebase(key.toString(), value));
        });
      }
    } catch (e) {
      newNote = 'Could not load restaurants. Check your internet.';
    }

    // 2. SENSOR: find my location, then sort by distance
    try {
      // Give up after 15 seconds so the screen never spins forever
      Position me = await getMyLocation().timeout(const Duration(seconds: 15));

      // Distance from me to each restaurant (in metres)
      for (Restaurant r in list) {
        r.distance = Geolocator.distanceBetween(
          me.latitude,
          me.longitude,
          r.lat,
          r.lng,
        );
      }

      // Closest first
      list.sort((a, b) => a.distance.compareTo(b.distance));
    } catch (e) {
      // Backup plan: no location, so show every restaurant without distances
      for (Restaurant r in list) {
        r.distance = -1; // -1 = unknown distance
      }
      if (newNote.isEmpty) {
        // Use the friendly message from location_helper if there is one
        if (e is String) {
          newNote = e;
        } else {
          newNote = 'Could not find your location.';
        }
        newNote = '$newNote Showing all restaurants instead.';
      }
    }

    if (!mounted) return; // Stop if the user left the tab while waiting

    // Save the results and hide the spinner
    setState(() {
      nearby = list;
      note = newNote;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (loading) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = Column(
        children: [
          // Message box with a Retry button, only when something went wrong
          note.isEmpty
              ? const SizedBox()
              : Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(Icons.location_off),
                    title: Text(note),
                    trailing: TextButton(
                      onPressed: loadNearby, // Try again
                      child: const Text('Retry'),
                    ),
                  ),
                ),

          // The list fills the rest of the screen
          Expanded(
            child: ListView.builder(
              itemCount: nearby.length,
              itemBuilder: (context, index) {
                Restaurant r = nearby[index];
                double km = r.distance / 1000; // Metres to kilometres
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show the distance only if it's known
                    r.distance >= 0
                        ? Padding(
                            padding: const EdgeInsets.only(left: 16, top: 8),
                            child: Text(
                              '📍 ${km.toStringAsFixed(1)} km away',
                            ), // 1 decimal place
                          )
                        : const SizedBox(),
                    RestaurantCard(restaurant: r), // Same reusable card as Home
                  ],
                );
              },
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby'),
        actions: [
          // Refresh button: find location and sort again
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadNearby),
        ],
      ),
      body: body,
    );
  }
}
