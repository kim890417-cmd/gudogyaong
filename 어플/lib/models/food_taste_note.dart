import 'dart:convert';

enum TasteReaction {
  love,    // 잘 먹음 (초록)
  normal,  // 보통 (파랑)
  refuse,  // 거부 (주황)
  allergy  // 구토·알레르기 (빨강)
}

class FoodTasteNote {
  final String ingredientName;
  TasteReaction reaction;
  String memo;
  DateTime updatedAt;

  FoodTasteNote({
    required this.ingredientName,
    this.reaction = TasteReaction.normal,
    this.memo = '',
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  String get reactionLabel {
    switch (reaction) {
      case TasteReaction.love:
        return '잘 먹음 😋';
      case TasteReaction.normal:
        return '보통 🙂';
      case TasteReaction.refuse:
        return '거부 😾';
      case TasteReaction.allergy:
        return '구토·알레르기 🚨';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'ingredientName': ingredientName,
      'reaction': reaction.name,
      'memo': memo,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FoodTasteNote.fromMap(Map<String, dynamic> map) {
    TasteReaction parseReaction(String? val) {
      switch (val) {
        case 'love':
          return TasteReaction.love;
        case 'refuse':
          return TasteReaction.refuse;
        case 'allergy':
          return TasteReaction.allergy;
        default:
          return TasteReaction.normal;
      }
    }

    return FoodTasteNote(
      ingredientName: map['ingredientName'] ?? '',
      reaction: parseReaction(map['reaction']),
      memo: map['memo'] ?? '',
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory FoodTasteNote.fromJson(String source) =>
      FoodTasteNote.fromMap(json.decode(source));
}
