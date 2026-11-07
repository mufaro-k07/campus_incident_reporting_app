import '../constants.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool isAluEmail(String email) {
  final lowerCaseEmail = email.trim().toLowerCase();
  return allowedEmailDomains.any(
    (domain) => lowerCaseEmail.endsWith('@$domain'),
  );
}

String? validateName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) return 'Enter your name';
  if (name.length < 2) return 'Name is too short';
  return null;
}

String? validateEmail(
  String? value, {
  bool allowAnyDomain = allowAnyEmailDomain,
}) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Enter your email';
  if (!_emailPattern.hasMatch(email)) return 'Enter a valid email address';
  if (!allowAnyDomain && !isAluEmail(email)) {
    return 'Use your ALU email (@alustudent.com or @alueducation.com)';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Enter your password';
  if (value.length < 8) return 'Password must be at least 8 characters';
  return null;
}

String? validateConfirmPassword(String? value, String password) {
  if (value == null || value.isEmpty) return 'Confirm your password';
  if (value != password) return 'Passwords do not match';
  return null;
}
