import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../data/baumann_data.dart';
import '../../models/question.dart';
import 'widgets/quiz_sidebar.dart';
import 'widgets/quiz_content.dart';
import 'widgets/quiz_result.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<SurveySection> surveySections = [];
  Map<String, dynamic> scoringRules = {};
  
  int currentSectionIndex = 0;
  int currentQuestionIndex = 0;
  
  // 저장될 점수 [sectionIndex][questionIndex] = score
  Map<int, Map<int, double>> answers = {};
  
  bool isLoading = true;
  bool isQuizFinished = false;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _loadSurveyData();
  }

  Future<void> _loadSurveyData() async {
    try {
      final String jsonString = await rootBundle.loadString('lib/data/baumann.json');  // json파일을 먼저 사용후 안되면 dart 사용
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> sectionsData = jsonData['sections'];
      scoringRules = jsonData['scoring_rules'];

      surveySections = sectionsData.map((sectionJson) {
        final List<dynamic> questionsData = sectionJson['questions'];
        final questions = questionsData.map((qJson) {
          return Question(
            id: qJson['id'] as int,
            text: qJson['text'] as String,
            options: List<String>.from(qJson['options']),
            scores: (qJson['scores'] as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
          );
        }).toList();

        return SurveySection(
          title: sectionJson['title'] as String,
          questions: questions,
        );
      }).toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading json data: $e. Falling back to hardcoded data.");
      setState(() {
        surveySections = baumannSurvey;
        isLoading = false;
      });
    }
  }

  void _nextQuestion() {
    setState(() {
      if (currentQuestionIndex < surveySections[currentSectionIndex].questions.length - 1) {
        currentQuestionIndex++;
      } else {
        // 다음 문제로 넘어갈 때, 비어있는 섹션(문제가 없는 파트)은 건너뛰도록 로직 수정
        int nextSection = currentSectionIndex + 1;
        while (nextSection < surveySections.length && surveySections[nextSection].questions.isEmpty) {
          nextSection++;
        }

        if (nextSection < surveySections.length) {
          // 비어있지 않은 다음 섹션으로 이동
          currentSectionIndex = nextSection;
          currentQuestionIndex = 0;
        } else {
          // 더 이상 진행할 섹션이 없으면 결과 화면으로
          isQuizFinished = true;
        }
      }
    });
  }

  void _previousQuestion() {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
      } else {
        // 이전 문제로 돌아갈 때, 비어있는 섹션은 건너뛰도록 로직 수정
        int prevSection = currentSectionIndex - 1;
        while (prevSection >= 0 && surveySections[prevSection].questions.isEmpty) {
          prevSection--;
        }

        if (prevSection >= 0) {
          // 비어있지 않은 이전 섹션으로 이동
          currentSectionIndex = prevSection;
          currentQuestionIndex = surveySections[prevSection].questions.length - 1;
        }
      }
    });
  }

  void _answerQuestion(double score) async {
    if (_isTransitioning) return;
    
    if (!answers.containsKey(currentSectionIndex)) {
      answers[currentSectionIndex] = {};
    }
    
    setState(() {
      answers[currentSectionIndex]![currentQuestionIndex] = score;
      _isTransitioning = true;
    });
    
    // 사용자가 답을 클릭했을 때 버튼 색이 변하는 것을 보여주기 위한 딜레이.
    // 기존 250ms 였던 것을 50ms로 대폭 줄여서 버벅이는 느낌(느린 인식)이 들지 않게 수정했습니다.
    await Future.delayed(const Duration(milliseconds: 50));
    if (mounted) {
      _nextQuestion();
      setState(() {
        _isTransitioning = false;
      });
    }
  }

  void _jumpToQuestion(int sectionIdx, int questionIdx, bool isWideScreen) {
    setState(() {
      currentSectionIndex = sectionIdx;
      currentQuestionIndex = questionIdx;
      isQuizFinished = false;
    });
    if (!isWideScreen) {
      Navigator.of(context).pop(); // Drawer 닫기
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('피부 타입 테스트')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (surveySections.isEmpty || surveySections[currentSectionIndex].questions.isEmpty) {
       return Scaffold(
        appBar: AppBar(title: const Text('피부 타입 테스트')),
        body: const Center(child: Text('설문 데이터를 불러오는 데 실패했거나, 현재 파트에 질문이 없습니다.')),
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    // 태블릿/윈도우 크기는 700 이상으로 봅니다.
    final bool isWideScreen = screenWidth > 700;

    final Widget rightSidebar = Container(
      width: isWideScreen ? 250 : null,
      color: Colors.white,
      child: QuizSidebar(
        surveySections: surveySections,
        currentSectionIndex: currentSectionIndex,
        currentQuestionIndex: currentQuestionIndex,
        isQuizFinished: isQuizFinished,
        answers: answers,
        isWideScreen: isWideScreen,
        onJumpToQuestion: _jumpToQuestion,
        onShowResult: () {
          setState(() {
            isQuizFinished = true;
          });
          if (!isWideScreen) {
            Navigator.of(context).pop();
          }
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isQuizFinished ? '결과' : surveySections[currentSectionIndex].title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      endDrawer: isWideScreen ? null : Drawer(child: rightSidebar),
      body: Row(
        children: [
          Expanded(
            child: isQuizFinished 
              ? QuizResult(
                  answers: answers,
                  surveySections: surveySections,
                  scoringRules: scoringRules,
                  isWideScreen: isWideScreen,
                  onExit: () {
                    Navigator.of(context).pop();
                  },
                ) 
              : QuizContent(
                  currentSection: surveySections[currentSectionIndex],
                  currentQuestion: surveySections[currentSectionIndex].questions[currentQuestionIndex],
                  currentSectionIndex: currentSectionIndex,
                  currentQuestionIndex: currentQuestionIndex,
                  currentAnswer: answers[currentSectionIndex]?[currentQuestionIndex],
                  isWideScreen: isWideScreen,
                  onAnswerQuestion: _answerQuestion,
                  onPreviousQuestion: _previousQuestion,
                  onNextQuestion: _nextQuestion,
                ),
          ),
          if (isWideScreen) rightSidebar,
        ],
      ),
    );
  }
}
