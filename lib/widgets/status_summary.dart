import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/incident.dart';
import '../models/incident_status.dart';
import 'summary_card.dart';

class StatusSummary extends StatelessWidget {
  const StatusSummary({
    super.key,
    required this.incidents,
    required this.totalLabel,
  });

  final List<Incident> incidents;
  final String totalLabel;

  int _countWith(IncidentStatus status) {
    return incidents.where((incident) => incident.status == status).length;
  }

  Widget _statusCard(IncidentStatus status, IconData icon) {
    return SummaryCard(
      label: status.label,
      count: _countWith(status),
      icon: icon,
      iconColor: status.textColor,
      iconBackground: status.backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                label: totalLabel,
                count: incidents.length,
                icon: Icons.list_alt,
                iconColor: AppColors.primary,
                iconBackground: AppColors.primaryLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statusCard(
                IncidentStatus.submitted,
                Icons.mark_email_unread_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statusCard(
                IncidentStatus.inProgress,
                Icons.construction_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statusCard(
                IncidentStatus.resolved,
                Icons.check_circle_outline,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
