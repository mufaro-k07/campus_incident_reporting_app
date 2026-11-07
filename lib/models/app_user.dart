import 'package:equatable/equatable.dart';

enum UserRole { student, staff }

class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] == UserRole.staff.name
          ? UserRole.staff
          : UserRole.student,
    );
  }

  final String uid;
  final String name;
  final String email;
  final UserRole role;

  bool get isStaff => role == UserRole.staff;

  String get roleLabel => isStaff ? 'Staff' : 'Student';

  String get firstName => name.trim().split(' ').first;

  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    return words.take(2).map((word) => word[0].toUpperCase()).join();
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'role': role.name};
  }

  @override
  List<Object?> get props => [uid, name, email, role];
}
