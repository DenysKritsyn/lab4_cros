import 'package:flutter/material.dart';
import 'package:nova_poshta_mail_tracker/core/sign_up/widgets/confirm_password_input.dart';
import 'package:nova_poshta_mail_tracker/core/text_styles.dart';
import 'package:nova_poshta_mail_tracker/core/utils/validators.dart';
import 'package:nova_poshta_mail_tracker/core/widgets/nova_input.dart';
import 'package:nova_poshta_mail_tracker/core/widgets/nova_main_button.dart';
import 'package:nova_poshta_mail_tracker/data/auth/auth_exception.dart';
import 'package:nova_poshta_mail_tracker/data/auth/auth_repository.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  static const Color applicationMainColor = Color(0xFFE22629);

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthRepository.instance.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Пароль успішно змінено!'),
            backgroundColor: Color(0xFF009B50),
          ),
        );
      Navigator.of(context).pop();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            onPressed: () {
              if (_isLoading) return;
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          title: const Text(
            'Зміна пароля',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Для безпеки введіть поточний пароль, а потім придумайте новий.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Current Password
                  const Text('Поточний пароль', style: SemiBoldTextStyle()),
                  const SizedBox(height: 8),
                  NovaInput(
                    controller: _currentPasswordController,
                    placeholder: '*********',
                    mainColor: applicationMainColor,
                    isPassword: true,
                    textInputAction: TextInputAction.next,
                    enabled: !_isLoading,
                    validator: Validators.loginPassword,
                  ),

                  const SizedBox(height: 20),

                  // New Password
                  const Text('Новий пароль', style: SemiBoldTextStyle()),
                  const SizedBox(height: 8),
                  NovaInput(
                    controller: _newPasswordController,
                    placeholder: '*********',
                    mainColor: applicationMainColor,
                    isPassword: true,
                    textInputAction: TextInputAction.next,
                    enabled: !_isLoading,
                    validator: (value) {
                      final baseError = Validators.password(value);
                      if (baseError != null) return baseError;
                      if (value == _currentPasswordController.text) {
                        return 'Новий пароль має відрізнятися від поточного';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Щонайменше 8 символів',
                    style: SmallFadeTextStyle(),
                  ),

                  const SizedBox(height: 16),

                  // Confirm New Password
                  ConfirmPasswordInput(
                    passwordController: _newPasswordController,
                    controller: _confirmPasswordController,
                    mainColor: applicationMainColor,
                    enabled: !_isLoading,
                    onFieldSubmitted: (_) => _handleChangePassword(),
                  ),

                  const SizedBox(height: 28),

                  NovaMainButton(
                    onPressed: _handleChangePassword,
                    isLoading: _isLoading,
                    text: 'Оновити пароль',
                    fontSize: 16,
                    icon: Icons.lock_reset_rounded,
                    iconSize: 20,
                    height: 54,
                    color: applicationMainColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

