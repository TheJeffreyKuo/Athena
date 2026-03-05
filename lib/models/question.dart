enum QuestionType { text, multipleChoice, checkbox }

class Question {
  final String id;
  final String title;
  final QuestionType type;
  final List<String>? options;
  final bool isRequired;
  final int maxLines;

  const Question({
    required this.id,
    required this.title,
    required this.type,
    this.options,
    this.isRequired = false,
    this.maxLines = 1,
  });
}
