import 'package:flutter/material.dart';
import '../models/question_model.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final Function(int) onAnswer;

  const QuestionCard({super.key, required this.question, required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(question.question),
        ...List.generate(question.options.length, (index) {
          return ElevatedButton(
            onPressed: () => onAnswer(index),
            child: Text(question.options[index]),
          );
        })
      ],
    );
  }
}