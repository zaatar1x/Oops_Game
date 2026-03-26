import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_model.dart';
import '../../ranking/data/ranking_service.dart';

class AuthService {
  final supabase = Supabase.instance.client;
  final rankingService = RankingService();

  // 🔹 SIGN UP
Future<AuthResponse> signUp({
  required String email,
  required String password,
  String? firstName,
  String? lastName,
}) async {
  try {
    print("🔹 SIGNUP START");

    final res = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    // 🔥 HANDLE EMAIL CONFIRMATION
    if (res.user == null) {
      print("⚠️ Email confirmation required");
      return res;
    }

    final user = res.user!;
    print("✅ User created: ${user.id}");

    await supabase.from('profiles').insert({
      'id': user.id,
      'first_name': firstName ?? '',
      'last_name': lastName ?? '',
      'rank': 'Bronze',
    });

    print("✅ Profile created");

    _joinRoomAsync(user.id, 'Bronze');

    return res;

  } catch (e) {
    print("❌ SIGNUP ERROR: $e");
    rethrow;
  }
}

  // 🔹 SIGN IN
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print("🔹 SIGNIN START");

      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user == null) throw Exception("Login failed");

      print("✅ Login success");

      final profile = await getProfile();

      if (profile != null) {
        _joinRoomAsync(user.id, profile.rank);
      }

      return res;
    } catch (e) {
      print("❌ SIGNIN ERROR: $e");
      rethrow;
    }
  }

  // 🔹 BACKGROUND ROOM JOIN
  void _joinRoomAsync(String userId, String rank) {
    Future(() async {
      try {
        print("🔹 Joining room...");
        await rankingService.joinRoom(userId: userId, rank: rank);
        print("✅ Joined room");
      } catch (e) {
        print("❌ Room join error: $e");
      }
    });
  }

  // 🔹 GET PROFILE
  Future<Profile?> getProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) return null;

      return Profile.fromJson(data);
    } catch (e) {
      print("❌ Profile error: $e");
      return null;
    }
  }

  // 🔥 UPDATE PROFILE AFTER QUIZ (FIXED)
  Future<int> updateProfileAfterQuiz({
    required int scoreEarned,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    try {
      final data = await supabase
          .from('profiles')
          .select('xp, games_played, streak')
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) throw Exception('Profile not found');

      final currentXP = data['xp'] ?? 0;
      final currentGames = data['games_played'] ?? 0;
      final currentStreak = data['streak'] ?? 0;

      final newStreak = currentStreak + 1;
      final newXP = currentXP + scoreEarned;
      final newGames = currentGames + 1;
      final newLevel = (newXP / 1000).floor() + 1;

      await supabase.from('profiles').update({
        'xp': newXP,
        'games_played': newGames,
        'streak': newStreak,
        'level': newLevel,
      }).eq('id', user.id);

      print("✅ Profile updated → XP:$newXP | Streak:$newStreak");

      return newStreak;
    } catch (e) {
      print("❌ updateProfileAfterQuiz error: $e");
      rethrow;
    }
  }

  // 🔹 SIGN OUT
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // 🔹 CURRENT USER
  User? get currentUser => supabase.auth.currentUser;
}