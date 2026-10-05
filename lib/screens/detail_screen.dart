// DetailScreen: one restaurant's details and its reviews (live from Firebase)
// Opened by tapping a restaurant card (master/detail)
import 'dart:async'; // For StreamSubscription (live connection)
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/resturant.dart';
import '../models/review.dart';

// Stateful because the reviews load and update live
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<Review> allReviews = []; // All reviews from Firebase (filtered in build)
  bool loading = true; // Show the spinner until reviews arrive
  String errorMessage = ''; // '' = no error
  late StreamSubscription subscription; // Live connection to Firebase

  // Runs once when the screen opens
  @override
  void initState() {
    super.initState();

    // READ: listen to all reviews in Firebase (runs again whenever they change)
    subscription = FirebaseDatabase.instance
        .ref('reviews')
        .onValue
        .listen(
          (event) {
            List<Review> loaded = [];

            // Turn each review from Firebase into a Review object
            if (event.snapshot.value != null) {
              Map data = event.snapshot.value as Map;
              data.forEach((key, value) {
                loaded.add(reviewFromFirebase(key.toString(), value));
              });
            }

            // Save the reviews, hide the spinner and rebuild
            setState(() {
              allReviews = loaded;
              loading = false;
            });
          },
          // If loading fails, show an error message
          onError: (error) {
            setState(() {
              errorMessage = 'Could not load reviews. Check your internet.';
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
    // Get the restaurant that was sent from the card (Passing Route Data)
    Restaurant restaurant =
        ModalRoute.of(context)!.settings.arguments as Restaurant;

    // Make a card for each review of THIS restaurant only
    List<Widget> reviewCards = [];
    for (Review r in allReviews) {
      if (r.restaurantId == restaurant.id) {
        // Ternary: turn true/false into text
        String recommendText = r.recommend
            ? 'Recommends 👍'
            : 'Not recommended';
        reviewCards.add(
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                '⭐ ${r.rating} / 5  •  ${r.userEmail}',
              ), // Stars + who wrote it
              subtitle: Text(
                // Comment, then visit type, recommend and date on a new line (\n)
                '${r.comment}\n${r.visitType} • $recommendText • ${r.date}',
              ),
              isThreeLine: true, // Room for the longer subtitle
            ),
          ),
        );
      }
    }

    // What to show in the reviews section: spinner, error, empty message or list
    Widget reviewsSection;
    if (loading) {
      reviewsSection = const Center(child: CircularProgressIndicator());
    } else if (errorMessage.isNotEmpty) {
      reviewsSection = Text(errorMessage);
    } else if (reviewCards.isEmpty) {
      reviewsSection = const Text('No reviews yet. Be the first!');
    } else {
      reviewsSection = Column(children: reviewCards);
    }

    return Scaffold(
      appBar: AppBar(title: Text(restaurant.name)),

      // ListView so the whole page scrolls
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Photo with Hero animation (same tag as the card's photo)
          Hero(
            tag: restaurant.id,
            child: Image.network(
              restaurant.imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover, // Fill the space without stretching
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.broken_image,
                  size: 80,
                ); // If the link fails
              },
            ),
          ),
          const SizedBox(height: 16),

          // Restaurant name (theme's large text style)
          Text(
            restaurant.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),

          // Cuisine shown as a Chip
          Wrap(spacing: 8, children: [Chip(label: Text(restaurant.cuisine))]),

          // Address with a location icon (Expanded lets long text wrap)
          Row(
            children: [
              const Icon(Icons.location_on),
              const SizedBox(width: 8),
              Expanded(child: Text(restaurant.address)),
            ],
          ),
          const SizedBox(height: 16),

          // Opens the review form and passes this restaurant along
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/write-review',
                arguments: restaurant,
              );
            },
            icon: const Icon(Icons.rate_review),
            label: const Text('Write a review'),
          ),
          const SizedBox(height: 16),

          // Reviews heading and the reviews section from above
          Text('Reviews', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          reviewsSection,
        ],
      ),
    );
  }
}
