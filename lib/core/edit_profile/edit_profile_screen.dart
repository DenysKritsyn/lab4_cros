import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:nova_poshta_mail_tracker/core/edit_profile/widgets/avatar_picker_sheet.dart';
import 'package:nova_poshta_mail_tracker/core/edit_profile/widgets/phone_numbers.dart';
import 'package:nova_poshta_mail_tracker/core/text_styles.dart';
import 'package:nova_poshta_mail_tracker/core/utils/validators.dart';
import 'package:nova_poshta_mail_tracker/core/widgets/nova_input.dart';
import 'package:nova_poshta_mail_tracker/core/widgets/nova_main_button.dart';
import 'package:nova_poshta_mail_tracker/core/widgets/profile_photo.dart';
import 'package:nova_poshta_mail_tracker/core/widgets/saved_phone_card.dart';
import 'package:nova_poshta_mail_tracker/data/auth/auth_exception.dart';
import 'package:nova_poshta_mail_tracker/data/auth/auth_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<SavedPhoneCard> _buildPhoneNumbers(BuildContext context) => [
    SavedPhoneCard(
      number: '+380 67 312 48 90',
      label: 'Основний',
      onEdit: () {
        FirebaseCrashlytics.instance.recordError(
          Exception('Тестова нефатальна помилка: редагування номера телефону'),
          StackTrace.current,
          reason: 'Редагування номера телефону "Основний"',
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Нефатальну помилку надіслано до Crashlytics'),
              backgroundColor: Color(0xFF009B50),
            ),
          );
      },
      onDelete: () {
        FirebaseCrashlytics.instance.log(
          'Crashlytics: фатальний краш при спробі видалити номер',
        );
        FirebaseCrashlytics.instance.crash();
      },
    ),
    SavedPhoneCard(
      number: '+380 93 805 16 42',
      label: 'Робочий',
      onEdit: () {
        // TODO: Edit the work phone number.
      },
      onDelete: () {
        // TODO: Delete the work phone number.
      },
    ),
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  String? _selectedPhotoUrl;
  bool _isLoading = false;

  // Main application color
  static const Color applicationMainColor = Color(0xFFE22629);

  @override
  void initState() {
    super.initState();
    final repo = AuthRepository.instance;
    final user = repo.currentUser;
    _nameController = TextEditingController(
      text: user?.displayName?.trim().isNotEmpty == true
          ? user!.displayName!
          : repo.displayName,
    );
    _emailController = TextEditingController(text: repo.email);
    _selectedPhotoUrl = repo.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _openAvatarPicker() async {
    if (_isLoading) {
      return;
    }
      
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AvatarPickerSheet(
        currentUrl: _selectedPhotoUrl,
        mainColor: applicationMainColor,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedPhotoUrl = result.isEmpty ? null : result;
      });
    }
  }

  Future<void> _handleSaveChanges() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repo = AuthRepository.instance;

      await repo.updateProfile(
        displayName: _nameController.text,
        photoUrl: _selectedPhotoUrl ?? '',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Зміни профілю успішно збережено!'),
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
    final previewInitials = AuthRepository.computeInitials(
      name: _nameController.text,
      email: _emailController.text,
    );

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

          // Return button
          leading: IconButton(
            onPressed: () {
              if (_isLoading) {
                return;
              }
              // Return to profile screen.
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          title: const Text(
            'Редагувати профіль',
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
                  // Profile Photo
                  ProfilePhoto(
                    text: previewInitials,
                    imageUrl: _selectedPhotoUrl,
                    mainColor: applicationMainColor,
                    borderColor: Colors.white,
                    size: 80,
                    onPressed: _openAvatarPicker,
                  ),
                  const SizedBox(height: 8),

                  // Name Input
                  const Text(
                    'Ім’я та прізвище',
                    style: SemiBoldTextStyle(),
                  ),
                  const SizedBox(height: 8),
                  NovaInput(
                    controller: _nameController,
                    placeholder: 'Ім’я та прізвище',
                    mainColor: applicationMainColor,
                    textInputAction: TextInputAction.next,
                    enabled: !_isLoading,
                    onChanged: (_) => setState(() {}),
                    validator: Validators.name,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  const Text(
                    'Електронна пошта',
                    style: SemiBoldTextStyle(),
                  ),
                  const SizedBox(height: 8),
                  NovaInput(
                    controller: _emailController,
                    placeholder: 'name@example.com',
                    mainColor: applicationMainColor,
                    keyboardType: TextInputType.emailAddress,
                    enabled: false,
                  ),
                  const SizedBox(height: 12),

                  // Phone Numbers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'НОМЕРИ ТЕЛЕФОНУ',
                          style: BoldFadeTextStyle(),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Add a phone number.
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: applicationMainColor,
                          padding: EdgeInsets.zero,
                        ),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text(
                          'Додати',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  PhoneNumbers(
                    cards: _buildPhoneNumbers(context),
                  ),
                  const SizedBox(height: 18),

                  // Save Changes Button
                  NovaMainButton(
                    onPressed: _handleSaveChanges,
                    isLoading: _isLoading,
                    text: 'Зберегти зміни',
                    fontSize: 16,
                    icon: Icons.check_rounded,
                    iconSize: 20,
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
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
