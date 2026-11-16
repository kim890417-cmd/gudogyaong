import 'dart:convert';

enum PetType { cat, dog }

class PetProfile {
  final String id;
  String name;
  PetType type;
  String breed;
  int ageYears;
  double weightKg;
  bool isNeutered;
  List<String> healthConcerns; // 음수량, 헤어볼, 신장, 관절, 다이어트 등
  DateTime? snackOpenedDate;
  bool isSnackFrozen; // false: 냉장(7일), true: 냉동(30일)

  PetProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.ageYears,
    required this.weightKg,
    this.isNeutered = true,
    required this.healthConcerns,
    this.snackOpenedDate,
    this.isSnackFrozen = false,
  });

  // 권장 음수량 (체중 kg × 50ml)
  int get recommendedWaterMl => (weightKg * 50).round();

  // 수제간식 D-Day 계산
  int? get snackDDay {
    if (snackOpenedDate == null) return null;
    final maxDays = isSnackFrozen ? 30 : 7;
    final expiryDate = snackOpenedDate!.add(Duration(days: maxDays));
    final diff = expiryDate.difference(DateTime.now()).inDays;
    return diff;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'breed': breed,
      'ageYears': ageYears,
      'weightKg': weightKg,
      'isNeutered': isNeutered,
      'healthConcerns': healthConcerns,
      'snackOpenedDate': snackOpenedDate?.toIso8601String(),
      'isSnackFrozen': isSnackFrozen,
    };
  }

  factory PetProfile.fromMap(Map<String, dynamic> map) {
    return PetProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] == 'dog' ? PetType.dog : PetType.cat,
      breed: map['breed'] ?? '',
      ageYears: map['ageYears']?.toInt() ?? 1,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 4.0,
      isNeutered: map['isNeutered'] ?? true,
      healthConcerns: List<String>.from(map['healthConcerns'] ?? []),
      snackOpenedDate: map['snackOpenedDate'] != null
          ? DateTime.tryParse(map['snackOpenedDate'])
          : null,
      isSnackFrozen: map['isSnackFrozen'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory PetProfile.fromJson(String source) =>
      PetProfile.fromMap(json.decode(source));

  // 기본 샘플 데이터 (루나: 코리안숏헤어, 4세, 4.2kg)
  static PetProfile defaultSample() {
    return PetProfile(
      id: 'default_luna',
      name: '루나',
      type: PetType.cat,
      breed: '코리안숏헤어',
      ageYears: 4,
      weightKg: 4.2,
      isNeutered: true,
      healthConcerns: ['음수량', '헤어볼', '신장'],
      snackOpenedDate: DateTime.now().subtract(const Duration(days: 2)),
      isSnackFrozen: false,
    );
  }
}
