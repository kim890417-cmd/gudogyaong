import 'dart:convert';

class DailyHealthRecord {
  final String dateString; // YYYY-MM-DD
  final String petId;
  int waterIntakeMl;
  int peeCount; // 감자 횟수
  int poopCount; // 맛동산 횟수
  int vomitCount; // 구토 및 헤어볼 횟수
  double weightKg;
  String memo;
  String recentSnack;

  DailyHealthRecord({
    required this.dateString,
    required this.petId,
    this.waterIntakeMl = 0,
    this.peeCount = 0,
    this.poopCount = 0,
    this.vomitCount = 0,
    this.weightKg = 0.0,
    this.memo = '',
    this.recentSnack = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'dateString': dateString,
      'petId': petId,
      'waterIntakeMl': waterIntakeMl,
      'peeCount': peeCount,
      'poopCount': poopCount,
      'vomitCount': vomitCount,
      'weightKg': weightKg,
      'memo': memo,
      'recentSnack': recentSnack,
    };
  }

  factory DailyHealthRecord.fromMap(Map<String, dynamic> map) {
    return DailyHealthRecord(
      dateString: map['dateString'] ?? '',
      petId: map['petId'] ?? '',
      waterIntakeMl: map['waterIntakeMl']?.toInt() ?? 0,
      peeCount: map['peeCount']?.toInt() ?? 0,
      poopCount: map['poopCount']?.toInt() ?? 0,
      vomitCount: map['vomitCount']?.toInt() ?? 0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      memo: map['memo'] ?? '',
      recentSnack: map['recentSnack'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DailyHealthRecord.fromJson(String source) =>
      DailyHealthRecord.fromMap(json.decode(source));
}
