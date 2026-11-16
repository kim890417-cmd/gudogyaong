import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/store_data.dart';
import '../models/food_taste_note.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  bool _isBothMode = false; // false: 고양이 전용, true: 냥+멍 공용
  bool _isBiweekly = false; // false: 월 1회, true: 2주 1회 (-10%)
  List<String> _allergyIngredients = [];
  List<String> _savedProductIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStoreState();
  }

  void _loadStoreState() async {
    final tasteNotes = await StorageService.loadTasteNotes();
    final allergies = tasteNotes
        .where((n) => n.reaction == TasteReaction.allergy)
        .map((n) => n.ingredientName)
        .toList();

    final saved = await StorageService.loadSavedStoreItems();

    setState(() {
      _allergyIngredients = allergies;
      _savedProductIds = saved;
      _isLoading = false;
    });
  }

  void _toggleSaveProduct(String id) async {
    setState(() {
      if (_savedProductIds.contains(id)) {
        _savedProductIds.remove(id);
      } else {
        _savedProductIds.add(id);
      }
    });
    await StorageService.saveSavedStoreItems(_savedProductIds);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_savedProductIds.contains(id) ? '관심 목록에 담았습니다! ❤️' : '관심 목록에서 제외했습니다.')),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('페이지를 열 수 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.terracotta));
    }

    final plans = _isBothMode ? StoreData.bothPlans : StoreData.catPlans;
    final discount = _isBiweekly ? 0.9 : 1.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('구독야옹 스토어'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: AppTheme.terracotta),
            tooltip: '웹스토어 바로가기',
            onPressed: () => _launchUrl(StoreData.webStoreUrl),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 알레르기 제외 배지 (시식 도감 연동)
            if (_allergyIngredients.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.warningRed.withOpacity(0.12),
                  borderRadius: AppTheme.cardRadius,
                  border: Border.all(color: AppTheme.warningRed.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: AppTheme.warningRed, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '알레르기 제외 반영 중: ${_allergyIngredients.join(', ')}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.warningRed),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // 2. 토글 스위치들 (고양이/공용 & 배송주기)
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _isBothMode = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: !_isBothMode ? AppTheme.charcoal : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('고양이 전용', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: !_isBothMode ? Colors.white : AppTheme.mutedText)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _isBothMode = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _isBothMode ? AppTheme.charcoal : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('냥+멍 공용', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _isBothMode ? Colors.white : AppTheme.mutedText)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _isBiweekly = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: !_isBiweekly ? AppTheme.terracotta : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('월 1회', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: !_isBiweekly ? Colors.white : AppTheme.mutedText)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _isBiweekly = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _isBiweekly ? AppTheme.terracotta : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('2주(-10%)', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _isBiweekly ? Colors.white : AppTheme.mutedText)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // 3. 맞춤 정기구독 플랜 3종 카드
            const Text('브론즈 · 실버 · 골드 정기구독 플랜', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.charcoal)),
            const SizedBox(height: 12),
            Column(
              children: plans.map((p) {
                final price = ((p.monthlyPrice * discount) / 100).round() * 100;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: AppTheme.cardRadius,
                    border: Border.all(
                      color: p.highlight ? AppTheme.terracotta : AppTheme.borderLight,
                      width: p.highlight ? 2.0 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: p.highlight ? AppTheme.terracotta : AppTheme.subBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(p.badge, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: p.highlight ? Colors.white : AppTheme.charcoal)),
                          ),
                          Text(
                            '$price원 / 회당',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.charcoal),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(p.tier, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.charcoal)),
                      const SizedBox(height: 4),
                      Text(p.desc, style: const TextStyle(fontSize: 12, color: AppTheme.mutedText)),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: p.items.map((it) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              const Text('✓ ', style: TextStyle(color: AppTheme.sageDark, fontWeight: FontWeight.bold, fontSize: 12)),
                              Expanded(child: Text(it, style: const TextStyle(fontSize: 12, color: AppTheme.charcoal))),
                            ],
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: p.highlight ? AppTheme.terracotta : AppTheme.charcoal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          onPressed: () => _launchUrl(StoreData.webStoreUrl),
                          child: Text('${p.tier.split(' ')[0]} 신청하기 (웹 연동) ↗', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // 4. 집사 꿀템 큐레이션
            const Text('집사 엄선 꿀템 큐레이션', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.charcoal)),
            const SizedBox(height: 12),
            Column(
              children: StoreData.curatedPicks.map((pick) {
                final isSaved = _savedProductIds.contains(pick.id);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
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
                            decoration: BoxDecoration(color: AppTheme.sageMint, borderRadius: BorderRadius.circular(6)),
                            child: Text(pick.tag, style: const TextStyle(color: AppTheme.sageDark, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          IconButton(
                            icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border, color: isSaved ? AppTheme.terracotta : AppTheme.mutedText),
                            onPressed: () => _toggleSaveProduct(pick.id),
                            tooltip: '관심 목록 담기',
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(pick.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.charcoal)),
                      const SizedBox(height: 4),
                      Text(pick.reason, style: const TextStyle(fontSize: 12, color: AppTheme.mutedText, height: 1.4)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('플랫폼: ${pick.platform}', style: const TextStyle(fontSize: 11, color: AppTheme.mutedText)),
                          TextButton(
                            onPressed: () => _launchUrl(pick.linkUrl),
                            child: const Text('상품 보러가기 ↗', style: TextStyle(color: AppTheme.terracotta, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
