import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/question_model.dart';
import 'services/question_generator_service.dart';
import '../auth/data/auth_service.dart';
import '../ranking/data/ranking_service.dart';

class QuizState {
  final List<Question> questions;
  final int currentIndex;
  final int score;
  final int timeLeft;
  final bool isLoading;
  final String? error;
  final int correctStreak;
  final bool isFinished;
  final bool isProcessed; // 🔥 prevent double execution

  bool get isQuizCompleted => currentIndex >= questions.length;

  QuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.score = 0,
    this.timeLeft = 180,
    this.isLoading = false,
    this.error,
    this.correctStreak = 0,
    this.isFinished = false,
    this.isProcessed = false,
  });

  QuizState copyWith({
    List<Question>? questions,
    int? currentIndex,
    int? score,
    int? timeLeft,
    bool? isLoading,
    String? error,
    int? correctStreak,
    bool? isFinished,
    bool? isProcessed,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      timeLeft: timeLeft ?? this.timeLeft,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      correctStreak: correctStreak ?? this.correctStreak,
      isFinished: isFinished ?? this.isFinished,
      isProcessed: isProcessed ?? this.isProcessed,
    );
  }
}

class QuizNotifier extends Notifier<QuizState> {
  final quizService = QuizService();
  final authService = AuthService();
  final rankingService = RankingService();

  @override
  QuizState build() {
    return QuizState();
  }

  // 🚀 START QUIZ
  Future<void> startQuiz() async {
    try {
      state = state.copyWith(isLoading: true);

      final questions = await quizService.fetchQuestions();

      state = state.copyWith(
        questions: questions,
        isLoading: false,
        currentIndex: 0,
        score: 0,
        timeLeft: 180,
        correctStreak: 0,
        isFinished: false,
        isProcessed: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 🎯 ANSWER QUESTION
  Future<void> answerQuestion(int selectedIndex) async {
    if (state.isFinished) return;

    final currentQuestion = state.questions[state.currentIndex];
    final isCorrect = selectedIndex == currentQuestion.correctIndex;

    int newScore = state.score;
    int newStreak = state.correctStreak;

    if (isCorrect) {
      newScore += 10;
      newStreak += 1;

      if (newStreak % 3 == 0) {
        newScore += 10;
      }
    } else {
      newStreak = 0;
    }

    final newIndex = state.currentIndex + 1;
    final finished = newIndex >= state.questions.length;

    if (finished && state.timeLeft > 0) {
      newScore += 20;
    }

    state = state.copyWith(
      score: newScore,
      currentIndex: newIndex,
      correctStreak: newStreak,
      isFinished: finished,
    );

    if (finished) {
      await _handleQuizEnd(newScore);
    }
  }

  // ⏱️ TIMER
  Future<void> decreaseTime() async {
    if (state.timeLeft > 0) {
      state = state.copyWith(timeLeft: state.timeLeft - 1);
    } else {
      if (state.isFinished) return;

      state = state.copyWith(
        isFinished: true,
        score: 0,
        currentIndex: state.questions.length,
      );

      await _handleQuizEnd(0);
    }
  }

  // 🔥 HANDLE END OF QUIZ (SAFE VERSION)
  Future<void> _handleQuizEnd(int finalScore) async {
    // ✅ prevent double execution
    if (state.isProcessed) return;

    state = state.copyWith(isProcessed: true);

    final user = authService.currentUser;
    if (user == null) return;

    try {
      // 🔹 update profile → get NEW streak
      final newStreak = await authService.updateProfileAfterQuiz(
        scoreEarned: finalScore,
      );

      // 🔹 update RP
      await rankingService.updateRP(
        userId: user.id,
        score: finalScore,
        streak: newStreak,
      );

      print("✅ Quiz end processed");
    } catch (e) {
      print("❌ Quiz end error: $e");
    }
  }

  // 🔄 RESET
  void resetQuiz() {
    state = QuizState();
  }
}

final quizProvider =
    NotifierProvider<QuizNotifier, QuizState>(() => QuizNotifier());