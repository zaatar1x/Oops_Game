import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/question_model.dart';
import 'services/question_generator_service.dart';

class QuizState {
  final List<Question> questions;
  final int currentIndex;
  final int score;
  final int timeLeft;
  final bool isLoading;
  final String? error;
  final int correctStreak; // Track consecutive correct answers

  bool get isFinished => currentIndex >= questions.length;

  QuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.score = 0,
    this.timeLeft = 180,
    this.isLoading = false,
    this.error,
    this.correctStreak = 0,
  });

  QuizState copyWith({
    List<Question>? questions,
    int? currentIndex,
    int? score,
    int? timeLeft,
    bool? isLoading,
    bool? isFinished,
    String? error,
    int? correctStreak,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      timeLeft: timeLeft ?? this.timeLeft,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      correctStreak: correctStreak ?? this.correctStreak,
    );
  }
}

class QuizNotifier extends Notifier<QuizState> {
  final quizService = QuizService();

  @override
  QuizState build() {
    return QuizState();
  }

  Future<void> startQuiz() async {
    try {
      state = state.copyWith(isLoading: true, isFinished: false);

      final questions = await quizService.fetchQuestions();

      state = state.copyWith(
        questions: questions,
        isLoading: false,
        currentIndex: 0,
        score: 0,
        timeLeft: 180,
        isFinished: false,
        correctStreak: 0,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void answerQuestion(int selectedIndex) {
    if (state.isFinished) return;

    final currentQuestion = state.questions[state.currentIndex];
    final isCorrect = selectedIndex == currentQuestion.correctIndex;

    int newScore = state.score;
    int newStreak = state.correctStreak;

    if (isCorrect) {
      // Add base points for correct answer
      newScore += 10;
      
      // Increment streak
      newStreak += 1;
      
      // Award streak bonus every 3 correct answers in a row
      if (newStreak % 3 == 0) {
        newScore += 10; // +10 streak bonus
      }
    } else {
      // Reset streak on wrong answer
      newStreak = 0;
    }

    // Always increment currentIndex to move forward
    final newIndex = state.currentIndex + 1;
    
    // Check if quiz is finished after incrementing
    final finished = newIndex >= state.questions.length;

    // If finished before time runs out, add time bonus
    if (finished && state.timeLeft > 0) {
      newScore += 20; // +20 bonus for finishing before time
    }

    state = state.copyWith(
      score: newScore,
      currentIndex: newIndex,
      isFinished: finished,
      correctStreak: newStreak,
    );
  }

  void decreaseTime() {
    if (state.timeLeft > 0) {
      state = state.copyWith(timeLeft: state.timeLeft - 1);
    } else {
      // Time's up! End quiz with 0 score
      state = state.copyWith(
        isFinished: true,
        score: 0, // Reset score to 0 when time runs out
        currentIndex: state.questions.length, // Move to end to show completion screen
      );
    }
  }

  void resetQuiz() {
    state = QuizState();
  }
}

final quizProvider = NotifierProvider<QuizNotifier, QuizState>(() {
  return QuizNotifier();
});