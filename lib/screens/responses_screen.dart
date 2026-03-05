import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/survey_response.dart';
import '../services/firebase_service.dart';

// Displays all submitted survey responses
class ResponsesScreen extends StatelessWidget {
  const ResponsesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Responses')),
      body: StreamBuilder<List<SurveyResponse>>(
        stream: FirebaseService.getResponses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final responses = snapshot.data ?? [];
          if (responses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No responses yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: responses.length,
            itemBuilder: (context, index) {
              final r = responses[index];
              final date = DateFormat.yMMMd().add_jm().format(r.submittedAt);
              final name = r.answers['name']?.toString();
              final title = (name != null && name.isNotEmpty) ? name : date;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: (name != null && name.isNotEmpty) ? Text(date) : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
