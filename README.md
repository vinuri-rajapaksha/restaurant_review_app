# Food Spot – Restaurant Review App

A Flutter mobile app for discovering local restaurants in Sri Lanka, finding the ones nearest to you with GPS, and sharing reviews with other users. Built for the Mobile Application Development module (Assignment 2).

## Features

- **Login and Register** with Firebase Authentication (email and password)
- **Browse restaurants** loaded live from Firebase Realtime Database, with photos
- **Search** restaurants by name and **filter** by cuisine
- **Nearby**: uses the device's GPS to sort restaurants from closest to furthest and show the distance in km
- **Restaurant details** with all reviews for that restaurant, updated in real time
- **Write a review** with a star rating, visit type, a "would you recommend" switch and a comment
- **My Reviews**: view, edit and delete your own reviews
- **Light and dark mode** that follows the device setting
- **Responsive layout**: the restaurant grid changes columns for portrait, landscape, phone and tablet
- **Hero animation** when opening a restaurant

## Screens

| Screen | Purpose |
|---|---|
| Login / Register | Sign in or create an account |
| Home | All restaurants with search and cuisine filter |
| Nearby | Restaurants sorted by distance from the user |
| My Reviews | The logged-in user's reviews, with edit and delete |
| Profile | Account email and sign out |
| Restaurant Detail | Restaurant info, reviews and a "Write a review" button |
| Write Review | Review form |

<!-- Add screenshots here, for example:
![Home screen](screenshots/home.png)
-->

## Built With

- [Flutter](https://flutter.dev) and Dart
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Firebase Realtime Database](https://firebase.google.com/docs/database)
- [geolocator](https://pub.dev/packages/geolocator) for GPS location
- Material Design 3

## Firebase Data Structure

```
restaurants
   r1: { name, cuisine, address, imageUrl, lat, lng }
   ...
reviews
   <auto-id>: { restaurantId, restaurantName, userId, userEmail,
                rating, comment, visitType, recommend, date }
```

Restaurant photos are internet-hosted images whose URLs are stored in each restaurant record (`imageUrl`).

## CRUD Operations (Reviews)

| Operation | Where in the app |
|---|---|
| Create | Restaurant Detail → Write a review → Post Review |
| Read | Restaurant Detail and My Reviews (real-time) |
| Update | My Reviews → edit icon → Save |
| Delete | My Reviews → delete icon → confirm |

## Security Rules

- Only logged-in users can read data.
- Restaurants are read-only.
- Users can only create reviews in their own name, and can only edit or delete their own reviews.

## Project Structure

```
lib/
  main.dart                  App entry, themes and routes
  location_helper.dart       GPS permission and location logic
  models/
    resturant.dart           Restaurant model and cuisine list
    review.dart              Review model
  screens/
    login_screen.dart
    register_screen.dart
    main_screen.dart         Bottom navigation (4 tabs)
    home_screen.dart
    nearby_screen.dart
    my_reviews_screen.dart
    profile_screen.dart
    detail_screen.dart
    write_review_screen.dart
  widgets/
    restaurant_card.dart     Reusable restaurant card
```

## Getting Started

### Requirements

- Flutter SDK
- Android Studio (for the Android emulator)
- An Android emulator or Android phone

### Run the app

```bash
git clone <this-repository-url>
cd restaurant_review_app
flutter pub get
flutter run
```

### Testing GPS on the emulator

The emulator has no real GPS. Open the emulator's **Extended Controls (•••) → Location**, choose a place (for example, Colombo) and click **Set Location** before opening the Nearby tab.

## Testing

The app was tested manually with a 31-case test plan covering login and registration, navigation, search and filtering, real-time updates, review CRUD, security rules, GPS permission handling, orientation, tablet layout and dark mode. All tests passed.

## Author

Vinuri Rajapaksha – Mobile Application Development