import 'package:equatable/equatable.dart';

enum AuthStatus { unknown, unauthenticated, unverified, authenticated }

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.unknown});

  final AuthStatus status;

  @override
  List<Object?> get props => [status];
}
