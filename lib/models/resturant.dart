class Restaurant {
  String id;
  String name;
  String cuisine;
  String address;
  String imageUrl;
  double lat;
  double lng;
  double distance = 0;

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

// Turns one restaurant from Firebase into a Restaurant object
Restaurant restaurantFromFirebase(String id, Map value) {
  return Restaurant(
    id: id,
    name: value['name'].toString(),
    cuisine: value['cuisine'].toString(),
    address: value['address'].toString(),
    imageUrl: value['imageUrl'].toString(),
    lat: value['lat'].toDouble(),
    lng: value['lng'].toDouble(),
  );
}
