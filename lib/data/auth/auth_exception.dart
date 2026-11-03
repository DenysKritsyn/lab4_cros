import 'package:firebase_auth/firebase_auth.dart';

/// Custom exception with user-friendly Ukrainian error messages for Auth flows.
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  factory AuthException.fromFirebase(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'INVALID_LOGIN_CREDENTIALS':
        return AuthException(
          'Не вдалося увійти. Перевірте електронну пошту та пароль.',
          code: exception.code,
        );
      case 'email-already-in-use':
        return AuthException(
          'Обліковий запис із цією електронною поштою вже існує.',
          code: exception.code,
        );
      case 'invalid-email':
        return AuthException(
          'Некоректний формат електронної пошти.',
          code: exception.code,
        );
      case 'weak-password':
      case 'password-does-not-meet-requirements':
        return AuthException(
          'Пароль занадто простий. Використайте щонайменше 8 символів.',
          code: exception.code,
        );
      case 'too-many-requests':
        return AuthException(
          'Забагато невдалих спроб. Спробуйте, будь ласка, пізніше.',
          code: exception.code,
        );
      case 'network-request-failed':
        return AuthException(
          'Помилка мережі. Перевірте підключення до інтернету.',
          code: exception.code,
        );
      case 'requires-recent-login':
        return AuthException(
          'З міркувань безпеки потрібно повторно увійти в обліковий запис.',
          code: exception.code,
        );
      case 'user-disabled':
        return AuthException(
          'Цей обліковий запис було заблоковано.',
          code: exception.code,
        );
      case 'operation-not-allowed':
        return AuthException(
          'Ця операція наразі недоступна.',
          code: exception.code,
        );
      default:
        return AuthException(
          'Сталася помилка автентифікації (${exception.code}). Спробуйте ще раз.',
          code: exception.code,
        );
    }
  }

  @override
  String toString() => message;
}

