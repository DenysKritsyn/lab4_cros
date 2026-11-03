import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:nova_poshta_mail_tracker/data/auth/auth_exception.dart';

/// Repository that encapsulates all Firebase Authentication operations.
class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseAnalytics? analytics,
    FirebaseCrashlytics? crashlytics,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _analytics = analytics ?? FirebaseAnalytics.instance,
       _crashlytics = crashlytics ?? FirebaseCrashlytics.instance {
    _firebaseAuth.setLanguageCode('uk');
  }

  static final AuthRepository instance = AuthRepository();

  final FirebaseAuth _firebaseAuth;
  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;

  /// Emits whenever the user signs in, signs out, or updates profile info.
  Stream<User?> userChanges() => _firebaseAuth.userChanges();

  /// Emits whenever the authentication state (signed in / signed out) changes.
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  /// Currently authenticated Firebase user, or `null` if signed out.
  User? get currentUser => _firebaseAuth.currentUser;

  /// User's display name or a default `UserXXXX` fallback.
  String get displayName {
    final user = currentUser;
    final name = user?.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    if (user != null) {
      final number = (user.uid.hashCode.abs() % 9000) + 1000;
      return 'User$number';
    }
    return 'User1000';
  }

  /// User's email address.
  String get email => currentUser?.email ?? '';

  /// User's profile photo URL (HTTPS), if set.
  String? get photoUrl {
    final url = currentUser?.photoURL?.trim();
    return (url != null && url.isNotEmpty) ? url : null;
  }

  /// Computes 1–2 uppercase initials from the user's name or email.
  String get initials => computeInitials(
    name: currentUser?.displayName,
    email: currentUser?.email,
  );

  static String computeInitials({String? name, String? email}) {
    final trimmedName = name?.trim() ?? '';
    if (trimmedName.isNotEmpty) {
      final parts = trimmedName.split(RegExp(r'\s+'));
      if (parts.length >= 2 &&
          parts[0].isNotEmpty &&
          parts[1].isNotEmpty) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return trimmedName.substring(0, trimmedName.length >= 2 ? 2 : 1).toUpperCase();
    }

    final trimmedEmail = email?.trim() ?? '';
    if (trimmedEmail.isNotEmpty) {
      final local = trimmedEmail.split('@').first;
      final parts = local.split(RegExp(r'[._\-]+'));
      if (parts.length >= 2 &&
          parts[0].isNotEmpty &&
          parts[1].isNotEmpty) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return local.substring(0, local.length >= 2 ? 2 : 1).toUpperCase();
    }

    return 'К';
  }

  /// Registers a new user with [email], [password], and optional [displayName].
  Future<UserCredential> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final trimmedName = displayName?.trim();
      final effectiveName = (trimmedName != null && trimmedName.isNotEmpty)
          ? trimmedName
          : 'User${1000 + Random().nextInt(9000)}';
      await credential.user?.updateDisplayName(effectiveName);
      await credential.user?.reload();

      await _analytics.logSignUp(signUpMethod: 'email');
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e, stack) {
      await _crashlytics.recordError(
        e,
        stack,
        reason: 'Unexpected error during signUp',
      );
      throw const AuthException('Не вдалося створити акаунт. Спробуйте ще раз.');
    }
  }

  /// Signs in an existing user with [email] and [password].
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _analytics.logLogin(loginMethod: 'email');
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e, stack) {
      await _crashlytics.recordError(
        e,
        stack,
        reason: 'Unexpected error during signIn',
      );
      throw const AuthException('Не вдалося виконати вхід. Спробуйте ще раз.');
    }
  }

  /// Sends a password reset link to [email].
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      await _analytics.logEvent(name: 'password_reset_requested');
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e, stack) {
      await _crashlytics.recordError(
        e,
        stack,
        reason: 'Unexpected error during sendPasswordResetEmail',
      );
      throw const AuthException(
        'Не вдалося надіслати лист для відновлення пароля.',
      );
    }
  }

  /// Updates the current user's [displayName] and [photoUrl].
  /// Pass an empty string for [photoUrl] to clear the profile photo.
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException('Користувач не авторизований.');
    }

    try {
      if (displayName != null && displayName.trim() != (user.displayName ?? '')) {
        await user.updateDisplayName(displayName.trim());
      }

      if (photoUrl != null) {
        final normalizedUrl = photoUrl.trim().isEmpty ? null : photoUrl.trim();
        if (normalizedUrl != user.photoURL) {
          await user.updatePhotoURL(normalizedUrl);
        }
      }

      await user.reload();
      await _analytics.logEvent(name: 'profile_updated');
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e, stack) {
      await _crashlytics.recordError(
        e,
        stack,
        reason: 'Unexpected error during updateProfile',
      );
      throw const AuthException('Не вдалося оновити дані профілю.');
    }
  }

  /// Sends a verification email to update the user's email address if it changed.
  /// Returns `true` if a verification email was sent, or `false` if unchanged.
  Future<bool> updateEmailIfChanged({required String newEmail}) async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException('Користувач не авторизований.');
    }

    final trimmedEmail = newEmail.trim();
    if (trimmedEmail.isEmpty ||
        trimmedEmail.toLowerCase() == (user.email ?? '').toLowerCase()) {
      return false;
    }

    try {
      await user.verifyBeforeUpdateEmail(trimmedEmail);
      return true;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e, stack) {
      await _crashlytics.recordError(
        e,
        stack,
        reason: 'Unexpected error during updateEmailIfChanged',
      );
      throw const AuthException('Не вдалося оновити електронну пошту.');
    }
  }

  /// Reauthenticates the user with [currentPassword] and updates to [newPassword].
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = currentUser;
    final userEmail = user?.email;
    if (user == null || userEmail == null) {
      throw const AuthException('Користувач не авторизований.');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: userEmail,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' ||
          e.code == 'wrong-password' ||
          e.code == 'INVALID_LOGIN_CREDENTIALS') {
        throw AuthException(
          'Поточний пароль введено неправильно.',
          code: e.code,
        );
      }
      throw AuthException.fromFirebase(e);
    } catch (e, stack) {
      await _crashlytics.recordError(
        e,
        stack,
        reason: 'Unexpected error during reauthentication',
      );
      throw const AuthException('Не вдалося підтвердити поточний пароль.');
    }

    try {
      await user.updatePassword(newPassword);
      await _analytics.logEvent(name: 'password_changed');
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e, stack) {
      await _crashlytics.recordError(
        e,
        stack,
        reason: 'Unexpected error during updatePassword',
      );
      throw const AuthException('Не вдалося змінити пароль.');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _analytics.logEvent(name: 'sign_out');
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e, stack) {
      await _crashlytics.recordError(
        e,
        stack,
        reason: 'Unexpected error during signOut',
      );
      throw const AuthException('Не вдалося вийти з облікового запису.');
    }
  }
}

