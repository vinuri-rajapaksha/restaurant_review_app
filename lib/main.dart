import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // My Firebase project settings (made by flutterfire configure)
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/write_review_screen.dart';

// The app starts here
void main() async {
  // Get Flutter ready before connecting to Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Connect to my Firebase project and wait until it's done
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Show the app on screen
  runApp(const MyApp());
}

// The main app widget: sets up themes and screens (routes)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Spot', // App name
      debugShowCheckedModeBanner: false, // Hide the "DEBUG" ribbon
      // Light mode colours, generated from one seed colour
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        brightness: Brightness.light,
      ),

      // Dark mode colours, from the same seed colour
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        brightness: Brightness.dark,
      ),

      // Follow the phone's light/dark setting automatically
      themeMode: ThemeMode.system,

      // The first screen shown when the app opens
      initialRoute: '/login',

      // All named screens in the app (name -> screen)
      // Home, Nearby, My Reviews and Profile are tabs inside MainScreen
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) =>
            const MainScreen(), // Screen with the bottom navigation bar
        '/detail': (context) =>
            const DetailScreen(), // One restaurant's details and reviews
        '/write-review': (context) => const WriteReviewScreen(), // Review form
      },
    );
  }
}
