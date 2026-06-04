class BeneficialIngredient {
  final String name;
  final String effect;

  BeneficialIngredient({required this.name, required this.effect});

  factory BeneficialIngredient.fromJson(Map<String, dynamic> json) {
    return BeneficialIngredient(
      name: json['name'] as String? ?? '',
      effect: json['effect'] as String? ?? '',
    );
  }
}

class SkinTypeInfo {
  final String name;
  final String summary;
  final List<String> avoidIngredients;
  final List<String> recentAvoidIngredients;
  final List<BeneficialIngredient> beneficialIngredients;
  final List<BeneficialIngredient> recentBeneficialIngredients;
  final String essentialTips;

  SkinTypeInfo({
    required this.name,
    required this.summary,
    required this.avoidIngredients,
    required this.recentAvoidIngredients,
    required this.beneficialIngredients,
    required this.recentBeneficialIngredients,
    required this.essentialTips,
  });

  factory SkinTypeInfo.fromJson(Map<String, dynamic> json) {
    var beneficialList = json['beneficialIngredients'] as List? ?? [];
    List<BeneficialIngredient> ingredients = beneficialList
        .map((i) => BeneficialIngredient.fromJson(Map<String, dynamic>.from(i)))
        .toList();

    var recentBeneficialList = json['recentBeneficialIngredients'] as List? ?? [];
    List<BeneficialIngredient> recentIngredients = recentBeneficialList
        .map((i) => BeneficialIngredient.fromJson(Map<String, dynamic>.from(i)))
        .toList();

    return SkinTypeInfo(
      name: json['name'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      avoidIngredients: json['avoidIngredients'] != null
          ? List<String>.from(json['avoidIngredients'] as List)
          : [],
      recentAvoidIngredients: json['recentAvoidIngredients'] != null
          ? List<String>.from(json['recentAvoidIngredients'] as List)
          : [],
      beneficialIngredients: ingredients,
      recentBeneficialIngredients: recentIngredients,
      essentialTips: json['essentialTips'] as String? ?? '',
    );
  }
}
