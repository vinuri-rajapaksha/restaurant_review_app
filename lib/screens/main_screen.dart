// MainScreen: the screen after login, with the bottom navigation bar (4 tabs)
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'nearby_screen.dart';
import 'profile_screen.dart';
import 'my_reviews_screen.dart';

// Stateful because it must remember which tab is selected
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Which tab is open: 0 = Home, 1 = Nearby, 2 = My Reviews, 3 = Profile
  int currentIndex = 0;

  // The 4 tab screens, in the same order as the tabs
  List<Widget> pages = [
    const HomeScreen(),
    const NearbyScreen(),
    const MyReviewsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Show the screen for the selected tab
      body: pages[currentIndex],

      // Material 3 bottom navigation bar
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex, // Highlight the open tab
        // When a tab is tapped, save its number and rebuild the screen
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
        },

        // The 4 tab buttons (icon + text label)
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.near_me), label: 'Nearby'),
          NavigationDestination(
            icon: Icon(Icons.rate_review),
            label: 'My Reviews',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
