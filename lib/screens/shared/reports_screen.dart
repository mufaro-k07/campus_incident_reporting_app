import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/incidents/incidents_cubit.dart';
import '../../cubits/incidents/incidents_state.dart';
import '../../models/incident_status.dart';
import '../../widgets/incident_filter_bar.dart';
import '../../widgets/incident_results_sliver.dart';
import 'incident_details_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: BlocBuilder<IncidentsCubit, IncidentsState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AllOrMineSwitch(showOnlyMine: state.showOnlyMine),
                      if (state.showOnlyMine) ...[
                        const SizedBox(height: 16),
                        _MyReportsHeader(state: state),
                      ],
                      const SizedBox(height: 16),
                      const IncidentFilterBar(),
                    ],
                  ),
                ),
              ),
              IncidentResultsSliver(
                state: state,
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

class _AllOrMineSwitch extends StatelessWidget {
  const _AllOrMineSwitch({required this.showOnlyMine});

  final bool showOnlyMine;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: AppColors.lime,
        selectedForegroundColor: AppColors.royalBlue,
      ),
      segments: const [
        ButtonSegment(value: false, label: Text('All')),
        ButtonSegment(value: true, label: Text('Mine')),
      ],
      selected: {showOnlyMine},
      onSelectionChanged: (selection) =>
          context.read<IncidentsCubit>().showOnlyMine(selection.first),
    );
  }
}

class _MyReportsHeader extends StatelessWidget {
  const _MyReportsHeader({required this.state});

  final IncidentsState state;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit cubit) => cubit.state.user);
    final myIncidents = state.myIncidents;
    final resolvedCount = myIncidents
        .where((incident) => incident.status == IncidentStatus.resolved)
        .length;
    final reportWord = myIncidents.length == 1 ? 'report' : 'reports';
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.royalBlueLight,
              child: Text(
                user?.initials ?? '',
                style: const TextStyle(
                  color: AppColors.royalBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? '',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${myIncidents.length} $reportWord · $resolvedCount resolved',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
