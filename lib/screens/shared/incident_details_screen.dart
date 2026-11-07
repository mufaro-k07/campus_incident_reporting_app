import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/incidents/incidents_cubit.dart';
import '../../models/incident.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/status_timeline.dart';
import '../staff/update_status_sheet.dart';
import '../student/report_incident_screen.dart';

class IncidentDetailsScreen extends StatelessWidget {
  const IncidentDetailsScreen({super.key, required this.incidentId});

  final String incidentId;

  // A pushed route is not below AuthGate in the widget tree, so the
  // IncidentsCubit has to be handed over explicitly.
  static Future<void> open(BuildContext context, String incidentId) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<IncidentsCubit>(),
          child: IncidentDetailsScreen(incidentId: incidentId),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Incident incident) async {
    final incidentsCubit = context.read<IncidentsCubit>();
    final navigator = Navigator.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this report?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!(shouldDelete ?? false)) return;

    final wasDeleted = await incidentsCubit.deleteIncident(incident.id);
    if (!context.mounted) return;
    if (wasDeleted) {
      showAppSnackBar(context, 'Report deleted.');
      navigator.pop();
    } else {
      showAppSnackBar(
        context,
        'Could not delete the report. Please try again.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final incident = context.select(
      (IncidentsCubit cubit) => cubit.state.findById(incidentId),
    );
    final currentUser = context.select((AuthCubit cubit) => cubit.state.user);
    final isStaff = currentUser?.isStaff ?? false;
    final canEditOrDelete =
        incident != null &&
        incident.reporterId == currentUser?.uid &&
        incident.canBeChangedByReporter;
    final canUpdateStatus =
        isStaff && incident != null && incident.status.next != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report details'),
        actions: [
          if (canEditOrDelete) ...[
            IconButton(
              tooltip: 'Edit report',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  ReportIncidentScreen.open(context, incidentToEdit: incident),
            ),
            IconButton(
              tooltip: 'Delete report',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, incident),
            ),
          ],
        ],
      ),
      body: incident == null
          ? const EmptyState(
              icon: Icons.delete_outline,
              title: 'Report not found',
              message: 'This report may have been deleted.',
            )
          : _IncidentDetails(incident: incident),
      bottomNavigationBar: canUpdateStatus
          ? _UpdateStatusBar(incident: incident)
          : null,
    );
  }
}

class _IncidentDetails extends StatelessWidget {
  const _IncidentDetails({required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final photoUrl = incident.photoUrl;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (photoUrl != null) ...[
          _IncidentPhoto(url: photoUrl),
          const SizedBox(height: 20),
        ],
        Text(
          incident.title,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            StatusChip(status: incident.status),
            Chip(
              avatar: Icon(incident.category.icon, size: 18),
              label: Text(incident.category.label),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.place_outlined,
                label: 'Location',
                value: incident.location,
              ),
              _InfoRow(
                icon: Icons.person_outline,
                label: 'Reported by',
                value: incident.reporterName,
              ),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Reported on',
                value: formatDateTime(incident.createdAt),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Description',
          child: Text(incident.description, style: textTheme.bodyLarge),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Progress',
          child: StatusTimeline(incident: incident),
        ),
      ],
    );
  }
}

class _UpdateStatusBar extends StatelessWidget {
  const _UpdateStatusBar({required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: AppButton(
          label: 'Update Status',
          onPressed: () => UpdateStatusSheet.show(context, incident),
        ),
      ),
    );
  }
}

class _IncidentPhoto extends StatelessWidget {
  const _IncidentPhoto({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          semanticLabel: 'Photo of the issue',
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const ColoredBox(
              color: AppColors.primaryLight,
              child: Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) => const ColoredBox(
            color: AppColors.primaryLight,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image_outlined, color: AppColors.primary),
                  SizedBox(height: 4),
                  Text('The photo could not be loaded'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.title});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sectionTitle = title;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sectionTitle != null) ...[
              Text(
                sectionTitle,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
