import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/question_model.dart';

class QuizService {
  final supabase = Supabase.instance.client;

  Future<List<Question>> fetchQuestions() async {
    final response = await supabase
        .from('questions')
        .select()
        .limit(10);

    final data = response as List;

    return data.map((q) => Question.fromJson(q)).toList();
  }
}