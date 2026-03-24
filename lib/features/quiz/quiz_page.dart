import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../auth/data/auth_service.dart';
import 'quiz_provider.dart';
import 'widgets/timer_widget.dart';

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({super.key});

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  int? selectedAnswerIndex;
  bool hasAnswered = false;
  bool scoreSaved = false;
  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Start quiz when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startQuiz();
    });
  }

  Future<void> _startQuiz() async {
    await ref.read(quizProvider.notifier).startQuiz();
  }

  Future<void> _saveScore(int score) async {
    if (scoreSaved) return; // Prevent saving multiple times
    scoreSaved = true;
    
    try {
      await authService.updateProfileAfterQuiz(scoreEarned: score);
    } catch (e) {
      // Handle error silently
    }
  }

  void _answerQuestion(int index) {
    if (hasAnswered) return; // Prevent multiple answers
    
    setState(() {
      selectedAnswerIndex = index;
      hasAnswered = true;
    });

    // Wait 2 seconds to show feedback, then move to next question
    Future.delayed(const Duration(seconds: 2), () {
      ref.read(quizProvider.notifier).answerQuestion(index);
      if (mounted) {
        setState(() {
          selectedAnswerIndex = null;
          hasAnswered = false;
        });
        
        // Check if quiz is finished and save score
        final quizState = ref.read(quizProvider);
        if (quizState.currentIndex >= quizState.questions.length) {
          _saveScore(quizState.score);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);
    
    // Show loading if no questions yet or still loading
    if (quizState.questions.isEmpty || quizState.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Generating Questions...'),
          backgroundColor: AppColors.background,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Loading your quiz...',
                style: AppTextStyles.body.copyWith(color: AppColors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Quiz finished
    if (quizState.currentIndex >= quizState.questions.length) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Quiz Finished'),
          backgroundColor: AppColors.background,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    size: 60,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Congratulations!',
                  style: AppTextStyles.title.copyWith(fontSize: 28),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your Score',
                  style: AppTextStyles.body.copyWith(color: AppColors.grey),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${quizState.score}',
                  style: AppTextStyles.title.copyWith(
                    fontSize: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  text: 'Back to Home',
                  icon: Icons.home_rounded,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show current question
    final question = quizState.questions[quizState.currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Question ${quizState.currentIndex + 1}/${quizState.questions.length}',
        ),
        backgroundColor: AppColors.background,
        actions: [
          // Score Widget
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs / 2,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${quizState.score}',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (quizState.currentIndex + 1) / quizState.questions.length,
                backgroundColor: AppColors.grey.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 8,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Category badge and Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs / 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      question.category.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs / 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer, size: 16, color: AppColors.white),
                        const SizedBox(width: 4),
                        const TimerWidget(),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Question card
              AppCard(
                child: Text(
                  question.question,
                  style: AppTextStyles.title.copyWith(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Answer options
              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    final isCorrect = index == question.correctIndex;
                    final isSelected = selectedAnswerIndex == index;
                    final showResult = hasAnswered;
                    
                    Color backgroundColor;
                    Color textColor = AppColors.white;
                    
                    if (showResult) {
                      if (isCorrect) {
                        // Always show correct answer in green
                        backgroundColor = AppColors.success;
                      } else if (isSelected) {
                        // Show wrong selected answer in red
                        backgroundColor = AppColors.error;
                      } else {
                        // Other options stay normal
                        backgroundColor = AppColors.grey.withValues(alpha: 0.3);
                      }
                    } else {
                      backgroundColor = AppColors.primary;
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: GestureDetector(
                        onTap: hasAnswered ? null : () => _answerQuestion(index),
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: Center(
                            child: Text(
                              question.options[index],
                              style: AppTextStyles.button.copyWith(color: textColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
