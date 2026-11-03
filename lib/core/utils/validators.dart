/// Form field validators used across authentication and profile screens.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  static String? name(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Введіть ім’я та прізвище';
    }
    if (trimmed.length < 2) {
      return 'Ім’я має містити щонайменше 2 символи';
    }
    return null;
  }

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Введіть електронну пошту';
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Введіть коректну адресу електронної пошти';
    }
    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введіть пароль';
    }
    if (value.length < 6) {
      return 'Пароль має містити щонайменше 6 символів';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введіть пароль';
    }
    if (value.length < 8) {
      return 'Пароль має містити щонайменше 8 символів';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Підтвердіть пароль';
    }
    if (value != password) {
      return 'Паролі не співпадають';
    }
    return null;
  }

  static String? httpsUrl(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Введіть HTTPS-посилання на зображення';
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      return 'Посилання повинно починатися з https://';
    }
    return null;
  }
}

