import 'package:flutter/material.dart';
import '../../../models/question.dart';
import '../../skin_type/skin_type_detail_screen.dart'; // 상세 화면 임포트
import 'package:shared_preferences/shared_preferences.dart'; // 로컬에 데이터 저장하는 패키지

class QuizResult extends StatelessWidget {
  final Map<int, Map<int, double>> answers;
  final List<SurveySection> surveySections;
  final Map<String, dynamic> scoringRules;
  final bool isWideScreen;
  final VoidCallback onExit;
  final VoidCallback onResumeQuiz;
  final void Function(int, int)? onGoToQuestion; // 특정 문제로 이동하는 콜백 추가

  const QuizResult({
    super.key,
    required this.answers,
    required this.surveySections,
    required this.scoringRules,
    required this.isWideScreen,
    required this.onExit,
    required this.onResumeQuiz,
    this.onGoToQuestion,
  });

  // 피부 타입 로컬에 저장하는 비동기 함수
  Future<void> _saveSkinTypeToLocal(String skinType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_skin_type', skinType);
    debugPrint("피부 타입 로컬 저장 완료: $skinType");
  }

  @override
  Widget build(BuildContext context) {
    double part1Score =
        answers[0]?.values.fold(0.0, (sum, v) => sum! + v) ?? 0.0;
    double part2Score =
        answers[1]?.values.fold(0.0, (sum, v) => sum! + v) ?? 0.0;
    double part3Score =
        answers[2]?.values.fold(0.0, (sum, v) => sum! + v) ?? 0.0;
    double part4Score =
        answers[3]?.values.fold(0.0, (sum, v) => sum! + v) ?? 0.0;

    String getResultFromRules(String partKey, double score) {
      if (scoringRules.isEmpty) {
        if (partKey == 'part1') return score >= 27 ? "O" : "D";
        if (partKey == 'part2') return score >= 30 ? "S" : "R";
        if (partKey == 'part3') return score >= 31 ? "P" : "N";
        if (partKey == 'part4') return score >= 41 ? "W" : "T";
        return "?";
      }
      final rules = scoringRules[partKey]['ranges'] as List<dynamic>;
      for (var rule in rules) {
        if (score >= rule['min'] && score <= rule['max']) {
          return rule['result'] as String;
        }
      }
      return "?";
    }

    String type1 = getResultFromRules('part1', part1Score);
    String type2 = getResultFromRules('part2', part2Score);
    String type3 = getResultFromRules('part3', part3Score);
    String type4 = getResultFromRules('part4', part4Score);

    String skinType = "$type1$type2$type3$type4";

    String getKoreanTypeName(String partKey, String type) {
      if (partKey == 'part1') {
        return type == 'O' ? '지성' : (type == 'D' ? '건성' : '?');
      }
      if (partKey == 'part2') {
        return type == 'S' ? '민감성' : (type == 'R' ? '저항성' : '?');
      }
      if (partKey == 'part3') {
        return type == 'P' ? '색소침착' : (type == 'N' ? '비색소성' : '?');
      }
      if (partKey == 'part4') {
        return type == 'W' ? '주름' : (type == 'T' ? '탄력' : '?');
      }
      return '?';
    }

    String koreanType1 = getKoreanTypeName('part1', type1);
    String koreanType2 = getKoreanTypeName('part2', type2);
    String koreanType3 = getKoreanTypeName('part3', type3);
    String koreanType4 = getKoreanTypeName('part4', type4);

    String koreanSkinType =
        "($koreanType1, $koreanType2, $koreanType3, $koreanType4)";

    int totalQuestions = surveySections.fold(
      0,
      (sum, section) => sum + section.questions.length,
    );
    int answeredQuestions = answers.values.fold(
      0,
      (sum, map) => sum + map.length,
    );
    bool allAnswered = answeredQuestions == totalQuestions;

    bool hasAnsweredPerPart = true;
    for (int i = 0; i < 4; i++) {
      if (answers[i] == null || answers[i]!.isEmpty) {
        hasAnsweredPerPart = false;
        break;
      }
    }

    // 안 푼 첫 번째 문제 찾기
    int? firstUnansweredSection;
    int? firstUnansweredQuestion;
    
    for (int s = 0; s < surveySections.length; s++) {
      for (int q = 0; q < surveySections[s].questions.length; q++) {
        if (answers[s] == null || !answers[s]!.containsKey(q)) {
          firstUnansweredSection = s;
          firstUnansweredQuestion = q;
          break;
        }
      }
      if (firstUnansweredSection != null) break;
    }

    // 피부 타입이 제대로 결정된 경우 (warning 상황이 아닐 때) 저장 실행
    if (hasAnsweredPerPart && allAnswered) {
      _saveSkinTypeToLocal(skinType);
    }

    final double titleFontSize = isWideScreen ? 28 : 22;
    final double subTitleFontSize = isWideScreen ? 20 : 16;
    final double typeFontSize = isWideScreen ? 48 : 36;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '피부 타입 검사 결과',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!allAnswered && hasAnsweredPerPart)
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '아직 답변하지 않은 문항이 있습니다.',
                      style: TextStyle(
                        fontSize: subTitleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '정확한 피부 타입 진단을 위해\n오른쪽 메뉴에서 확인 후 모든 문항에 답해주세요.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (firstUnansweredSection != null && firstUnansweredQuestion != null)
                      ElevatedButton(
                        onPressed: () {
                          if (onGoToQuestion != null) {
                            onGoToQuestion!(firstUnansweredSection!, firstUnansweredQuestion!);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(250, 50),
                        ),
                        child: const Text(
                          '안 푼 문제로 바로 이동하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            if (!hasAnsweredPerPart)
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 48,
                      color: Colors.orange.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '각 Part별로 1문제 이상 선택해주세요.',
                      style: TextStyle(
                        fontSize: subTitleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '정확한 피부 타입 결과를 확인하기 위해서는\n모든 파트의 문항이 최소 1개 이상 필요합니다.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: onResumeQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        minimumSize: const Size(250, 50),
                      ),
                      child: const Text(
                        '남은 문제 풀러 가기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Text(
                '당신의 피부 타입은',
                style: TextStyle(fontSize: subTitleFontSize),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                skinType,
                style: TextStyle(
                  fontSize: typeFontSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                koreanSkinType,
                style: TextStyle(
                  fontSize: subTitleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildResultRow(
                        'Part 1 (건성/지성)',
                        part1Score,
                        type1,
                        koreanType1,
                      ),
                      const Divider(),
                      _buildResultRow(
                        'Part 2 (민감성/저항성)',
                        part2Score,
                        type2,
                        koreanType2,
                      ),
                      const Divider(),
                      _buildResultRow(
                        'Part 3 (색소성/비색소성)',
                        part3Score,
                        type3,
                        koreanType3,
                      ),
                      const Divider(),
                      _buildResultRow(
                        'Part 4 (주름/탄력)',
                        part4Score,
                        type4,
                        koreanType4,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 버튼 영역 변경: 자세히 알아보기 & 테스트 종료
              ElevatedButton(
                onPressed: () {
                  // 내 피부타입 알아보기 버튼: 상세 설명 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SkinTypeDetailScreen(skinType: skinType),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text(
                  '내 피부타입 자세히 알아보기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onExit,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('테스트 종료 (홈으로)', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(
    String title,
    double score,
    String type,
    String koreanType,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(title, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 4,
            child: Text(
              '$score점 -> $type($koreanType)',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right, // 오른쪽 정렬
            ),
          ),
        ],
      ),
    );
  }
}
