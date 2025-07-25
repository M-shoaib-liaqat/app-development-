import 'package:cloud_firestore/cloud_firestore.dart';

class EventRequestService {
  static Future<void> createEventRequest({
    required String eventId,
    required String collection,
    required String eventName,
    required String createdBy,
    required String type,
    List<String>? facilities,
  }) async {
    final Map<String, dynamic> requestData = {
      'eventId': eventId,
      'collection': collection,
      'eventName': eventName,
      'createdBy': createdBy,
      'type': type,
      'status': 'pending',
      'created_at': FieldValue.serverTimestamp(),
    };

    if (facilities != null && facilities.isNotEmpty) {
      requestData['facilities'] = facilities;
    }

    await FirebaseFirestore.instance.collection('event_requests').add(requestData);
  }

  static Future<void> updateRequestStatus(String requestId, String status) async {
    await FirebaseFirestore.instance.collection('event_requests').doc(requestId).update({
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<List<String>> getFacilitiesFromEvent(String eventId, String collection) async {
    final doc = await FirebaseFirestore.instance.collection(collection).doc(eventId).get();
    final data = doc.data();
    if (data == null) return [];
    final facilities = data['facilities'] ?? [];
    return List<String>.from(facilities);
  }

  static Future<Map<String, List<String>>> getFacilityProviders(List<String> facilities) async {
    Map<String, List<String>> providerMap = {};

    for (final facility in facilities) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('facilities')
          .where('facility', isEqualTo: facility)
          .get();

      final emails = querySnapshot.docs
          .map((doc) => doc['email'])
          .where((email) => email != null && email.contains('@'))
          .cast<String>()
          .toList();

      providerMap[facility] = emails;
    }

    return providerMap;
  }
}
