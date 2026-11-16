import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({Key? key}) : super(key: key);

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  // 모드: 0: 물고기 잡기, 1: 레이저 포인트, 2: 안정 케어 타이머
  int _selectedMode = 0;

  // 게임 상태
  int _catchCount = 0;
  double _targetX = 0.5;
  double _targetY = 0.5;
  Timer? _moveTimer;

  // 타이머 상태
  int _timerSeconds = 300; // 5분
  int _remainingSeconds = 300;
  bool _isTimerRunning = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startTargetMovement();
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTargetMovement() {
    _moveTimer?.cancel();
    _moveTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (mounted && (_selectedMode == 0 || _selectedMode == 1)) {
        setState(() {
          final rand = Random();
          _targetX = 0.15 + rand.nextDouble() * 0.7;
          _targetY = 0.15 + rand.nextDouble() * 0.7;
        });
      }
    });
  }

  void _onTargetTapped() {
    setState(() {
      _catchCount++;
      final rand = Random();
      _targetX = 0.15 + rand.nextDouble() * 0.7;
      _targetY = 0.15 + rand.nextDouble() * 0.7;
    });
  }

  void _toggleTimer() {
    if (_isTimerRunning) {
      _countdownTimer?.cancel();
      setState(() => _isTimerRunning = false);
    } else {
      setState(() => _isTimerRunning = true);
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _countdownTimer?.cancel();
          setState(() => _isTimerRunning = false);
        }
      });
    }
  }

  void _resetTimer(int seconds) {
    _countdownTimer?.cancel();
    setState(() {
      _timerSeconds = seconds;
      _remainingSeconds = seconds;
      _isTimerRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('냥이 놀이 & 안정 케어'),
      ),
      body: Column(
        children: [
          // 모드 선택 칩
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('🐟 물고기 터치', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    selected: _selectedMode == 0,
                    selectedColor: AppTheme.terracottaLight,
                    onSelected: (v) => setState(() => _selectedMode = 0),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('🔴 레이저 포인트', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    selected: _selectedMode == 1,
                    selectedColor: AppTheme.terracottaLight,
                    onSelected: (v) => setState(() => _selectedMode = 1),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('⏳ 안정 타이머', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    selected: _selectedMode == 2,
                    selectedColor: AppTheme.terracottaLight,
                    onSelected: (v) => setState(() => _selectedMode = 2),
                  ),
                ),
              ],
            ),
          ),

          // 컨텐츠 영역
          Expanded(
            child: _selectedMode == 2 ? _buildTimerView() : _buildGameView(),
          ),
        ],
      ),
    );
  }

  // 1. 냥이 터치 놀이 뷰 (물고기 / 레이저)
  Widget _buildGameView() {
    return Stack(
      children: [
        // 게임 터치 바닥
        Container(
          width: double.infinity,
          height: double.infinity,
          color: _selectedMode == 1 ? Colors.black87 : AppTheme.cream,
        ),

        // 터치 안내 헤더
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Text('냥이 터치 성공: $_catchCount회 🐾', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.terracotta)),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.mutedText),
                onPressed: () => setState(() => _catchCount = 0),
                tooltip: '점수 초기화',
              ),
            ],
          ),
        ),

        // 움직이는 타겟 (물고기 / 레이저)
        AnimatedAlign(
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOutBack,
          alignment: FractionalOffset(_targetX, _targetY),
          child: GestureDetector(
            onTap: _onTargetTapped,
            child: Container(
              width: 80,
              height: 80,
              color: Colors.transparent,
              child: Center(
                child: _selectedMode == 0
                    ? const Text('🐟', style: TextStyle(fontSize: 48))
                    : Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.red.withOpacity(0.8), blurRadius: 16, spreadRadius: 4),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),

        // 하단 안내
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.cardBg.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('스마트폰을 바닥에 내려놓고 냥이가 터치하게 해주세요 🐾', style: TextStyle(fontSize: 11, color: AppTheme.mutedText)),
            ),
          ),
        ),
      ],
    );
  }

  // 2. 안정 케어 타이머 뷰
  Widget _buildTimerView() {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    final progress = (_timerSeconds > 0) ? (_remainingSeconds / _timerSeconds) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // 원형 타이머
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: AppTheme.subBg,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.sageDark),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$minutes:$seconds', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.charcoal)),
                  const SizedBox(height: 4),
                  const Text('차분한 휴식 시간', style: TextStyle(fontSize: 12, color: AppTheme.mutedText)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 제어 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.terracotta,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
                ),
                onPressed: _toggleTimer,
                label: Text(_isTimerRunning ? '일시정지' : '시작', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
                ),
                onPressed: () => _resetTimer(_timerSeconds),
                child: const Text('리셋', style: TextStyle(color: AppTheme.charcoal, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 시간 빠른 선택 칩
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ActionChip(label: const Text('3분 (목욕 후)'), onPressed: () => _resetTimer(180)),
              const SizedBox(width: 8),
              ActionChip(label: const Text('5분 (이동 전)'), onPressed: () => _resetTimer(300)),
              const SizedBox(width: 8),
              ActionChip(label: const Text('10분 (안정)'), onPressed: () => _resetTimer(600)),
            ],
          ),
          const SizedBox(height: 24),
          // 집사용 진정 팁 카드
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.sageMint,
              borderRadius: AppTheme.cardRadius,
              border: Border.all(color: AppTheme.sageDark.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('💡 집사용 안정 케어 팁', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.sageDark)),
                SizedBox(height: 6),
                Text('• 조명을 어둡게 낮추고 주변 소음을 최소화해 주세요.\n• 좋아하는 부드러운 담요로 몸을 가볍게 감싸 안아주세요.\n• 캣닢이나 마따따비 스프레이를 이동장에 살짝 뿌려두면 긴장 완화에 큰 도움이 됩니다.', style: TextStyle(fontSize: 12, height: 1.5, color: AppTheme.charcoal)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
