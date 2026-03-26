import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../data/ranking_service.dart';
import '../models/room_member_model.dart';
import '../models/room_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardPage extends StatefulWidget {
  final String rank;

  const LeaderboardPage({
    super.key,
    required this.rank,
  });

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final rankingService = RankingService();
  final currentUserId = Supabase.instance.client.auth.currentUser?.id;

  List<RoomMember> leaderboard = [];
  Room? currentRoom;
  int? userPosition;
  int totalPlayers = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      final room = await rankingService.getActiveRoomByRank(widget.rank);
      final data = await rankingService.getLeaderboard(
        rank: widget.rank,
        page: 0,
        pageSize: 100,
      );

      int? position;
      if (currentUserId != null) {
        position = await rankingService.getUserRankPosition(currentUserId!);
      }

      final count = await rankingService.getRoomPlayerCount(widget.rank);

      if (mounted) {
        setState(() {
          currentRoom = room;
          leaderboard = data;
          userPosition = position;
          totalPlayers = count;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading leaderboard: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _testRankedResults() async {
    try {
      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );

      final result = await rankingService.testRankedResults();

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Promoted: ${result['promoted']}, Demoted: ${result['demoted']}. Ranks updated!',
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );

      // Go back to home page so user can see their new rank
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${widget.rank} Leaderboard'),
        backgroundColor: AppColors.background,
        actions: [
          // Test button for manual ranked results
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Test Ranked Results',
            onPressed: _testRankedResults,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  _buildRoomInfo(),
                  const SizedBox(height: AppSpacing.md),
                  if (currentUserId != null && userPosition != null)
                    _buildUserPositionCard(),
                  const SizedBox(height: AppSpacing.md),
                  Text('Rankings', style: AppTextStyles.subtitle),
                  const SizedBox(height: AppSpacing.sm),
                  if (leaderboard.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          'No players in this room yet',
                          style: AppTextStyles.body.copyWith(color: AppColors.grey),
                        ),
                      ),
                    )
                  else
                    ...leaderboard.asMap().entries.map((entry) {
                      final index = entry.key;
                      final member = entry.value;
                      final position = index + 1;
                      final isCurrentUser = member.userId == currentUserId;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: _buildLeaderboardItem(
                          member: member,
                          position: position,
                          isCurrentUser: isCurrentUser,
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }

  Widget _buildRoomInfo() {
    final daysLeft = currentRoom?.endDate != null
        ? currentRoom!.endDate!.difference(DateTime.now()).inDays
        : 7; // Default to 7 days if no end date

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: _getRankGradient(widget.rank),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 32,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.rank} Room', style: AppTextStyles.subtitle),
                    const SizedBox(height: 4),
                    Text(
                      '$totalPlayers players',
                      style: AppTextStyles.body.copyWith(color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Resets in $daysLeft days',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserPositionCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        color: AppColors.primary.withValues(alpha: 0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Position', style: AppTextStyles.caption.copyWith(color: AppColors.grey)),
                Text('#$userPosition', style: AppTextStyles.title.copyWith(color: AppColors.primary)),
              ],
            ),
            Text('of $totalPlayers', style: AppTextStyles.body.copyWith(color: AppColors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem({
    required RoomMember member,
    required int position,
    required bool isCurrentUser,
  }) {
    return AppCard(
      color: isCurrentUser ? AppColors.primary.withValues(alpha: 0.1) : AppColors.white,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: position <= 3 ? _getPositionGradient(position) : null,
              color: position > 3 ? AppColors.greyLight : null,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: position <= 3
                  ? Icon(_getPositionIcon(position), color: AppColors.white, size: 20)
                  : Text('$position', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.displayName,
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'YOU',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text('${member.gamesPlayed} games', style: AppTextStyles.caption.copyWith(color: AppColors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${member.rp}', style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold)),
              Text('RP', style: AppTextStyles.caption.copyWith(color: AppColors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  LinearGradient _getRankGradient(String rank) {
    switch (rank) {
      case 'Bronze': return const LinearGradient(colors: [Color(0xFFCD7F32), Color(0xFFE6A85C)]);
      case 'Silver': return const LinearGradient(colors: [Color(0xFFC0C0C0), Color(0xFFE8E8E8)]);
      case 'Gold': return const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFE55C)]);
      case 'Diamond': return const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF7FEFFF)]);
      default: return AppColors.primaryGradient;
    }
  }

  LinearGradient _getPositionGradient(int position) {
    switch (position) {
      case 1: return const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFE55C)]);
      case 2: return const LinearGradient(colors: [Color(0xFFC0C0C0), Color(0xFFE8E8E8)]);
      case 3: return const LinearGradient(colors: [Color(0xFFCD7F32), Color(0xFFE6A85C)]);
      default: return AppColors.primaryGradient;
    }
  }

  IconData _getPositionIcon(int position) {
    switch (position) {
      case 1: return Icons.emoji_events;
      case 2: return Icons.military_tech;
      case 3: return Icons.workspace_premium;
      default: return Icons.star;
    }
  }
}
