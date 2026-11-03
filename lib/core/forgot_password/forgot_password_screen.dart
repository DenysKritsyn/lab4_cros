import 'package:flutter/material.dart';
import 'package:nova_poshta_mail_tracker/core/forgot_password/widgets/password_reset_notice.dart';
import 'package:nova_poshta_mail_tracker/core/text_styles.dart';
import 'package:nova_poshta_mail_tracker/core/utils/validators.dart';
import 'package:nova_poshta_mail_tracker/core/widgets/nova_input.dart';
import 'package:nova_poshta_mail_tracker/core/widgets/nova_main_button.dart';
import 'package:nova_poshta_mail_tracker/data/auth/auth_exception.dart';
import 'package:nova_poshta_mail_tracker/data/auth/auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isSent = false;

  // Main application color
  static const Color applicationMainColor = Color(0xFFE22629);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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

        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),

                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - 32.0).clamp(
                      0.0,
                      double.infinity,
                    ),
                  ),

                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const SizedBox(height: 12),

                          // Back Button
                          SizedBox(
                            width: 42,
                            height: 42,
                            child: OutlinedButton(
                              onPressed: () {
                                if (_isLoading) return;
                                // Return to SignInScreen.
                                Navigator.of(context).pop();
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF1F2937),
                                side: const BorderSide(
                                  color: Color(0xFFDDE1E7),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                size: 20,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Header
                          const Text(
                            'Відновлення пароля',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Введіть email вашого акаунту, і ми надішлемо вам посилання для зміни пароля',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Email Input
                          const Text(
                            'Електронна пошта',
                            style: SemiBoldTextStyle(),
                          ),
                          const SizedBox(height: 8),
                          NovaInput(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            placeholder: 'name@example.com',
                            mainColor: applicationMainColor,
                            textInputAction: TextInputAction.done,
                            enabled: !_isLoading,
                            onFieldSubmitted: (_) => _handleSendResetLink(),
                            validator: Validators.email,
                          ),

                          const SizedBox(height: 24),

                          // Send Reset Link Button
                          NovaMainButton(
                            onPressed: _handleSendResetLink,
                            isLoading: _isLoading,
                            text: 'Надіслати посилання',
                            fontSize: 16,
                            icon: Icons.mark_email_read_outlined,
                            iconSize: 20,
                            height: 54,
                            color: applicationMainColor,
                          ),
                          const SizedBox(height: 24),

                          if (_isSent) const PasswordResetNotice(),
                          const Spacer(),

                          // Link Expiration tip
                          const Padding(
                            padding: EdgeInsets.only(top: 24.0, bottom: 16.0),
                            child: Center(
                              child: Text(
                                'Посилання у листі діє 30 хвилин',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleSendResetLink() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthRepository.instance.sendPasswordResetEmail(
        email: _emailController.text,
      );

      if (!mounted) return;
      setState(() {
        _isSent = true;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Якщо акаунт із цим email існує, ми надіслали посилання для скидання пароля.',
            ),
            backgroundColor: Color(0xFF009B50),
          ),
        );
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
}
