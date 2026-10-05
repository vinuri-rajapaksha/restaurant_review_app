// RegisterScreen: lets new users create an account with Firebase Authentication
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Stateful because it shows a spinner and error messages
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Read what the user types in the text boxes
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool loading = false; // True while creating the account (shows the spinner)
  String errorMessage = ''; // Red error text ('' = no error)

  // Runs when the Create Account button is pressed
  void register() async {
    // 1. Stop if a box is empty
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter an email and password';
      });
      return;
    }

    // 2. Firebase needs passwords of at least 6 characters
    if (passwordController.text.length < 6) {
      setState(() {
        errorMessage = 'Password must be at least 6 characters';
      });
      return;
    }

    // 3. Show the spinner and clear old errors
    setState(() {
      loading = true;
      errorMessage = '';
    });

    try {
      // 4. Ask Firebase to create a new account, and wait for the answer
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(), // trim() removes extra spaces
        password: passwordController.text,
      );

      if (!mounted) return; // Stop if this screen was closed while waiting

      // Show a success message at the bottom of the screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Please log in.')),
      );

      // Close Register and go back to Login
      Navigator.pop(context);
    } catch (e) {
      // 5. Failed (e.g. email already used): show an error and hide the spinner
      setState(() {
        errorMessage = 'Could not create account. Try a different email.';
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
      appBar: AppBar(
        title: const Text('Register'),
      ), // Back arrow returns to Login
      // ListView so the page scrolls when the keyboard opens
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Register icon
          const Icon(Icons.person_add, size: 80, color: Colors.deepOrange),
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
              labelText: 'Password (at least 6 characters)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Error message in the theme's error colour
          Text(
            errorMessage,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 16),

          // Ternary: spinner while loading, otherwise the Create Account button
          loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: register,
                  child: const Text('Create Account'),
                ),
        ],
      ),
    );
  }
}
