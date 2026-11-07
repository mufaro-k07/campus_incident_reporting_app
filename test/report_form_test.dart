import 'package:campus_incident_app/cubits/report_form/report_form_cubit.dart';
import 'package:campus_incident_app/models/app_user.dart';
import 'package:campus_incident_app/models/incident_category.dart';
import 'package:campus_incident_app/repositories/image_upload_service.dart';
import 'package:campus_incident_app/repositories/incident_repository.dart';
import 'package:campus_incident_app/screens/student/report_incident_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockIncidentRepository extends Mock implements IncidentRepository {}

class MockImageUploadService extends Mock implements ImageUploadService {}

void main() {
  const reporter = AppUser(
    uid: 'student-1',
    name: 'Test Student',
    email: 'test@alustudent.com',
    role: UserRole.student,
  );

  late MockIncidentRepository incidentRepository;

  setUp(() {
    incidentRepository = MockIncidentRepository();
    registerFallbackValue(IncidentCategory.other);
    registerFallbackValue(reporter);
  });

  Future<void> openReportForm(WidgetTester tester) async {
    // A tall screen so the whole form is built without scrolling.
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => ReportFormCubit(
                      incidentRepository: incidentRepository,
                      imageUploadService: MockImageUploadService(),
                      reporter: reporter,
                    ),
                    child: const ReportIncidentScreen(),
                  ),
                ),
              ),
              child: const Text('Open form'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();
  }

  Future<void> tapSubmit(WidgetTester tester) async {
    await tester.tap(find.text('Submit Report'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows an error for every missing field and saves nothing', (
    tester,
  ) async {
    await openReportForm(tester);

    await tapSubmit(tester);

    expect(find.text('Choose a category'), findsOneWidget);
    expect(find.text('Enter a short title'), findsOneWidget);
    expect(find.text('Describe the issue'), findsOneWidget);
    expect(find.text('Choose a location'), findsOneWidget);
    verifyNever(
      () => incidentRepository.createIncident(
        title: any(named: 'title'),
        description: any(named: 'description'),
        category: any(named: 'category'),
        location: any(named: 'location'),
        reporter: any(named: 'reporter'),
        photoUrl: any(named: 'photoUrl'),
      ),
    );
  });

  testWidgets('submits a valid report without a photo', (tester) async {
    when(
      () => incidentRepository.createIncident(
        title: any(named: 'title'),
        description: any(named: 'description'),
        category: any(named: 'category'),
        location: any(named: 'location'),
        reporter: any(named: 'reporter'),
        photoUrl: any(named: 'photoUrl'),
      ),
    ).thenAnswer((_) async {});
    await openReportForm(tester);

    await tester.tap(find.text('Water'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Leaking tap',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'The tap in the Block B bathroom will not stop running.',
    );
    await tester.tap(find.text('Location'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block B').last);
    await tester.pumpAndSettle();
    await tapSubmit(tester);

    verify(
      () => incidentRepository.createIncident(
        title: 'Leaking tap',
        description: 'The tap in the Block B bathroom will not stop running.',
        category: IncidentCategory.water,
        location: 'Block B',
        reporter: reporter,
        photoUrl: null,
      ),
    ).called(1);
    expect(find.text('Report submitted. Thank you!'), findsOneWidget);
    expect(find.text('Open form'), findsOneWidget);
  });
}
