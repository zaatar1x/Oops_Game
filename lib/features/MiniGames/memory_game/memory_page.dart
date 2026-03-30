import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'services/memory_service.dart';
import 'controllers/memory_controller.dart';
import 'models/memory_card_model.dart';
import '../../auth/data/auth_service.dart';
import '../../ranking/data/ranking_service.dart';

class MemoryPage extends StatefulWidget {
  final String difficulty;

  const MemoryPage({
    super.key,
    required this.difficulty,
  });

  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> with TickerProviderStateMixin {
  late MemoryController controller;
  final service = MemoryService();
  final authService = AuthService();
  final rankingService = RankingService();
  
  bool _isGameFinishedHandled = false;
  int moves = 0;
  int matches = 0;
  late AnimationController _celebrationController;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _initGame();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _initGame() {
    final cards = service.generate(widget.difficulty);
    controller = MemoryController(cards);
    controller.onStateChanged = () {
      if (mounted) {
        setState(() {
          // Check if a match was made
          final newMatches = controller.cards.where((c) => c.isMatched).length ~/ 2;
          if (newMatches > matches) {
            matches = newMatches;
            _celebrationController.forward(from: 0);
          }
        });
      }
    };
    moves = 0;
    matches = 0;
    _isGameFinishedHandled = false;
    
    Future.delayed(const Duration(milliseconds: 500), _checkGameCompletion);
  }

  void _checkGameCompletion() {
    if (!mounted) return;
    
    if (controller.isFinished && !_isGameFinishedHandled) {
      _isGameFinishedHandled = true;
      _celebrationController.forward();
      Future.delayed(const Duration(milliseconds: 800), _handleGameComplete);
    } else if (!controller.isFinished) {
      Future.delayed(const Duration(milliseconds: 500), _checkGameCompletion);
    }
  }

  Future<void> _handleGameComplete() async {
    try {
      final user = authService.currentUser;
      if (user == null) return;

      int score = _getScoreForDifficulty();
      final profile = await authService.getProfile();
      if (profile == null) return;

      await authService.updateProfileAfterQuiz(scoreEarned: score);
      await rankingService.updateRP(
        userId: user.id,
        score: score,
        streak: profile.streak + 1,
      );

      if (mounted) {
        _showVictoryDialog();
      }
    } catch (e) {
      print("❌ Error updating score: $e");
    }
  }

  void _showVictoryDialog() {
    final score = _getScoreForDifficulty();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScaleTransition(
        scale: CurvedAnimation(
          parent: _celebrationController,
          curve: Curves.elasticOut,
        ),
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '🎉 Victory! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Amazing memory!',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getDifficultyColor().withValues(alpha: 0.1),
                      _getDifficultyColor().withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getDifficultyColor().withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    _buildStatRow(
                      icon: Icons.touch_app_rounded,
                      label: 'Moves',
                      value: '$moves',
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      icon: Icons.stars_rounded,
                      label: 'XP Earned',
                      value: '+$score',
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      icon: Icons.trending_up_rounded,
                      label: 'RP Earned',
                      value: '+$score',
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.home_rounded),
              label: const Text('Menu'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.grey,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _restartGame();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Play Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getDifficultyColor(),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  int _getScoreForDifficulty() {
    switch (widget.difficulty) {
      case 'easy':
        return 50;
      case 'medium':
        return 100;
      case 'hard':
        return 150;
      default:
        return 50;
    }
  }

  void _restartGame() {
    setState(() {
      _celebrationController.reset();
      _initGame();
    });
  }

  String _getDifficultyLabel() {
    switch (widget.difficulty) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      default:
        return widget.difficulty;
    }
  }

  Color _getDifficultyColor() {
    switch (widget.difficulty) {
      case 'easy':
        return const Color(0xFF4CAF50);
      case 'medium':
        return const Color(0xFFFF9800);
      case 'hard':
        return const Color(0xFFF44336);
      default:
        return AppColors.primary;
    }
  }

  int _getGridColumns() {
    switch (widget.difficulty) {
      case 'easy':
        return 4;
      case 'medium':
        return 4;
      case 'hard':
        return 5;
      default:
        return 4;
    }
  }

  int _getTotalPairs() {
    switch (widget.difficulty) {
      case 'easy':
        return 6;
      case 'medium':
        return 8;
      case 'hard':
        return 10;
      default:
        return 6;
    }
  }

  void _onCardTap(MemoryCardModel card) {
    if (card.isMatched || card.isFlipped || controller.isBusy) return;
    
    setState(() {
      controller.onCardTapped(card);
      moves++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final columns = _getGridColumns();
    final totalPairs = _getTotalPairs();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.psychology_rounded,
              color: _getDifficultyColor(),
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text('Memory Game'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getDifficultyColor(),
                    _getDifficultyColor().withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _getDifficultyColor().withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _getDifficultyLabel(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '$moves',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _restartGame,
            tooltip: 'Restart',
            color: _getDifficultyColor(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            color: _getDifficultyColor(),
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Progress',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.greyDark,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$matches / $totalPairs pairs',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getDifficultyColor(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: matches / totalPairs,
                      minHeight: 12,
                      backgroundColor: AppColors.grey.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getDifficultyColor(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Game grid
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.white.withValues(alpha: 0.9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: _getDifficultyColor().withValues(alpha: 0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: controller.cards.length,
                      itemBuilder: (context, index) {
                        final card = controller.cards[index];
                        return _MemoryCard(
                          key: ValueKey('${card.id}_${card.isFlipped}_${card.isMatched}'),
                          card: card,
                          onTap: () => _onCardTap(card),
                          difficultyColor: _getDifficultyColor(),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final MemoryCardModel card;
  final VoidCallback onTap;
  final Color difficultyColor;

  const _MemoryCard({
    super.key,
    required this.card,
    required this.onTap,
    required this.difficultyColor,
  });

  @override
  Widget build(BuildContext context) {
    final isRevealed = card.isFlipped || card.isMatched;
    
    return GestureDetector(
      onTap: card.isMatched || card.isFlipped ? null : onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: isRevealed ? 180 : 0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          final isFront = value > 90;
          final angle = (value * 3.14159) / 180;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: Container(
              decoration: BoxDecoration(
                gradient: card.isMatched
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                      )
                    : isFront
                        ? null
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              difficultyColor,
                              difficultyColor.withValues(alpha: 0.7),
                            ],
                          ),
                color: isFront && !card.isMatched ? Colors.white : null,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: card.isMatched
                      ? const Color(0xFF4CAF50)
                      : isFront
                          ? difficultyColor.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.5),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: card.isMatched
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.15),
                    blurRadius: card.isMatched ? 15 : 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: isFront
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(3.14159),
                        child: Text(
                          card.image,
                          style: TextStyle(
                            fontSize: 40,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Icon(
                        Icons.question_mark_rounded,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 32,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
