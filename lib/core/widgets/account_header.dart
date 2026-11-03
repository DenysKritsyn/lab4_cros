import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nova_poshta_mail_tracker/core/widgets/app_branding.dart';
import 'package:nova_poshta_mail_tracker/data/auth/auth_repository.dart';

class AccountHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAccountPressed;
  final Color mainColor;

  const AccountHeader({
    super.key,
    required this.title,
    required this.onAccountPressed,
    required this.mainColor,
  });

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository.instance;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFDDE1E7))),
      ),
      child: Row(
        children: [
          // Application name and logo
          AppBranding(mainColor: mainColor),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Avatar synchronized with current user
          StreamBuilder<User?>(
            stream: authRepository.userChanges(),
            builder: (context, _) {
              final photoUrl = authRepository.photoUrl;
              final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
              final initials = authRepository.initials;

              return IconButton(
                onPressed: onAccountPressed,
                tooltip: 'Акаунт',
                padding: EdgeInsets.zero,
                icon: CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFFFF0F1),
                  foregroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
                  onForegroundImageError: hasPhoto ? (_, _) {} : null,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: mainColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
