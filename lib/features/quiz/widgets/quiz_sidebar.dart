import 'package:flutter/material.dart';
import '../../../models/question.dart';

class QuizSidebar extends StatelessWidget {
  final List<SurveySection> surveySections;
  final int currentSectionIndex;
  final int currentQuestionIndex;
  final bool isQuizFinished;
  final Map<int, Map<int, double>> answers;
  final bool isWideScreen;
  final Function(int sectionIdx, int questionIdx, bool isWideScreen) onJumpToQuestion;
  final VoidCallback onShowResult;

  const QuizSidebar({
    super.key,
    required this.surveySections,
    required this.currentSectionIndex,
    required this.currentQuestionIndex,
    required this.isQuizFinished,
    required this.answers,
    required this.isWideScreen,
    required this.onJumpToQuestion,
    required this.onShowResult,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 24, top: 24, bottom: 16, right: 16),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '문항 이동',
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.black87
                  ),
                ),
                // 모바일에서 사이드바를 닫기 위한 투명 아이콘 (여백 확보용, 닫기 기능은 백그라운드 터치로 동작)
                if (!isWideScreen)
                  const SizedBox(width: 48), // 모양 맞추기 용도
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Colors.black12),
          Expanded(
            child: ListView.builder(
              itemCount: surveySections.length,
              itemBuilder: (context, sectionIndex) {
                final section = surveySections[sectionIndex];
                final isSectionSelected = sectionIndex == currentSectionIndex && !isQuizFinished;
                
                return ExpansionTile(
                  initiallyExpanded: isSectionSelected,
                  title: Text(
                    section.title,
                    style: TextStyle(
                      fontWeight: isSectionSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSectionSelected ? Theme.of(context).primaryColor : Colors.black,
                    ),
                  ),
                  children: List.generate(section.questions.length, (qIndex) {
                    final isQuestionSelected = isSectionSelected && (qIndex == currentQuestionIndex);
                    final isAnswered = answers[sectionIndex]?.containsKey(qIndex) ?? false;
                    
                    return ListTile(
                      contentPadding: const EdgeInsets.only(left: 32, right: 16),
                      title: Text(
                        '질문 ${qIndex + 1}',
                        style: TextStyle(
                          fontWeight: isQuestionSelected ? FontWeight.bold : FontWeight.normal,
                          color: isQuestionSelected ? Theme.of(context).primaryColor : null,
                        ),
                      ),
                      selected: isQuestionSelected,
                      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      trailing: isAnswered ? const Icon(Icons.check_circle, color: Colors.green, size: 20) : null,
                      onTap: () {
                        onJumpToQuestion(sectionIndex, qIndex, isWideScreen);
                      },
                    );
                  }),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: onShowResult,
              child: const Text('결과 보기'),
            ),
          ),
        ],
      ),
    );
  }
}
