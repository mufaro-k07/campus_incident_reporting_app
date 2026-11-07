import '../models/incident_category.dart';

class SampleIncident {
  const SampleIncident({
    required this.title,
    required this.description,
    required this.category,
    required this.location,
  });

  final String title;
  final String description;
  final IncidentCategory category;
  final String location;
}

// Example reports for demos and testing. Only added from a debug build.
const sampleIncidents = [
  SampleIncident(
    title: 'Flickering lights in the Learning Commons',
    description: 'The ceiling lights near the stairs flicker all evening.',
    category: IncidentCategory.electricity,
    location: 'Learning Commons',
  ),
  SampleIncident(
    title: 'No water in the Wellness Center sinks',
    description:
        'The sinks in the Wellness Center have had no water since morning.',
    category: IncidentCategory.water,
    location: 'Wellness Center',
  ),
  SampleIncident(
    title: 'Broken desk in the Library',
    description: 'A study desk near the entrance has a loose leg and wobbles.',
    category: IncidentCategory.furniture,
    location: 'Library',
  ),
  SampleIncident(
    title: 'Overflowing bins at the Cafeteria',
    description: 'The bins behind the Cafeteria are full and attract flies.',
    category: IncidentCategory.sanitation,
    location: 'Cafeteria',
  ),
  SampleIncident(
    title: 'Main gate light is off',
    description: 'The light at the main gate is off, so the path is very dark.',
    category: IncidentCategory.safety,
    location: 'Parking',
  ),
  SampleIncident(
    title: 'Leaking roof in the Auditorium',
    description: 'Water drips from the roof near the stage when it rains.',
    category: IncidentCategory.facilities,
    location: 'Auditorium',
  ),
  SampleIncident(
    title: 'Projector not working in the Enterprise Commons',
    description: 'The projector in the meeting room does not turn on.',
    category: IncidentCategory.electricity,
    location: 'Enterprise Commons',
  ),
  SampleIncident(
    title: 'Torn net on the Basketball Court',
    description: 'The net on the north hoop is torn and hanging down.',
    category: IncidentCategory.other,
    location: 'Basketball Court',
  ),
];
