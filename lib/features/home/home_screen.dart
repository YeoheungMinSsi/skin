import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../quiz/quiz_screen.dart';
import '../cosmetics/cosmetics_screen.dart';
import '../skin_type/skin_type_detail_screen.dart';
import '../news/news_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _savedSkinType;
  bool _isLoading = true;
  List<dynamic> _newsList = [];
  late PageController _pageController;
  Timer? _carouselTimer;
  int _currentNewsPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 10000);
    _currentNewsPage = 10000;
    _loadSavedSkinType();
    _loadNews();
  }
  
  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // 최신 논문 뉴스 로드
  Future<void> _loadNews() async {
    try {
      final String response = await rootBundle.loadString('lib/data/latest_news.json');
      final data = await json.decode(response);
      setState(() {
        _newsList = data;
      });
      // 4초마다 자동으로 배너 넘기기
      if (_newsList.isNotEmpty) {
        _carouselTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
          if (_pageController.hasClients) {
            _currentNewsPage++;
            _pageController.animateToPage(
              _currentNewsPage,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    } catch (e) {
      debugPrint("Failed to load news: $e");
    }
  }

  // 로컬에 저장된 피부 타입 로드
  Future<void> _loadSavedSkinType() async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedSkinType = prefs.getString('user_skin_type');
      _isLoading = false;
    });
  }

  // 피부 타입 초기화 (삭제)
  Future<void> _clearSkinType() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_skin_type');
    setState(() {
      _savedSkinType = null;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('피부 타입 데이터가 초기화되었습니다.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // 피부 타입 알파벳을 한국어 설명으로 변환
  String _getKoreanSkinTypeDescription(String skinType) {
    if (skinType.length != 4) return "정보 없음";
    
    final p1 = skinType[0] == 'O' ? '지성' : (skinType[0] == 'D' ? '건성' : '?');
    final p2 = skinType[1] == 'S' ? '민감성' : (skinType[1] == 'R' ? '저항성' : '?');
    final p3 = skinType[2] == 'P' ? '색소침착' : (skinType[2] == 'N' ? '비색소성' : '?');
    final p4 = skinType[3] == 'W' ? '주름성' : (skinType[3] == 'T' ? '탄력성' : '?');

    return "$p1 • $p2 • $p3 • $p4";
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // 부드러운 오프화이트 배경
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.spa, color: primaryColor, size: 28),
            const SizedBox(width: 8),
            const Text(
              'GlowSkin',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (_savedSkinType != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: '피부 타입 초기화',
              onPressed: () {
                // 초기화 확인 모달창
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('피부 타입 초기화'),
                    content: const Text('저장된 피부 타입 검사 결과를 지우시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearSkinType();
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 환영 메세지
                  const Text(
                    '나만의 피부 분석 매니저 ✨',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '피부 건강을 위한\n첫 단추를 끼워보세요!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 💡 논문 뉴스 배너 추가
                  _buildNewsCarousel(primaryColor),

                  // 메인 피부 타입 카드 영역
                  _savedSkinType != null
                      ? _buildPremiumResultCard(primaryColor)
                      : _buildDiagnosticBanner(primaryColor),

                  const SizedBox(height: 32),

                  // 추가 메뉴 영역
                  const Text(
                    '피부 건강 퀵메뉴',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 화장품 추천 리스트 퀵 링크 카드
                  _buildQuickMenuCard(
                    icon: Icons.auto_awesome,
                    iconBgColor: const Color(0xFFECFDF5),
                    iconColor: const Color(0xFF059669),
                    title: '피부 타입별 화장품',
                    subtitle: '모든 바우만 피부 타입의 추천/주의 화장품 목록',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CosmeticsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  // 💡 뉴스 배너 캐러셀 (PageView)
  Widget _buildNewsCarousel(Color primaryColor) {
    if (_newsList.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 120, // 높이를 늘려 화면이 좁아질 때 글씨가 잘리거나 오버플로우 발생하지 않도록 함
      margin: const EdgeInsets.only(bottom: 32),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.grey),
            onPressed: () {
              if (_pageController.hasClients) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                _currentNewsPage = index;
              },
              itemBuilder: (context, index) {
                final news = _newsList[index % _newsList.length];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewsDetailScreen(newsItem: news)),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.auto_awesome, color: primaryColor, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'HOT 뷰티 논문',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (news['date'] != null)
                              Text(
                                news['date'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          news['headline'] ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.grey),
            onPressed: () {
              if (_pageController.hasClients) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // 1. 결과가 있을 때 보여주는 프리미엄 카드 디자인
  Widget _buildPremiumResultCard(Color primaryColor) {
    final String skinType = _savedSkinType!;
    final String description = _getKoreanSkinTypeDescription(skinType);
    final bool isNarrowScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)], // 세련된 퍼플 to 시안 그라데이션
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '나의 바우만 피부 타입 🧬',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.white, size: 14),
                      if (!isNarrowScreen) ...[
                        const SizedBox(width: 4),
                        const Text(
                          '진단 완료',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              skinType,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isNarrow = constraints.maxWidth < 360;

                Widget detailBtn = SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SkinTypeDetailScreen(skinType: skinType),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4F46E5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '피부타입 상세',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );

                Widget cosmeticBtn = SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CosmeticsScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '맞춤 화장품',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );

                Widget refreshBtn = Container(
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    tooltip: '다시 테스트하기',
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const QuizScreen()),
                      );
                      _loadSavedSkinType();
                    },
                  ),
                );

                if (isNarrow) {
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              detailBtn,
                              const SizedBox(height: 8),
                              cosmeticBtn,
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        AspectRatio(
                          aspectRatio: 1, // 정사각형 (두 버튼 높이와 동일)
                          child: refreshBtn,
                        ),
                      ],
                    ),
                  );
                } else {
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: detailBtn),
                        const SizedBox(width: 8),
                        Expanded(child: cosmeticBtn),
                        const SizedBox(width: 12),
                        AspectRatio(
                          aspectRatio: 1, // 정사각형 (단일 버튼 높이와 동일)
                          child: refreshBtn,
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // 2. 결과가 없을 때 피부 분석을 유도하는 배너 카드 디자인
  Widget _buildDiagnosticBanner(Color primaryColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.face_retouching_natural, color: primaryColor, size: 30),
            ),
            const SizedBox(height: 20),
            const Text(
              '나의 피부 타입 진단하기 🔍',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '바우만 설문을 풀고 내 피부가 어떤 타입인지 분석받으세요. 피부에 맞는 화장품 정보도 제공됩니다!',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizScreen()),
                );
                _loadSavedSkinType();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('지금 무료로 진단 시작하기'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. 공통 퀵메뉴 리스트 빌더
  Widget _buildQuickMenuCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}