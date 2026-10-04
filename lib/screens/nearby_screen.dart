import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import '../models/resturant.dart';
import '../widgets/restaurant_card.dart';
import '../location_helper.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  List<Restaurant> nearby = [];
  bool loading = true;
  String note = '';

  @override
  void initState() {
    super.initState();
    loadNearby();
  }

  void loadNearby() async {
    setState(() {
      loading = true;
      note = '';
    });

    List<Restaurant> list = [];
    String newNote = '';

    // 1. Get all restaurants from Firebase (once)
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

    // 2. Where am I? Then sort by distance
    try {
      Position me = await getMyLocation().timeout(const Duration(seconds: 15));
      for (Restaurant r in list) {
        r.distance = Geolocator.distanceBetween(
          me.latitude,
          me.longitude,
          r.lat,
          r.lng,
        );
      }
      list.sort((a, b) => a.distance.compareTo(b.distance));
    } catch (e) {
      // No location: still show every restaurant, just not sorted
      for (Restaurant r in list) {
        r.distance = -1;
      }
      if (newNote.isEmpty) {
        if (e is String) {
          newNote = e;
        } else {
          newNote = 'Could not find your location.';
        }
        newNote = '$newNote Showing all restaurants instead.';
      }
    }

    if (!mounted) return;
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
          // Message box, only when something went wrong
          note.isEmpty
              ? const SizedBox()
              : Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(Icons.location_off),
                    title: Text(note),
                    trailing: TextButton(
                      onPressed: loadNearby,
                      child: const Text('Retry'),
                    ),
                  ),
                ),
          Expanded(
            child: ListView.builder(
              itemCount: nearby.length,
              itemBuilder: (context, index) {
                Restaurant r = nearby[index];
                double km = r.distance / 1000;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    r.distance >= 0
                        ? Padding(
                            padding: const EdgeInsets.only(left: 16, top: 8),
                            child: Text('📍 ${km.toStringAsFixed(1)} km away'),
                          )
                        : const SizedBox(),
                    RestaurantCard(restaurant: r),
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadNearby),
        ],
      ),
      body: body,
    );
  }
}
