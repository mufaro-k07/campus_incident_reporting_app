import '../../models/incident.dart';
import '../../models/incident_category.dart';
import '../../models/incident_status.dart';

List<Incident> filterIncidents(
  List<Incident> incidents, {
  String searchText = '',
  IncidentStatus? status,
  IncidentCategory? category,
  String? reporterId,
}) {
  final query = searchText.trim().toLowerCase();
  return incidents.where((incident) {
    if (status != null && incident.status != status) return false;
    if (category != null && incident.category != category) return false;
    if (reporterId != null && incident.reporterId != reporterId) return false;
    return query.isEmpty || _searchableText(incident).contains(query);
  }).toList();
}

String _searchableText(Incident incident) {
  return [
    incident.title,
    incident.description,
    incident.location,
    incident.reporterName,
    incident.category.label,
  ].join(' ').toLowerCase();
}
