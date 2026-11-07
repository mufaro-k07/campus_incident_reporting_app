import 'package:equatable/equatable.dart';

import '../../models/app_user.dart';

enum AuthStatus { unknown, unauthenticated, unverified, authenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.email,
    this.isBusy = false,
    this.errorMessage,
    this.infoMessage,
  });

  final AuthStatus status;
  final AppUser? user;
  final String? email;
  final bool isBusy;
  final String? errorMessage;
  final String? infoMessage;

  // Messages are left out unless passed again, so each one is shown only once.
  AuthState copyWith({
    bool? isBusy,
    String? errorMessage,
    String? infoMessage,
  }) {
    return AuthState(
      status: status,
      user: user,
      email: email,
      isBusy: isBusy ?? this.isBusy,
      errorMessage: errorMessage,
      infoMessage: infoMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    email,
    isBusy,
    errorMessage,
    infoMessage,
  ];
}
