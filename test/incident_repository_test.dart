import 'package:campus_incident_app/models/app_user.dart';
import 'package:campus_incident_app/models/incident_category.dart';
import 'package:campus_incident_app/models/incident_status.dart';
import 'package:campus_incident_app/repositories/incident_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const student = AppUser(
    uid: 'student-1',
    name: 'Test Student',
    email: 'test@alustudent.com',
    role: UserRole.student,
  );
  const staff = AppUser(
    uid: 'staff-1',
    name: 'Test Staff',
    email: 'staff@alueducation.com',
    role: UserRole.staff,
  );

  late FakeFirebaseFirestore firestore;
  late IncidentRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = IncidentRepository(firestore: firestore);
  });

  Future<String> createLeakingTap() async {
    await repository.createIncident(
      title: 'Leaking tap',
      description: 'The tap in Block B will not stop running.',
      category: IncidentCategory.water,
      location: 'Block B',
      reporter: student,
    );
    final incidents = await repository.watchIncidents().first;
    return incidents.single.id;
  }

  test('a new report starts as submitted with one history entry', () async {
    await createLeakingTap();

    final incident = (await repository.watchIncidents().first).single;
    expect(incident.status, IncidentStatus.submitted);
    expect(incident.reporterId, 'student-1');
    expect(incident.photoUrl, isNull);
    expect(incident.statusHistory.single.status, IncidentStatus.submitted);
    expect(incident.statusHistory.single.changedByName, 'Test Student');
  });

  test('updating the status adds to the history with the note', () async {
    final incidentId = await createLeakingTap();

    await repository.updateStatus(
      incidentId: incidentId,
      newStatus: IncidentStatus.inProgress,
      changedBy: staff,
      note: 'Plumber is on the way.',
    );

    final incident = (await repository.watchIncidents().first).single;
    expect(incident.status, IncidentStatus.inProgress);
    expect(incident.statusHistory.length, 2);
    expect(incident.statusHistory.last.note, 'Plumber is on the way.');
    expect(incident.statusHistory.last.changedByName, 'Test Staff');
  });

  test('the reporter can edit and delete a report', () async {
    final incidentId = await createLeakingTap();

    await repository.updateIncident(
      incidentId: incidentId,
      title: 'Leaking tap on floor 2',
      description: 'The tap in Block B will not stop running.',
      category: IncidentCategory.water,
      location: 'Block B',
    );
    final edited = (await repository.watchIncidents().first).single;
    expect(edited.title, 'Leaking tap on floor 2');

    await repository.deleteIncident(incidentId);
    expect(await repository.watchIncidents().first, isEmpty);
  });
}
