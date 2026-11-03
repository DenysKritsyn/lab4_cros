import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String text;
  final Color mainColor;
  final String? imageUrl;

  const ProfileAvatar({
    super.key,
    required this.text,
    required this.mainColor,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Center(
      // Avatar
      child: CircleAvatar(
        radius: 38,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 35,
          backgroundColor: const Color(0xFFFFF0F1),
          foregroundImage: hasImage ? NetworkImage(imageUrl!) : null,
          onForegroundImageError: hasImage ? (_, _) {} : null,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: mainColor,
            ),
          ),
        ),
      ),
    );
  }
}
