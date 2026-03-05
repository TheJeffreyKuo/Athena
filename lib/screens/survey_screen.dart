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
    switch (q.type) {
      case QuestionType.text:
        return TextFormField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Type your answer...',
          ),
          maxLines: q.maxLines,
          validator: q.isRequired
              ? (v) => (v == null || v.trim().isEmpty) ? 'This field is required' : null
              : null,
          onSaved: (v) => _answers[q.id] = v?.trim() ?? '',
        );

      case QuestionType.multipleChoice:
        return FormField<String>(
          validator: q.isRequired
              ? (v) => v == null ? 'Please select an option' : null
              : null,
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...q.options!.map((option) => RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: _answers[q.id] as String?,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) {
                        setState(() => _answers[q.id] = v);
                        state.didChange(v);
                      },
                    )),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );

      case QuestionType.checkbox:
        return FormField<List<String>>(
          initialValue: _answers[q.id] as List<String>? ?? [],
          validator: q.isRequired
              ? (v) => (v == null || v.isEmpty) ? 'Select at least one option' : null
              : null,
          builder: (state) {
            final selected = _answers[q.id] as List<String>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...q.options!.map((option) => CheckboxListTile(
                      title: Text(option),
                      value: selected.contains(option),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            selected.add(option);
                          } else {
                            selected.remove(option);
                          }
                        });
                        state.didChange(selected);
                      },
                    )),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
    }
  }
}
