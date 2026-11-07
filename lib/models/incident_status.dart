import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

enum IncidentStatus {
  submitted(
    'Submitted',
    AppColors.submittedText,
    AppColors.submittedBackground,
  ),
  inProgress(
    'In Progress',
    AppColors.inProgressText,
    AppColors.inProgressBackground,
  ),
  resolved('Resolved', AppColors.resolvedText, AppColors.resolvedBackground);

  const IncidentStatus(this.label, this.textColor, this.backgroundColor);

  final String label;
  final Color textColor;
  final Color backgroundColor;

  IncidentStatus? get next {
    return switch (this) {
      IncidentStatus.submitted => IncidentStatus.inProgress,
      IncidentStatus.inProgress => IncidentStatus.resolved,
      IncidentStatus.resolved => null,
    };
  }

  static IncidentStatus fromName(String? name) {
    return IncidentStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => IncidentStatus.submitted,
    );
  }
}
