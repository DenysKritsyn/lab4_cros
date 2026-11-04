import 'package:flutter/material.dart';
import 'package:nova_poshta_mail_tracker/core/forgot_password/forgot_password_screen.dart';
import 'package:nova_poshta_mail_tracker/core/sign_in/widgets/forgot_password_button.dart';
import 'package:nova_poshta_mail_tracker/core/sign_up/sign_up_screen.dart';
import 'package:nova_poshta_mail_tracker/core/text_styles.dart';
import 'package:nova_poshta_mail_tracker/core/utils/validators.dart';
import 'package:nova_poshta_mail_tracker/core/widgets/account_option.dart';
import 'package:nova_poshta_mail_tracker/core/widgets/app_branding.dart';
import 'package:nova_poshta_mail_tracker/core/widgets/nova_input.dart';
import 'package:nova_poshta_mail_tracker/core/widgets/nova_main_button.dart';
import 'package:nova_poshta_mail_tracker/data/auth/auth_exception.dart';
import 'package:nova_poshta_mail_tracker/data/auth/auth_repository.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // Main application color
  static const Color applicationMainColor = Color(0xFFE22629);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthRepository.instance.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Успішний вхід в обліковий запис'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const SizedBox(height: 12),

                // Logo and application's name
                AppBranding(mainColor: applicationMainColor),

                const SizedBox(height: 36),

                // Header
                const Text(
                  'З поверненням!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Увійдіть у свій акаунт',
                  style: LargeFadeTextStyle(),
                ),

                const SizedBox(height: 32),

                // Email Input
                const Text('Електронна пошта', style: SemiBoldTextStyle()),
                const SizedBox(height: 8),
                NovaInput(
                  controller: _emailController,
                  placeholder: "some.mail.example@gmail.com",
                  mainColor: applicationMainColor,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: Validators.email,
                ),

                const SizedBox(height: 20),

                // Password Input
                const Text('Пароль', style: SemiBoldTextStyle()),
                const SizedBox(height: 8),
                NovaInput(
                  controller: _passwordController,
                  placeholder: "*********",
                  mainColor: applicationMainColor,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  enabled: !_isLoading,
                  onFieldSubmitted: (_) => _handleSignIn(),
                  validator: Validators.loginPassword,
                ),

                const SizedBox(height: 12),

                // "Forgot your password?" Button
                ForgotPasswordButton(
                  onPressed: () {
                    if (_isLoading) return;
                    // Open forgot password screen.
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        settings: const RouteSettings(name: 'forgot_password'),
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  mainColor: applicationMainColor,
                  fontSize: 13,
                ),

                const SizedBox(height: 24),

                // LogIn Button
                NovaMainButton(
                  onPressed: _handleSignIn,
                  isLoading: _isLoading,
                  text: 'Увійти',
                  fontSize: 16,
                  icon: Icons.login_rounded,
                  iconSize: 20,
                  color: applicationMainColor,
                ),

                // "Don't have an account yet?" Option
                AccountOption(
                  text: 'Ще не маєте акаунту?',
                  actionText: 'Зареєструватися',
                  onTap: () {
                    if (_isLoading) return;
                    // Open sign up screen.
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        settings: const RouteSettings(name: 'sign_up'),
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
