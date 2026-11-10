import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/incidents/incidents_cubit.dart';
import '../cubits/incidents/incidents_state.dart';
import '../models/incident.dart';
import 'empty_state.dart';
import 'error_view.dart';
import 'incident_card.dart';
import 'loading_view.dart';

class IncidentResultsSliver extends StatelessWidget {
  const IncidentResultsSliver({
    super.key,
    required this.state,
    required this.incidents,
    required this.onIncidentTap,
  });

  final IncidentsState state;
  final List<Incident> incidents;
  final ValueChanged<Incident> onIncidentTap;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case IncidentsStatus.loading:
        return const SliverFillRemaining(child: LoadingView());
      case IncidentsStatus.error:
        return SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorView(
            message: 'Could not load reports. Check your connection.',
            onRetry: context.read<IncidentsCubit>().start,
          ),
        );
      case IncidentsStatus.loaded:
        if (incidents.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.search_off,
              title: 'No reports found',
              message: 'Try another search or filter.',
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          sliver: SliverList.separated(
            itemCount: incidents.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => IncidentCard(
              incident: incidents[index],
              onTap: () => onIncidentTap(incidents[index]),
            ),
          ),
        );
    }
  }
}
