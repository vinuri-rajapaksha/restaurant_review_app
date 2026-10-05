// WriteReviewScreen: form to CREATE a new review for a restaurant
// Opened from the Detail screen's "Write a review" button
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/resturant.dart';

// Stateful because the form values change and it shows a spinner while saving
class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({super.key});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  TextEditingController commentController =
      TextEditingController(); // Comment box
  double rating = 3; // Slider value (starts at 3 stars)
  List<String> visitTypes = [
    'Dine-in',
    'Takeaway',
    'Delivery',
  ]; // Dropdown choices
  String visitType = 'Dine-in'; // Chosen visit type
  bool recommend = true; // Switch (on by default)
  bool saving = false; // True while posting (shows the spinner)

  // Helper: show a message bar at the bottom of the screen
  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // CREATE: runs when Post Review is pressed
  void saveReview(Restaurant restaurant) async {
    // 1. Stop if the comment is empty
    if (commentController.text.isEmpty) {
      showMessage('Please write a comment');
      return;
    }

    // 2. Show the spinner
    setState(() {
      saving = true;
    });

    try {
      // 3. push() makes a new review with a unique ID, set() saves the data
      await FirebaseDatabase.instance.ref('reviews').push().set({
        'restaurantId': restaurant.id, // Which restaurant
        'restaurantName': restaurant.name,
        'userId': FirebaseAuth
            .instance
            .currentUser!
            .uid, // Who wrote it (checked by security rules)
        'userEmail': FirebaseAuth.instance.currentUser!.email.toString(),
        'rating': rating.round(), // Whole number 1-5
        'comment': commentController.text,
        'visitType': visitType,
        'recommend': recommend,
        'date': DateTime.now().toString().substring(
          0,
          10,
        ), // Today's date, e.g. 2026-10-04
      });

      if (!mounted) return; // Stop if this screen was closed while waiting
      showMessage('Review posted!');
      Navigator.pop(context); // Back to Detail (the new review appears live)
    } catch (e) {
      // 4. Saving failed: show a message and hide the spinner
      if (!mounted) return;
      showMessage('Could not post review. Please try again.');
      setState(() {
        saving = false;
      });
    }
  }

  // Clean up the controller when the screen closes (widget lifecycle)
  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the restaurant sent from the Detail screen (Passing Route Data)
    Restaurant restaurant =
        ModalRoute.of(context)!.settings.arguments as Restaurant;

    return Scaffold(
      appBar: AppBar(title: const Text('Write a Review')),

      // ListView so the form scrolls when the keyboard opens
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Name of the restaurant being reviewed
          Text(restaurant.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          // SLIDER (additional component): rating from 1 to 5 whole stars
          Text('Rating: ${rating.round()} stars'),
          Slider(
            value: rating,
            min: 1,
            max: 5,
            divisions: 4, // Snaps to whole stars
            onChanged: (value) {
              setState(() {
                rating = value;
              });
            },
          ),

          // DROPDOWN (field type 1): visit type
          const Text('How did you visit?'),
          DropdownButton<String>(
            value: visitType,
            isExpanded: true,
            // Turn each choice into a menu option
            items: visitTypes.map((v) {
              return DropdownMenuItem(value: v, child: Text(v));
            }).toList(),
            onChanged: (value) {
              setState(() {
                visitType = value!;
              });
            },
          ),

          // SWITCH (field type 2): would you recommend it?
          SwitchListTile(
            title: const Text('Would you recommend it?'),
            value: recommend,
            onChanged: (value) {
              setState(() {
                recommend = value;
              });
            },
          ),

          // TEXT FIELD (field type 3): the written comment
          TextField(
            controller: commentController,
            maxLines: 3, // Taller box for longer text
            decoration: const InputDecoration(labelText: 'Your comment'),
          ),
          const SizedBox(height: 24),

          // Ternary: spinner while saving, otherwise the Post Review button
          saving
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: () {
                    saveReview(restaurant);
                  },
                  child: const Text('Post Review'),
                ),
        ],
      ),
    );
  }
}
