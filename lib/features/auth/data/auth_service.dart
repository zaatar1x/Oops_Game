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

  // CURRENT USER
  User? get currentUser => supabase.auth.currentUser;
}