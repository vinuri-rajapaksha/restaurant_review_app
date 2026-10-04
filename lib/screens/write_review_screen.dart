import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/resturant.dart';

class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({super.key});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  TextEditingController commentController = TextEditingController();
  double rating = 3;
  List<String> visitTypes = ['Dine-in', 'Takeaway', 'Delivery'];
  String visitType = 'Dine-in';
  bool recommend = true;
  bool saving = false;

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void saveReview(Restaurant restaurant) async {
    if (commentController.text.isEmpty) {
      showMessage('Please write a comment');
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await FirebaseDatabase.instance.ref('reviews').push().set({
        'restaurantId': restaurant.id,
        'restaurantName': restaurant.name,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'userEmail': FirebaseAuth.instance.currentUser!.email.toString(),
        'rating': rating.round(),
        'comment': commentController.text,
        'visitType': visitType,
        'recommend': recommend,
        'date': DateTime.now().toString().substring(0, 10),
      });
      if (!mounted) return;
      showMessage('Review posted!');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showMessage('Could not post review. Please try again.');
      setState(() {
        saving = false;
      });
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Which restaurant are we reviewing?
    Restaurant restaurant =
        ModalRoute.of(context)!.settings.arguments as Restaurant;

    return Scaffold(
      appBar: AppBar(title: const Text('Write a Review')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(restaurant.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          Text('Rating: ${rating.round()} stars'),
          Slider(
            value: rating,
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (value) {
              setState(() {
                rating = value;
              });
            },
          ),

          const Text('How did you visit?'),
          DropdownButton<String>(
            value: visitType,
            isExpanded: true,
            items: visitTypes.map((v) {
              return DropdownMenuItem(value: v, child: Text(v));
            }).toList(),
            onChanged: (value) {
              setState(() {
                visitType = value!;
              });
            },
          ),

          SwitchListTile(
            title: const Text('Would you recommend it?'),
            value: recommend,
            onChanged: (value) {
              setState(() {
                recommend = value;
              });
            },
          ),

          TextField(
            controller: commentController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Your comment'),
          ),
          const SizedBox(height: 24),

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

// The restaurant arrives through route arguments (ModalRoute...), just like the Detail screen.
// The form covers the marks: a text box (comment), a dropdown (visit type) and a switch (recommend) 
// make 3 field types, and the slider (rating) is the extra component.
// push().set({...}) saves a new review under reviews in Firebase. It stores restaurantId 
// (which restaurant) and userId (who wrote it).
// DateTime.now().toString().substring(0, 10) saves today's date. DateTime.now() gives something like 
// 2026-09-30 14:22:05.123, and substring(0, 10) keeps just the first 10 characters: 2026-09-30. 
// That connects to your Formatting & Showing Dates lesson.
// After posting, Navigator.pop takes you back to the Detail page.