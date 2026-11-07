import 'package:campus_incident_app/models/incident.dart';
import 'package:campus_incident_app/models/incident_category.dart';
import 'package:campus_incident_app/models/incident_status.dart';
import 'package:campus_incident_app/models/status_change.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final createdAt = DateTime(2026, 11, 7, 9, 30);
  final startedAt = DateTime(2026, 11, 7, 11, 0);

  final incident = Incident(
    id: 'incident-1',
    title: 'Broken tap in Block B',
    description: 'The tap in the second floor bathroom keeps running.',
    category: IncidentCategory.water,
    location: 'Block B',
    status: IncidentStatus.inProgress,
    reporterId: 'student-1',
    reporterName: 'Test Student',
    photoUrl: 'https://res.cloudinary.com/demo/image/upload/tap.jpg',
    createdAt: createdAt,
    updatedAt: startedAt,
    statusHistory: [
      StatusChange(
        status: IncidentStatus.submitted,
        changedBy: 'student-1',
        changedByName: 'Test Student',
        at: createdAt,
      ),
      StatusChange(
        status: IncidentStatus.inProgress,
        changedBy: 'staff-1',
        changedByName: 'Test Staff',
        note: 'Plumber is on the way.',
        at: startedAt,
      ),
    ],
  );

  group('Incident', () {
    test('toMap stores enums as their names and dates as Timestamps', () {
      final map = incident.toMap();

      expect(map['category'], 'water');
      expect(map['status'], 'inProgress');
      expect(map['createdAt'], Timestamp.fromDate(createdAt));
      expect(map.containsKey('id'), isFalse);
      expect((map['statusHistory'] as List).length, 2);
    });

    test('fromMap(toMap()) gives back the same incident', () {
      final copy = Incident.fromMap('incident-1', incident.toMap());

      expect(copy, incident);
    });

    test('fromMap falls back to safe values for unknown or missing data', () {
      final copy = Incident.fromMap('incident-2', {
        'title': 'Something odd',
        'category': 'spaceship',
        'status': 'archived',
        'createdAt': null,
      });

      expect(copy.category, IncidentCategory.other);
      expect(copy.status, IncidentStatus.submitted);
      expect(copy.photoUrl, isNull);
      expect(copy.statusHistory, isEmpty);
      expect(copy.createdAt, isA<DateTime>());
    });

    test('only a submitted report can be changed by its reporter', () {
      expect(incident.canBeChangedByReporter, isFalse);

      final submitted = Incident.fromMap('incident-3', {
        ...incident.toMap(),
        'status': 'submitted',
      });
      expect(submitted.canBeChangedByReporter, isTrue);
    });
  });

  group('StatusChange', () {
    test('leaves out the note when there is none', () {
      final change = incident.statusHistory.first;

      expect(change.toMap().containsKey('note'), isFalse);
    });

    test('keeps the note when there is one', () {
      final change = StatusChange.fromMap(incident.statusHistory[1].toMap());

      expect(change.note, 'Plumber is on the way.');
      expect(change.changedByName, 'Test Staff');
    });
  });

  group('IncidentStatus', () {
    test('moves forward one step at a time and stops at resolved', () {
      expect(IncidentStatus.submitted.next, IncidentStatus.inProgress);
      expect(IncidentStatus.inProgress.next, IncidentStatus.resolved);
      expect(IncidentStatus.resolved.next, isNull);
    });
  });
}
