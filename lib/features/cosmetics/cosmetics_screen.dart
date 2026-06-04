import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, Clipboard, ClipboardData;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/cosmetic.dart';

class CosmeticsScreen extends StatefulWidget {
  const CosmeticsScreen({super.key});

  @override
  State<CosmeticsScreen> createState() => _CosmeticsScreenState();
}

class _CosmeticsScreenState extends State<CosmeticsScreen> {
  List<Cosmetic> _allCosmetics = [];
  List<Cosmetic> _recommendedCosmetics = [];
  String? _userSkinType;
  String? _selectedSkinType;
  bool _isLoading = true;
  bool _isAvoidMode = false;
  String _searchQuery = '';
  String _selectedCategory = '전체';
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  
  bool get _isSearchMode => _searchQuery.trim().isNotEmpty;

  final List<String> allCategories = [
    '전체', '스킨/토너', '로션/에멀젼', '크림', '에센스/세럼/앰플', '마스크/팩', '선케어', '립케어', '클렌징', '기타'
  ];

  final List<String> allSkinTypes = [
    'OSNT', 'OSNW', 'OSPT', 'OSPW',
    'ORNT', 'ORNW', 'ORPT', 'ORPW',
    'DSNT', 'DSNW', 'DSPT', 'DSPW',
    'DRNT', 'DRNW', 'DRPT', 'DRPW',
  ];

  // 피부 타입별 추천/주의 성분 데이터
  final Map<String, List<String>> beneficialIngredients = {
    'O': ['살리실산', '티트리', '녹차추출물', '나이아신아마이드', '징크피씨에이'], // 지성
    'D': ['히알루론산', '글리세린', '시어버터', '세라마이드', '스쿠알란'], // 건성
    'S': ['병풀추출물', '판테놀', '알란토인', '마데카소사이드', '아줄렌'], // 민감성
    'P': ['나이아신아마이드', '비타민C', '알부틴', '트라넥사믹애씨드', '글루타티온'], // 색소침착
    'R': [], // 저항성
    'W': ['레티놀', '아데노신', '펩타이드', '콜라겐'], // 주름
    'T': ['콜라겐', '엘라스틴'], // 탄력
  };

