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
    title: 'Flickering lights in Block A',
    description:
        'The ceiling lights in the Block A corridor flicker all evening.',
    category: IncidentCategory.electricity,
    location: 'Block A',
  ),
  SampleIncident(
    title: 'No water in Hostel showers',
    description: 'The second floor showers have had no water since morning.',
    category: IncidentCategory.water,
    location: 'Hostel',
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
    title: 'Projector not working in Block C',
    description: 'The projector in room C2 does not turn on.',
    category: IncidentCategory.electricity,
    location: 'Block C',
  ),
  SampleIncident(
    title: 'Goal net torn on the Sports Field',
    description: 'The net on the north goal is torn and hanging down.',
    category: IncidentCategory.other,
    location: 'Sports Field',
  ),
];
