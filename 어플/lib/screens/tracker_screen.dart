import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/pet_profile.dart';
import '../models/health_record.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class TrackerScreen extends StatefulWidget {
  final PetProfile currentPet;

  const TrackerScreen({Key? key, required this.currentPet}) : super(key: key);

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  late DailyHealthRecord _record;
  List<DailyHealthRecord> _weeklyRecords = [];
  bool _isLoading = true;
  String _todayStr = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant TrackerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPet.id != widget.currentPet.id) {
      _loadData();
    }
  }

  void _loadData() async {
    setState(() => _isLoading = true);
    final now = DateTime.now();
    _todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final todayRec = await StorageService.getRecord(_todayStr, widget.currentPet.id);
    final weekly = await StorageService.getRecentRecords(widget.currentPet.id, 7);
    setState(() {
      _record = todayRec;
      _weeklyRecords = weekly;
      _isLoading = false;
    });
  }

  void _saveCurrentRecord() async {
    await StorageService.saveRecord(_record);
    final weekly = await StorageService.getRecentRecords(widget.currentPet.id, 7);
    setState(() {
      _weeklyRecords = weekly;
    });
  }

  void _showHospitalReportModal() {
    if (_weeklyRecords.isEmpty) return;

    int totalWater = 0;
    int totalPee = 0;
    int totalPoop = 0;
    int totalVomit = 0;
    for (var r in _weeklyRecords) {
      totalWater += r.waterIntakeMl;
      totalPee += r.peeCount;
      totalPoop += r.poopCount;
      totalVomit += r.vomitCount;
    }
    final avgWater = (totalWater / _weeklyRecords.length).round();

    final reportText = """
[동물병원 제출용 건강 요약 리포트]
- 이름: ${widget.currentPet.name} (${widget.currentPet.breed}, ${widget.currentPet.ageYears}세, ${widget.currentPet.weightKg}kg)
- 기간: 최근 7일 기준
- 일평균 음수량: ${avgWater}ml (권장: ${widget.currentPet.recommendedWaterMl}ml)
- 주간 총 소변(감자): ${totalPee}회
- 주간 총 대변(맛동산): ${totalPoop}회
- 주간 총 구토/헤어볼: ${totalVomit}회
- 최근 급여 간식/메모: ${_record.recentSnack.isEmpty ? '기록 없음' : _record.recentSnack}
- 특이사항: ${_record.memo.isEmpty ? '없음' : _record.memo}
""".trim();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
                const Text('📋 동물병원 제출용 7일 리포트', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.charcoal)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.subBg,
                borderRadius: AppTheme.cardRadius,
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Text(reportText, style: const TextStyle(fontSize: 13, height: 1.6, color: AppTheme.charcoal)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy, size: 16),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.terracotta,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: reportText));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('요약 리포트가 클립보드에 복사되었습니다! 🐾')),
                  );
                },
                label: const Text('요약 텍스트 복사하기', style: TextStyle(fontWeight: FontWeight.bold)),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 날짜 및 동물병원 리포트 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📅 오늘 ($_todayStr)', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.charcoal)),
              OutlinedButton.icon(
                icon: const Icon(Icons.medical_services_outlined, size: 14, color: AppTheme.sageDark),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
                  side: const BorderSide(color: AppTheme.sageDark),
                ),
                onPressed: _showHospitalReportModal,
                label: const Text('병원 제출용 7일 요약', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.sageDark)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 1. 원터치 일일 체크 카드
          _buildDailyCheckCard(),

          const SizedBox(height: 16),

          // 2. 주간 음수량 & 배변 추이 막대 그래프
          _buildWeeklyChartCard(),

          const SizedBox(height: 16),

          // 3. 메모 및 최근 간식 기록 카드
          _buildMemoCard(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDailyCheckCard() {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('원터치 데일리 체크', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.charcoal)),
          const SizedBox(height: 14),
          _buildCounterRow('🥔 감자 (소변 횟수)', _record.peeCount, (val) {
            setState(() => _record.peeCount = val);
            _saveCurrentRecord();
          }),
          const Divider(height: 20, color: AppTheme.borderLight),
          _buildCounterRow('💩 맛동산 (대변 횟수)', _record.poopCount, (val) {
            setState(() => _record.poopCount = val);
            _saveCurrentRecord();
          }),
          const Divider(height: 20, color: AppTheme.borderLight),
          _buildCounterRow('🤮 구토 · 헤어볼 (횟수)', _record.vomitCount, (val) {
            setState(() => _record.vomitCount = val);
            _saveCurrentRecord();
          }),
        ],
      ),
    );
  }

  Widget _buildCounterRow(String label, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.charcoal)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: AppTheme.mutedText),
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
            ),
            SizedBox(
              width: 32,
              child: Text(
                '$value회',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.charcoal),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: AppTheme.terracotta),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyChartCard() {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('최근 7일간 음수량 추이', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.charcoal)),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _weeklyRecords.map((rec) {
                final maxWater = widget.currentPet.recommendedWaterMl;
                final heightFactor = (maxWater > 0) ? (rec.waterIntakeMl / maxWater).clamp(0.05, 1.0) : 0.05;
                final dateLabel = rec.dateString.split('-').last;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${rec.waterIntakeMl}m', style: const TextStyle(fontSize: 9, color: AppTheme.mutedText)),
                    const SizedBox(height: 4),
                    Container(
                      width: 22,
                      height: 80 * heightFactor,
                      decoration: BoxDecoration(
                        color: rec.waterIntakeMl >= maxWater ? AppTheme.sageDark : AppTheme.terracotta,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(dateLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.charcoal)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoCard() {
    final memoController = TextEditingController(text: _record.memo);
    final snackController = TextEditingController(text: _record.recentSnack);

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('오늘 먹은 간식 & 건강 메모', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.charcoal)),
          const SizedBox(height: 12),
          TextField(
            controller: snackController,
            decoration: InputDecoration(
              labelText: '오늘 급여한 간식 (예: 생연어 다이스 3알)',
              labelStyle: const TextStyle(fontSize: 12, color: AppTheme.mutedText),
              border: OutlineInputBorder(borderRadius: AppTheme.buttonRadius),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (val) {
              _record.recentSnack = val;
              StorageService.saveRecord(_record);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: memoController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: '간단 메모 (변 상태, 활력도, 특이사항)',
              labelStyle: const TextStyle(fontSize: 12, color: AppTheme.mutedText),
              border: OutlineInputBorder(borderRadius: AppTheme.buttonRadius),
              contentPadding: const EdgeInsets.all(12),
            ),
            onChanged: (val) {
              _record.memo = val;
              StorageService.saveRecord(_record);
            },
          ),
        ],
      ),
    );
  }
}
