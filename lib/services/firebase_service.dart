import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/survey_response.dart';

// Handles Firestore CRUD operations for survey responses
class FirebaseService {
  static final _collection =
      FirebaseFirestore.instance.collection('survey_responses');

  // Submits a response, filtering out empty answers
  static Future<void> submitResponse(Map<String, dynamic> answers) async {
    final filtered = Map<String, dynamic>.from(answers)
      ..removeWhere((key, value) {
        if (value == null) return true;
        if (value is String && value.trim().isEmpty) return true;
        if (value is List && value.isEmpty) return true;
        return false;
      });

    final response = SurveyResponse(
      answers: filtered,
      submittedAt: DateTime.now(),
    );
    await _collection.add(response.toMap());
  }

  // Streams all responses, newest first
  static Stream<List<SurveyResponse>> getResponses() {
    return _collection
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SurveyResponse.fromFirestore(doc))
            .toList());
  }

  // Deletes a response by document ID
  static Future<void> deleteResponse(String id) async {
    await _collection.doc(id).delete();
  }
}
