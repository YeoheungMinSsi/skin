import 'package:flutter/material.dart';
import '../../../models/question.dart';

class QuizContent extends StatelessWidget {
  final SurveySection currentSection;
  final Question currentQuestion;
  final int currentSectionIndex;
  final int currentQuestionIndex;
  final double? currentAnswer;
  final bool isWideScreen;
  final Function(double) onAnswerQuestion;
  final VoidCallback onPreviousQuestion;
  final VoidCallback onNextQuestion;

  const QuizContent({
    super.key,
    required this.currentSection,
    required this.currentQuestion,
    required this.currentSectionIndex,
    required this.currentQuestionIndex,
    required this.currentAnswer,
    required this.isWideScreen,
    required this.onAnswerQuestion,
    required this.onPreviousQuestion,
    required this.onNextQuestion,
  });

  @override
  Widget build(BuildContext context) {
    // =========================================================================
    // 💡 [UI 크기 조절 위치] 💡
    // isWideScreen ? (PC/태블릿 크기) : (모바일 휴대폰 크기);
    // =========================================================================

    // 1. [Part N: ~ 부분의 Title 글자크기] 수정 위치
    final double titleFontSize = isWideScreen ? 18.0 : 16.0;

    // 2. [문항 질문 글자크기] 수정 위치
    final double questionFontSize = isWideScreen ? 24.0 : 16.0;

    // 3. [문항 선택지 부분 글자크기] 수정 위치 (이전/다음 버튼 글자 크기에도 적용됨)
    final double optionFontSize = isWideScreen ? 18.0 : 12.0;

    // 4. [문항 선택지 버튼 위아래 크기(통통함)] 수정 위치
    final double buttonVerticalPadding = isWideScreen ? 20.0 : 12.0;
    // =========================================================================
    
    // 모바일에서는 위쪽 여백을 확 줄여서 선택지가 잘리지 않게 합니다.
    final double topPadding = isWideScreen ? MediaQuery.of(context).size.height * 0.15 : 40.0;

    // 이전/다음 버튼 영역 위젯
    final Widget prevNextButtons = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: (currentSectionIndex == 0 && currentQuestionIndex == 0) ? null : onPreviousQuestion,
          icon: const Icon(Icons.arrow_back),
          label: Text('이전 문항', style: TextStyle(fontSize: optionFontSize)),
        ),
        ElevatedButton.icon(
          onPressed: onNextQuestion,
          icon: const Icon(Icons.arrow_forward),
          label: Text('다음 문항', style: TextStyle(fontSize: optionFontSize)),
        ),
      ],
    );

    // 원본 텍스트에 번호가 있든 없든 일관성 있게 보여주기 위해, 먼저 원래 있던 숫자 형식을 지웁니다.
    final String cleanQuestionText = currentQuestion.text.replaceFirst(RegExp(r'^\d+\.\s*'), '');

    // 스크롤 가능한 질문과 선택지 영역
    final Widget scrollableContent = SingleChildScrollView(
      padding: EdgeInsets.only(
        top: topPadding, 
        left: 24.0, 
        right: 24.0, 
        bottom: isWideScreen ? 40.0 : 16.0
      ),
      // Align을 사용하여 모바일에서는 무조건 왼쪽 상단(topLeft)에 붙이고, 
      // 윈도우 창에서는 중앙 상단(topCenter)에 붙이도록 명시적으로 설정합니다.
      child: Align(
        alignment: isWideScreen ? Alignment.topCenter : Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          // Container의 너비를 무한(double.infinity)으로 주어, 
          // 글자 길이에 상관없이 언제나 남은 화면 가로 폭을 완전히 채우도록 강제합니다.
          // 이로 인해 박스의 너비가 줄었다 늘었다 하면서 화면이 널뛰는 현상이 원천 차단됩니다.
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 파트 제목 및 진행 상황 (몇 번 문제인지) 표시
                Text(
                  '${currentSection.title} - 질문 ${currentQuestionIndex + 1} / ${currentSection.questions.length}',
                  style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, color: Colors.grey),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 12),
                // 질문 텍스트 부분 (현재 문항 인덱스를 이용해 "1. 문제", "2. 문제" 형식으로 고정 출력)
                Text(
                  '${currentQuestionIndex + 1}. $cleanQuestionText',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: questionFontSize, fontWeight: FontWeight.bold, height: 1.4),
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: currentQuestion.options.map((option) {
                    final index = currentQuestion.options.indexOf(option);
                    final isSelected = currentAnswer == currentQuestion.scores[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                          padding: EdgeInsets.symmetric(vertical: buttonVerticalPadding, horizontal: 20.0),
                          alignment: Alignment.centerLeft,
                        ),
                        onPressed: () {
                          onAnswerQuestion(currentQuestion.scores[index]);
                        },
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: optionFontSize,
                            color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : null,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                // 넓은 화면일 때만 스크롤 내부에 버튼을 붙여둡니다.
                if (isWideScreen) ...[
                  const SizedBox(height: 48),
                  prevNextButtons,
                ]
              ],
            ),
          ),
        ),
      ),
    );

    if (isWideScreen) {
      return scrollableContent;
    } else {
      return Column(
        children: [
          Expanded(child: scrollableContent),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 16.0, top: 8.0),
              child: prevNextButtons,
            ),
          ),
        ],
      );
    }
  }
}
