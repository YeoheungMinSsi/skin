// lib/models/question.dart
class Question {
  final int id;
  final String text;
  final List<String> options;
  final List<double> scores; // 각 답변당 점수 (1번은 1점, 5번은 2.5점 등)

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.scores,
  });
}

class SurveySection {
  final String title; // 예: Part 1 건성(D) vs 지성(O)
  final List<Question> questions;

  SurveySection({
    required this.title,
    required this.questions
  });
}