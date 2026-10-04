import 'dart:async';
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
  List<Restaurant> restaurants = [];
  bool loading = true;
  String errorMessage = '';
  late StreamSubscription subscription;

  String searchText = '';
  String selectedCuisine = 'All';

  @override
  void initState() {
    super.initState();

    // Listen to the restaurants in Firebase
    subscription = FirebaseDatabase.instance
        .ref('restaurants')
        .onValue
        .listen(
          (event) {
            List<Restaurant> loaded = [];

            if (event.snapshot.value != null) {
              Map data = event.snapshot.value as Map;
              data.forEach((key, value) {
                loaded.add(restaurantFromFirebase(key.toString(), value));
              });
            }

            // A to Z by name
            loaded.sort((a, b) => a.name.compareTo(b.name));

            setState(() {
              restaurants = loaded;
              loading = false;
            });
          },
          onError: (error) {
            setState(() {
              errorMessage = 'Could not load restaurants. Check your internet.';
              loading = false;
            });
          },
        );
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // How should the list look on this screen?
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

    // Make a list of only the restaurants that match
    List<Restaurant> shown = [];
    for (Restaurant r in restaurants) {
      bool cuisineMatches =
          selectedCuisine == 'All' || r.cuisine == selectedCuisine;
      bool nameMatches = r.name.toLowerCase().contains(
        searchText.toLowerCase(),
      );
      if (cuisineMatches && nameMatches) {
        shown.add(r);
      }
    }

    // What to show under the search bar
    Widget listArea;
    if (loading) {
      listArea = const Center(child: CircularProgressIndicator());
    } else if (errorMessage.isNotEmpty) {
      listArea = Center(child: Text(errorMessage));
    } else if (shown.isEmpty) {
      listArea = const Center(child: Text('No restaurants found'));
    } else {
      listArea = GridView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: shown.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisExtent: 300,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: selectedCuisine,
              isExpanded: true,
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
          Expanded(child: listArea),
        ],
      ),
    );
  }
}
