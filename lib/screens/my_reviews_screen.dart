// MyReviewsScreen (tab 3): the logged-in user's own reviews,
// with UPDATE (edit) and DELETE through pop-up dialogs
import 'dart:async'; // For StreamSubscription (live connection)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/review.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  List<Review> myReviews = []; // Only the logged-in user's reviews
  bool loading = true; // Show the spinner until data arrives
  String errorMessage = ''; // '' = no error
  late StreamSubscription subscription; // Live connection to Firebase
  String userId = FirebaseAuth.instance.currentUser!.uid; // Who is logged in

  // Runs once when the tab opens
  @override
  void initState() {
    super.initState();

    // READ: listen to all reviews, but keep only the ones I wrote
    subscription = FirebaseDatabase.instance
        .ref('reviews')
        .onValue
        .listen(
          (event) {
            List<Review> loaded = [];

            if (event.snapshot.value != null) {
              Map data = event.snapshot.value as Map;
              data.forEach((key, value) {
                Review r = reviewFromFirebase(key.toString(), value);
                if (r.userId == userId) {
                  loaded.add(r); // Only my reviews
                }
              });
            }

            // Save the list, hide the spinner and rebuild
            setState(() {
              myReviews = loaded;
              loading = false;
            });
          },
          // If loading fails, show an error message
          onError: (error) {
            setState(() {
              errorMessage =
                  'Could not load your reviews. Check your internet.';
              loading = false;
            });
          },
        );
  }

  // Stop listening to Firebase when leaving the tab (widget lifecycle)
  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  // Helper: show a message bar at the bottom of the screen
  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // UPDATE: edit the comment in a pop-up dialog
  void editReview(Review review) {
    // Text box that starts with the old comment
    TextEditingController commentController = TextEditingController(
      text: review.comment,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Edit review for ${review.restaurantName}'),
          content: TextField(
            controller: commentController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Your comment'),
          ),
          actions: [
            // Cancel: just close the pop-up
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            // Save: update only the comment of THIS review in Firebase
            TextButton(
              onPressed: () {
                FirebaseDatabase.instance.ref('reviews/${review.id}').update({
                  'comment': commentController.text,
                });
                Navigator.pop(dialogContext); // Close the pop-up
                showMessage('Review updated!');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // DELETE: ask for confirmation first, then remove the review
  void deleteReview(Review review) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete review?'),
          content: Text('Delete your review for ${review.restaurantName}?'),
          actions: [
            // Cancel: just close the pop-up
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            // Delete: remove THIS review from Firebase
            TextButton(
              onPressed: () {
                FirebaseDatabase.instance.ref('reviews/${review.id}').remove();
                Navigator.pop(dialogContext); // Close the pop-up
                showMessage('Review deleted');
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    // Spinner, error, empty message or the list
    if (loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (errorMessage.isNotEmpty) {
      body = Center(child: Text(errorMessage));
    } else if (myReviews.isEmpty) {
      body = const Center(child: Text('You have not written any reviews yet.'));
    } else {
      // One card per review
      body = ListView.builder(
        itemCount: myReviews.length,
        itemBuilder: (context, index) {
          Review review = myReviews[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(review.restaurantName),
              subtitle: Text(
                '⭐ ${review.rating} / 5\n${review.comment}',
              ), // \n = new line
              isThreeLine: true,

              // Edit and Delete buttons on the right
              trailing: Row(
                mainAxisSize: MainAxisSize.min, // Keep the Row small
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      editReview(review);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      deleteReview(review);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Reviews')),
      body: body,
    );
  }
}
