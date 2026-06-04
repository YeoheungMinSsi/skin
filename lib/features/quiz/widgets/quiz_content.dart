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

    // 1. 고정된 Header 영역 (Part 제목 + 문제 텍스트)
    final Widget headerArea = SizedBox(
      width: double.infinity, // 문항 길이에 상관없이 항상 최대 너비를 차지하게 하여 왼쪽 끝을 고정
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${currentSection.title} - 질문 ${currentQuestionIndex + 1} / ${currentSection.questions.length}',
            style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, color: Colors.grey),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 12),
          Text(
            '${currentQuestionIndex + 1}. $cleanQuestionText',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: questionFontSize, fontWeight: FontWeight.bold, height: 1.4),
          ),
        ],
      ),
    );

    // 2. 선택지 영역
    final Widget optionsArea = SizedBox(
      width: double.infinity, // 문항 길이에 상관없이 항상 최대 너비를 차지하게 하여 왼쪽 끝을 고정
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 글자 길이만큼만 버튼 크기 차지
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
    );

    return Column(
      children: [
        // 상단 고정: 질문 영역
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: isWideScreen ? 60.0 : 40.0, // 웹 환경에서 너무 중앙에 오지 않도록 고정 값으로 변경
            left: 24.0, right: 24.0, bottom: 16.0,
          ),
          alignment: isWideScreen ? Alignment.topCenter : Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: headerArea,
          ),
        ),
        
        // 중앙 영역: 선택지 (질문과 떨어져서 고정적으로 시작, 내용이 많으면 스크롤)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Align(
              alignment: isWideScreen ? Alignment.topCenter : Alignment.topLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 40.0), // 질문 항목에서 약간 떨어지도록 여백 추가
                  child: optionsArea,
                ),
              ),
            ),
          ),
        ),
        
        // 하단 고정: 이전/다음 버튼
        SafeArea(
          child: Container(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0, top: 16.0),
            alignment: isWideScreen ? Alignment.topCenter : Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: prevNextButtons,
            ),
          ),
        ),
      ],
    );
  }
}
