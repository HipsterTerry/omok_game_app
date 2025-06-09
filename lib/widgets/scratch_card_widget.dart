import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../models/lottery_system.dart';

class ScratchCardScreen extends StatefulWidget {
  final LotteryTicket ticket;
  final Function(LotteryReward) onComplete;

  const ScratchCardScreen({
    Key? key,
    required this.ticket,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<ScratchCardScreen> createState() =>
      _ScratchCardScreenState();
}

class _ScratchCardScreenState
    extends State<ScratchCardScreen>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late AnimationController _revealController;
  late LotteryReward _reward;

  List<Offset> scratchedPoints = [];
  bool isRevealed = false;
  double scratchProgress = 0.0;
  final double requiredScratchPercent =
      0.3; // 30% 긁으면 완전히 드러남

  @override
  void initState() {
    super.initState();

    _reward = widget.ticket.drawReward();

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();

    _revealController = AnimationController(
      duration: const Duration(
        milliseconds: 1500,
      ),
      vsync: this,
    );

    // 진동 피드백
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _addScratchPoint(Offset point) {
    setState(() {
      scratchedPoints.add(point);
      scratchProgress =
          (scratchedPoints.length / 100).clamp(
            0.0,
            1.0,
          );

      if (scratchProgress >=
              requiredScratchPercent &&
          !isRevealed) {
        _revealReward();
      }
    });
  }

  void _revealReward() async {
    setState(() {
      isRevealed = true;
    });

    // 진동 피드백
    HapticFeedback.mediumImpact();

    // 드러나는 애니메이션
    _revealController.forward();

    // 2초 후 결과 전달
    await Future.delayed(
      const Duration(seconds: 2),
    );
    widget.onComplete(_reward);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '${widget.ticket.name} 긁기',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${(scratchProgress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 진행바
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: LinearProgressIndicator(
                value: scratchProgress,
                backgroundColor: Colors.grey[700],
                valueColor:
                    AlwaysStoppedAnimation<Color>(
                      widget.ticket.primaryColor,
                    ),
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 20),

            // 안내 텍스트
            if (!isRevealed)
              Container(
                margin:
                    const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(
                    0.1,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: Colors.white,
                    ),
                    SizedBox(width: 12),
                    Text(
                      '복권을 긁어서 보상을 확인하세요!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 40),

            // 긁기 카드
            Expanded(
              child: Center(
                child: Container(
                  width: 300,
                  height: 400,
                  child: ScratchCard(
                    ticket: widget.ticket,
                    reward: _reward,
                    scratchedPoints:
                        scratchedPoints,
                    isRevealed: isRevealed,
                    revealAnimation:
                        _revealController,
                    onScratch: _addScratchPoint,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class ScratchCard extends StatelessWidget {
  final LotteryTicket ticket;
  final LotteryReward reward;
  final List<Offset> scratchedPoints;
  final bool isRevealed;
  final AnimationController revealAnimation;
  final Function(Offset) onScratch;

  const ScratchCard({
    Key? key,
    required this.ticket,
    required this.reward,
    required this.scratchedPoints,
    required this.isRevealed,
    required this.revealAnimation,
    required this.onScratch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (!isRevealed) {
          final RenderBox box =
              context.findRenderObject()
                  as RenderBox;
          final localPosition = box.globalToLocal(
            details.globalPosition,
          );
          onScratch(localPosition);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ticket.primaryColor
                  .withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: CustomPaint(
            size: const Size(300, 400),
            painter: ScratchCardPainter(
              ticket: ticket,
              reward: reward,
              scratchedPoints: scratchedPoints,
              isRevealed: isRevealed,
              revealProgress:
                  revealAnimation.value,
            ),
          ),
        ),
      ),
    );
  }
}

class ScratchCardPainter extends CustomPainter {
  final LotteryTicket ticket;
  final LotteryReward reward;
  final List<Offset> scratchedPoints;
  final bool isRevealed;
  final double revealProgress;

  ScratchCardPainter({
    required this.ticket,
    required this.reward,
    required this.scratchedPoints,
    required this.isRevealed,
    required this.revealProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    );

    // 보상 내용 그리기 (배경)
    _drawRewardBackground(canvas, rect);

    // 긁기 레이어 그리기
    if (!isRevealed || revealProgress < 1.0) {
      _drawScratchLayer(canvas, rect);
    }

    // 완전히 드러난 후 반짝이는 효과
    if (isRevealed && revealProgress > 0.5) {
      _drawSparkleEffect(canvas, rect);
    }
  }

  void _drawRewardBackground(
    Canvas canvas,
    Rect rect,
  ) {
    // 배경 그라데이션
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          reward.color.withOpacity(0.2),
          reward.color.withOpacity(0.4),
          Colors.white,
        ],
      ).createShader(rect);

    canvas.drawRect(rect, backgroundPaint);

    // 보상 정보 그리기
    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '🎉\n',
            style: TextStyle(
              fontSize: 40,
              height: 1.5,
            ),
          ),
          TextSpan(
            text: '${reward.name}\n',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: reward.color,
              height: 1.2,
            ),
          ),
          TextSpan(
            text: 'x${reward.quantity}\n\n',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: reward.color,
              height: 1.5,
            ),
          ),
          TextSpan(
            text: reward.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.3,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout(maxWidth: rect.width - 40);

    final textOffset = Offset(
      (rect.width - textPainter.width) / 2,
      (rect.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  void _drawScratchLayer(
    Canvas canvas,
    Rect rect,
  ) {
    // 긁기 레이어 배경
    final scratchPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          ticket.primaryColor,
          ticket.secondaryColor,
        ],
      ).createShader(rect);

    canvas.drawRect(rect, scratchPaint);

    // 티켓 정보 그리기
    final ticketTextPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '🎫\n',
            style: TextStyle(
              fontSize: 40,
              height: 1.5,
            ),
          ),
          TextSpan(
            text: '${ticket.name}\n',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          TextSpan(
            text: '긁어서 확인하세요!',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    ticketTextPainter.layout(
      maxWidth: rect.width - 40,
    );

    final ticketTextOffset = Offset(
      (rect.width - ticketTextPainter.width) / 2,
      (rect.height - ticketTextPainter.height) /
          2,
    );

    ticketTextPainter.paint(
      canvas,
      ticketTextOffset,
    );

    // 긁힌 부분 지우기
    final erasePaint = Paint()
      ..blendMode = BlendMode.dstOut;

    for (final point in scratchedPoints) {
      canvas.drawCircle(point, 15, erasePaint);
    }

    // 자동으로 드러나는 애니메이션
    if (isRevealed) {
      final revealPaint = Paint()
        ..blendMode = BlendMode.dstOut;

      final revealRadius =
          revealProgress *
          math.max(rect.width, rect.height);
      canvas.drawCircle(
        rect.center,
        revealRadius,
        revealPaint,
      );
    }
  }

  void _drawSparkleEffect(
    Canvas canvas,
    Rect rect,
  ) {
    final sparkleProgress =
        (revealProgress - 0.5) * 2;
    final random = math.Random(
      42,
    ); // 고정된 시드로 일관된 패턴

    final sparklePaint = Paint()
      ..color = Colors.white.withOpacity(
        sparkleProgress * 0.8,
      );

    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * rect.width;
      final y = random.nextDouble() * rect.height;
      final size = random.nextDouble() * 4 + 1;

      canvas.drawCircle(
        Offset(x, y),
        size,
        sparklePaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return true;
  }
}
