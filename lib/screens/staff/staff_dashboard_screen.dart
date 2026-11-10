import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/incidents/incidents_cubit.dart';
import '../../cubits/incidents/incidents_state.dart';
import '../../widgets/incident_filter_bar.dart';
import '../../widgets/incident_results_sliver.dart';
import '../../widgets/status_summary.dart';
import '../shared/incident_details_screen.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firstName = context.select(
      (AuthCubit cubit) => cubit.state.user?.firstName ?? '',
    );
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: BlocBuilder<IncidentsCubit, IncidentsState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Hello, $firstName',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Here is what needs attention on campus.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StatusSummary(
                        incidents: state.incidents,
                        totalLabel: 'All reports',
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Reports, newest first',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const IncidentFilterBar(),
                    ],
                  ),
                ),
              ),
              IncidentResultsSliver(
                state: state,
                incidents: state.allMatchingIncidents,
                onIncidentTap: (incident) =>
                    IncidentDetailsScreen.open(context, incident.id),
              ),
            ],
          );
        },
      ),
    );
  }
}
