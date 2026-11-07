import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/incidents/incidents_cubit.dart';
import '../../models/app_user.dart';
import '../../widgets/app_snack_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final authCubit = context.read<AuthCubit>();
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to log in again to use the app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (shouldSignOut ?? false) await authCubit.signOut();
  }

  Future<void> _addSampleReports(BuildContext context, AppUser user) async {
    final wasAdded = await context.read<IncidentsCubit>().addSampleIncidents(
      user,
    );
    if (!context.mounted) return;
    showAppSnackBar(
      context,
      wasAdded ? 'Sample reports added.' : 'Could not add sample reports.',
      isError: !wasAdded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit cubit) => cubit.state.user);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (user != null) _ProfileCard(user: user),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _confirmSignOut(context),
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
          if (kDebugMode && user != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _addSampleReports(context, user),
              icon: const Icon(Icons.science_outlined),
              label: const Text('Add sample reports (debug only)'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.royalBlueLight,
              child: Text(
                user.initials,
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.royalBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _RoleBadge(user: user),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: user.isStaff ? AppColors.royalBlue : AppColors.royalBlueLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        user.roleLabel,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: user.isStaff ? AppColors.surface : AppColors.primaryEnd,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
