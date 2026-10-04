import 'dart:async';
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
  List<Review> myReviews = [];
  bool loading = true;
  String errorMessage = '';
  late StreamSubscription subscription;
  String userId = FirebaseAuth.instance.currentUser!.uid;

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
                Review r = reviewFromFirebase(key.toString(), value);
                if (r.userId == userId) {
                  loaded.add(r);
                }
              });
            }

            setState(() {
              myReviews = loaded;
              loading = false;
            });
          },
          onError: (error) {
            setState(() {
              errorMessage =
                  'Could not load your reviews. Check your internet.';
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

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // UPDATE: change the comment in a pop-up
  void editReview(Review review) {
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
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseDatabase.instance.ref('reviews/${review.id}').update({
                  'comment': commentController.text,
                });
                Navigator.pop(dialogContext);
                showMessage('Review updated!');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // DELETE: ask first, then remove
  void deleteReview(Review review) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete review?'),
          content: Text('Delete your review for ${review.restaurantName}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseDatabase.instance.ref('reviews/${review.id}').remove();
                Navigator.pop(dialogContext);
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

    if (loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (errorMessage.isNotEmpty) {
      body = Center(child: Text(errorMessage));
    } else if (myReviews.isEmpty) {
      body = const Center(child: Text('You have not written any reviews yet.'));
    } else {
      body = ListView.builder(
        itemCount: myReviews.length,
        itemBuilder: (context, index) {
          Review review = myReviews[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(review.restaurantName),
              subtitle: Text('⭐ ${review.rating} / 5\n${review.comment}'),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
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

// Listening is the same as on Detail, but it keeps only reviews where userId matches you.
// ✏️ editReview opens a pop-up with your old comment already typed in. Save uses update(...) to 
// change just the comment in Firebase.
// 🗑 deleteReview asks "Delete your review?" Delete uses remove() to delete that review from Firebase.
// reviews/${review.id} means "go to this exact review by its ID."