import 'package:bloc_test/bloc_test.dart';
import 'package:campus_incident_app/cubits/status_update/status_update_cubit.dart';
import 'package:campus_incident_app/cubits/status_update/status_update_state.dart';
import 'package:campus_incident_app/models/app_user.dart';
import 'package:campus_incident_app/models/incident.dart';
import 'package:campus_incident_app/models/incident_category.dart';
import 'package:campus_incident_app/models/incident_status.dart';
import 'package:campus_incident_app/repositories/incident_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockIncidentRepository extends Mock implements IncidentRepository {}

void main() {
  const staff = AppUser(
    uid: 'staff-1',
    name: 'Test Staff',
    email: 'staff@alueducation.com',
    role: UserRole.staff,
  );
  final incident = Incident(
    id: 'incident-1',
    title: 'Leaking tap',
    description: 'The tap will not stop running.',
    category: IncidentCategory.water,
    location: 'Learning Commons',
    status: IncidentStatus.submitted,
    reporterId: 'student-1',
    reporterName: 'Test Student',
    createdAt: DateTime(2026, 11, 7),
    updatedAt: DateTime(2026, 11, 7),
    statusHistory: const [],
  );

  late MockIncidentRepository repository;

  setUpAll(() {
    registerFallbackValue(IncidentStatus.submitted);
    registerFallbackValue(staff);
  });

  setUp(() {
    repository = MockIncidentRepository();
  });

  blocTest<StatusUpdateCubit, StatusUpdateState>(
    'moves the report to the next status with a trimmed note',
    setUp: () {
      when(
        () => repository.updateStatus(
          incidentId: any(named: 'incidentId'),
          newStatus: any(named: 'newStatus'),
          changedBy: any(named: 'changedBy'),
          note: any(named: 'note'),
        ),
      ).thenAnswer((_) async {});
    },
    build: () =>
        StatusUpdateCubit(incidentRepository: repository, staff: staff),
    act: (cubit) => cubit.moveToNextStatus(incident, '  On my way  '),
    expect: () => [
      const StatusUpdateState(status: StatusUpdateStatus.saving),
      const StatusUpdateState(status: StatusUpdateStatus.success),
    ],
    verify: (_) {
      verify(
        () => repository.updateStatus(
          incidentId: 'incident-1',
          newStatus: IncidentStatus.inProgress,
          changedBy: staff,
          note: 'On my way',
        ),
      ).called(1);
    },
  );

  blocTest<StatusUpdateCubit, StatusUpdateState>(
    'shows an error when the update is refused',
    setUp: () {
      when(
        () => repository.updateStatus(
          incidentId: any(named: 'incidentId'),
          newStatus: any(named: 'newStatus'),
          changedBy: any(named: 'changedBy'),
          note: any(named: 'note'),
        ),
      ).thenThrow(Exception('permission-denied'));
    },
    build: () =>
        StatusUpdateCubit(incidentRepository: repository, staff: staff),
    act: (cubit) => cubit.moveToNextStatus(incident, ''),
    skip: 1,
    expect: () => [
      isA<StatusUpdateState>()
          .having((state) => state.status, 'status', StatusUpdateStatus.failure)
          .having((state) => state.errorMessage, 'errorMessage', isNotNull),
    ],
  );
}
