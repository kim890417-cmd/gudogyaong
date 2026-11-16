import 'package:flutter/material.dart';
import '../models/pet_profile.dart';
import '../models/health_record.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../data/care_tips_data.dart';

class HomeScreen extends StatefulWidget {
  final PetProfile currentPet;
  final List<PetProfile> allProfiles;
  final Function(PetProfile) onPetChanged;
  final VoidCallback onProfileListUpdated;

  const HomeScreen({
    Key? key,
    required this.currentPet,
    required this.allProfiles,
    required this.onPetChanged,
    required this.onProfileListUpdated,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DailyHealthRecord _todayRecord;
  bool _isLoading = true;
  String _todayDateStr = '';

  @override
  void initState() {
    super.initState();
    _loadTodayRecord();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPet.id != widget.currentPet.id) {
      _loadTodayRecord();
    }
  }

  void _loadTodayRecord() async {
    setState(() => _isLoading = true);
    final now = DateTime.now();
    _todayDateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final record = await StorageService.getRecord(_todayDateStr, widget.currentPet.id);
    setState(() {
      _todayRecord = record;
      _isLoading = false;
    });
  }

  void _addWater(int amount) async {
    setState(() {
      _todayRecord.waterIntakeMl += amount;
      if (_todayRecord.waterIntakeMl < 0) _todayRecord.waterIntakeMl = 0;
    });
    await StorageService.saveRecord(_todayRecord);
  }

  void _showCustomWaterDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.cardRadius),
        title: const Text('음수량 직접 입력', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '추가할 양 (ml)',
            border: OutlineInputBorder(borderRadius: AppTheme.buttonRadius),
            suffixText: 'ml',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: AppTheme.mutedText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.terracotta,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
            ),
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                _addWater(val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _showSnackManageDialog() {
    bool isFrozen = widget.currentPet.isSnackFrozen;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardBg,
          shape: RoundedRectangleBorder(borderRadius: AppTheme.cardRadius),
          title: const Text('수제간식 개봉일 관리', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('보존료 0% 수제간식은 개봉 후 신선할 때 급여해야 합니다.', style: TextStyle(fontSize: 13, color: AppTheme.mutedText)),
              const SizedBox(height: 14),
              const Text('보관 방식 선택:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Radio<bool>(
                    value: false,
                    groupValue: isFrozen,
                    activeColor: AppTheme.terracotta,
                    onChanged: (v) => setDialogState(() => isFrozen = v!),
                  ),
                  const Text('냉장 보관 (권장 7일)'),
                ],
              ),
              Row(
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: isFrozen,
                    activeColor: AppTheme.terracotta,
                    onChanged: (v) => setDialogState(() => isFrozen = v!),
                  ),
                  const Text('냉동 보관 (권장 30일)'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소', style: TextStyle(color: AppTheme.mutedText)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.terracotta,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
              ),
              onPressed: () async {
                widget.currentPet.snackOpenedDate = DateTime.now();
                widget.currentPet.isSnackFrozen = isFrozen;
                await StorageService.saveProfiles(widget.allProfiles);
                widget.onProfileListUpdated();
                Navigator.pop(ctx);
                setState(() {});
              },
              child: const Text('오늘 개봉으로 등록'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTipDetailModal(CareTip tip) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24.0),
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
                    color: AppTheme.sageMint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(tip.category, style: const TextStyle(color: AppTheme.sageDark, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.mutedText),
                  onPressed: () => Navigator.pop(ctx),
                )
              ],
            ),
            const SizedBox(height: 12),
            Text(tip.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.charcoal)),
            const SizedBox(height: 16),
            Text(tip.body, style: const TextStyle(fontSize: 14, color: AppTheme.charcoal, height: 1.6)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.terracotta,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('확인 완료', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.terracotta));
    }

    final pet = widget.currentPet;
    final targetWater = pet.recommendedWaterMl;
    final currentWater = _todayRecord.waterIntakeMl;
    final progress = (targetWater > 0) ? (currentWater / targetWater).clamp(0.0, 1.0) : 0.0;
    final percent = (progress * 100).toInt();

    final dDay = pet.snackDDay;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 반려동물 프로필 헤더 & 전환 카드
          _buildPetHeader(pet),

          const SizedBox(height: 16),

          // 2. 오늘의 음수량 프로그레스 대시보드 (주인공)
          _buildWaterCard(currentWater, targetWater, progress, percent),

          const SizedBox(height: 16),

          // 3. 수제간식 개봉일 / D-Day 카드
          _buildSnackDDayCard(dDay, pet.isSnackFrozen),

          const SizedBox(height: 16),

          // 4. 오늘의 맞춤 케어 팁 (웹 칼럼 요약 카드)
          _buildDailyCareTip(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPetHeader(PetProfile pet) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppTheme.terracottaLight,
            child: Text(
              pet.type == PetType.cat ? '🐱' : '🐶',
              style: const TextStyle(fontSize: 26),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.charcoal),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.subBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        pet.breed,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.mutedText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${pet.ageYears}세 · ${pet.weightKg}kg · ${pet.isNeutered ? '중성화 완료' : '중성화 미완료'}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.mutedText),
                ),
                if (pet.healthConcerns.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: pet.healthConcerns.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.sageMint,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.sageDark),
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
          // 프로필 변경 버튼
          PopupMenuButton<PetProfile>(
            icon: const Icon(Icons.swap_horiz, color: AppTheme.terracotta),
            tooltip: '반려동물 전환',
            shape: RoundedRectangleBorder(borderRadius: AppTheme.cardRadius),
            onSelected: (selectedPet) => widget.onPetChanged(selectedPet),
            itemBuilder: (ctx) => widget.allProfiles.map((p) => PopupMenuItem(
              value: p,
              child: Row(
                children: [
                  Text(p.type == PetType.cat ? '🐱' : '🐶', style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text('${p.name} (${p.breed})', style: TextStyle(
                    fontWeight: p.id == pet.id ? FontWeight.bold : FontWeight.normal,
                    color: p.id == pet.id ? AppTheme.terracotta : AppTheme.charcoal,
                  )),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterCard(int current, int target, double progress, int percent) {
    return Container(
      padding: const EdgeInsets.all(20.0),
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
              Row(
                children: const [
                  Text('💧', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 6),
                  Text('오늘의 음수량 체크', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.charcoal)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: percent >= 100 ? AppTheme.sageMint : AppTheme.terracottaLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  percent >= 100 ? '목표 달성 완료! 🎉' : '$percent% 달성',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: percent >= 100 ? AppTheme.sageDark : AppTheme.terracottaDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 수치 표시
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$current',
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppTheme.charcoal, height: 1.0),
              ),
              const SizedBox(width: 4),
              Text(
                '/ $target ml',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.mutedText),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 프로그레스 바
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppTheme.subBg,
              valueColor: AlwaysStoppedAnimation<Color>(percent >= 100 ? AppTheme.sageDark : AppTheme.terracotta),
            ),
          ),
          const SizedBox(height: 16),
          // 원터치 추가 버튼들
          Row(
            children: [
              _buildWaterAddBtn('+20ml', 20),
              const SizedBox(width: 8),
              _buildWaterAddBtn('+50ml', 50),
              const SizedBox(width: 8),
              _buildWaterAddBtn('+100ml', 100),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
                    side: const BorderSide(color: AppTheme.borderLight),
                  ),
                  onPressed: _showCustomWaterDialog,
                  child: const Text('직접입력', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.charcoal)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterAddBtn(String label, int amount) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.subBg,
          foregroundColor: AppTheme.charcoal,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
        ),
        onPressed: () => _addWater(amount),
        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSnackDDayCard(int? dDay, bool isFrozen) {
    final hasSnack = dDay != null;
    String statusText = '등록된 간식이 없습니다';
    Color badgeColor = AppTheme.subBg;
    Color textColor = AppTheme.mutedText;

    if (hasSnack) {
      if (dDay > 0) {
        statusText = 'D-$dDay일 남음 (${isFrozen ? '냉동' : '냉장'})';
        badgeColor = dDay <= 2 ? AppTheme.warningOrange.withOpacity(0.15) : AppTheme.sageMint;
        textColor = dDay <= 2 ? AppTheme.warningOrange : AppTheme.sageDark;
      } else if (dDay == 0) {
        statusText = '오늘까지 급여 완료 권장! (D-Day)';
        badgeColor = AppTheme.warningOrange.withOpacity(0.2);
        textColor = AppTheme.warningOrange;
      } else {
        statusText = '기한 만료 (${-dDay}일 초과)';
        badgeColor = AppTheme.warningRed.withOpacity(0.15);
        textColor = AppTheme.warningRed;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.terracottaLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('🍖', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('수제간식 안심 유통기한', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.charcoal)),
                const SizedBox(height: 3),
                Text(statusText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.subBg,
              foregroundColor: AppTheme.charcoal,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
            ),
            onPressed: _showSnackManageDialog,
            child: Text(hasSnack ? '재설정' : '개봉 등록', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCareTip() {
    final tip = CareTipsData.tips[0];
    return InkWell(
      onTap: () => _showTipDetailModal(tip),
      borderRadius: AppTheme.cardRadius,
      child: Container(
        padding: const EdgeInsets.all(18.0),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.sageMint,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('오늘의 집사 꿀팁 · ${tip.category}', style: const TextStyle(color: AppTheme.sageDark, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.mutedText),
              ],
            ),
            const SizedBox(height: 10),
            Text(tip.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.charcoal)),
            const SizedBox(height: 6),
            Text(tip.summary, style: const TextStyle(fontSize: 12, color: AppTheme.mutedText, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
