import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../features/auth/data/auth_service.dart';
import '../features/auth/data/profile_model.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/app_card.dart';
import '../shared/widgets/app_progress_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final auth = AuthService();
  Profile? profile;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    final data = await auth.getProfile();
    if (mounted) {
      setState(() {
        profile = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: profile == null
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // XP Progress Card
                    _buildXPCard(),
                    
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Level & Rank Cards
                    Row(
                      children: [
                        Expanded(child: _buildLevelCard()),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: _buildRankCard()),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Play Now Button
                    AppButton(
                      text: 'Play Now',
                   
                      icon: Icons.play_arrow_rounded,
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Daily Tasks Section
                    _buildDailyTasks(),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Stats Section
                    _buildStatsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${profile!.firstName ?? "Player"}! 👋',
              style: AppTextStyles.title,
            ),
            const SizedBox(height: AppSpacing.xs / 2),
            Text(
              'Ready to learn something new?',
              style: AppTextStyles.body.copyWith(color: AppColors.grey),
            ),
          ],
        ),
        IconButton(
          onPressed: () async {
            await auth.signOut();
          },
          icon: Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(Icons.logout, color: AppColors.error),
          ),
        ),
      ],
    );
  }

  Widget _buildXPCard() {
    final currentXP = profile!.xp;
    final progress = (currentXP % 1000) / 1000;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Experience Points',
                style: AppTextStyles.subtitle,
              ),
              Container(
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
                      '$currentXP XP',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppProgressBar(
            progress: progress,
            height: 16,
            showPercentage: false,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${(currentXP % 1000)} / 1000 XP to Level ${profile!.level + 1}',
            style: AppTextStyles.caption.copyWith(color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard() {
    return AppCard(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${profile!.level}',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Level',
            style: AppTextStyles.body.copyWith(color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRankCard() {
    return AppCard(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              size: 32,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            profile!.rank,
            style: AppTextStyles.body.copyWith(
              color: AppColors.greyDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTasks() {
    final tasks = [
      {'title': 'Complete 3 quizzes', 'xp': 150, 'completed': false},
      {'title': 'Win 2 games', 'xp': 200, 'completed': false},
      {'title': 'Daily login streak', 'xp': 50, 'completed': true},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Tasks',
          style: AppTextStyles.subtitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...tasks.map((task) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: task['completed'] as bool
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Icon(
                        task['completed'] as bool
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: task['completed'] as bool
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task['title'] as String,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.greyDark,
                            ),
                          ),
                          Text(
                            '+${task['xp']} XP',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildStatsSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Stats',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.videogame_asset_rounded,
                label: 'Games',
                value: profile!.gamesPlayed.toString(),
              ),
              _buildStatItem(
                icon: Icons.local_fire_department_rounded,
                label: 'Streak',
                value: profile!.streak.toString(),
              ),
              _buildStatItem(
                icon: Icons.trending_up_rounded,
                label: 'Rating',
                value: profile!.skillRating.toStringAsFixed(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 32),
        const SizedBox(height: AppSpacing.xs / 2),
        Text(
          value,
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.greyDark,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.grey),
        ),
      ],
    );
  }
}