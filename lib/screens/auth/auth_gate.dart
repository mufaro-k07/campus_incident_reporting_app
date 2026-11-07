import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/incidents/incidents_cubit.dart';
import '../../repositories/incident_repository.dart';
import '../../widgets/loading_view.dart';
import '../staff/staff_shell.dart';
import '../student/student_shell.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) =>
          previous.status != current.status || previous.user != current.user,
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.unknown:
            return const Scaffold(body: LoadingView());
          case AuthStatus.unauthenticated:
            return const LoginScreen();
          case AuthStatus.unverified:
            return const VerifyEmailScreen();
          case AuthStatus.authenticated:
            final user = state.user!;
            // Created only after login, so the Firestore stream stops when
            // this widget is removed at sign-out. Otherwise the stream would
            // throw permission errors once the user is signed out.
            return BlocProvider(
              key: ValueKey(user.uid),
              create: (context) => IncidentsCubit(
                incidentRepository: context.read<IncidentRepository>(),
                currentUserId: user.uid,
              )..start(),
              child: user.isStaff ? const StaffShell() : const StudentShell(),
            );
        }
      },
    );
  }
}
