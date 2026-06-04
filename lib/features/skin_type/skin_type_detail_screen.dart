import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../../models/skin_type_info.dart';

class SkinTypeDetailScreen extends StatefulWidget {
  final String skinType;

  const SkinTypeDetailScreen({super.key, required this.skinType});

  @override
  State<SkinTypeDetailScreen> createState() => _SkinTypeDetailScreenState();
}

class _SkinTypeDetailScreenState extends State<SkinTypeDetailScreen> {
  SkinTypeInfo? _skinTypeInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSkinTypeDescription();
  }

  Future<void> _loadSkinTypeDescription() async {
    try {
      // skin_types.json 파일을 읽어옵니다.
      final String jsonString = await rootBundle.loadString('lib/data/skin_types.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final Map<String, dynamic> allTypes = jsonData['skinTypes'];
      
      // 현재 피부 타입에 맞는 데이터를 파싱하여 모델에 저장합니다.
      if (allTypes.containsKey(widget.skinType)) {
        setState(() {
          _skinTypeInfo = SkinTypeInfo.fromJson(allTypes[widget.skinType]);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("Error loading skin_types.json: $e");
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title, Color color) {
    return Text(
      title,
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
    );
  }

  Widget _buildSubSectionTitle(BuildContext context, String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildIngredientCard(String name, String effect) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            Text(effect, style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey.shade800)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentIngredientCard(String name, String effect) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade700,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '최신 연구',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              effect,
              style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey.shade800),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.skinType} 타입 상세 정보'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _skinTypeInfo == null
              ? const Center(
                  child: Text(
                    "해당 피부 타입에 대한 상세 정보가 준비되지 않았습니다.",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 피부 타입 영문명 (예: DSPT)
                      Text(
                        widget.skinType,
                        style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // 피부 타입 한글명 (예: 건성, 민감성, 색소침착, 탄력)
                      Text(
                        _skinTypeInfo!.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // 피부 타입 요약 설명
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                        ),
                        child: Text(
                          _skinTypeInfo!.summary,
                          style: const TextStyle(fontSize: 16, height: 1.6),
                        ),
                      ),
                      
                      // 핵심 스킨케어 팁 (Essential Tips)
                      if (_skinTypeInfo!.essentialTips.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.amber.shade50, Colors.amber.shade100.withOpacity(0.2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade300, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.shade100.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.lightbulb_rounded, color: Colors.amber.shade800, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    '💡 핵심 스킨케어 가이드',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _skinTypeInfo!.essentialTips,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 40),

                      // 추천 성분 영역
                      _buildSectionTitle(context, '✅ 추천/유효 성분', Colors.green.shade700),
                      const SizedBox(height: 16),
                      ..._skinTypeInfo!.beneficialIngredients.map((item) => _buildIngredientCard(item.name, item.effect)),
                      
                      // 최신 추가 추천 성분
                      if (_skinTypeInfo!.recentBeneficialIngredients.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildSubSectionTitle(context, '🆕 최신 연구 기반 추가 추천 성분', Colors.teal.shade700),
                        const SizedBox(height: 12),
                        ..._skinTypeInfo!.recentBeneficialIngredients.map((item) => _buildRecentIngredientCard(item.name, item.effect)),
                      ],
                      
                      const SizedBox(height: 32),

                      // 피해야 할 성분 영역
                      _buildSectionTitle(context, '❌ 피해야 할 성분', Colors.red.shade700),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _skinTypeInfo!.avoidIngredients.map((item) {
                          return Chip(
                            label: Text(item),
                            backgroundColor: Colors.red.shade50,
                            labelStyle: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.w500),
                            side: BorderSide(color: Colors.red.shade200),
                          );
                        }).toList(),
                      ),
                      
                      // 최신 추가 주의 성분
                      if (_skinTypeInfo!.recentAvoidIngredients.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildSubSectionTitle(context, '⚠️ 최신 연구 기반 추가 주의 성분', Colors.orange.shade800),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: _skinTypeInfo!.recentAvoidIngredients.map((item) {
                            return Chip(
                              label: Text(item),
                              backgroundColor: Colors.orange.shade50,
                              labelStyle: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.w500),
                              side: BorderSide(color: Colors.orange.shade200),
                            );
                          }).toList(),
                        ),
                      ],
                      
                      const SizedBox(height: 40), // 하단 버튼과의 여백
                    ],
                  ),
                ),
      // 화면 하단에 홈으로 돌아가기 버튼 고정
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              // popUntil을 사용하여 퀴즈 관련 화면을 모두 닫고 첫 화면(홈)으로 돌아갑니다.
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('홈으로 돌아가기', style: TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }
}
