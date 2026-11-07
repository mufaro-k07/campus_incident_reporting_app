import 'package:bloc_test/bloc_test.dart';
import 'package:campus_incident_app/cubits/incidents/incidents_cubit.dart';
import 'package:campus_incident_app/cubits/incidents/incidents_state.dart';
import 'package:campus_incident_app/models/incident.dart';
import 'package:campus_incident_app/models/incident_category.dart';
import 'package:campus_incident_app/models/incident_status.dart';
import 'package:campus_incident_app/repositories/incident_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockIncidentRepository extends Mock implements IncidentRepository {}

Incident makeIncident(String id, String reporterId, IncidentStatus status) {
  return Incident(
    id: id,
    title: 'Report $id',
    description: 'Details for report $id',
    category: IncidentCategory.other,
    location: 'Library',
    status: status,
    reporterId: reporterId,
    reporterName: 'Someone',
    createdAt: DateTime(2026, 11, 7),
    updatedAt: DateTime(2026, 11, 7),
    statusHistory: const [],
  );
}

void main() {
  late MockIncidentRepository repository;

  final mine = makeIncident('1', 'me', IncidentStatus.submitted);
  final someoneElses = makeIncident('2', 'other', IncidentStatus.resolved);

  setUp(() {
    repository = MockIncidentRepository();
  });

  IncidentsCubit buildCubit() {
    return IncidentsCubit(incidentRepository: repository, currentUserId: 'me');
  }

  blocTest<IncidentsCubit, IncidentsState>(
    'loads the reports from the repository',
    setUp: () =>
        when(() => repository.watchIncidents())
            .thenAnswer((_) => Stream.value([mine, someoneElses])),
    build: buildCubit,
    act: (cubit) => cubit.start(),
    expect: () => [
      const IncidentsState(currentUserId: 'me'),
      IncidentsState(
        currentUserId: 'me',
        status: IncidentsStatus.loaded,
        incidents: [mine, someoneElses],
      ),
    ],
  );

  blocTest<IncidentsCubit, IncidentsState>(
    'shows an error when the reports cannot be loaded',
    setUp: () =>
        when(() => repository.watchIncidents())
            .thenAnswer((_) => Stream.error(Exception('permission-denied'))),
    build: buildCubit,
    act: (cubit) => cubit.start(),
    skip: 1,
    expect: () => [
      const IncidentsState(currentUserId: 'me', status: IncidentsStatus.error),
    ],
  );

  blocTest<IncidentsCubit, IncidentsState>(
    'Mine and the status filter narrow the visible reports',
    build: buildCubit,
    seed: () => IncidentsState(
      currentUserId: 'me',
      status: IncidentsStatus.loaded,
      incidents: [mine, someoneElses],
    ),
    act: (cubit) {
      cubit.filterByStatus(IncidentStatus.resolved);
      cubit.filterByStatus(null);
      cubit.showOnlyMine(true);
    },
    verify: (cubit) {
      expect(cubit.state.visibleIncidents, [mine]);
      expect(cubit.state.myIncidents, [mine]);
      expect(cubit.state.statusFilter, isNull);
    },
  );
}
