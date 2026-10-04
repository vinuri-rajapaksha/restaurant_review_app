import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/resturant.dart';
import '../models/review.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<Review> allReviews = [];
  bool loading = true;
  String errorMessage = '';
  late StreamSubscription subscription;

  @override
  void initState() {
    super.initState();

    subscription = FirebaseDatabase.instance
        .ref('reviews')
        .onValue
        .listen(
          (event) {
            List<Review> loaded = [];

            if (event.snapshot.value != null) {
              Map data = event.snapshot.value as Map;
              data.forEach((key, value) {
                loaded.add(reviewFromFirebase(key.toString(), value));
              });
            }

            setState(() {
              allReviews = loaded;
              loading = false;
            });
          },
          onError: (error) {
            setState(() {
              errorMessage = 'Could not load reviews. Check your internet.';
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
    Restaurant restaurant =
        ModalRoute.of(context)!.settings.arguments as Restaurant;

    // Make a card for each review of THIS restaurant
    List<Widget> reviewCards = [];
    for (Review r in allReviews) {
      if (r.restaurantId == restaurant.id) {
        String recommendText = r.recommend
            ? 'Recommends 👍'
            : 'Not recommended';
        reviewCards.add(
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text('⭐ ${r.rating} / 5  •  ${r.userEmail}'),
              subtitle: Text(
                '${r.comment}\n${r.visitType} • $recommendText • ${r.date}',
              ),
              isThreeLine: true,
            ),
          ),
        );
      }
    }

    // What to show in the reviews section
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Hero(
            tag: restaurant.id,
            child: Image.network(
              restaurant.imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 80);
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            restaurant.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [Chip(label: Text(restaurant.cuisine))]),
          Row(
            children: [
              const Icon(Icons.location_on),
              const SizedBox(width: 8),
              Expanded(child: Text(restaurant.address)),
            ],
          ),
          const SizedBox(height: 16),

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

          Text('Reviews', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          reviewsSection,
        ],
      ),
    );
  }
}

// initState listens to all reviews in Firebase, the same as your old Home screen did with restaurants. 
// Whenever a review is added, edited or deleted anywhere, this list updates by itself.
// In build, a for loop keeps only reviews where restaurantId matches this restaurant, and turns each 
// one into a Card with a ListTile:
// The title shows the stars and who wrote it.
// The subtitle shows the comment, then the visit type, recommend and date. \n means "new line."
// reviewsSection uses the same if / else if pattern: spinner, error, "No reviews yet", or the list.
// "Write a review" opens the form and passes the restaurant along with arguments:. That's Passing 
// Route Data again.