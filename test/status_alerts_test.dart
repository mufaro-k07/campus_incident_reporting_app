import 'package:campus_incident_app/core/utils/status_alerts.dart';
import 'package:campus_incident_app/models/incident.dart';
import 'package:campus_incident_app/models/incident_category.dart';
import 'package:campus_incident_app/models/incident_status.dart';
import 'package:campus_incident_app/models/status_change.dart';
import 'package:flutter_test/flutter_test.dart';

StatusChange change(IncidentStatus status, int hour, {String? note}) {
  return StatusChange(
    status: status,
    changedBy: 'staff-1',
    changedByName: 'Test Staff',
    note: note,
    at: DateTime(2026, 11, 7, hour),
  );
}

Incident makeIncident(
  String id,
  String reporterId,
  List<StatusChange> history,
) {
  return Incident(
    id: id,
    title: 'Report $id',
    description: 'Details for report $id',
    category: IncidentCategory.other,
    location: 'Library',
    status: history.last.status,
    reporterId: reporterId,
    reporterName: 'Test Student',
    createdAt: DateTime(2026, 11, 7),
    updatedAt: DateTime(2026, 11, 7),
    statusHistory: history,
  );
}

void main() {
  test('lists staff updates on my reports, newest first', () {
    final mine = makeIncident('1', 'me', [
      change(IncidentStatus.submitted, 8),
      change(IncidentStatus.inProgress, 9, note: 'On it'),
      change(IncidentStatus.resolved, 12),
    ]);
    final alsoMine = makeIncident('2', 'me', [
      change(IncidentStatus.submitted, 8),
      change(IncidentStatus.inProgress, 10),
    ]);
    final someoneElses = makeIncident('3', 'other', [
      change(IncidentStatus.submitted, 8),
      change(IncidentStatus.inProgress, 11),
    ]);

    final alerts = statusAlertsFor([mine, alsoMine, someoneElses], 'me');

    expect(alerts.map((alert) => alert.change.at.hour), [12, 10, 9]);
    expect(alerts.last.change.note, 'On it');
    expect(alerts.every((alert) => alert.incident.reporterId == 'me'), isTrue);
  });

  test('a report that is only submitted gives no alerts', () {
    final waiting = makeIncident('1', 'me', [
      change(IncidentStatus.submitted, 8),
    ]);

    expect(statusAlertsFor([waiting], 'me'), isEmpty);
  });
}
