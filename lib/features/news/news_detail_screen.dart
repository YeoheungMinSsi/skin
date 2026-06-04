import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, Clipboard, ClipboardData;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/cosmetic.dart';

class NewsDetailScreen extends StatefulWidget {
  final Map<String, dynamic> newsItem;

  const NewsDetailScreen({super.key, required this.newsItem});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  List<_MatchedItem> _matchedCosmetics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatchedCosmetics();
  }

  Future<void> _loadMatchedCosmetics() async {
    try {
      final String jsonString = await rootBundle.loadString('lib/data/cosmetic.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      final allCosmetics = jsonData.map((item) => Cosmetic.fromJson(item)).toList();

      final keywords = (widget.newsItem['keywords'] as List<dynamic>?)
              ?.map((e) => e.toString().toLowerCase())
              .toList() ??
          [];

      if (keywords.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final List<_MatchedItem> matched = [];
      for (final c in allCosmetics) {
        final Set<String> foundKeywords = {};
        for (final kw in keywords) {
          if (c.ingredients.any((ing) => ing.toLowerCase().contains(kw)) ||
              c.name.toLowerCase().contains(kw) ||
              c.category.toLowerCase().contains(kw) ||
              c.brand.toLowerCase().contains(kw)) {
            foundKeywords.add(kw);
          }
        }
        if (foundKeywords.isNotEmpty) {
          matched.add(_MatchedItem(cosmetic: c, matchedKeywords: foundKeywords.toList()));
          if (matched.length >= 10) break;
        }
      }

      _matchedCosmetics = matched;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading matched cosmetics: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchSearch(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('해당 링크를 열 수 없습니다.')),
        );
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('클립보드에 복사되었습니다!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '뷰티 최신 과학 뉴스',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 태그 및 날짜
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '논문 요약 리포트',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  widget.newsItem['date'] ?? '',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 헤드라인
            Text(
              widget.newsItem['headline'] ?? '',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.35,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),

            // 요약 본문
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.format_quote, color: Colors.blueGrey.withValues(alpha: 0.5), size: 32),
                      const SizedBox(width: 8),
                      const Text(
                        'AI 요약 리포트',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.newsItem['summary'] ?? '',
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.7,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 키워드
            if (widget.newsItem['keywords'] != null) ...[
              const Text(
                '관련 키워드',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (widget.newsItem['keywords'] as List).map<Widget>((kw) {
                  return Chip(
                    label: Text('#$kw', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 32),

            // 원문 출처
            if (widget.newsItem['paper_link'] != null && widget.newsItem['paper_link'].toString().isNotEmpty)
              Center(
                child: Column(
                  children: [
                    if (widget.newsItem['journal'] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          '출처: ${widget.newsItem['journal']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    TextButton.icon(
                      onPressed: () async {
                        final String urlString = widget.newsItem['paper_link'];
                        await _launchSearch(urlString);
                      },
                      icon: const Icon(Icons.menu_book_rounded),
                      label: const Text('논문 원문 보기'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blueGrey,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              
            const SizedBox(height: 48),

            // 관련 추천 화장품 섹션
            if (!_isLoading && _matchedCosmetics.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.orange.shade400),
                  const SizedBox(width: 8),
                  const Text(
                    '키워드 관련 추천 화장품',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _matchedCosmetics.length,
                  itemBuilder: (context, index) {
                    final item = _matchedCosmetics[index];
                    return _buildMatchedCosmeticCard(item);
                  },
                ),
              ),
              const SizedBox(height: 48),
            ],
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchedCosmeticCard(_MatchedItem item) {
    final cosmetic = item.cosmetic;
    final keywordsText = item.matchedKeywords.map((k) => '#$k').join(' ');

    final cleanName = cosmetic.name.replaceAll(RegExp(r'\s*\[.*?\]\s*'), '').trim();
    final searchNameOlive = Uri.encodeComponent(cleanName);
    final searchNameHwahae = Uri.encodeComponent('[${cosmetic.brand}] ${cosmetic.name}');
    
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 매칭된 키워드 표시
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                keywordsText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange.shade800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    cosmetic.brand,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    cosmetic.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Tooltip(
                  message: '제품명 복사하기',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _copyToClipboard('[${cosmetic.brand}] ${cosmetic.name}'),
                      customBorder: const CircleBorder(),
                      hoverColor: Colors.black.withValues(alpha: 0.08),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(Icons.copy, size: 16, color: Colors.blueGrey.shade300),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _launchSearch('https://www.oliveyoung.co.kr/store/search/getSearchMain.do?query=$searchNameOlive');
                    },
                    icon: SvgPicture.asset('lib/data/icon/oliveyoung.svg', height: 14),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: BorderSide(color: Colors.green.shade600),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    label: Text('올리브영', style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _launchSearch('https://www.hwahae.co.kr/search?q=$searchNameHwahae');
                    },
                    icon: Image.asset('lib/data/icon/hwahae.png', height: 14),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: BorderSide(color: Colors.blue.shade600),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    label: Text('화해', style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchedItem {
  final Cosmetic cosmetic;
  final List<String> matchedKeywords;
  _MatchedItem({required this.cosmetic, required this.matchedKeywords});
}
