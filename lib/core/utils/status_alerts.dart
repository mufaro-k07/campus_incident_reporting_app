import '../../models/incident.dart';
import '../../models/incident_status.dart';
import '../../models/status_change.dart';

class StatusAlert {
  const StatusAlert({required this.incident, required this.change});

  final Incident incident;
  final StatusChange change;
}

// Staff updates on the user's own reports, newest first. The "submitted"
// entry is skipped because the user created it themselves.
List<StatusAlert> statusAlertsFor(List<Incident> incidents, String userId) {
  final alerts = <StatusAlert>[];
  for (final incident in incidents) {
    if (incident.reporterId != userId) continue;
    for (final change in incident.statusHistory) {
      if (change.status == IncidentStatus.submitted) continue;
      alerts.add(StatusAlert(incident: incident, change: change));
    }
  }
  alerts.sort((a, b) => b.change.at.compareTo(a.change.at));
  return alerts;
}
