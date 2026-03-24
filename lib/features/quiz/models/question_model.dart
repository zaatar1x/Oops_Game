class Question {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String category;

  Question({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.category,
  });
}