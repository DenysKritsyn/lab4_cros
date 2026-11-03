import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nova_poshta_mail_tracker/core/favorites/favorites_screen.dart';
import 'package:nova_poshta_mail_tracker/core/sign_in/sign_in_screen.dart';
import 'package:nova_poshta_mail_tracker/data/auth/auth_repository.dart';

/// Root widget that listens to Firebase authentication state and restores the
/// user session automatically across app restarts.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static const Color _mainColor = Color(0xFFE22629);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthRepository.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: _mainColor),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const FavoritesScreen();
        }

        return const SignInScreen();
      },
    );
  }
}

