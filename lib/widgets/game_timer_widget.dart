import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

// 🎨 v2.0.0: 듀얼 타이머 시스템 (전체 5분 + 1수 30초)
// 10초 이하 남으면 펄스 애니메이션으로 시각적 경고 제공
class GameTimerWidget extends StatefulWidget {
  final bool isCurrentPlayer;
  final int initialTime; // 초 단위
  final Function? onTimeUp;
  final Color primaryColor;
  final Color accentColor;
  final String playerName;
  final int moveTimeLimit; // 1수 제한 시간 추가

  const GameTimerWidget({
    super.key,
    required this.isCurrentPlayer,
    this.initialTime = 300, // 전체 시간 5분
    this.moveTimeLimit = 30, // 1수 제한 30초
    this.onTimeUp,
    this.primaryColor = Colors.blue,
    this.accentColor = Colors.lightBlue,
    this.playerName = "플레이어",
  });

  @override
  State<GameTimerWidget> createState() =>
      _GameTimerWidgetState();
}

class _GameTimerWidgetState
    extends State<GameTimerWidget>
    with TickerProviderStateMixin {
  late int _totalTime; // 전체 남은 시간
  late int _moveTime; // 현재 수 남은 시간
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _totalTime = widget.initialTime;
    _moveTime = widget.moveTimeLimit;

    _pulseController = AnimationController(
      duration: const Duration(
        milliseconds: 1000,
      ),
      vsync: this,
    );

    _pulseAnimation =
        Tween<double>(
          begin: 1.0,
          end: 1.3,
        ).animate(
          CurvedAnimation(
            parent: _pulseController,
            curve: Curves.easeInOut,
          ),
        );

    if (widget.isCurrentPlayer) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(
    GameTimerWidget oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (widget.isCurrentPlayer !=
        oldWidget.isCurrentPlayer) {
      if (widget.isCurrentPlayer) {
        _resetMoveTimer();
        _startTimer();
      } else {
        _stopTimer();
      }
    }
  }

  void _startTimer() {
    if (!mounted) return;

    _stopTimer();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted || !widget.isCurrentPlayer) {
          _stopTimer();
          return;
        }

        setState(() {
          _totalTime--;
          _moveTime--;
        });

        // 경고 애니메이션
        if (_moveTime <= 10 || _totalTime <= 30) {
          if (!_pulseController.isAnimating) {
            _pulseController.repeat(
              reverse: true,
            );
          }
        } else {
          _pulseController.stop();
          _pulseController.reset();
        }

        // 시간 종료 체크
        if (_totalTime <= 0 || _moveTime <= 0) {
          _stopTimer();
          if (widget.onTimeUp != null) {
            widget.onTimeUp!();
          }
        }
      },
    );
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _pulseController.stop();
  }

  void _resetMoveTimer() {
    setState(() {
      _moveTime = widget.moveTimeLimit;
    });
  }

  @override
  void dispose() {
    _stopTimer();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isLowTime =
        _moveTime <= 10 || _totalTime <= 30;
    final moveProgress =
        _moveTime / widget.moveTimeLimit;
    final totalProgress =
        _totalTime / widget.initialTime;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale:
              widget.isCurrentPlayer && isLowTime
              ? _pulseAnimation.value
              : 1.0,
          child: Container(
            padding: const EdgeInsets.all(6),
            margin: const EdgeInsets.symmetric(
              horizontal: 1,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                15,
              ),
              gradient: LinearGradient(
                colors: widget.isCurrentPlayer
                    ? [
                        widget.primaryColor
                            .withValues(alpha: 0.8),
                        widget.primaryColor
                            .withValues(alpha: 0.6),
                      ]
                    : [
                        Colors.grey.withValues(alpha: 
                          0.3,
                        ),
                        Colors.grey.withValues(alpha: 
                          0.1,
                        ),
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(
                color: widget.isCurrentPlayer
                    ? widget.primaryColor
                    : Colors.grey,
                width: widget.isCurrentPlayer
                    ? 3
                    : 1,
              ),
              boxShadow: widget.isCurrentPlayer
                  ? [
                      BoxShadow(
                        color: widget.primaryColor
                            .withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(
                          0,
                          4,
                        ),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 플레이어 이름
                Text(
                  widget.playerName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.isCurrentPlayer
                        ? Colors.white
                        : Colors.grey[700],
                    fontSize: 10,
                  ),
                ),

                // 전체 시간
                Text(
                  _formatTime(_totalTime),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _totalTime <= 30
                        ? Colors.red
                        : widget.isCurrentPlayer
                        ? Colors.white
                        : Colors.grey[800],
                  ),
                ),

                const SizedBox(height: 4),

                // 전체 시간 프로그레스 바
                Container(
                  width: 50,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(2),
                    color: Colors.grey[300],
                  ),
                  child: FractionallySizedBox(
                    alignment:
                        Alignment.centerLeft,
                    widthFactor: totalProgress
                        .clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(
                              2,
                            ),
                        color: _totalTime <= 30
                            ? Colors.red
                            : widget.primaryColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 1수 제한 시간 (현재 플레이어만 표시)
                if (widget.isCurrentPlayer) ...[
                  const SizedBox(height: 2),
                  Text(
                    '이번 수',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 1),

                  // 1수 시간 프로그레스 바 (원형)
                  Container(
                    width: 32,
                    height: 32,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: moveProgress
                              .clamp(0.0, 1.0),
                          backgroundColor: Colors
                              .white
                              .withValues(alpha: 0.3),
                          valueColor:
                              AlwaysStoppedAnimation<
                                Color
                              >(
                                _moveTime <= 10
                                    ? Colors.red
                                    : Colors
                                          .white,
                              ),
                          strokeWidth: 4,
                        ),
                        Container(
                          padding:
                              const EdgeInsets.all(
                                1,
                              ),
                          decoration: BoxDecoration(
                            color: _moveTime <= 10
                                ? Colors.red
                                      .withValues(alpha: 
                                        0.9,
                                      )
                                : Colors.black
                                      .withValues(alpha: 
                                        0.7,
                                      ),
                            shape:
                                BoxShape.circle,
                          ),
                          child: Text(
                            '$_moveTime',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 2),
                  Text(
                    '대기',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    this.strokeWidth = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );
    final radius = (size.width - strokeWidth) / 2;

    // 배경 링
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      center,
      radius,
      backgroundPaint,
    );

    // 진행률 링
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startAngle =
        -math.pi / 2; // 12시 방향에서 시작
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return oldDelegate is! ProgressRingPainter ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}

class RotatingRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  RotatingRingPainter({
    required this.color,
    this.strokeWidth = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );
    final radius =
        (size.width - strokeWidth * 2) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 점선 원형 링
    const dashLength = 10.0;
    const gapLength = 5.0;
    final circumference = 2 * math.pi * radius;
    final dashCount =
        (circumference / (dashLength + gapLength))
            .floor();

    for (int i = 0; i < dashCount; i++) {
      final startAngle =
          (i * 2 * math.pi) / dashCount;
      final sweepAngle =
          (dashLength / circumference) *
          2 *
          math.pi;

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return oldDelegate is! RotatingRingPainter ||
        oldDelegate.color != color;
  }
}

// 🎨 v2.0.0: StatefulWidget으로 변경하여 깜빡임 애니메이션 추가
// 10초 이하 남으면 빨간색 깜빡임 효과로 시각적 경고 제공
class CuteTimerWidget extends StatefulWidget {
  final bool isCurrentPlayer;
  final int remainingTime;
  final String playerName;
  final Color themeColor;

  const CuteTimerWidget({
    super.key,
    required this.isCurrentPlayer,
    required this.remainingTime,
    required this.playerName,
    this.themeColor = Colors.pink,
  });

  @override
  State<CuteTimerWidget> createState() =>
      _CuteTimerWidgetState();
}

class _CuteTimerWidgetState
    extends State<CuteTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _blinkAnimation =
        Tween<double>(
          begin: 0.3,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _blinkController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void didUpdateWidget(
    CuteTimerWidget oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    final isLowTime = widget.remainingTime <= 10;
    final wasLowTime =
        oldWidget.remainingTime <= 10;

    if (isLowTime && widget.isCurrentPlayer) {
      if (!wasLowTime ||
          !_blinkController.isAnimating) {
        _blinkController.repeat(reverse: true);
      }
    } else {
      _blinkController.stop();
      _blinkController.reset();
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLowTime = widget.remainingTime <= 10;
    final shouldBlink =
        isLowTime && widget.isCurrentPlayer;

    return AnimatedBuilder(
      animation: _blinkAnimation,
      builder: (context, child) {
        final blinkValue = shouldBlink
            ? _blinkAnimation.value
            : 1.0;
        final containerColor = shouldBlink
            ? Color.lerp(
                Colors.red.withValues(alpha: 0.8),
                Colors.red,
                blinkValue,
              )!
            : widget.themeColor;

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: shouldBlink
                  ? [
                      containerColor.withValues(alpha: 
                        0.9 * blinkValue,
                      ),
                      containerColor.withValues(alpha: 
                        0.7 * blinkValue,
                      ),
                    ]
                  : [
                      widget.themeColor
                          .withValues(alpha: 0.8),
                      widget.themeColor
                          .withValues(alpha: 0.6),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(
              20,
            ),
            boxShadow: [
              BoxShadow(
                color: shouldBlink
                    ? Colors.red.withValues(alpha: 
                        0.4 * blinkValue,
                      )
                    : widget.themeColor
                          .withValues(alpha: 0.3),
                blurRadius: widget.isCurrentPlayer
                    ? 10
                    : 5,
                offset: const Offset(0, 3),
              ),
              if (shouldBlink)
                BoxShadow(
                  color: Colors.red.withValues(alpha: 
                    0.2 * blinkValue,
                  ),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 0),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 귀여운 아이콘
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 
                    0.9,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: shouldBlink
                      ? [
                          BoxShadow(
                            color: Colors.red
                                .withValues(alpha: 
                                  0.3 *
                                      blinkValue,
                                ),
                            blurRadius: 5,
                            offset: const Offset(
                              0,
                              0,
                            ),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isLowTime
                      ? Icons.timer
                      : Icons.access_time,
                  color: isLowTime
                      ? (shouldBlink
                            ? Color.lerp(
                                Colors
                                    .red
                                    .shade700,
                                Colors
                                    .red
                                    .shade900,
                                blinkValue,
                              )
                            : Colors.red)
                      : widget.themeColor,
                  size: 16,
                ),
              ),

              const SizedBox(width: 8),

              // 플레이어 이름과 시간
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.playerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.remainingTime}초',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isLowTime
                          ? 16
                          : 14,
                      fontWeight: isLowTime
                          ? FontWeight.bold
                          : FontWeight.w500,
                      shadows: shouldBlink
                          ? [
                              Shadow(
                                color: Colors.red
                                    .withValues(alpha: 
                                      0.5 *
                                          blinkValue,
                                    ),
                                blurRadius: 3,
                                offset:
                                    const Offset(
                                      0,
                                      0,
                                    ),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
