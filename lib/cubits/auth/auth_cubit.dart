import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/app_user.dart';
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
  StreamSubscription<AppUser?>? _profileSubscription;

  Future<void> _onAuthUserChanged(User? firebaseUser) async {
    await _profileSubscription?.cancel();
    _profileSubscription = null;

    if (firebaseUser == null) {
      if (state.status != AuthStatus.unauthenticated) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
      }
      return;
    }

    if (!firebaseUser.emailVerified) {
      emit(AuthState(status: AuthStatus.unverified, email: firebaseUser.email));
      return;
    }

    try {
      await _authRepository.createProfileIfMissing(firebaseUser);
    } catch (_) {
      await _failToLoadProfile();
      return;
    }
    if (isClosed) return;

    // Listening to the profile document means a role change made in the
    // Firebase Console shows up straight away, without logging in again.
    _profileSubscription = _authRepository
        .watchProfile(firebaseUser.uid)
        .listen((profile) {
          if (profile != null) {
            emit(AuthState(status: AuthStatus.authenticated, user: profile));
          }
        }, onError: (_) => _failToLoadProfile());
  }

  Future<void> _failToLoadProfile() async {
    emit(
      const AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage:
            'Could not load your profile. Check your connection and try again.',
      ),
    );
    await _authRepository.signOut();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(isBusy: true));
    try {
      await _authRepository.register(
        name: name,
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      emit(state.copyWith(isBusy: false, errorMessage: _messageFor(error)));
    }
  }

  Future<void> logIn({required String email, required String password}) async {
    emit(state.copyWith(isBusy: true));
    try {
      await _authRepository.logIn(email: email, password: password);
    } on FirebaseAuthException catch (error) {
      emit(state.copyWith(isBusy: false, errorMessage: _messageFor(error)));
    }
  }

  Future<void> resendVerificationEmail() async {
    emit(state.copyWith(isBusy: true));
    try {
      await _authRepository.sendVerificationEmail();
      emit(
        state.copyWith(
          isBusy: false,
          infoMessage: 'Verification email sent. Check your inbox.',
        ),
      );
    } on FirebaseAuthException catch (error) {
      emit(state.copyWith(isBusy: false, errorMessage: _messageFor(error)));
    }
  }

  Future<void> checkEmailVerified() async {
    emit(state.copyWith(isBusy: true));
    try {
      final firebaseUser = await _authRepository.reloadUser();
      if (firebaseUser != null && firebaseUser.emailVerified) {
        await _onAuthUserChanged(firebaseUser);
      } else {
        emit(
          state.copyWith(
            isBusy: false,
            errorMessage:
                'Your email is not verified yet. Open the link we sent you, '
                'then try again.',
          ),
        );
      }
    } on FirebaseAuthException catch (error) {
      emit(state.copyWith(isBusy: false, errorMessage: _messageFor(error)));
    }
  }

  Future<void> signOut() async {
    await _profileSubscription?.cancel();
    _profileSubscription = null;
    await _authRepository.signOut();
  }

  String _messageFor(FirebaseAuthException error) {
    return switch (error.code) {
      'email-already-in-use' =>
        'An account already exists for this email. Try logging in.',
      'invalid-email' => 'That email address is not valid.',
      'weak-password' => 'Choose a stronger password.',
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'Incorrect email or password.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' =>
        'Too many attempts. Wait a few minutes and try again.',
      'network-request-failed' =>
        'No internet connection. Check your connection and try again.',
      _ => 'Something went wrong. Please try again.',
    };
  }

  @override
  Future<void> close() async {
    await _authSubscription.cancel();
    await _profileSubscription?.cancel();
    return super.close();
  }
}
