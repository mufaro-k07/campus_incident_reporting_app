import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/incidents/incidents_cubit.dart';
import '../../cubits/incidents/incidents_state.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/status_summary.dart';
import '../shared/incident_details_screen.dart';
import 'report_incident_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSeeAllReports});

  final VoidCallback onSeeAllReports;

  void _seeAllMyReports(BuildContext context) {
    context.read<IncidentsCubit>().showOnlyMine(true);
    onSeeAllReports();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<IncidentsCubit, IncidentsState>(
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  const _Greeting(),
                  const SizedBox(height: 20),
                  _ReportBanner(
                    onReport: () => ReportIncidentScreen.open(context),
                  ),
                  const SizedBox(height: 28),
                  const _SectionTitle(title: 'Report Summary'),
                  const SizedBox(height: 12),
                  StatusSummary(
                    incidents: state.myIncidents,
                    totalLabel: 'My Reports',
                  ),
                  const SizedBox(height: 28),
                  _SectionTitle(
                    title: 'Recent Reports',
                    actionLabel: 'See all',
                    onAction: () => _seeAllMyReports(context),
                  ),
                  const SizedBox(height: 4),
                  _RecentReports(state: state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit cubit) => cubit.state.user);
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${user?.firstName ?? ''}',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "Let's keep our campus safe and working.",
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
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
      ],
    );
  }
}

class _ReportBanner extends StatelessWidget {
  const _ReportBanner({required this.onReport});

  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.royalBlue, AppColors.primaryEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'See an issue on campus?',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Report it in a minute and follow it until it is fixed.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.surface,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.royalBlue,
                    minimumSize: const Size(0, 48),
                  ),
                  onPressed: onReport,
                  child: const Text('Report an Issue'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const ExcludeSemantics(
            child: Icon(
              Icons.campaign_outlined,
              size: 72,
              color: AppColors.royalBlueLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (label != null) TextButton(onPressed: onAction, child: Text(label)),
      ],
    );
  }
}

class _RecentReports extends StatelessWidget {
  const _RecentReports({required this.state});

  final IncidentsState state;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case IncidentsStatus.loading:
        return const SizedBox(height: 160, child: LoadingView());
      case IncidentsStatus.error:
        return ErrorView(
          message: 'Could not load your reports.',
          onRetry: context.read<IncidentsCubit>().start,
        );
      case IncidentsStatus.loaded:
        final recent = state.myIncidents.take(3).toList();
        if (recent.isEmpty) {
          return const EmptyState(
            icon: Icons.inbox_outlined,
            title: 'No reports yet',
            message: 'Issues you report will show up here.',
          );
        }
        return Column(
          children: [
            for (final incident in recent)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: IncidentCard(
                  incident: incident,
                  onTap: () => IncidentDetailsScreen.open(context, incident.id),
                ),
              ),
          ],
        );
    }
  }
}
