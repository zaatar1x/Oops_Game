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

  // 🔥 UPDATE PROFILE AFTER QUIZ (FIXED) - Using RPC to bypass RLS
  Future<int> updateProfileAfterQuiz({
    required int scoreEarned,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    try {
      // Use RPC function to bypass RLS policy
      final result = await supabase.rpc('increment_profile_stats', params: {
        'user_id_input': user.id,
        'xp_gain': scoreEarned,
      });

      if (result == null || (result is List && result.isEmpty)) {
        throw Exception('Profile update failed - no result returned');
      }

      // Extract the new streak from the result
      final resultData = result is List ? result.first : result;
      final newStreak = resultData['new_streak'] as int;

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