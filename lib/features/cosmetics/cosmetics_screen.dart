import 'package:flutter/material.dart';

class CosmeticsScreen extends StatelessWidget {
  const CosmeticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('피부별 화장품 추천'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text(
          '여기에 피부 타입에 맞는 화장품 리스트가 들어갈 예정입니다.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}