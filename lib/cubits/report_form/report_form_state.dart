import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

enum ReportFormStatus { initial, submitting, success, failure }

class ReportFormState extends Equatable {
  const ReportFormState({
    this.status = ReportFormStatus.initial,
    this.photo,
    this.errorMessage,
  });

  final ReportFormStatus status;
  final XFile? photo;
  final String? errorMessage;

  bool get isSubmitting => status == ReportFormStatus.submitting;

  @override
  List<Object?> get props => [status, photo, errorMessage];
}
