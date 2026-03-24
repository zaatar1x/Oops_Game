import 'package:supabase_flutter/supabase_flutter.dart';

class QuizService {
  final supabase = Supabase.instance.client;

  Future<void> saveQuizResult(String userId, int score, int timeLeft) async {
    await supabase.from('quiz_attempts').insert({
      'user_id': userId,
      'score': score,
      'time_left': timeLeft,
    });
  }

  String getLeague(int score) {
    if (score >= 80) return "Gold";
    if (score >= 50) return "Silver";
    return "Bronze";
  }
}