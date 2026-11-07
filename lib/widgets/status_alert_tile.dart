import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../core/utils/status_alerts.dart';
import '../models/incident_status.dart';

class StatusAlertTile extends StatelessWidget {
  const StatusAlertTile({super.key, required this.alert, required this.onTap});

  final StatusAlert alert;
  final VoidCallback onTap;

  IconData get _statusIcon {
    return switch (alert.change.status) {
      IncidentStatus.submitted => Icons.mark_email_unread_outlined,
      IncidentStatus.inProgress => Icons.construction_outlined,
      IncidentStatus.resolved => Icons.check_circle_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final change = alert.change;
    final note = change.note;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: change.status.backgroundColor,
                child: Icon(_statusIcon, color: change.status.textColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Moved to ${change.status.label}',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alert.incident.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium,
                    ),
                    if (note != null) ...[
                      const SizedBox(height: 4),
                      Text('Staff note: $note', style: textTheme.bodySmall),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${formatDateTime(change.at)} · ${change.changedByName}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
