import 'package:flutter/material.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skin Care App',
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        
        // =====================================================================
        // 1. 앱 전체의 [글자 크기] 및 [글자 굵기(Bold)] 조절
        // =====================================================================
        textTheme: const TextTheme(
          // 일반 본문 텍스트 (fontSize: 글자 크기, fontWeight: 글자 굵기)
          bodyMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
          // 큰 제목 텍스트 (FontWeight.bold 를 통해 굵게 처리)
          titleLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),

        // =====================================================================
        // 2. 앱 전체의 [버튼 크기] 및 [버튼 내 글자 크기] 조절
        // =====================================================================
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            // 버튼 내 글자 크기와 굵기 조절
            textStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            // 버튼 안쪽 여백 조절 (버튼의 실질적인 크기를 결정합니다)
            // vertical: 위아래 여백 (버튼 높이 조절), horizontal: 좌우 여백 (버튼 너비 조절)
            padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
            // 버튼의 최소 높이(height)를 고정하고 싶을 때 사용 (너비 무한대, 높이 55)
            // minimumSize: const Size(double.infinity, 55.0),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
