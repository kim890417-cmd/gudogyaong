enum SafetyLevel {
  forbidden, // 절대 금기 (빨강)
  caution,   // 소량 주의 (주황)
  safe       // 안전 영양식 (초록)
}

class FoodSafetyItem {
  final String name;
  final String category; // 육류·어류, 과일·채소, 사람음식, 식물
  final SafetyLevel safetyLevel;
  final String target; // 고양이 전용, 강아지 전용, 멍냥 공통
  final String reason;
  final String symptoms;
  final String advice;

  const FoodSafetyItem({
    required this.name,
    required this.category,
    required this.safetyLevel,
    required this.target,
    required this.reason,
    required this.symptoms,
    required this.advice,
  });

  String get safetyBadgeText {
    switch (safetyLevel) {
      case SafetyLevel.forbidden:
        return '절대 금기';
      case SafetyLevel.caution:
        return '소량 주의';
      case SafetyLevel.safe:
        return '안전 영양';
    }
  }
}
