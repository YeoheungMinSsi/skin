class BeneficialIngredient {
  final String name;
  final String effect;

  BeneficialIngredient({required this.name, required this.effect});

  factory BeneficialIngredient.fromJson(Map<String, dynamic> json) {
    return BeneficialIngredient(
      name: json['name'] as String,
      effect: json['effect'] as String,
    );
  }
}

class SkinTypeInfo {
  final String name;
  final String summary;
  final List<String> avoidIngredients;
  final List<BeneficialIngredient> beneficialIngredients;

  SkinTypeInfo({
    required this.name,
    required this.summary,
    required this.avoidIngredients,
    required this.beneficialIngredients,
  });

  factory SkinTypeInfo.fromJson(Map<String, dynamic> json) {
    var beneficialList = json['beneficialIngredients'] as List;
    List<BeneficialIngredient> ingredients = beneficialList.map((i) => BeneficialIngredient.fromJson(i)).toList();

    return SkinTypeInfo(
      name: json['name'] as String,
      summary: json['summary'] as String,
      avoidIngredients: List<String>.from(json['avoidIngredients']),
      beneficialIngredients: ingredients,
    );
  }
}
