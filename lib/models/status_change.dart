import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'incident_status.dart';

class StatusChange extends Equatable {
  const StatusChange({
    required this.status,
    required this.changedBy,
    required this.changedByName,
    required this.at,
    this.note,
  });

  factory StatusChange.fromMap(Map<String, dynamic> map) {
    return StatusChange(
      status: IncidentStatus.fromName(map['status'] as String?),
      changedBy: map['changedBy'] as String? ?? '',
      changedByName: map['changedByName'] as String? ?? '',
      note: map['note'] as String?,
      at: (map['at'] as Timestamp).toDate(),
    );
  }

  final IncidentStatus status;
  final String changedBy;
  final String changedByName;
  final String? note;
  final DateTime at;

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'changedBy': changedBy,
      'changedByName': changedByName,
      if (note != null) 'note': note,
      'at': Timestamp.fromDate(at),
    };
  }

  @override
  List<Object?> get props => [status, changedBy, changedByName, note, at];
}
