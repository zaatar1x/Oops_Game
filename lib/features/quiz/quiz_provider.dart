import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/question_model.dart';
import 'services/question_generator_service.dart';

// Quiz State
class QuizState {
  final List<Question> questions;
  final int currentIndex;
  final int score;
  final int timeLeft;
  final bool isLoading;
  final String? error;

  QuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.score = 0,
    this.timeLeft = 180,
    this.isLoading = false,
    this.error,
  });

  QuizState copyWith({
    List<Question>? questions,
    int? currentIndex,
    int? score,
    int? timeLeft,
    bool? isLoading,
    String? error,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      timeLeft: timeLeft ?? this.timeLeft,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Quiz Notifier (using new Riverpod 3.x Notifier class)
class QuizNotifier extends Notifier<QuizState> {
  final generator = QuestionGeneratorService();

  @override
  QuizState build() {
    return QuizState();
  }

  Future<void> startQuiz({String? category, String? difficulty}) async {
    // Set loading state
    state = state.copyWith(isLoading: true, error: null);
    
    // Small delay to show loading animation
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Generate diverse questions
    final questions = generator.generateQuiz(10);
    
    state = state.copyWith(
      questions: questions,
      isLoading: false,
      currentIndex: 0,
      score: 0,
    );
  }

  void answerQuestion(int selectedIndex) {
    final currentQuestion = state.questions[state.currentIndex];

    if (selectedIndex == currentQuestion.correctIndex) {
      state = state.copyWith(score: state.score + 10);
    }

    // Always move to next question after answering
    state = state.copyWith(currentIndex: state.currentIndex + 1);
  }

  void decreaseTime() {
    if (state.timeLeft > 0) {
      state = state.copyWith(timeLeft: state.timeLeft - 1);
    }
  }
}

// Provider (using new Riverpod 3.x NotifierProvider)
final quizProvider = NotifierProvider<QuizNotifier, QuizState>(() {
  return QuizNotifier();
});
