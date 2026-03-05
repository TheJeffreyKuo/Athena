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

// Survey question definitions
const List<Question> surveyQuestions = [
  Question(
    id: 'name',
    title: 'What is your name?',
    type: QuestionType.text,
  ),
  Question(
    id: 'theme',
    title: 'What theme do you use?',
    type: QuestionType.multipleChoice,
    options: ['Dark', 'Light'],
  ),
  Question(
    id: 'pages',
    title: 'What pages do you use? (Select all that apply)',
    type: QuestionType.checkbox,
    options: ['Off', 'Pit/Drive', 'Pit/Reverse', 'Endurance', 'Efficiency'],
  ),
  Question(
    id: 'liked_features',
    title: 'What features do you like?',
    type: QuestionType.text,
    maxLines: 4,
  ),
  Question(
    id: 'feature_requests',
    title: 'Are there any features you would request or improve to enhance your user experience?',
    type: QuestionType.text,
    maxLines: 4,
  ),
];
