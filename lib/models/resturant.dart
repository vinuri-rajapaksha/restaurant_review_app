// Restaurant model: the blueprint for one restaurant,
// plus the cuisine list and a helper to read restaurants from Firebase

class Restaurant {
  String id; // Unique ID in Firebase (r1, r2...). Reviews and Hero use it
  String name;
  String cuisine;
  String address;
  String imageUrl; // Link to the photo (shown with Image.network)
  double lat; // Latitude (location)
  double lng; // Longitude (location)
  double distance =
      0; // Not stored in Firebase. Nearby fills it in (-1 = unknown)

  // Constructor: every field is required, so nothing is missed by mistake
  Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.address,
    required this.imageUrl,
    required this.lat,
    required this.lng,
  });
}

// Options for the cuisine dropdown on Home ('All' = no filter)
// Names must match the cuisine values in Firebase exactly
List<String> cuisines = [
  'All',
  'Sri Lankan',
  'Indian',
  'Chinese',
  'Italian',
  'Japanese',
  'Fast Food',
  'Cafe',
];

// Turns one restaurant from Firebase (a Map) into a Restaurant object
// Used by the Home and Nearby screens
Restaurant restaurantFromFirebase(String id, Map value) {
  return Restaurant(
    id: id, // The Firebase key, e.g. 'r1'
    name: value['name'].toString(),
    cuisine: value['cuisine'].toString(),
    address: value['address'].toString(),
    imageUrl: value['imageUrl'].toString(),
    lat: value['lat'].toDouble(), // toDouble() makes sure it's a decimal number
    lng: value['lng'].toDouble(),
  );
}
