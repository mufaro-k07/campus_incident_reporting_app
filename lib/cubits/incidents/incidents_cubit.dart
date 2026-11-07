import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/incident.dart';
import '../../models/incident_category.dart';
import '../../models/incident_status.dart';
import '../../repositories/incident_repository.dart';
import 'incidents_state.dart';

class IncidentsCubit extends Cubit<IncidentsState> {
  IncidentsCubit({
    required this._incidentRepository,
    required String currentUserId,
  }) : super(IncidentsState(currentUserId: currentUserId));

  final IncidentRepository _incidentRepository;
  StreamSubscription<List<Incident>>? _incidentsSubscription;

  void start() {
    _incidentsSubscription?.cancel();
    emit(state.copyWith(status: IncidentsStatus.loading));
    _incidentsSubscription = _incidentRepository.watchIncidents().listen(
      _onIncidentsLoaded,
      onError: (_) => emit(state.copyWith(status: IncidentsStatus.error)),
    );
  }

  void _onIncidentsLoaded(List<Incident> incidents) {
    emit(state.copyWith(status: IncidentsStatus.loaded, incidents: incidents));
  }

  void search(String text) {
    emit(state.copyWith(searchText: text));
  }

  void filterByStatus(IncidentStatus? status) {
    emit(state.withStatusFilter(status));
  }

  void filterByCategory(IncidentCategory? category) {
    emit(state.withCategoryFilter(category));
  }

  void showOnlyMine(bool onlyMine) {
    emit(state.copyWith(showOnlyMine: onlyMine));
  }

  @override
  Future<void> close() async {
    await _incidentsSubscription?.cancel();
    return super.close();
  }
}
