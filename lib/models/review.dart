// Review model: the blueprint for one review,
// plus a helper to read reviews from Firebase

class Review {
  String
  id; // Unique ID made by Firebase (push). Used to edit/delete this review
  String
  restaurantId; // Which restaurant it's for (r1, r2...). Detail filters by this
  String restaurantName; // Saved so My Reviews can show the name directly
  String
  userId; // Who wrote it (Firebase Auth ID). Used by My Reviews and security rules
  String userEmail; // Shown on the review
  int rating; // 1 to 5 stars (from the slider)
  String comment; // The written review (from the text box)
  String visitType; // Dine-in, Takeaway or Delivery (from the dropdown)
  bool recommend; // true or false (from the switch)
  String date; // Date posted, e.g. 2026-10-04

  // Constructor: every field is required
  Review({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.userId,
    required this.userEmail,
    required this.rating,
    required this.comment,
    required this.visitType,
    required this.recommend,
    required this.date,
  });
}

// Turns one review from Firebase (a Map) into a Review object
// Used by the Detail and My Reviews screens
Review reviewFromFirebase(String id, Map value) {
  return Review(
    id: id, // The Firebase key made by push()
    restaurantId: value['restaurantId'].toString(),
    restaurantName: value['restaurantName'].toString(),
    userId: value['userId'].toString(),
    userEmail: value['userEmail'].toString(),
    rating: value['rating'], // Already a whole number
    comment: value['comment'].toString(),
    visitType: value['visitType'].toString(),
    recommend: value['recommend'] == true, // Makes sure it's true or false
    date: value['date'].toString(),
  );
}
