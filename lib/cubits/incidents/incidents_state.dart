import 'package:equatable/equatable.dart';

import '../../core/utils/incident_filter.dart';
import '../../models/incident.dart';
import '../../models/incident_category.dart';
import '../../models/incident_status.dart';

enum IncidentsStatus { loading, loaded, error }

class IncidentsState extends Equatable {
  const IncidentsState({
    required this.currentUserId,
    this.status = IncidentsStatus.loading,
    this.incidents = const [],
    this.searchText = '',
    this.statusFilter,
    this.categoryFilter,
    this.showOnlyMine = false,
  });

  final String currentUserId;
  final IncidentsStatus status;
  final List<Incident> incidents;
  final String searchText;
  final IncidentStatus? statusFilter;
  final IncidentCategory? categoryFilter;
  final bool showOnlyMine;

  List<Incident> get visibleIncidents {
    return filterIncidents(
      incidents,
      searchText: searchText,
      status: statusFilter,
      category: categoryFilter,
      reporterId: showOnlyMine ? currentUserId : null,
    );
  }

  List<Incident> get myIncidents {
    return incidents
        .where((incident) => incident.reporterId == currentUserId)
        .toList();
  }

  Incident? findById(String incidentId) {
    for (final incident in incidents) {
      if (incident.id == incidentId) return incident;
    }
    return null;
  }

  IncidentsState copyWith({
    IncidentsStatus? status,
    List<Incident>? incidents,
    String? searchText,
    bool? showOnlyMine,
  }) {
    return IncidentsState(
      currentUserId: currentUserId,
      status: status ?? this.status,
      incidents: incidents ?? this.incidents,
      searchText: searchText ?? this.searchText,
      statusFilter: statusFilter,
      categoryFilter: categoryFilter,
      showOnlyMine: showOnlyMine ?? this.showOnlyMine,
    );
  }

  // The filters get their own methods because null means "show all",
  // which copyWith cannot tell apart from "keep the old value".
  IncidentsState withStatusFilter(IncidentStatus? filter) {
    return IncidentsState(
      currentUserId: currentUserId,
      status: status,
      incidents: incidents,
      searchText: searchText,
      statusFilter: filter,
      categoryFilter: categoryFilter,
      showOnlyMine: showOnlyMine,
    );
  }

  IncidentsState withCategoryFilter(IncidentCategory? filter) {
    return IncidentsState(
      currentUserId: currentUserId,
      status: status,
      incidents: incidents,
      searchText: searchText,
      statusFilter: statusFilter,
      categoryFilter: filter,
      showOnlyMine: showOnlyMine,
    );
  }

  @override
  List<Object?> get props => [
    currentUserId,
    status,
    incidents,
    searchText,
    statusFilter,
    categoryFilter,
    showOnlyMine,
  ];
}
