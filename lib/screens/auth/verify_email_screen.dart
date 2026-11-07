import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/auth_header.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  void _showMessage(BuildContext context, AuthState state) {
    if (state.errorMessage != null) {
      showAppSnackBar(context, state.errorMessage!, isError: true);
    } else if (state.infoMessage != null) {
      showAppSnackBar(context, state.infoMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          current.errorMessage != previous.errorMessage ||
          current.infoMessage != previous.infoMessage,
      listener: _showMessage,
      builder: (context, state) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthHeader(
                        icon: Icons.mark_email_unread_outlined,
                        title: 'Verify your email',
                        subtitle:
                            'We sent a verification link to '
                            '${state.email ?? 'your email'}. Open the link, '
                            'then come back and tap "I have verified".',
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        label: 'I have verified',
                        isLoading: state.isBusy,
                        onPressed: authCubit.checkEmailVerified,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: state.isBusy
                            ? null
                            : authCubit.resendVerificationEmail,
                        child: const Text('Resend email'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: authCubit.signOut,
                        child: const Text('Use a different account'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
