import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/character.dart';

class SkillEffectWidget extends StatefulWidget {
  final SkillType skillType;
  final Offset center;
  final double radius;
  final VoidCallback? onComplete;

  const SkillEffectWidget({
    super.key,
    required this.skillType,
    required this.center,
    this.radius = 50.0,
    this.onComplete,
  });

  @override
  State<SkillEffectWidget> createState() =>
      _SkillEffectWidgetState();
}

class _SkillEffectWidgetState
    extends State<SkillEffectWidget>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(
        milliseconds: 1200,
      ),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(
        milliseconds: 2000,
      ),
      vsync: this,
    );

    _scaleAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(
              0.0,
              0.6,
              curve: Curves.elasticOut,
            ),
          ),
        );

    _rotationAnimation =
        Tween<double>(
          begin: 0.0,
          end: 2 * math.pi,
        ).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: Curves.linear,
          ),
        );

    _opacityAnimation =
        Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(
              0.7,
              1.0,
              curve: Curves.easeOut,
            ),
          ),
        );

    _startAnimation();
  }

  void _startAnimation() async {
    _particleController.forward();
    await _mainController.forward();

    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _mainController,
        _particleController,
      ]),
      builder: (context, child) {
        return Positioned(
          left: widget.center.dx - widget.radius,
          top: widget.center.dy - widget.radius,
          child: SizedBox(
            width: widget.radius * 2,
            height: widget.radius * 2,
            child: Stack(
              children: [
                // 파티클 효과
                _buildParticleEffect(),

                // 메인 스킬 아이콘
                Center(
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation
                          .value,
                      child: Opacity(
                        opacity: _opacityAnimation
                            .value,
                        child: _buildSkillIcon(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticleEffect() {
    return CustomPaint(
      size: Size(
        widget.radius * 2,
        widget.radius * 2,
      ),
      painter: SkillParticlePainter(
        skillType: widget.skillType,
        progress: _particleController.value,
        radius: widget.radius,
      ),
    );
  }

  Widget _buildSkillIcon() {
    Color color;
    IconData icon;

    switch (widget.skillType) {
      case SkillType.offensive:
        color = Colors.red;
        icon = Icons.flash_on;
        break;
      case SkillType.defensive:
        color = Colors.blue;
        icon = Icons.shield;
        break;
      case SkillType.disruptive:
        color = Colors.purple;
        icon = Icons.psychology;
        break;
      case SkillType.timeControl:
        color = Colors.orange;
        icon = Icons.access_time;
        break;
    }

    return Container(
      width: widget.radius,
      height: widget.radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: widget.radius * 0.6,
      ),
    );
  }
}

class SkillParticlePainter extends CustomPainter {
  final SkillType skillType;
  final double progress;
  final double radius;

  SkillParticlePainter({
    required this.skillType,
    required this.progress,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    switch (skillType) {
      case SkillType.offensive:
        _drawOffensiveParticles(canvas, center);
        break;
      case SkillType.defensive:
        _drawDefensiveParticles(canvas, center);
        break;
      case SkillType.disruptive:
        _drawDisruptiveParticles(canvas, center);
        break;
      case SkillType.timeControl:
        _drawTimeControlParticles(canvas, center);
        break;
    }
  }

  void _drawOffensiveParticles(
    Canvas canvas,
    Offset center,
  ) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(
        0.7 * (1 - progress),
      )
      ..style = PaintingStyle.fill;

    // 번개 모양 파티클
    for (int i = 0; i < 8; i++) {
      final angle =
          (i * 2 * math.pi / 8) +
          (progress * math.pi);
      final distance = radius * progress * 1.5;

      final x =
          center.dx + math.cos(angle) * distance;
      final y =
          center.dy + math.sin(angle) * distance;

      final particleSize = 3 * (1 - progress);
      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        paint,
      );

      // 작은 번개 라인
      final lineEnd = Offset(
        x +
            math.cos(angle + math.pi / 4) *
                10 *
                (1 - progress),
        y +
            math.sin(angle + math.pi / 4) *
                10 *
                (1 - progress),
      );

      final linePaint = Paint()
        ..color = Colors.yellow.withOpacity(
          0.8 * (1 - progress),
        )
        ..strokeWidth = 2 * (1 - progress)
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(x, y),
        lineEnd,
        linePaint,
      );
    }
  }

  void _drawDefensiveParticles(
    Canvas canvas,
    Offset center,
  ) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(
        0.6 * (1 - progress),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 방어막 원형 파티클
    for (int i = 0; i < 3; i++) {
      final ringRadius =
          radius * (0.5 + i * 0.3) * progress;
      canvas.drawCircle(
        center,
        ringRadius,
        paint,
      );
    }

    // 방어 결정체 파티클
    final crystalPaint = Paint()
      ..color = Colors.lightBlue.withOpacity(
        0.8 * (1 - progress),
      )
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final distance = radius * 0.8;

      final x =
          center.dx + math.cos(angle) * distance;
      final y =
          center.dy + math.sin(angle) * distance;

      final size = 4 * (1 - progress);
      _drawCrystal(
        canvas,
        Offset(x, y),
        size,
        crystalPaint,
      );
    }
  }

  void _drawDisruptiveParticles(
    Canvas canvas,
    Offset center,
  ) {
    final paint = Paint()
      ..color = Colors.purple.withOpacity(
        0.7 * (1 - progress),
      )
      ..style = PaintingStyle.fill;

    // 혼란 소용돌이 파티클
    for (int i = 0; i < 12; i++) {
      final angle =
          (i * 2 * math.pi / 12) +
          (progress * 4 * math.pi);
      final spiralRadius =
          radius *
          progress *
          math.sin(progress * math.pi);

      final x =
          center.dx +
          math.cos(angle) * spiralRadius;
      final y =
          center.dy +
          math.sin(angle) * spiralRadius;

      final particleSize =
          2 +
          math.sin(
                angle + progress * 8 * math.pi,
              ) *
              2;
      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        paint,
      );
    }

    // 중앙 소용돌이
    final spiralPaint = Paint()
      ..color = Colors.deepPurple.withOpacity(
        0.5 * (1 - progress),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * (1 - progress);

    final spiralPath = Path();
    for (
      double t = 0;
      t <= 4 * math.pi;
      t += 0.1
    ) {
      final r = t * 3 * progress;
      final x = center.dx + r * math.cos(t);
      final y = center.dy + r * math.sin(t);

      if (t == 0) {
        spiralPath.moveTo(x, y);
      } else {
        spiralPath.lineTo(x, y);
      }
    }

    canvas.drawPath(spiralPath, spiralPaint);
  }

  void _drawTimeControlParticles(
    Canvas canvas,
    Offset center,
  ) {
    final paint = Paint()
      ..color = Colors.orange.withOpacity(
        0.7 * (1 - progress),
      )
      ..style = PaintingStyle.fill;

    // 시계 파티클
    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final distance = radius * 0.7;

      final x =
          center.dx + math.cos(angle) * distance;
      final y =
          center.dy + math.sin(angle) * distance;

      // 시계 숫자 위치에 점
      final dotSize = 3 * (1 - progress);
      canvas.drawCircle(
        Offset(x, y),
        dotSize,
        paint,
      );
    }

    // 시계 바늘 회전 효과
    final handPaint = Paint()
      ..color = Colors.amber.withOpacity(
        0.8 * (1 - progress),
      )
      ..strokeWidth = 3 * (1 - progress)
      ..strokeCap = StrokeCap.round;

    // 분침
    final minuteAngle = progress * 12 * math.pi;
    final minuteEnd = Offset(
      center.dx +
          math.cos(minuteAngle - math.pi / 2) *
              radius *
              0.6,
      center.dy +
          math.sin(minuteAngle - math.pi / 2) *
              radius *
              0.6,
    );
    canvas.drawLine(center, minuteEnd, handPaint);

    // 시침
    final hourAngle = progress * math.pi;
    final hourEnd = Offset(
      center.dx +
          math.cos(hourAngle - math.pi / 2) *
              radius *
              0.4,
      center.dy +
          math.sin(hourAngle - math.pi / 2) *
              radius *
              0.4,
    );
    canvas.drawLine(center, hourEnd, handPaint);

    // 중앙점
    canvas.drawCircle(
      center,
      4 * (1 - progress),
      paint,
    );
  }

  void _drawCrystal(
    Canvas canvas,
    Offset center,
    double size,
    Paint paint,
  ) {
    final path = Path();

    // 다이아몬드 모양 결정체
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(
      center.dx + size * 0.7,
      center.dy,
    );
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(
      center.dx - size * 0.7,
      center.dy,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return oldDelegate is! SkillParticlePainter ||
        oldDelegate.progress != progress;
  }
}

class SkillRippleEffect extends StatefulWidget {
  final Offset center;
  final Color color;
  final double maxRadius;
  final VoidCallback? onComplete;

  const SkillRippleEffect({
    super.key,
    required this.center,
    required this.color,
    this.maxRadius = 100.0,
    this.onComplete,
  });

  @override
  State<SkillRippleEffect> createState() =>
      _SkillRippleEffectState();
}

class _SkillRippleEffectState
    extends State<SkillRippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOut,
          ),
        );

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left:
              widget.center.dx - widget.maxRadius,
          top:
              widget.center.dy - widget.maxRadius,
          child: SizedBox(
            width: widget.maxRadius * 2,
            height: widget.maxRadius * 2,
            child: CustomPaint(
              painter: RipplePainter(
                progress: _animation.value,
                color: widget.color,
                maxRadius: widget.maxRadius,
              ),
            ),
          ),
        );
      },
    );
  }
}

class RipplePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double maxRadius;

  RipplePainter({
    required this.progress,
    required this.color,
    required this.maxRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    // 3개의 동심원 물결 효과
    for (int i = 0; i < 3; i++) {
      final delay = i * 0.2;
      final rippleProgress = math.max(
        0.0,
        math.min(1.0, (progress - delay) / 0.8),
      );

      if (rippleProgress > 0) {
        final radius = maxRadius * rippleProgress;
        final opacity =
            (1 - rippleProgress) * 0.6;

        final paint = Paint()
          ..color = color.withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

        canvas.drawCircle(center, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return oldDelegate is! RipplePainter ||
        oldDelegate.progress != progress;
  }
}
