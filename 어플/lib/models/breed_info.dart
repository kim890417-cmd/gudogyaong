import 'pet_profile.dart';

class BreedInfo {
  final String id;
  final String name;
  final PetType type;
  final String imagePath;
  final String? imageUrl;
  final String coatType; // 단모, 장모, 세미롱 등
  final String sizeType; // 소형, 중형, 대형
  final String avgWeightKg;
  final String personality;
  final List<String> healthCarePoints;
  final List<String> recommendedFoods;
  final String foodTypeGuide;
  final String dietCaution;

  const BreedInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.imagePath,
    this.imageUrl,
    required this.coatType,
    required this.sizeType,
    required this.avgWeightKg,
    required this.personality,
    required this.healthCarePoints,
    required this.recommendedFoods,
    required this.foodTypeGuide,
    required this.dietCaution,
  });
}