  final Map<String, List<String>> harmfulIngredients = {
    'O': ['시어버터', '코코넛오일', '미네랄오일', '비즈왁스'], // 지성은 모공 막는 성분 주의
    'D': ['에탄올', '변성알코올', '진흙', '카올린'], // 건성은 수분 뺏는 성분 주의
    'S': ['알코올', '인공향료', '향료', '살리실산', '멘톨', '유칼립투스'], // 민감성 자극 주의
    'R': [],
    'P': [],
    'W': [],
    'T': [],
  };

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {});
    });
    _loadData();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // 1. 유저 피부 타입 로드
      final prefs = await SharedPreferences.getInstance();
      _userSkinType = prefs.getString('user_skin_type');
      _selectedSkinType = _userSkinType;

      // 2. JSON 데이터 로드
      final String jsonString = await rootBundle.loadString('lib/data/cosmetic.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      
      _allCosmetics = jsonData.map((item) => Cosmetic.fromJson(item)).toList();

      // 3. 데이터 필터링
      _filterCosmetics();
    } catch (e) {
      debugPrint("Error loading data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterCosmetics() {
    if (_isSearchMode) {
      List<String> tokens = _searchQuery.trim().toLowerCase().split(RegExp(r'\s+'));
      
      List<Cosmetic> filtered = _allCosmetics.where((cosmetic) {
        String name = cosmetic.name.toLowerCase();
        String brand = cosmetic.brand.toLowerCase();
        
        // 다중 키워드 교집합 검사 (모든 키워드가 이름이나 브랜드에 포함되어야 함)
        bool isMatch = tokens.every((token) => name.contains(token) || brand.contains(token));
        
        if (isMatch && _selectedCategory != '전체') {
          isMatch = cosmetic.category == _selectedCategory;
        }
        return isMatch;
      }).toList();
      
      setState(() {
        _recommendedCosmetics = filtered;
        _isLoading = false;
        _currentPage = 1;
      });
      return;
    }

    if (_selectedSkinType == null || _selectedSkinType!.length != 4) {
      // 피부 타입 정보가 없으면 전체 리스트 혹은 빈 리스트
      setState(() {
        _recommendedCosmetics = [];
        _isLoading = false;
        _currentPage = 1;
      });
      return;
    }

    String part1 = _selectedSkinType![0];
    String part2 = _selectedSkinType![1];
    String part3 = _selectedSkinType![2];
    String part4 = _selectedSkinType![3];

    List<String> goodIngs = [];
    List<String> badIngs = [];

    void addIngs(String type) {
      goodIngs.addAll(beneficialIngredients[type] ?? []);
      badIngs.addAll(harmfulIngredients[type] ?? []);
    }

    addIngs(part1);
    addIngs(part2);
    addIngs(part3);
    addIngs(part4);

    // 중복 제거
    goodIngs = goodIngs.toSet().toList();
    badIngs = badIngs.toSet().toList();

    List<Cosmetic> filtered = _allCosmetics.where((cosmetic) {
      bool hasBad = cosmetic.ingredients.any((ing) => badIngs.any((b) => ing.contains(b)));
      
      bool isMatch = false;
      if (_isAvoidMode) {
        // 주의 모드: 주의 성분이 하나라도 포함된 화장품
        isMatch = hasBad;
      } else {
        // 추천 모드: 주의 성분이 없고 추천 성분이 하나라도 포함된 화장품
        if (hasBad) {
          isMatch = false;
        } else {
          bool hasGood = cosmetic.ingredients.any((ing) => goodIngs.any((g) => ing.contains(g)));
          isMatch = hasGood;
        }
      }
      
      if (isMatch && _selectedCategory != '전체') {
        isMatch = cosmetic.category == _selectedCategory;
      }
      return isMatch;
    }).toList();

    setState(() {
      _recommendedCosmetics = filtered;
      _isLoading = false;
      _currentPage = 1;
    });
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('피부 맞춤 화장품', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              _buildCategorySelector(),
                              if (!_isSearchMode) _buildModeToggle(),
                              if (!_isSearchMode) _buildSkinTypeSelector(),
                            ],
                          ),
                        ),
                        (_selectedSkinType == null && !_isSearchMode)
                            ? _buildEmptyState()
                            : _buildRecommendationList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: TextField(
        focusNode: _searchFocusNode,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _filterCosmetics();
          });
        },
        decoration: InputDecoration(
          hintText: '화장품 이름이나 브랜드를 검색해보세요',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: _searchFocusNode.hasFocus ? Colors.grey.shade100 : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _isAvoidMode = false;
                  _filterCosmetics();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isAvoidMode ? Theme.of(context).primaryColor : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '추천 화장품',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: !_isAvoidMode ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _isAvoidMode = true;
                  _filterCosmetics();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isAvoidMode ? Colors.redAccent : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '피해야 할 화장품',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isAvoidMode ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkinTypeSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            if (_userSkinType != null) ...[
              ChoiceChip(
                label: Text('👑 내 피부 타입 ($_userSkinType)'),
                selected: _selectedSkinType == _userSkinType,
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _selectedSkinType == _userSkinType ? Theme.of(context).primaryColor : Colors.black87,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedSkinType = _userSkinType;
                      _filterCosmetics();
                    });
                  }
                },
              ),
              const SizedBox(width: 12),
              Container(width: 1, height: 24, color: Colors.grey.shade300),
              const SizedBox(width: 12),
            ],
            ...allSkinTypes.where((type) => type != _userSkinType).map((type) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(type),
                  selected: _selectedSkinType == type,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedSkinType = type;
                        _filterCosmetics();
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: allCategories.map((category) {
            final isSelected = _selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category),
                selected: isSelected,
                selectedColor: Colors.blueAccent.withOpacity(0.15),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blueAccent.shade700 : Colors.black87,
                ),
                side: BorderSide(
                  color: isSelected ? Colors.blueAccent.shade200 : Colors.grey.shade300,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCategory = category;
                      _filterCosmetics();
                    });
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.face_retouching_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            '진단된 피부 타입이 없습니다.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '홈 화면에서 피부 타입 검사를 먼저 진행해주세요!',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationList() {
    if (_recommendedCosmetics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _isAvoidMode ? '피해야 할 화장품이 없습니다.' : '추천할 화장품이 없습니다.',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '조건에 맞는 화장품 데이터를 찾지 못했습니다.',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      );
    }

    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    if (endIndex > _recommendedCosmetics.length) endIndex = _recommendedCosmetics.length;
    List<Cosmetic> currentItems = _recommendedCosmetics.sublist(startIndex, endIndex);
    int totalPages = (_recommendedCosmetics.length / _itemsPerPage).ceil();

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isSearchMode
                    ? '검색 결과'
                    : '$_selectedSkinType 피부를 위한 ${_isAvoidMode ? "주의 화장품" : "맞춤 추천"}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isSearchMode 
                      ? Colors.black87 
                      : (_isAvoidMode ? Colors.redAccent : Theme.of(context).primaryColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isSearchMode
                    ? '총 ${_recommendedCosmetics.length}개의 화장품을 찾았습니다.'
                    : _isAvoidMode
                        ? '총 ${_recommendedCosmetics.length}개의 주의해야 할 제품을 찾았습니다.'
                        : '총 ${_recommendedCosmetics.length}개의 피부 친화적 제품을 찾았습니다.',
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: currentItems.length,
          itemBuilder: (context, index) {
            final cosmetic = currentItems[index];
            return _buildCosmeticCard(cosmetic);
          },
        ),
        if (totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 32, top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 1 ? () {
                    setState(() { _currentPage--; });
                  } : null,
                ),
                Text('$_currentPage / $totalPages', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentPage < totalPages ? () {
                    setState(() { _currentPage++; });
                  } : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBadge(String text, bool isGood) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isGood ? const Color(0xFFECFDF5) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isGood ? const Color(0xFFD1FAE5) : const Color(0xFFFECACA)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isGood ? const Color(0xFF059669) : const Color(0xFFDC2626),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent.shade700,
        ),
      ),
    );
  }

  Widget _buildCosmeticCard(Cosmetic cosmetic) {
    if (_selectedSkinType == null && !_isSearchMode) return const SizedBox.shrink();

    List<Widget> searchBadges = [];
    List<String> displayTags = [];
    Color tagBgColor = const Color(0xFFECFDF5);
    Color tagBorderColor = const Color(0xFFD1FAE5);
    Color tagTextColor = const Color(0xFF059669);
    IconData tagIcon = Icons.check_circle;

    if (_isSearchMode) {
      void checkType(String typeCode, String typeName) {
        bool isGood = cosmetic.ingredients.any((ing) => (beneficialIngredients[typeCode] ?? []).any((b) => ing.contains(b)));
        bool isBad = cosmetic.ingredients.any((ing) => (harmfulIngredients[typeCode] ?? []).any((b) => ing.contains(b)));
        
        if (isGood) {
          searchBadges.add(_buildSearchBadge('$typeName 추천', true));
        }
        if (isBad) {
          searchBadges.add(_buildSearchBadge('$typeName 주의', false));
        }
      }
      
      checkType('O', '지성');
      checkType('D', '건성');
      checkType('S', '민감성');
      checkType('P', '색소침착');
      checkType('W', '주름');
      checkType('T', '탄력');
    } else {
      String part1 = _selectedSkinType![0];
      String part2 = _selectedSkinType![1];
      String part3 = _selectedSkinType![2];
      String part4 = _selectedSkinType![3];

      List<String> targetIngs = [];

      if (_isAvoidMode) {
        targetIngs = [
          ...?harmfulIngredients[part1],
          ...?harmfulIngredients[part2],
          ...?harmfulIngredients[part3],
          ...?harmfulIngredients[part4],
        ].toSet().toList();
      } else {
        targetIngs = [
          ...?beneficialIngredients[part1],
          ...?beneficialIngredients[part2],
          ...?beneficialIngredients[part3],
          ...?beneficialIngredients[part4],
        ].toSet().toList();
      }

      List<String> matchedIngs = cosmetic.ingredients
          .where((ing) => targetIngs.any((t) => ing.contains(t)))
          .toList();

      displayTags = matchedIngs.take(3).toList();

      tagBgColor = _isAvoidMode ? const Color(0xFFFEE2E2) : const Color(0xFFECFDF5);
      tagBorderColor = _isAvoidMode ? const Color(0xFFFECACA) : const Color(0xFFD1FAE5);
      tagTextColor = _isAvoidMode ? const Color(0xFFDC2626) : const Color(0xFF059669);
      tagIcon = _isAvoidMode ? Icons.warning_amber_rounded : Icons.check_circle;
    }

    final cleanName = cosmetic.name.replaceAll(RegExp(r'\s*\[.*?\]\s*'), '').trim();
    final searchNameOlive = Uri.encodeComponent(cleanName);
    final searchNameHwahae = Uri.encodeComponent('[${cosmetic.brand}] ${cosmetic.name}');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _isSearchMode 
                        ? Colors.blue.withOpacity(0.1)
                        : _isAvoidMode 
                            ? Colors.redAccent.withOpacity(0.1) 
                            : Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isSearchMode 
                        ? Icons.shopping_bag 
                        : _isAvoidMode ? Icons.warning : Icons.clean_hands, 
                    color: _isSearchMode 
                        ? Colors.blue 
                        : _isAvoidMode ? Colors.redAccent : Theme.of(context).primaryColor
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCategoryBadge(cosmetic.category),
                        ],
                      ),
                      Text(
                        cosmetic.brand,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              cosmetic.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
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
                      if (cosmetic.capacity.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            cosmetic.capacity,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isSearchMode && searchBadges.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: searchBadges,
              ),
            ] else if (!_isSearchMode && displayTags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: displayTags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagBgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: tagBorderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tagIcon, size: 12, color: tagTextColor),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: tagTextColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFF1F5F9)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _launchSearch('https://www.oliveyoung.co.kr/store/search/getSearchMain.do?query=$searchNameOlive');
                    },
                    icon: SvgPicture.asset('lib/data/icon/oliveyoung.svg', height: 16),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(color: Colors.green.shade600),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    label: Text('올리브영 검색', style: TextStyle(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _launchSearch('https://www.hwahae.co.kr/search?q=$searchNameHwahae');
                    },
                    icon: Image.asset('lib/data/icon/hwahae.png', height: 16),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(color: Colors.blue.shade600),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    label: Text('화해 검색', style: TextStyle(fontSize: 13, color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
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