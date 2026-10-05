// LoginScreen: lets existing users log in with Firebase Authentication
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Stateful because it shows a spinner and error messages
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Read what the user types in the text boxes
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool loading = false; // True while logging in (shows the spinner)
  String errorMessage = ''; // Red error text ('' = no error)

  // Runs when the Login button is pressed
  void login() async {
    // 1. Stop if a box is empty
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your email and password';
      });
      return;
    }

    // 2. Show the spinner and clear old errors
    setState(() {
      loading = true;
      errorMessage = '';
    });

    try {
      // 3. Ask Firebase to log in, and wait for the answer
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(), // trim() removes extra spaces
        password: passwordController.text,
      );

      if (!mounted) return; // Stop if this screen was closed while waiting

      // Open the main app and replace Login (Back won't return here)
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      // 4. Login failed: show an error and hide the spinner
      setState(() {
        errorMessage = 'Login failed. Check your email and password.';
        loading = false;
      });
    }
  }

  // Clean up the controllers when the screen closes (widget lifecycle)
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),

      // ListView so the page scrolls when the keyboard opens
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // App logo
          const Icon(Icons.restaurant, size: 80, color: Colors.deepOrange),
          const SizedBox(height: 24),

          // Email box (keyboard with the @ key)
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Password box (obscureText shows dots)
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Error message in the theme's error colour (works in light and dark mode)
          Text(
            errorMessage,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 16),

          // Ternary: show the spinner while loading, otherwise the Login button
          loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(onPressed: login, child: const Text('Login')),

          // Link to the Register screen (Login stays underneath)
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            child: const Text("Don't have an account? Register"),
          ),
        ],
      ),
    );
  }
}
