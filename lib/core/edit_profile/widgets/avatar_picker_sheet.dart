import 'package:flutter/material.dart';
import 'package:nova_poshta_mail_tracker/core/text_styles.dart';
import 'package:nova_poshta_mail_tracker/core/utils/validators.dart';
import 'package:nova_poshta_mail_tracker/core/widgets/nova_input.dart';
import 'package:nova_poshta_mail_tracker/core/widgets/nova_main_button.dart';

/// Bottom sheet that allows picking a profile photo from predefined HTTPS URLs
/// or entering a custom HTTPS URL with live preview (as required by Lab 4).
class AvatarPickerSheet extends StatefulWidget {
  final String? currentUrl;
  final Color mainColor;

  const AvatarPickerSheet({
    super.key,
    required this.currentUrl,
    required this.mainColor,
  });

  /// Preset HTTPS avatar URLs.
  static const List<String> presetAvatarUrls = [
    'https://api.dicebear.com/9.x/adventurer/png?seed=Olena&backgroundColor=ffdfbf',
    'https://api.dicebear.com/9.x/adventurer/png?seed=Taras&backgroundColor=b6e3f4',
    'https://api.dicebear.com/9.x/adventurer/png?seed=Solomiia&backgroundColor=c0aede',
    'https://api.dicebear.com/9.x/adventurer/png?seed=Maksym&backgroundColor=d1d4f9',
    'https://api.dicebear.com/9.x/adventurer/png?seed=Iryna&backgroundColor=ffd5dc',
    'https://api.dicebear.com/9.x/adventurer/png?seed=Bohdan&backgroundColor=c9f2c7',
    'https://robohash.org/nova_user_1.png?set=set4&size=200x200',
    'https://robohash.org/nova_user_2.png?set=set4&size=200x200',
  ];

  @override
  State<AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<AvatarPickerSheet> {
  final GlobalKey<FormState> _urlFormKey = GlobalKey<FormState>();
  late final TextEditingController _customUrlController;
  String? _selectedUrl;

  @override
  void initState() {
    super.initState();
    _selectedUrl = widget.currentUrl;
    _customUrlController = TextEditingController(
      text: widget.currentUrl != null &&
              !AvatarPickerSheet.presetAvatarUrls.contains(widget.currentUrl)
          ? widget.currentUrl
          : '',
    );
  }

  @override
  void dispose() {
    _customUrlController.dispose();
    super.dispose();
  }

  void _applyCustomUrl() {
    if (_urlFormKey.currentState!.validate()) {
      setState(() {
        _selectedUrl = _customUrlController.text.trim();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Фото профілю',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                if (_selectedUrl != null && _selectedUrl!.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop('');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: widget.mainColor,
                    ),
                    child: const Text('Скинути фото'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Live preview
            Center(
              child: CircleAvatar(
                radius: 42,
                backgroundColor: widget.mainColor,
                child: CircleAvatar(
                  radius: 39,
                  backgroundColor: const Color(0xFFFFF0F1),
                  foregroundImage:
                      (_selectedUrl != null && _selectedUrl!.isNotEmpty)
                          ? NetworkImage(_selectedUrl!)
                          : null,
                  onForegroundImageError:
                      (_selectedUrl != null && _selectedUrl!.isNotEmpty)
                          ? (_, _) {}
                          : null,
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 36,
                    color: widget.mainColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Оберіть готовий аватар', style: SemiBoldTextStyle()),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: AvatarPickerSheet.presetAvatarUrls.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final url = AvatarPickerSheet.presetAvatarUrls[index];
                final isSelected = _selectedUrl == url;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedUrl = url;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? widget.mainColor
                            : const Color(0xFFE5E7EB),
                        width: isSelected ? 3 : 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFFF3F4F6),
                      foregroundImage: NetworkImage(url),
                      onForegroundImageError: (_, _) {},
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            const Text(
              'Або введіть власне HTTPS-посилання',
              style: SemiBoldTextStyle(),
            ),
            const SizedBox(height: 8),
            Form(
              key: _urlFormKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: NovaInput(
                      controller: _customUrlController,
                      placeholder: 'https://example.com/avatar.png',
                      mainColor: widget.mainColor,
                      keyboardType: TextInputType.url,
                      validator: Validators.httpsUrl,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _applyCustomUrl,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.mainColor,
                        side: BorderSide(color: widget.mainColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Перегляд'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            NovaMainButton(
              onPressed: () {
                if (_customUrlController.text.trim().isNotEmpty &&
                    _selectedUrl != _customUrlController.text.trim()) {
                  if (!_urlFormKey.currentState!.validate()) {
                    return;
                  }
                  _selectedUrl = _customUrlController.text.trim();
                }
                Navigator.of(context).pop(_selectedUrl ?? '');
              },
              text: 'Застосувати фото',
              fontSize: 16,
              icon: Icons.check_rounded,
              iconSize: 20,
              color: widget.mainColor,
            ),
          ],
        ),
      ),
    );
  }
}

