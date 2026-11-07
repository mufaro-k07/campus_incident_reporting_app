import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/status_alerts.dart';
import '../../cubits/incidents/incidents_cubit.dart';
import '../../cubits/incidents/incidents_state.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/status_alert_tile.dart';
import '../shared/incident_details_screen.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: BlocBuilder<IncidentsCubit, IncidentsState>(
        builder: (context, state) => _AlertsBody(state: state),
      ),
    );
  }
}

class _AlertsBody extends StatelessWidget {
  const _AlertsBody({required this.state});

  final IncidentsState state;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case IncidentsStatus.loading:
        return const LoadingView();
      case IncidentsStatus.error:
        return ErrorView(
          message: 'Could not load your alerts.',
          onRetry: context.read<IncidentsCubit>().start,
        );
      case IncidentsStatus.loaded:
        final alerts = statusAlertsFor(state.incidents, state.currentUserId);
        if (alerts.isEmpty) {
          return const EmptyState(
            icon: Icons.notifications_none,
            title: 'No alerts yet',
            message: 'When staff update one of your reports, it shows here.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
          itemCount: alerts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return StatusAlertTile(
              alert: alert,
              onTap: () =>
                  IncidentDetailsScreen.open(context, alert.incident.id),
            );
          },
        );
    }
  }
}
