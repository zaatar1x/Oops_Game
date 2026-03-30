import 'package:flame/components.dart';
import 'components/grid_component.dart';
import 'services/memory_service.dart';
import 'controllers/memory_controller.dart';
import '../../auth/data/auth_service.dart';
import '../../ranking/data/ranking_service.dart';

class MemoryWorld extends World {
  final String difficulty;

  MemoryWorld({required this.difficulty});

  final service = MemoryService();
  final authService = AuthService();
  final rankingService = RankingService();

  late MemoryController controller;
  late GridComponent grid;

  bool _isGameFinishedHandled = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final cards = service.generate(difficulty);

    controller = MemoryController(cards);

    grid = GridComponent(
      cards: controller.cards,
      onCardTap: controller.onCardTapped,
    );

    add(grid);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (controller.isFinished && !_isGameFinishedHandled) {
      _isGameFinishedHandled = true;
      _handleGameComplete();
    }
  }

  Future<void> _handleGameComplete() async {
    try {
      final user = authService.currentUser;
      if (user == null) return;

      // Calculate score based on difficulty
      int score = _getScoreForDifficulty();

      // Get current profile to get streak
      final profile = await authService.getProfile();
      if (profile == null) return;

      // Update profile (XP, games played, streak, level)
      await authService.updateProfileAfterQuiz(scoreEarned: score);

      // Update RP in ranking system
      await rankingService.updateRP(
        userId: user.id,
        score: score,
        streak: profile.streak + 1, // Use updated streak
      );

      print("✅ Memory game completed! Score: $score, Difficulty: $difficulty");
    } catch (e) {
      print("❌ Error updating score: $e");
    }
  }

  int _getScoreForDifficulty() {
    switch (difficulty) {
      case 'easy':
        return 50; // Easy: 50 XP/RP base
      case 'medium':
        return 100; // Medium: 100 XP/RP base
      case 'hard':
        return 150; // Hard: 150 XP/RP base
      default:
        return 50;
    }
  }

  void restart() {
    removeAll(children);
    _isGameFinishedHandled = false;
    onLoad();
  }
}