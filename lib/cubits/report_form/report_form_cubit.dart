import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants.dart';
import '../../models/app_user.dart';
import '../../models/incident.dart';
import '../../models/incident_category.dart';
import '../../repositories/image_upload_service.dart';
import '../../repositories/incident_repository.dart';
import 'report_form_state.dart';

class ReportFormCubit extends Cubit<ReportFormState> {
  ReportFormCubit({
    required this._incidentRepository,
    required this._imageUploadService,
    required this._reporter,
    this._incidentToEdit,
  }) : super(const ReportFormState());

  final IncidentRepository _incidentRepository;
  final ImageUploadService _imageUploadService;
  final AppUser _reporter;
  final Incident? _incidentToEdit;

  Future<void> setPhoto(XFile photo) async {
    final sizeInBytes = await photo.length();
    if (sizeInBytes > maxPhotoBytes) {
      emit(
        ReportFormState(
          status: ReportFormStatus.failure,
          photo: state.photo,
          errorMessage:
              'That photo is bigger than 5 MB. Please choose a smaller one.',
        ),
      );
      return;
    }
    emit(ReportFormState(photo: photo));
  }

  void removePhoto() {
    emit(const ReportFormState());
  }

  Future<void> submit({
    required String title,
    required String description,
    required IncidentCategory category,
    required String location,
    String? savedPhotoUrl,
  }) async {
    final photo = state.photo;
    emit(ReportFormState(status: ReportFormStatus.submitting, photo: photo));

    var photoUrl = savedPhotoUrl;
    if (photo != null) {
      try {
        photoUrl = await _imageUploadService.uploadImage(photo);
      } catch (_) {
        emit(
          ReportFormState(
            status: ReportFormStatus.failure,
            photo: photo,
            errorMessage:
                'The photo could not be uploaded. Try again, or remove the '
                'photo to send the report without it.',
          ),
        );
        return;
      }
    }

    try {
      final incidentToEdit = _incidentToEdit;
      if (incidentToEdit == null) {
        await _incidentRepository.createIncident(
          title: title,
          description: description,
          category: category,
          location: location,
          reporter: _reporter,
          photoUrl: photoUrl,
        );
      } else {
        await _incidentRepository.updateIncident(
          incidentId: incidentToEdit.id,
          title: title,
          description: description,
          category: category,
          location: location,
          photoUrl: photoUrl,
        );
      }
      emit(const ReportFormState(status: ReportFormStatus.success));
    } catch (_) {
      emit(
        ReportFormState(
          status: ReportFormStatus.failure,
          photo: photo,
          errorMessage:
              'Your report could not be saved. Check your connection and '
              'try again.',
        ),
      );
    }
  }
}
