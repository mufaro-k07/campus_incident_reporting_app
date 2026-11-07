import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/incident.dart';
import '../models/incident_status.dart';
import '../models/status_change.dart';

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.incident});

  final Incident incident;

  bool _isReached(IncidentStatus status) {
    return status.index <= incident.status.index;
  }

  StatusChange? _latestChangeTo(IncidentStatus status) {
    StatusChange? latest;
    for (final change in incident.statusHistory) {
      if (change.status == status) latest = change;
    }
    return latest;
  }

  @override
  Widget build(BuildContext context) {
    const steps = IncidentStatus.values;
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _TimelineStep(
            status: steps[i],
            change: _latestChangeTo(steps[i]),
            isReached: _isReached(steps[i]),
            isNextReached: i < steps.length - 1 && _isReached(steps[i + 1]),
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.status,
    required this.change,
    required this.isReached,
    required this.isNextReached,
    required this.isLast,
  });

  final IncidentStatus status;
  final StatusChange? change;
  final bool isReached;
  final bool isNextReached;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                _StepDot(isReached: isReached),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isNextReached
                          ? AppColors.royalBlue
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: _StepDetails(
                status: status,
                change: change,
                isReached: isReached,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.isReached});

  final bool isReached;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isReached ? AppColors.royalBlue : AppColors.surface,
        border: Border.all(
          color: isReached ? AppColors.royalBlue : AppColors.border,
          width: 2,
        ),
      ),
      child: isReached
          ? const Icon(Icons.check, size: 14, color: AppColors.surface)
          : null,
    );
  }
}

class _StepDetails extends StatelessWidget {
  const _StepDetails({
    required this.status,
    required this.change,
    required this.isReached,
  });

  final IncidentStatus status;
  final StatusChange? change;
  final bool isReached;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondaryStyle = textTheme.bodySmall?.copyWith(
      color: AppColors.textSecondary,
    );
    final stepChange = change;
    final note = stepChange?.note;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          status.label,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isReached ? AppColors.black : AppColors.textSecondary,
          ),
        ),
        if (stepChange != null)
          Text(
            '${formatDateTime(stepChange.at)} · ${stepChange.changedByName}',
            style: secondaryStyle,
          )
        else if (!isReached)
          Text('Not yet', style: secondaryStyle),
        if (note != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Staff note: $note', style: textTheme.bodyMedium),
          ),
      ],
    );
  }
}
