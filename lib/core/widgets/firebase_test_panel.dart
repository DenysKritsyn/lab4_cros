import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

/// Panel with buttons for manual testing of Firebase Analytics and Crashlytics.
class FirebaseTestPanel extends StatelessWidget {
  const FirebaseTestPanel({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Sends a custom Analytics event.
  Future<void> _sendTestEvent(BuildContext context) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'lab4_test_event',
      parameters: {'source': 'firebase_test_panel'},
    );
    if (context.mounted) _showMessage(context, 'Подію Analytics надіслано');
  }

  // Records a non-fatal error: the app keeps running, the report is sent immediately.
  Future<void> _recordNonFatalError(BuildContext context) async {
    try {
      throw StateError('Lab 4: test non-fatal error');
    } catch (error, stack) {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: 'Manual non-fatal error from FirebaseTestPanel',
      );
    }
    if (context.mounted) _showMessage(context, 'Нефатальну помилку надіслано');
  }

  // Forces a native crash: the report is sent on the next app launch.
  void _forceCrash() {
    FirebaseCrashlytics.instance.log('Lab 4: forcing test crash');
    FirebaseCrashlytics.instance.crash();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton(
          onPressed: () => _sendTestEvent(context),
          child: const Text('Тест Analytics'),
        ),
        OutlinedButton(
          onPressed: () => _recordNonFatalError(context),
          child: const Text('Нефатальна помилка'),
        ),
        OutlinedButton(
          onPressed: _forceCrash,
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Краш'),
        ),
      ],
    );
  }
}

