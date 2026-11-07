import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'incident_category.dart';
import 'incident_status.dart';
import 'status_change.dart';

class Incident extends Equatable {
  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    required this.createdAt,
    required this.updatedAt,
    required this.statusHistory,
    this.photoUrl,
  });

  factory Incident.fromMap(String id, Map<String, dynamic> map) {
    final history = map['statusHistory'] as List<dynamic>? ?? [];
    return Incident(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: IncidentCategory.fromName(map['category'] as String?),
      location: map['location'] as String? ?? '',
      status: IncidentStatus.fromName(map['status'] as String?),
      reporterId: map['reporterId'] as String? ?? '',
      reporterName: map['reporterName'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      createdAt: _readDate(map['createdAt']),
      updatedAt: _readDate(map['updatedAt']),
      statusHistory: history
          .map((entry) => StatusChange.fromMap(entry as Map<String, dynamic>))
          .toList(),
    );
  }

  final String id;
  final String title;
  final String description;
  final IncidentCategory category;
  final String location;
  final IncidentStatus status;
  final String reporterId;
  final String reporterName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<StatusChange> statusHistory;

  bool get canBeChangedByReporter => status == IncidentStatus.submitted;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category.name,
      'location': location,
      'status': status.name,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'statusHistory': statusHistory.map((change) => change.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    location,
    status,
    reporterId,
    reporterName,
    photoUrl,
    createdAt,
    updatedAt,
    statusHistory,
  ];
}

// A serverTimestamp() field reads as null until the server has saved the
// write, so the local time is used for that short moment.
DateTime _readDate(Object? value) {
  return value is Timestamp ? value.toDate() : DateTime.now();
}
