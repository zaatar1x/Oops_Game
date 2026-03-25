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

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      options: List<String>.from(json['options']),
      correctIndex: json['correct_index'],
      category: json['category'],
    );
  }
}