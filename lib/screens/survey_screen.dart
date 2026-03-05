import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/firebase_service.dart';

// Survey form screen
class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _answers = {};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    for (final q in surveyQuestions) {
      if (q.type == QuestionType.checkbox) {
        _answers[q.id] = <String>[];
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _submitting = true);
    try {
      await FirebaseService.submitResponse(_answers);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Response submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _formKey.currentState!.reset();
      setState(() {
        _answers.clear();
        for (final q in surveyQuestions) {
          if (q.type == QuestionType.checkbox) {
            _answers[q.id] = <String>[];
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Survey')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...surveyQuestions.map(_buildQuestion),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(_submitting ? 'Submitting...' : 'Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(Question q) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.title, style: Theme.of(context).textTheme.titleMedium),
            if (q.isRequired)
              Text('Required', style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              )),
            const SizedBox(height: 12),
            _buildInput(q),
          ],
        ),
      ),
    );
  }

  // Builds the input widget for a question
  Widget _buildInput(Question q) {
    return const Text('Input placeholder');
  }
}
