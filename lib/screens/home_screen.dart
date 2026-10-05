// HomeScreen (tab 1): all restaurants from Firebase, with search,
// cuisine filter and a responsive grid
import 'dart:async'; // For StreamSubscription (live connection)
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/resturant.dart';
import '../widgets/restaurant_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Restaurant> restaurants = []; // All restaurants from Firebase
  bool loading = true; // Show the spinner until data arrives
  String errorMessage = ''; // '' = no error
  late StreamSubscription
  subscription; // Live connection to Firebase (set in initState)

  String searchText = ''; // What the user typed in the search bar
  String selectedCuisine = 'All'; // Dropdown choice ('All' = no filter)

  // Runs once when the screen opens
  @override
  void initState() {
    super.initState();

    // READ: listen to the restaurants in Firebase (runs again every time they change)
    subscription = FirebaseDatabase.instance
        .ref('restaurants')
        .onValue
        .listen(
          (event) {
            List<Restaurant> loaded = [];

            // Turn each restaurant from Firebase into a Restaurant object
            if (event.snapshot.value != null) {
              Map data = event.snapshot.value as Map;
              data.forEach((key, value) {
                loaded.add(restaurantFromFirebase(key.toString(), value));
              });
            }

            // Sort A to Z by name
            loaded.sort((a, b) => a.name.compareTo(b.name));

            // Save the list, hide the spinner and rebuild the screen
            setState(() {
              restaurants = loaded;
              loading = false;
            });
          },
          // If loading fails, show an error message
          onError: (error) {
            setState(() {
              errorMessage = 'Could not load restaurants. Check your internet.';
              loading = false;
            });
          },
        );
  }

  // Stop listening to Firebase when leaving the screen (widget lifecycle)
  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // RESPONSIVE: phone = 1 column (portrait) / 2 (landscape)
    //             tablet = 2 columns (portrait) / 3 (landscape)
    bool landscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    bool tablet = MediaQuery.of(context).size.shortestSide >= 600;

    int columns = 1;
    if (landscape) {
      columns = 2;
    }
    if (tablet) {
      columns = columns + 1;
    }

    // FILTER: keep only restaurants that match the cuisine AND the search text
    List<Restaurant> shown = [];
    for (Restaurant r in restaurants) {
      bool cuisineMatches =
          selectedCuisine == 'All' || r.cuisine == selectedCuisine;
      bool nameMatches = r.name.toLowerCase().contains(
        searchText.toLowerCase(), // Ignore capital letters
      );
      if (cuisineMatches && nameMatches) {
        shown.add(r);
      }
    }

    // What to show under the search bar: spinner, error, empty message or grid
    Widget listArea;
    if (loading) {
      listArea = const Center(child: CircularProgressIndicator());
    } else if (errorMessage.isNotEmpty) {
      listArea = Center(child: Text(errorMessage));
    } else if (shown.isEmpty) {
      listArea = const Center(child: Text('No restaurants found'));
    } else {
      // Grid of restaurant cards (number of columns depends on the screen)
      listArea = GridView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: shown.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisExtent: 300, // Every card is 300 tall
        ),
        itemBuilder: (context, index) {
          return RestaurantCard(restaurant: shown[index]);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Restaurants')),
      body: Column(
        children: [
          // Search bar: filters the list as the user types
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search restaurants',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),

          // Cuisine dropdown: filters by cuisine
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: selectedCuisine,
              isExpanded: true,
              // Turn each cuisine name into a menu option
              items: cuisines.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCuisine = value!;
                });
              },
            ),
          ),

          // The grid (or spinner/message) fills the rest of the screen
          Expanded(child: listArea),
        ],
      ),
    );
  }
}
