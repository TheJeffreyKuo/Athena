import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a single submitted survey response
class SurveyResponse {
  final String? id;
  final Map<String, dynamic> answers;
  final DateTime submittedAt;

  SurveyResponse({
    this.id,
    required this.answers,
    required this.submittedAt,
  });

  factory SurveyResponse.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SurveyResponse(
      id: doc.id,
      answers: Map<String, dynamic>.from(data['answers'] ?? {}),
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'answers': answers,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }
}
