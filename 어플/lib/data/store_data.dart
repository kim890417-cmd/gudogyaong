class SubscriptionPlan {
  final String id;
  final String tier;
  final String badge;
  final int monthlyPrice;
  final String desc;
  final List<String> items;
  final bool highlight;

  const SubscriptionPlan({
    required this.id,
    required this.tier,
    required this.badge,
    required this.monthlyPrice,
    required this.desc,
    required this.items,
    this.highlight = false,
  });
}

class StoreProduct {
  final String id;
  final String tag;
  final String name;
  final String reason;
  final String platform;
  final String linkUrl;

  const StoreProduct({
    required this.id,
    required this.tag,
    required this.name,
    required this.reason,
    required this.platform,
    required this.linkUrl,
  });
}

class StoreData {
  static const String webStoreUrl = 'https://gudogyaong.pages.dev/#plans';
  static const String kakaoChatUrl = 'https://pf.kakao.com'; // 실제 카카오톡 채널 연동 URL

  static const List<SubscriptionPlan> catPlans = [
    SubscriptionPlan(
      id: 'cat_bronze',
      tier: '브론즈 (Bronze)',
      badge: '데일리 입문',
      monthlyPrice: 23900,
      desc: '입 짧은 냥이도 부드럽게 시작하는 기본 동결건조 & 수제트릿 3종',
      items: [
        '동결건조 무항생제 닭가슴살 큐브 (50g)',
        '가다랑어포 저염 바삭 플레이크 (40g)',
        '국내산 단호박 식이섬유 퓨레 스틱 5개입',
      ],
      highlight: false,
    ),
    SubscriptionPlan(
      id: 'cat_silver',
      tier: '실버 (Silver)',
      badge: '가장 인기 · 냥이 베스트 ⭐',
      monthlyPrice: 36900,
      desc: '음수량과 모질·헤어볼을 동시에 케어하는 가장 균형 잡힌 인기 박스',
      items: [
        '동결건조 노르웨이 생연어 다이스 (60g)',
        '닭안심 수분 듬뿍 화식 파우치 3팩 (음수량 집중)',
        '초유 & 타우린 필수 영양 트릿 (50g)',
        '헤어볼 케어 유기농 캣그라스 미니 재배 키트',
      ],
      highlight: true,
    ),
    SubscriptionPlan(
      id: 'cat_gold',
      tier: '골드 (Gold)',
      badge: '프리미엄 VIP 오마카세 👑',
      monthlyPrice: 54900,
      desc: '참치·연어·메추리 최고급 원물과 신장·요로 건강 집중 케어 박스',
      items: [
        '노르웨이 생연어 필렛 프리미엄 트릿 (80g)',
        '동결건조 메추리 & 오리 안심 믹스 (70g)',
        '저인(Low-P) 유리너리 수분 테린 4팩',
        '엄선된 냥이 생유산균 & 오메가3 체험 키트',
      ],
      highlight: false,
    ),
  ];

  static const List<SubscriptionPlan> bothPlans = [
    SubscriptionPlan(
      id: 'both_bronze',
      tier: '브론즈 (Bronze)',
      badge: '냥+멍 실속 입문',
      monthlyPrice: 28900,
      desc: '고양이와 강아지가 함께 안전하게 먹는 무염 단일 원물 3종 박스',
      items: [
        '무염 닭가슴살 한입 큐브 (80g)',
        '동결건조 북어 트릿 (60g)',
        '달콤 찐 단호박 건조 스낵 (60g)',
      ],
      highlight: false,
    ),
    SubscriptionPlan(
      id: 'both_silver',
      tier: '실버 (Silver)',
      badge: '다견·다묘 추천 ⭐',
      monthlyPrice: 44900,
      desc: '냥이용 2종 + 멍이용 2종을 맞춤 분할 포장한 베스트셀러 박스',
      items: [
        '냥이용: 생연어 다이스 & 가다랑어 플레이크',
        '멍이용: 오리안심 져키 & 고구마 비스킷',
        '공용 장 건강 유산균 파우더 토퍼 (50g)',
      ],
      highlight: true,
    ),
    SubscriptionPlan(
      id: 'both_gold',
      tier: '골드 (Gold)',
      badge: '프리미엄 풀패키지 👑',
      monthlyPrice: 64900,
      desc: '한우·생연어·오리 최고급 원물과 종별 화식이 모두 담긴 VIP 박스',
      items: [
        '한우 홍두깨살 육포 & 생연어 큐브 듀오 (160g)',
        '냥이용 저인 테린 2팩 + 멍이용 관절 화식 2팩',
        '종별 맞춤 기능성 덴탈 트릿 2종',
        '프리미엄 영양제 체험 키트 증정',
      ],
      highlight: false,
    ),
  ];

  static const List<StoreProduct> curatedPicks = [
    StoreProduct(
      id: 'pick_1',
      tag: '고양이 · 음수량 폭발',
      name: '저소음 세라믹 무선 고양이 자동 급수기 2L',
      reason: '플라스틱 턱드름 걱정 없는 위생적인 세라믹 도자기 재질로, 수제 동결건조를 띄워주면 음수량이 2배로 증가합니다.',
      platform: '쿠팡 파트너스 연동',
      linkUrl: 'https://gudogyaong.pages.dev/#curation',
    ),
    StoreProduct(
      id: 'pick_2',
      tag: '신장/요로 · 수분 보충',
      name: '저인(Low-P) 퓨어 치킨 수분 파우치 12입',
      reason: '인(P) 함량을 안전하게 낮추고 수분 비율이 83% 이상이라 만성 음수량 부족 냥이와 노령묘에게 안성맞춤입니다.',
      platform: '네이버 쇼핑 커넥트 연동',
      linkUrl: 'https://gudogyaong.pages.dev/#curation',
    ),
    StoreProduct(
      id: 'pick_3',
      tag: '냥이 웰니스 · 장 건강',
      name: '무향 무첨가 냥이 전용 생유산균 파우더 (30포)',
      reason: '동결건조 트릿이나 수분 테린 위에 가볍게 솔솔 뿌려주면 거부감 없이 장내 유익균과 면역력을 케어해 줍니다.',
      platform: '쿠팡 파트너스 연동',
      linkUrl: 'https://gudogyaong.pages.dev/#curation',
    ),
  ];
}
