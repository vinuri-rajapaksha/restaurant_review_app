class Review {
  String id;
  String restaurantId;
  String restaurantName;
  String userId;
  String userEmail;
  int rating;
  String comment;
  String visitType;
  bool recommend;
  String date;

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

// Turns one review from Firebase into a Review object
Review reviewFromFirebase(String id, Map value) {
  return Review(
    id: id,
    restaurantId: value['restaurantId'].toString(),
    restaurantName: value['restaurantName'].toString(),
    userId: value['userId'].toString(),
    userEmail: value['userEmail'].toString(),
    rating: value['rating'],
    comment: value['comment'].toString(),
    visitType: value['visitType'].toString(),
    recommend: value['recommend'] == true,
    date: value['date'].toString(),
  );
}

// This is the blueprint for one review, the same idea as the old Restaurant model you had.

// restaurantId says which restaurant the review is for (r1, r2…). That's how Detail knows which 
// reviews to show.
// userId says who wrote it. That's how My Reviews shows only yours.
// reviewFromFirebase turns Firebase's Map into a neat Review object. It's the same trick you used 
// before.