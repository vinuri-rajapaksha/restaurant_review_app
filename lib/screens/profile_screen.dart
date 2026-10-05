// ProfileScreen (tab 4): shows who is logged in, with a Sign out button
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Stateless because nothing on this screen changes while it's open
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Log out of Firebase and go back to the Login screen
  void signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Log out and wait until done

    if (!context.mounted) return; // Stop if this screen is already gone

    // Replace the app with Login (Back can't return to the app)
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    // The logged-in user's email (someone is always logged in on this screen)
    String email = FirebaseAuth.instance.currentUser!.email.toString();

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),

      // Everything centred in the middle of the screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 100), // Profile icon
            const SizedBox(height: 8),
            const Text('Logged in as'),
            Text(
              email,
              style: Theme.of(context).textTheme.titleMedium,
            ), // User's email
            const SizedBox(height: 24),

            // Sign out button (icon + text)
            ElevatedButton.icon(
              onPressed: () {
                signOut(context);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
