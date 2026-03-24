import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_model.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // SIGN UP + CREATE PROFILE
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    final res = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = res.user;

    if (user != null) {
      await supabase.from('profiles').insert({
        'id': user.id,
        'first_name': firstName,
        'last_name': lastName,
      });
    }

    return res;
  }

  // SIGN IN
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // SIGN OUT
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // GET PROFILE
  Future<Profile?> getProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) return null;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return Profile.fromJson(data);
  }

  // UPDATE PROFILE AFTER QUIZ
  Future<void> updateProfileAfterQuiz({required int scoreEarned}) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    // Get current profile data
    final currentProfile = await getProfile();
    if (currentProfile == null) throw Exception('Profile not found');

    // Calculate new values
    final newXP = currentProfile.xp + scoreEarned;
    final newGamesPlayed = currentProfile.gamesPlayed + 1;
    final newStreak = currentProfile.streak + 1;
    final newLevel = (newXP / 1000).floor() + 1;

    // Update profile in database
    await supabase.from('profiles').update({
      'xp': newXP,
      'games_played': newGamesPlayed,
      'streak': newStreak,
      'level': newLevel,
    }).eq('id', user.id);
  }

  // CURRENT USER
  User? get currentUser => supabase.auth.currentUser;
}