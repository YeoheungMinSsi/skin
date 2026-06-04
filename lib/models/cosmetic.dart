class Cosmetic {
  final String capacity;
  final String manufacturer;
  final List<String> ingredients;
  final String brand;
  final String name;
  final String goodsId;
  final String category;

  Cosmetic({
    required this.capacity,
    required this.manufacturer,
    required this.ingredients,
    required this.brand,
    required this.name,
    required this.goodsId,
    required this.category,
  });

  factory Cosmetic.fromJson(Map<String, dynamic> json) {
    // 주요성분 문자열을 가져옴
    String ingredientsRaw = json['주요성분'] ?? '';
    
    // 쉼표(,)나 세미콜론(;) 기준으로 분리하여 배열(List)로 변환
    List<String> ingredientsList = ingredientsRaw
        .split(RegExp(r'[,;]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Cosmetic(
      capacity: json['용량 또는 중량'] ?? '',
      manufacturer: json['제조자 및 제조판매업자'] ?? '',
      ingredients: ingredientsList,
      brand: json['브랜드'] ?? '',
      name: json['제품명'] ?? '',
      goodsId: json['goods_id'] ?? '',
      category: json['분류'] ?? '기타',
    );
  }
}
