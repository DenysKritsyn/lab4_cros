import 'package:flutter/material.dart';

class NovaMainButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color color;
  final double fontSize;
  final double iconSize;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final String text;
  final IconData icon;
  final bool isLoading;

  const NovaMainButton({
    super.key,
    required this.onPressed,
    required this.color,
    required this.fontSize,
    required this.iconSize,
    this.width = double.infinity,
    this.height = 52.0,
    this.margin,
    this.padding,
    required this.text,
    required this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withValues(alpha: 0.65),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            else
              Icon(icon, size: iconSize, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
