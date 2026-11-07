import 'package:campus_incident_app/core/utils/incident_filter.dart';
import 'package:campus_incident_app/models/incident.dart';
import 'package:campus_incident_app/models/incident_category.dart';
import 'package:campus_incident_app/models/incident_status.dart';
import 'package:flutter_test/flutter_test.dart';

Incident makeIncident({
  required String id,
  required String title,
  IncidentCategory category = IncidentCategory.other,
  IncidentStatus status = IncidentStatus.submitted,
  String location = 'Library',
  String reporterId = 'student-1',
}) {
  return Incident(
    id: id,
    title: title,
    description: 'Details about $title',
    category: category,
    location: location,
    status: status,
    reporterId: reporterId,
    reporterName: 'Test Student',
    createdAt: DateTime(2026, 11, 7),
    updatedAt: DateTime(2026, 11, 7),
    statusHistory: const [],
  );
}

void main() {
  final leakingTap = makeIncident(
    id: '1',
    title: 'Leaking tap',
    category: IncidentCategory.water,
    location: 'Learning Commons',
  );
  final brokenLight = makeIncident(
    id: '2',
    title: 'Broken light',
    category: IncidentCategory.electricity,
    status: IncidentStatus.inProgress,
    reporterId: 'student-2',
  );
  final wobblyChair = makeIncident(
    id: '3',
    title: 'Wobbly chair',
    category: IncidentCategory.furniture,
    status: IncidentStatus.resolved,
  );
  final all = [leakingTap, brokenLight, wobblyChair];

  test('returns everything when no filter is set', () {
    expect(filterIncidents(all), all);
  });

  test('filters by status', () {
    expect(filterIncidents(all, status: IncidentStatus.inProgress), [
      brokenLight,
    ]);
  });

  test('filters by category', () {
    expect(filterIncidents(all, category: IncidentCategory.furniture), [
      wobblyChair,
    ]);
  });

  test('filters to one reporter for the Mine tab', () {
    expect(filterIncidents(all, reporterId: 'student-1'), [
      leakingTap,
      wobblyChair,
    ]);
  });

  test('search ignores case and looks at title, location and category', () {
    expect(filterIncidents(all, searchText: 'TAP'), [leakingTap]);
    expect(filterIncidents(all, searchText: 'learning commons'), [leakingTap]);
    expect(filterIncidents(all, searchText: 'electricity'), [brokenLight]);
  });

  test('combines search and filters', () {
    expect(
      filterIncidents(
        all,
        searchText: 'broken',
        status: IncidentStatus.submitted,
      ),
      isEmpty,
    );
  });
}
