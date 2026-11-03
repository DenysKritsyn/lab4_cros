import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nova_poshta_mail_tracker/core/auth_gate.dart';
import 'package:nova_poshta_mail_tracker/core/change_password/change_password_screen.dart';
import 'package:nova_poshta_mail_tracker/core/edit_profile/edit_profile_screen.dart';
import 'package:nova_poshta_mail_tracker/core/profile/widgets/edit_profile_button.dart';
import 'package:nova_poshta_mail_tracker/core/profile/widgets/profile_actions.dart';
import 'package:nova_poshta_mail_tracker/core/profile/widgets/profile_avatar.dart';
import 'package:nova_poshta_mail_tracker/core/text_styles.dart';
import 'package:nova_poshta_mail_tracker/core/widgets/account_bottom_navigation.dart';
import 'package:nova_poshta_mail_tracker/core/widgets/account_header.dart';
import 'package:nova_poshta_mail_tracker/core/widgets/saved_phone_card.dart';
import 'package:nova_poshta_mail_tracker/data/auth/auth_exception.dart';
import 'package:nova_poshta_mail_tracker/data/auth/auth_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Main application color
  static const Color applicationMainColor = Color(0xFFE22629);

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),

      body: SafeArea(
        child: Column(
          children: [
            // Logo, screen title and account
            AccountHeader(
              title: 'Профіль',
              mainColor: applicationMainColor,
              onAccountPressed: () {},
            ),

            Expanded(
              child: StreamBuilder<User?>(
                stream: authRepository.userChanges(),
                builder: (context, _) {
                  final displayName = authRepository.displayName;
                  final email = authRepository.email;
                  final initials = authRepository.initials;
                  final photoUrl = authRepository.photoUrl;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Account details
                        ProfileAvatar(
                          text: initials,
                          imageUrl: photoUrl,
                          mainColor: applicationMainColor,
                        ),
                        const SizedBox(height: 12),

                        // Data
                        Text(
                          displayName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          textAlign: TextAlign.center,

                          style: const FadeTextStyle(),
                        ),
                        const SizedBox(height: 12),

                        // Edit Profile Button
                        EditProfileButton(
                          onPressed: () {
                            // Open EditProfileScreen.
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                settings: const RouteSettings(
                                  name: 'edit_profile',
                                ),
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 28),

                        // Saved Phone Numbers
                        const Text(
                          'ЗБЕРЕЖЕНІ НОМЕРИ',
                          style: BoldFadeTextStyle(),
                        ),
                        const SizedBox(height: 8),
                        const SavedPhoneCard(
                          number: '+380 67 312 48 90',
                          label: 'Основний',
                        ),
                        const SizedBox(height: 10),
                        const SavedPhoneCard(
                          number: '+380 93 805 16 42',
                          label: 'Робочий',
                        ),
                        const SizedBox(height: 18),

                        // Account Actions
                        ProfileActions(
                          mainColor: applicationMainColor,
                          onChangePassword: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                settings: const RouteSettings(
                                  name: 'change_password',
                                ),
                                builder: (context) =>
                                    const ChangePasswordScreen(),
                              ),
                            );
                          },
                          onSignOut: () => _confirmAndSignOut(context),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: const AccountBottomNavigation(currentIndex: 2),
    );
  }

  Future<void> _confirmAndSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Вихід із акаунту',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        content: const Text(
          'Ви дійсно бажаєте вийти зі свого облікового запису?',
          style: TextStyle(color: Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Скасувати',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: applicationMainColor),
            child: const Text(
              'Вийти',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await AuthRepository.instance.signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'auth_gate'),
          builder: (context) => const AuthGate(),
        ),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
    }
  }
}
