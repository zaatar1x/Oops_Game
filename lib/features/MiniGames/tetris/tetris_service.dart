import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/data/auth_service.dart';
import '../../ranking/data/ranking_service.dart';

class TetrisService {
  final supabase = Supabase.instance.client;
  final authService = AuthService();
  final rankingService = RankingService();

  /// Save Tetris score to database
  /// - Updates XP in profiles table
  /// - Updates RP in room_members table
  Future<void> saveScore({
    required int score,
    required int level,
    required int linesCleared,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    try {
      // Update profiles table (XP, games_played, streak, level) using authService
      final newStreak = await authService.updateProfileAfterQuiz(
        scoreEarned: score,
      );

      // Update room_members table (RP)
      await rankingService.updateRP(
        userId: user.id,
        score: score,
        streak: newStreak,
      );
    } catch (e) {
      print("❌ Error saving Tetris score: $e");
      rethrow;
    }
  }

  /// Get user's current stats
  Future<Map<String, dynamic>> getUserStats() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    try {
      // Get profile data
      final profile = await authService.getProfile();
      if (profile == null) throw Exception('Profile not found');

      // Get RP from room_members
      final roomData = await supabase
          .from('room_members')
          .select('rp, games_played')
          .eq('user_id', user.id)
          .maybeSingle();

      return {
        'xp': profile.xp,
        'level': profile.level,
        'rp': roomData?['rp'] ?? 0,
        'games_played': profile.gamesPlayed,
        'streak': profile.streak,
      };
    } catch (e) {
      print('❌ Error getting user stats: $e');
      rethrow;
    }
  }
}
