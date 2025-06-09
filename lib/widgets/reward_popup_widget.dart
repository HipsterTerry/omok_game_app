import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/lottery_system.dart';

class RewardPopupWidget extends StatefulWidget {
  final LotteryReward reward;

  const RewardPopupWidget({
    Key? key,
    required this.reward,
  }) : super(key: key);

  @override
  State<RewardPopupWidget> createState() =>
      _RewardPopupWidgetState();
}

class _RewardPopupWidgetState
    extends State<RewardPopupWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _sparkleController;
  late AnimationController _bounceController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // 크기 애니메이션
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _scaleController,
            curve: Curves.elasticOut,
          ),
        );

    // 반짝이는 애니메이션
    _sparkleController = AnimationController(
      duration: const Duration(
        milliseconds: 1200,
      ),
      vsync: this,
    )..repeat();

    _sparkleAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _sparkleController,
            curve: Curves.easeInOut,
          ),
        );

    // 바운스 애니메이션
    _bounceController = AnimationController(
      duration: const Duration(
        milliseconds: 1000,
      ),
      vsync: this,
    );

    _bounceAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _bounceController,
            curve: Curves.bounceOut,
          ),
        );

    // 진동 및 애니메이션 시작
    HapticFeedback.heavyImpact();
    _scaleController.forward();

    // 0.3초 후 바운스 시작
    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        _bounceController.forward();
      },
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _sparkleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _closePopup() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(
        0.8,
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _sparkleAnimation,
          _bounceAnimation,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // 배경 반짝이는 효과
              Positioned.fill(
                child: CustomPaint(
                  painter:
                      SparkleBackgroundPainter(
                        sparkleProgress:
                            _sparkleAnimation
                                .value,
                        rewardColor:
                            widget.reward.color,
                      ),
                ),
              ),

              // 메인 팝업
              Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.all(
                      40,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                            30,
                          ),
                      boxShadow: [
                        BoxShadow(
                          color: widget
                              .reward
                              .color
                              .withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(
                            0,
                            15,
                          ),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        // 헤더
                        Container(
                          padding:
                              const EdgeInsets.all(
                                30,
                              ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget
                                    .reward
                                    .color
                                    .withOpacity(
                                      0.8,
                                    ),
                                widget
                                    .reward
                                    .color,
                              ],
                            ),
                            borderRadius:
                                const BorderRadius.only(
                                  topLeft:
                                      Radius.circular(
                                        30,
                                      ),
                                  topRight:
                                      Radius.circular(
                                        30,
                                      ),
                                ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                '🎉 축하합니다! 🎉',
                                style: TextStyle(
                                  color: Colors
                                      .white,
                                  fontSize: 24,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                '복권에서 보상을 획득했습니다!',
                                style: TextStyle(
                                  color: Colors
                                      .white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 보상 정보
                        Padding(
                          padding:
                              const EdgeInsets.all(
                                30,
                              ),
                          child: Column(
                            children: [
                              // 보상 아이콘 (바운스 효과)
                              Transform.translate(
                                offset: Offset(
                                  0,
                                  -10 *
                                      (1 -
                                          _bounceAnimation
                                              .value),
                                ),
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: widget
                                        .reward
                                        .color
                                        .withOpacity(
                                          0.1,
                                        ),
                                    shape: BoxShape
                                        .circle,
                                    border: Border.all(
                                      color: widget
                                          .reward
                                          .color,
                                      width: 3,
                                    ),
                                  ),
                                  child: Icon(
                                    widget
                                        .reward
                                        .icon,
                                    size: 60,
                                    color: widget
                                        .reward
                                        .color,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 20,
                              ),

                              // 보상 이름
                              Text(
                                widget
                                    .reward
                                    .name,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  color: widget
                                      .reward
                                      .color,
                                ),
                                textAlign:
                                    TextAlign
                                        .center,
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              // 수량 (애니메이션 텍스트)
                              AnimatedBuilder(
                                animation:
                                    _bounceAnimation,
                                builder: (context, child) {
                                  final animatedQuantity =
                                      (_bounceAnimation.value *
                                              widget.reward.quantity)
                                          .toInt();
                                  return Text(
                                    'x$animatedQuantity',
                                    style: TextStyle(
                                      fontSize:
                                          32,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      color: widget
                                          .reward
                                          .color,
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(
                                height: 16,
                              ),

                              // 설명
                              Container(
                                padding:
                                    const EdgeInsets.all(
                                      16,
                                    ),
                                decoration: BoxDecoration(
                                  color: Colors
                                      .grey[100],
                                  borderRadius:
                                      BorderRadius.circular(
                                        12,
                                      ),
                                ),
                                child: Text(
                                  widget
                                      .reward
                                      .description,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors
                                        .grey[700],
                                    height: 1.4,
                                  ),
                                  textAlign:
                                      TextAlign
                                          .center,
                                ),
                              ),

                              const SizedBox(
                                height: 30,
                              ),

                              // 확인 버튼
                              SizedBox(
                                width: double
                                    .infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _closePopup,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        widget
                                            .reward
                                            .color,
                                    foregroundColor:
                                        Colors
                                            .white,
                                    padding:
                                        const EdgeInsets.symmetric(
                                          vertical:
                                              16,
                                        ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                            12,
                                          ),
                                    ),
                                    elevation: 8,
                                  ),
                                  child: const Text(
                                    '확인',
                                    style: TextStyle(
                                      fontSize:
                                          18,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SparkleBackgroundPainter
    extends CustomPainter {
  final double sparkleProgress;
  final Color rewardColor;

  SparkleBackgroundPainter({
    required this.sparkleProgress,
    required this.rewardColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(12345); // 고정된 시드
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    // 배경 방사형 그라데이션
    final bgPaint = Paint()
      ..shader =
          RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              rewardColor.withOpacity(
                0.1 * sparkleProgress,
              ),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromLTWH(
              0,
              0,
              size.width,
              size.height,
            ),
          );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
      bgPaint,
    );

    // 반짝이는 별들
    for (int i = 0; i < 50; i++) {
      final angle =
          random.nextDouble() * 2 * math.pi;
      final distance =
          random.nextDouble() *
          math.min(size.width, size.height) /
          2;
      final sparkleSize =
          random.nextDouble() * 4 + 1;

      // 시간에 따른 위치 변화
      final animatedDistance =
          distance *
          (0.8 +
              0.4 *
                  math.sin(
                    sparkleProgress *
                            2 *
                            math.pi +
                        i,
                  ));
      final sparkleX =
          center.dx +
          math.cos(angle) * animatedDistance;
      final sparkleY =
          center.dy +
          math.sin(angle) * animatedDistance;

      // 알파값 애니메이션
      final alpha =
          (math.sin(
                sparkleProgress * 2 * math.pi +
                    i * 0.5,
              ) +
              1) /
          2;

      final sparklePaint = Paint()
        ..color = Colors.white.withOpacity(
          alpha * 0.8,
        );

      // 별 모양 그리기
      _drawStar(
        canvas,
        Offset(sparkleX, sparkleY),
        sparkleSize,
        sparklePaint,
      );
    }

    // 중심에서 퍼지는 링 효과
    final ringRadius =
        sparkleProgress *
        math.min(size.width, size.height) /
        2;
    final ringPaint = Paint()
      ..color = rewardColor.withOpacity(
        0.3 * (1 - sparkleProgress),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      center,
      ringRadius,
      ringPaint,
    );
  }

  void _drawStar(
    Canvas canvas,
    Offset center,
    double size,
    Paint paint,
  ) {
    final path = Path();
    final double angle = 2 * math.pi / 5;

    for (int i = 0; i < 5; i++) {
      final x =
          center.dx +
          size *
              math.cos(i * angle - math.pi / 2);
      final y =
          center.dy +
          size *
              math.sin(i * angle - math.pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // 안쪽 점
      final innerX =
          center.dx +
          (size * 0.4) *
              math.cos(
                (i + 0.5) * angle - math.pi / 2,
              );
      final innerY =
          center.dy +
          (size * 0.4) *
              math.sin(
                (i + 0.5) * angle - math.pi / 2,
              );
      path.lineTo(innerX, innerY);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return true;
  }
}
