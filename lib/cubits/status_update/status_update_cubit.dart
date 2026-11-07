import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/app_user.dart';
import '../../models/incident.dart';
import '../../repositories/incident_repository.dart';
import 'status_update_state.dart';

class StatusUpdateCubit extends Cubit<StatusUpdateState> {
  StatusUpdateCubit({required this._incidentRepository, required this._staff})
    : super(const StatusUpdateState());

  final IncidentRepository _incidentRepository;
  final AppUser _staff;

  Future<void> moveToNextStatus(Incident incident, String note) async {
    final nextStatus = incident.status.next;
    if (nextStatus == null) return;

    emit(const StatusUpdateState(status: StatusUpdateStatus.saving));
    try {
      final trimmedNote = note.trim();
      await _incidentRepository.updateStatus(
        incidentId: incident.id,
        newStatus: nextStatus,
        changedBy: _staff,
        note: trimmedNote.isEmpty ? null : trimmedNote,
      );
      emit(const StatusUpdateState(status: StatusUpdateStatus.success));
    } catch (_) {
      emit(
        const StatusUpdateState(
          status: StatusUpdateStatus.failure,
          errorMessage:
              'Could not update the status. Check your connection and try '
              'again.',
        ),
      );
    }
  }
}
