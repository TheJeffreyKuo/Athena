import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/question.dart';
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
                child: ExpansionTile(
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: (name != null && name.isNotEmpty) ? Text(date) : null,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: surveyQuestions.map((q) {
                          final answer = r.answers[q.id];
                          if (answer == null) return const SizedBox.shrink();
                          String display;
                          if (answer is List) {
                            display = answer.isNotEmpty ? answer.join(', ') : '—';
                          } else {
                            final text = answer.toString();
                            display = text.isNotEmpty ? text : '—';
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    q.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(display,
                                      style: const TextStyle(fontSize: 13)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _confirmDelete(context, r.id!),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Delete'),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Shows a delete confirmation dialog
  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Response?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              FirebaseService.deleteResponse(id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
