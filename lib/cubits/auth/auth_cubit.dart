import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository) : super(const AuthState()) {
    _authSubscription = _authRepository.authStateChanges().listen(
      _onAuthUserChanged,
    );
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<User?> _authSubscription;

  void _onAuthUserChanged(User? firebaseUser) {
    if (firebaseUser == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } else if (!firebaseUser.emailVerified) {
      emit(const AuthState(status: AuthStatus.unverified));
    } else {
      emit(const AuthState(status: AuthStatus.authenticated));
    }
  }

  Future<void> signOut() => _authRepository.signOut();

  @override
  Future<void> close() async {
    await _authSubscription.cancel();
    return super.close();
  }
}
