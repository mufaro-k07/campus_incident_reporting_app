import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:campus_incident_app/cubits/auth/auth_cubit.dart';
import 'package:campus_incident_app/cubits/auth/auth_state.dart';
import 'package:campus_incident_app/models/app_user.dart';
import 'package:campus_incident_app/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUser extends Mock implements User {}

void main() {
  late MockAuthRepository authRepository;
  late StreamController<User?> authChanges;
  late StreamController<AppUser?> profileChanges;

  const student = AppUser(
    uid: 'user-1',
    name: 'Test Student',
    email: 'test@alustudent.com',
    role: UserRole.student,
  );
  const sameUserAsStaff = AppUser(
    uid: 'user-1',
    name: 'Test Student',
    email: 'test@alustudent.com',
    role: UserRole.staff,
  );

  MockUser firebaseUser({required bool emailVerified}) {
    final user = MockUser();
    when(() => user.uid).thenReturn('user-1');
    when(() => user.email).thenReturn('test@alustudent.com');
    when(() => user.emailVerified).thenReturn(emailVerified);
    return user;
  }

  setUpAll(() {
    registerFallbackValue(MockUser());
  });

  setUp(() {
    authRepository = MockAuthRepository();
    authChanges = StreamController<User?>();
    profileChanges = StreamController<AppUser?>();
    when(() => authRepository.authStateChanges())
        .thenAnswer((_) => authChanges.stream);
    when(() => authRepository.watchProfile(any()))
        .thenAnswer((_) => profileChanges.stream);
    when(() => authRepository.createProfileIfMissing(any()))
        .thenAnswer((_) async {});
  });

  // Not awaited: close() on a stream nobody listened to never completes.
  tearDown(() {
    authChanges.close();
    profileChanges.close();
  });

  blocTest<AuthCubit, AuthState>(
    'is unauthenticated when nobody is signed in',
    build: () => AuthCubit(authRepository),
    act: (_) => authChanges.add(null),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
  );

  blocTest<AuthCubit, AuthState>(
    'is unverified when the email has not been verified',
    build: () => AuthCubit(authRepository),
    act: (_) => authChanges.add(firebaseUser(emailVerified: false)),
    expect: () => [
      const AuthState(
        status: AuthStatus.unverified,
        email: 'test@alustudent.com',
      ),
    ],
    verify: (_) {
      verifyNever(() => authRepository.createProfileIfMissing(any()));
    },
  );

  blocTest<AuthCubit, AuthState>(
    'is authenticated for a verified user and follows role changes live',
    build: () => AuthCubit(authRepository),
    act: (_) async {
      authChanges.add(firebaseUser(emailVerified: true));
      await Future<void>.delayed(Duration.zero);
      profileChanges.add(student);
      await Future<void>.delayed(Duration.zero);
      profileChanges.add(sameUserAsStaff);
    },
    expect: () => [
      const AuthState(status: AuthStatus.authenticated, user: student),
      const AuthState(status: AuthStatus.authenticated, user: sameUserAsStaff),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'shows a friendly message when the password is wrong',
    setUp: () {
      when(
        () => authRepository.logIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'invalid-credential'));
    },
    build: () => AuthCubit(authRepository),
    act: (cubit) =>
        cubit.logIn(email: 'test@alustudent.com', password: 'wrong-pass'),
    expect: () => [
      const AuthState(isBusy: true),
      const AuthState(errorMessage: 'Incorrect email or password.'),
    ],
  );
}
