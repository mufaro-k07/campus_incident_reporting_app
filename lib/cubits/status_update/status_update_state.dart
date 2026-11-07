import 'package:equatable/equatable.dart';

enum StatusUpdateStatus { initial, saving, success, failure }

class StatusUpdateState extends Equatable {
  const StatusUpdateState({
    this.status = StatusUpdateStatus.initial,
    this.errorMessage,
  });

  final StatusUpdateStatus status;
  final String? errorMessage;

  bool get isSaving => status == StatusUpdateStatus.saving;

  @override
  List<Object?> get props => [status, errorMessage];
}
