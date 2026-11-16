import 'dart:math';
import 'package:flutter/material.dart';
import '../models/breed_info.dart';
import '../models/pet_profile.dart';
import '../models/food_safety.dart';
import '../models/food_taste_note.dart';
import '../data/breed_data.dart';
import '../data/forbidden_food_data.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class EncyclopediaScreen extends StatefulWidget {
  final Function(PetProfile) onNewPetRegistered;

  const EncyclopediaScreen({Key? key, required this.onNewPetRegistered}) : super(key: key);

  @override
  State<EncyclopediaScreen> createState() => _EncyclopediaScreenState();
}

class _EncyclopediaScreenState extends State<EncyclopediaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 1. 도감 검색 및 필터
  PetType _breedPetType = PetType.cat;
  String _breedSearchQuery = '';

  // 2. 칼로리 계산기 상태
  double _calcWeight = 4.0;
  String _lifeStage = '성묘/성견';
  String _activityLevel = '보통(중성화 완료)';
  int _calculatedRer = 0;
  int _calculatedDer = 0;
  int _calculatedWater = 0;

  // 3. DM 계산기 상태
  final _crudeProteinCtrl = TextEditingController(text: '32');
  final _crudeFatCtrl = TextEditingController(text: '14');
  final _crudeFiberCtrl = TextEditingController(text: '3');
  final _crudeAshCtrl = TextEditingController(text: '7');
  final _moistureCtrl = TextEditingController(text: '10');
  double? _dmProtein, _dmFat, _dmCarb;

  // 4. 금기 음식 상태
  String _foodSearchQuery = '';
  String _foodCategoryFilter = '전체';

  // 5. 시식 도감 상태
  List<FoodTasteNote> _tasteNotes = [];
  bool _isLoadingNotes = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _calculateCalories();
    _calculateDm();
    _loadTasteNotes();
  }

  void _loadTasteNotes() async {
    final notes = await StorageService.loadTasteNotes();
    setState(() {
      _tasteNotes = notes;
      _isLoadingNotes = false;
    });
  }

  // RER & DER 계산 공식
  void _calculateCalories() {
    if (_calcWeight <= 0) return;
    // RER = 70 * (체중^0.75)
    final rer = 70 * pow(_calcWeight, 0.75);
    double factor = 1.2; // 기본 보통

    if (_lifeStage == '자묘/자견 (성장기)') {
      factor = 2.0;
    } else if (_lifeStage == '노령 (7세 이상)') {
      factor = 1.0;
    } else {
      if (_activityLevel == '비만 경향 / 다이어트') {
        factor = 1.0;
      } else if (_activityLevel == '활동적 / 중성화 미완료') {
        factor = 1.4;
      } else {
        factor = 1.2;
      }
    }

    final der = rer * factor;
    final water = (_calcWeight * 50).round();

    setState(() {
      _calculatedRer = rer.round();
      _calculatedDer = der.round();
      _calculatedWater = water;
    });
  }

  // DM 건물 기준 성분 계산
  void _calculateDm() {
    final protein = double.tryParse(_crudeProteinCtrl.text) ?? 0.0;
    final fat = double.tryParse(_crudeFatCtrl.text) ?? 0.0;
    final fiber = double.tryParse(_crudeFiberCtrl.text) ?? 0.0;
    final ash = double.tryParse(_crudeAshCtrl.text) ?? 0.0;
    final moisture = double.tryParse(_moistureCtrl.text) ?? 0.0;

    final dryMatter = 100.0 - moisture;
    if (dryMatter <= 0) return;

    final dmP = (protein / dryMatter) * 100.0;
    final dmF = (fat / dryMatter) * 100.0;
    final rawCarb = 100.0 - (protein + fat + fiber + ash + moisture);
    final dmC = (rawCarb.clamp(0.0, 100.0) / dryMatter) * 100.0;

    setState(() {
      _dmProtein = dmP;
      _dmFat = dmF;
      _dmCarb = dmC;
    });
  }

  void _showBreedDetailModal(BreedInfo breed) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            controller: scrollController,
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.subBg, borderRadius: BorderRadius.circular(8)),
                    child: Text('${breed.type == PetType.cat ? '고양이' : '강아지'} · ${breed.coatType}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.mutedText)),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 10),
              Text(breed.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.charcoal)),
              Text('평균 체중: ${breed.avgWeightKg} · 크기: ${breed.sizeType}', style: const TextStyle(fontSize: 12, color: AppTheme.mutedText)),
              const SizedBox(height: 16),
              // 성격
              _buildSectionTitle('성격 및 특성'),
              Text(breed.personality, style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.charcoal)),
              const SizedBox(height: 16),
              // 취약 질환
              _buildSectionTitle('품종별 취약 질환 & 건강 포인트'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: breed.healthCarePoints.map((pt) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🚨 ', style: TextStyle(fontSize: 12)),
                      Expanded(child: Text(pt, style: const TextStyle(fontSize: 13, color: AppTheme.charcoal))),
                    ],
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              // 추천 원물 및 급여 가이드
              _buildSectionTitle('추천 맞춤 음식 & 조리 형태'),
              Wrap(
                spacing: 6,
                children: breed.recommendedFoods.map((f) => Chip(
                  label: Text(f, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.terracottaDark)),
                  backgroundColor: AppTheme.terracottaLight,
                  side: BorderSide.none,
                )).toList(),
              ),
              const SizedBox(height: 8),
              Text('💡 ${breed.foodTypeGuide}', style: const TextStyle(fontSize: 12, color: AppTheme.sageDark, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text('⚠️ 주의 식습관: ${breed.dietCaution}', style: const TextStyle(fontSize: 12, color: AppTheme.mutedText)),
              const SizedBox(height: 24),
              // 내 아이로 바로 등록하기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.pets, size: 16),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.terracotta,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    final newPet = PetProfile(
                      id: 'pet_${DateTime.now().millisecondsSinceEpoch}',
                      name: '우리 ${breed.name}',
                      type: breed.type,
                      breed: breed.name,
                      ageYears: 2,
                      weightKg: breed.type == PetType.cat ? 4.0 : 3.0,
                      healthConcerns: ['음수량', '맞춤케어'],
                    );
                    widget.onNewPetRegistered(newPet);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${breed.name} 프로필이 추가되어 홈에 적용되었습니다! 🐾')),
                    );
                  },
                  label: const Text('내 아이로 바로 등록하기', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFoodDetailModal(FoodSafetyItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22.0),
        decoration: const BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.safetyLevel == SafetyLevel.forbidden
                        ? AppTheme.warningRed.withOpacity(0.15)
                        : item.safetyLevel == SafetyLevel.caution
                            ? AppTheme.warningOrange.withOpacity(0.15)
                            : AppTheme.sageMint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.safetyBadgeText} · ${item.category}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: item.safetyLevel == SafetyLevel.forbidden
                          ? AppTheme.warningRed
                          : item.safetyLevel == SafetyLevel.caution
                              ? AppTheme.warningOrange
                              : AppTheme.sageDark,
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 10),
            Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.charcoal)),
            const SizedBox(height: 4),
            Text('대상: ${item.target}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.mutedText)),
            const SizedBox(height: 14),
            _buildSectionTitle('위험/효능 이유'),
            Text(item.reason, style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.charcoal)),
            const SizedBox(height: 12),
            _buildSectionTitle('섭취 시 증상 및 대처 가이드'),
            Text('증상: ${item.symptoms}', style: const TextStyle(fontSize: 12, color: AppTheme.charcoal)),
            const SizedBox(height: 4),
            Text('대처: ${item.advice}', style: const TextStyle(fontSize: 12, color: AppTheme.mutedText)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.terracottaDark)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('백과 · 식단 도구 5종'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.terracotta,
          unselectedLabelColor: AppTheme.mutedText,
          indicatorColor: AppTheme.terracotta,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: '품종 도감 (22종)'),
            Tab(text: '칼로리·음수량 계산기'),
            Tab(text: '사료 건물(DM) 분석기'),
            Tab(text: '금기 음식 검색'),
            Tab(text: '원물 시식 도감'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBreedCatalogTab(),
          _buildCalorieCalcTab(),
          _buildDmCalcTab(),
          _buildForbiddenFoodTab(),
          _buildTasteNotesTab(),
        ],
      ),
    );
  }

  // 1. 품종별 동물 백과사전 탭
  Widget _buildBreedCatalogTab() {
    final filtered = BreedData.breeds.where((b) {
      final matchesType = b.type == _breedPetType;
      final matchesSearch = _breedSearchQuery.isEmpty || b.name.contains(_breedSearchQuery);
      return matchesType && matchesSearch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 고양이 / 강아지 전환 세그먼트
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('🐱 고양이 품종 (12종)', style: TextStyle(fontWeight: FontWeight.bold))),
                  selected: _breedPetType == PetType.cat,
                  selectedColor: AppTheme.terracottaLight,
                  onSelected: (val) => setState(() => _breedPetType = PetType.cat),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('🐶 강아지 품종 (10종)', style: TextStyle(fontWeight: FontWeight.bold))),
                  selected: _breedPetType == PetType.dog,
                  selectedColor: AppTheme.terracottaLight,
                  onSelected: (val) => setState(() => _breedPetType = PetType.dog),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 품종 검색창
          TextField(
            decoration: InputDecoration(
              hintText: '품종명 검색 (예: 코숏, 랙돌, 말티즈, 포메)',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(borderRadius: AppTheme.buttonRadius),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onChanged: (val) => setState(() => _breedSearchQuery = val.trim()),
          ),
          const SizedBox(height: 12),
          // 품종 카드 그리드
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final breed = filtered[i];
                return InkWell(
                  onTap: () => _showBreedDetailModal(breed),
                  borderRadius: AppTheme.cardRadius,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: AppTheme.cardRadius,
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 품종 사진 영역
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 80,
                            width: double.infinity,
                            color: AppTheme.subBg,
                            child: breed.imageUrl != null
                                ? Image.network(
                                    breed.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(child: Text('🐾', style: TextStyle(fontSize: 28))),
                                  )
                                : const Center(child: Text('🐾', style: TextStyle(fontSize: 28))),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(breed.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.charcoal), maxLines: 1),
                        Text('${breed.coatType} · ${breed.avgWeightKg}', style: const TextStyle(fontSize: 10, color: AppTheme.mutedText)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppTheme.sageMint, borderRadius: BorderRadius.circular(6)),
                          child: Text(breed.healthCarePoints.first, style: const TextStyle(fontSize: 9, color: AppTheme.sageDark, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 2. 칼로리 및 음수량 계산기 탭
  Widget _buildCalorieCalcTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: AppTheme.cardRadius, border: Border.all(color: AppTheme.borderLight)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📊 체중 및 생애주기 입력', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.charcoal)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text('체중: ${_calcWeight.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Slider(
                        value: _calcWeight,
                        min: 1.0,
                        max: 40.0,
                        divisions: 390,
                        activeColor: AppTheme.terracotta,
                        onChanged: (v) {
                          setState(() => _calcWeight = v);
                          _calculateCalories();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _lifeStage,
                  decoration: InputDecoration(labelText: '생애주기', border: OutlineInputBorder(borderRadius: AppTheme.buttonRadius)),
                  items: ['자묘/자견 (성장기)', '성묘/성견', '노령 (7세 이상)'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) {
                    setState(() => _lifeStage = v!);
                    _calculateCalories();
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _activityLevel,
                  decoration: InputDecoration(labelText: '활동량 / 상태', border: OutlineInputBorder(borderRadius: AppTheme.buttonRadius)),
                  items: ['보통(중성화 완료)', '활동적 / 중성화 미완료', '비만 경향 / 다이어트'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) {
                    setState(() => _activityLevel = v!);
                    _calculateCalories();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 계산 결과 카드
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppTheme.terracottaLight, borderRadius: AppTheme.cardRadius, border: Border.all(color: AppTheme.terracotta.withOpacity(0.3))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡 1일 권장 필요량 계산 결과', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.terracottaDark)),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCalcResultItem('기초대사량(RER)', '$_calculatedRer', 'kcal'),
                    _buildCalcResultItem('권장칼로리(DER)', '$_calculatedDer', 'kcal'),
                    _buildCalcResultItem('목표 음수량', '$_calculatedWater', 'ml'),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const Text(
                  '🐾 추천 구독 플랜: 음수량과 칼로리 균형이 중요한 아이라면 [실버 맞춤 박스 - 동결건조 생연어 & 수분 테린 파우치]를 추천합니다.',
                  style: TextStyle(fontSize: 11, color: AppTheme.charcoal, height: 1.4, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalcResultItem(String title, String val, String unit) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.mutedText)),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            text: val,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.charcoal),
            children: [TextSpan(text: ' $unit', style: const TextStyle(fontSize: 11, color: AppTheme.mutedText))],
          ),
        ),
      ],
    );
  }

  // 3. 사료 건물 기준(DM) 분석기 탭
  Widget _buildDmCalcTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: AppTheme.cardRadius, border: Border.all(color: AppTheme.borderLight)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('사료 포장지 성분표 입력 (%)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.charcoal)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildDmField('조단백', _crudeProteinCtrl)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDmField('조지방', _crudeFatCtrl)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDmField('조섬유', _crudeFiberCtrl)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildDmField('조회분', _crudeAshCtrl)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDmField('수분 (보통 10%)', _moistureCtrl)),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.terracotta, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius)),
                    onPressed: _calculateDm,
                    child: const Text('건물 기준(DM) 분석하기'),
                  ),
                ),
              ],
            ),
          ),
          if (_dmProtein != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppTheme.sageMint, borderRadius: AppTheme.cardRadius, border: Border.all(color: AppTheme.sageDark.withOpacity(0.3))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🌿 실제 건물 기준(Dry Matter) 성분 비율', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.sageDark)),
                  const SizedBox(height: 12),
                  Text('• 실제 단백질: ${_dmProtein!.toStringAsFixed(1)}% (30% 이상 시 고단백 우수 식단)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('• 실제 지방: ${_dmFat!.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('• 실제 탄수화물: ${_dmCarb!.toStringAsFixed(1)}% (육식동물인 고양이는 20% 이하 권장)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 10),
                  Text(
                    _dmProtein! >= 35 && _dmCarb! <= 25 ? '✅ 고단백 저탄수의 매우 훌륭한 프리미엄 사료입니다!' : '⚠️ 탄수화물 비중이 다소 높은 편입니다. 단백질 원물 간식을 함께 보충해 주세요.',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.charcoal),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDmField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: '%',
        border: OutlineInputBorder(borderRadius: AppTheme.buttonRadius),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }

  // 4. 먹어도 되나요? 금기 음식 검색기 탭
  Widget _buildForbiddenFoodTab() {
    final filtered = ForbiddenFoodData.items.where((item) {
      final matchCat = _foodCategoryFilter == '전체' || item.category == _foodCategoryFilter;
      final matchSearch = _foodSearchQuery.isEmpty || item.name.contains(_foodSearchQuery);
      return matchCat && matchSearch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 검색창
          TextField(
            decoration: InputDecoration(
              hintText: '음식 이름 검색 (예: 양파, 포도, 연어, 단호박, 우유)',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: AppTheme.buttonRadius),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (v) => setState(() => _foodSearchQuery = v.trim()),
          ),
          const SizedBox(height: 10),
          // 카테고리 필터 칩
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['전체', '육류·어류', '과일·채소', '사람음식', '식물'].map((cat) => Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: FilterChip(
                  label: Text(cat, style: const TextStyle(fontSize: 11)),
                  selected: _foodCategoryFilter == cat,
                  selectedColor: AppTheme.terracottaLight,
                  onSelected: (val) => setState(() => _foodCategoryFilter = cat),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 10),
          // 음식 목록
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final f = filtered[i];
                Color badgeBg = AppTheme.sageMint;
                Color badgeColor = AppTheme.sageDark;
                if (f.safetyLevel == SafetyLevel.forbidden) {
                  badgeBg = AppTheme.warningRed.withOpacity(0.15);
                  badgeColor = AppTheme.warningRed;
                } else if (f.safetyLevel == SafetyLevel.caution) {
                  badgeBg = AppTheme.warningOrange.withOpacity(0.15);
                  badgeColor = AppTheme.warningOrange;
                }

                return ListTile(
                  tileColor: AppTheme.cardBg,
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius, side: const BorderSide(color: AppTheme.borderLight)),
                  title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(f.reason, style: const TextStyle(fontSize: 11, color: AppTheme.mutedText), maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
                    child: Text(f.safetyBadgeText, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  onTap: () => _showFoodDetailModal(f),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 5. 원물 시식 도감 (기호성 및 알레르기 노트) 탭
  Widget _buildTasteNotesTab() {
    if (_isLoadingNotes) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: _tasteNotes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final note = _tasteNotes[i];
        Color reactionBg = AppTheme.subBg;
        if (note.reaction == TasteReaction.love) reactionBg = AppTheme.sageMint;
        if (note.reaction == TasteReaction.allergy) reactionBg = AppTheme.warningRed.withOpacity(0.15);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: AppTheme.cardRadius,
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(note.ingredientName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.charcoal)),
                  DropdownButton<TasteReaction>(
                    value: note.reaction,
                    underline: const SizedBox(),
                    items: TasteReaction.values.map((r) {
                      String label = '보통';
                      if (r == TasteReaction.love) label = '잘 먹음 😋';
                      if (r == TasteReaction.refuse) label = '거부 😾';
                      if (r == TasteReaction.allergy) label = '알레르기 🚨';
                      return DropdownMenuItem(value: r, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)));
                    }).toList(),
                    onChanged: (newR) {
                      if (newR != null) {
                        setState(() => note.reaction = newR);
                        StorageService.saveTasteNotes(_tasteNotes);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: TextEditingController(text: note.memo),
                decoration: const InputDecoration(
                  hintText: '시식 반응 메모 (예: 물에 불려주니 완식, 소화 잘 됨)',
                  hintStyle: TextStyle(fontSize: 11, color: AppTheme.mutedText),
                  isDense: true,
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  note.memo = val;
                  StorageService.saveTasteNotes(_tasteNotes);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
