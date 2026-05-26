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

  Widget _buildIngredientCard(String name, String effect) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(effect, style: const TextStyle(fontSize: 16, height: 1.5)),
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
                      const SizedBox(height: 40),

                      // 추천 성분 영역
                      _buildSectionTitle(context, '✅ 추천/유효 성분', Colors.green.shade700),
                      const SizedBox(height: 16),
                      ..._skinTypeInfo!.beneficialIngredients.map((item) => _buildIngredientCard(item.name, item.effect)),
                      
                      const SizedBox(height: 24),

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
