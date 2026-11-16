import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet_profile.dart';
import '../models/health_record.dart';
import '../models/food_taste_note.dart';

class StorageService {
  static const String _keyProfiles = 'gudog_profiles';
  static const String _keyCurrentPetId = 'gudog_current_pet_id';
  static const String _keyDailyRecords = 'gudog_daily_records';
  static const String _keyTasteNotes = 'gudog_taste_notes';
  static const String _keySavedStoreItems = 'gudog_saved_items';

  // 1. 프로필 관리
  static Future<List<PetProfile>> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyProfiles);
    if (jsonList == null || jsonList.isEmpty) {
      final defaultList = [PetProfile.defaultSample()];
      await saveProfiles(defaultList);
      return defaultList;
    }
    return jsonList.map((str) => PetProfile.fromJson(str)).toList();
  }

  static Future<void> saveProfiles(List<PetProfile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = profiles.map((p) => p.toJson()).toList();
    await prefs.setStringList(_keyProfiles, jsonList);
  }

  static Future<String?> loadCurrentPetId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrentPetId);
  }

  static Future<void> saveCurrentPetId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrentPetId, id);
  }

  // 2. 건강 기록 관리 (날짜_반려동물ID 기준)
  static Future<DailyHealthRecord> getRecord(String dateString, String petId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_keyDailyRecords}_${petId}_$dateString';
    final jsonStr = prefs.getString(key);
    if (jsonStr == null) {
      return DailyHealthRecord(dateString: dateString, petId: petId);
    }
    return DailyHealthRecord.fromJson(jsonStr);
  }

  static Future<void> saveRecord(DailyHealthRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_keyDailyRecords}_${record.petId}_${record.dateString}';
    await prefs.setString(key, record.toJson());
  }

  // 최근 N일간의 기록 불러오기 (그래프 및 병원 리포트용)
  static Future<List<DailyHealthRecord>> getRecentRecords(String petId, int days) async {
    final list = <DailyHealthRecord>[];
    final now = DateTime.now();
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final rec = await getRecord(dateStr, petId);
      list.add(rec);
    }
    return list;
  }

  // 3. 기호성 및 알레르기 노트 관리
  static Future<List<FoodTasteNote>> loadTasteNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyTasteNotes);
    if (jsonList == null || jsonList.isEmpty) {
      // 기본 주요 원물 초기화
      final defaultNotes = [
        FoodTasteNote(ingredientName: '닭가슴살', reaction: TasteReaction.love, memo: '동결건조 큐브 완식'),
        FoodTasteNote(ingredientName: '노르웨이 생연어', reaction: TasteReaction.love, memo: '물에 불려주면 국물까지 싹 비움'),
        FoodTasteNote(ingredientName: '오리안심', reaction: TasteReaction.normal, memo: '져키 형태로 무난하게 섭취'),
        FoodTasteNote(ingredientName: '메추리', reaction: TasteReaction.normal, memo: '단백질 토핑으로 활용'),
        FoodTasteNote(ingredientName: '가다랑어포', reaction: TasteReaction.love, memo: '밥 안 먹을 때 마법의 가루'),
        FoodTasteNote(ingredientName: '국내산 단호박', reaction: TasteReaction.love, memo: '헤어볼 배출용 퓨레로 애용'),
        FoodTasteNote(ingredientName: '참치', reaction: TasteReaction.normal, memo: '가끔 특식으로 급여'),
        FoodTasteNote(ingredientName: '초록입홍합', reaction: TasteReaction.normal, memo: '관절 파우더로 사료에 섞어줌'),
      ];
      await saveTasteNotes(defaultNotes);
      return defaultNotes;
    }
    return jsonList.map((s) => FoodTasteNote.fromJson(s)).toList();
  }

  static Future<void> saveTasteNotes(List<FoodTasteNote> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notes.map((n) => n.toJson()).toList();
    await prefs.setStringList(_keyTasteNotes, jsonList);
  }

  // 4. 관심 상품 목록 관리
  static Future<List<String>> loadSavedStoreItems() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keySavedStoreItems) ?? [];
  }

  static Future<void> saveSavedStoreItems(List<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keySavedStoreItems, items);
  }
}
