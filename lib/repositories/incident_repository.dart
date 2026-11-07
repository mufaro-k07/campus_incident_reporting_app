import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../models/incident_category.dart';
import '../models/incident_status.dart';
import '../models/status_change.dart';

class IncidentRepository {
  IncidentRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _incidents =>
      _firestore.collection('incidents');

  Stream<List<Incident>> watchIncidents() {
    return _incidents
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Incident.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> createIncident({
    required String title,
    required String description,
    required IncidentCategory category,
    required String location,
    required AppUser reporter,
    String? photoUrl,
  }) {
    final now = DateTime.now();
    final incident = Incident(
      id: '',
      title: title,
      description: description,
      category: category,
      location: location,
      status: IncidentStatus.submitted,
      reporterId: reporter.uid,
      reporterName: reporter.name,
      photoUrl: photoUrl,
      createdAt: now,
      updatedAt: now,
      // serverTimestamp() isn't allowed inside arrays, so the history entry
      // uses the phone's time.
      statusHistory: [
        StatusChange(
          status: IncidentStatus.submitted,
          changedBy: reporter.uid,
          changedByName: reporter.name,
          at: now,
        ),
      ],
    );
    return _incidents.add({
      ...incident.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatus({
    required String incidentId,
    required IncidentStatus newStatus,
    required AppUser changedBy,
    String? note,
  }) {
    // serverTimestamp() isn't allowed inside arrays, so use the phone's time.
    final change = StatusChange(
      status: newStatus,
      changedBy: changedBy.uid,
      changedByName: changedBy.name,
      note: note,
      at: DateTime.now(),
    );
    return _incidents.doc(incidentId).update({
      'status': newStatus.name,
      'statusHistory': FieldValue.arrayUnion([change.toMap()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateIncident({
    required String incidentId,
    required String title,
    required String description,
    required IncidentCategory category,
    required String location,
    String? photoUrl,
  }) {
    return _incidents.doc(incidentId).update({
      'title': title,
      'description': description,
      'category': category.name,
      'location': location,
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteIncident(String incidentId) {
    return _incidents.doc(incidentId).delete();
  }
}
