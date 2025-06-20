import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/character.dart';

class SkillEffectAnimations extends StatefulWidget {
  final SkillType skillType;
  final CharacterTier tier;
  final Size boardSize;
  final VoidCallback? onComplete;

  const SkillEffectAnimations({
    Key? key,
    required this.skillType,
    required this.tier,
    required this.boardSize,
    this.onComplete,
  }) : super(key: key);

  @override
  State<SkillEffectAnimations> createState() => _SkillEffectAnimationsState();
}

class _SkillEffectAnimationsState extends State<SkillEffectAnimations>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _rippleController;
  late AnimationController _particleController;

  late Animation<double> _mainAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _particleAnimation;

  List<Particle> particles = [];

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _mainAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutExpo),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    _initializeParticles();
    _startAnimation();
  }

  void _initializeParticles() {
    particles.clear();
    final random = math.Random();
    final particleCount = _getParticleCount();

    for (int i = 0; i < particleCount; i++) {
      particles.add(
        Particle(
          x: widget.boardSize.width / 2,
          y: widget.boardSize.height / 2,
          vx: (random.nextDouble() - 0.5) * 200,
          vy: (random.nextDouble() - 0.5) * 200,
          size: random.nextDouble() * 4 + 2,
          color: _getParticleColor(),
          life: 1.0,
        ),
      );
    }
  }

  int _getParticleCount() {
    switch (widget.skillType) {
      case SkillType.offensive:
        return 30;
      case SkillType.defensive:
        return 20;
      case SkillType.disruptive:
        return 40;
      case SkillType.timeControl:
        return 25;
    }
  }

  Color _getParticleColor() {
    switch (widget.skillType) {
      case SkillType.offensive:
        return Colors.red;
      case SkillType.defensive:
        return Colors.blue;
      case SkillType.disruptive:
        return Colors.purple;
      case SkillType.timeControl:
        return Colors.orange;
    }
  }

  void _startAnimation() async {
    // 동시에 여러 애니메이션 시작
    _mainController.forward();
    _rippleController.forward();
    _particleController.forward();

    // 완료 후 콜백 호출
    Future.delayed(const Duration(milliseconds: 1500), () {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _rippleController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _mainAnimation,
        _rippleAnimation,
        _particleAnimation,
      ]),
      builder: (context, child) {
        return Container(
          width: widget.boardSize.width,
          height: widget.boardSize.height,
          child: CustomPaint(
            painter: SkillEffectPainter(
              skillType: widget.skillType,
              tier: widget.tier,
              mainProgress: _mainAnimation.value,
              rippleProgress: _rippleAnimation.value,
              particleProgress: _particleAnimation.value,
              particles: particles,
              boardSize: widget.boardSize,
            ),
          ),
        );
      },
    );
  }
}

class Particle {
  double x, y;
  double vx, vy;
  double size;
  Color color;
  double life;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.life,
  });
}

class SkillEffectPainter extends CustomPainter {
  final SkillType skillType;
  final CharacterTier tier;
  final double mainProgress;
  final double rippleProgress;
  final double particleProgress;
  final List<Particle> particles;
  final Size boardSize;

  SkillEffectPainter({
    required this.skillType,
    required this.tier,
    required this.mainProgress,
    required this.rippleProgress,
    required this.particleProgress,
    required this.particles,
    required this.boardSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. 배경 이펙트
    _drawBackgroundEffect(canvas, size, center);

    // 2. 파동 이펙트
    _drawRippleEffect(canvas, center);

    // 3. 파티클 이펙트
    _drawParticles(canvas);

    // 4. 중앙 아이콘 이펙트
    _drawCenterIcon(canvas, center);
  }

  void _drawBackgroundEffect(Canvas canvas, Size size, Offset center) {
    final paint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              _getSkillColor().withValues(alpha: 0.3 * mainProgress),
              _getSkillColor().withValues(alpha: 0.1 * mainProgress),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: center,
              radius: size.width * 0.8 * mainProgress,
            ),
          );

    canvas.drawCircle(center, size.width * 0.8 * mainProgress, paint);
  }

  void _drawRippleEffect(Canvas canvas, Offset center) {
    final ripplePaint = Paint()
      ..color = _getSkillColor().withValues(alpha: (1 - rippleProgress) * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    for (int i = 0; i < 3; i++) {
      final rippleRadius = (i * 50 + rippleProgress * 150);
      final opacity = (1 - rippleProgress) * (1 - i * 0.3);

      ripplePaint.color = _getSkillColor().withValues(alpha: opacity);

      canvas.drawCircle(center, rippleRadius, ripplePaint);
    }
  }

  void _drawParticles(Canvas canvas) {
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final currentX = particle.x + particle.vx * particleProgress;
      final currentY = particle.y + particle.vy * particleProgress;
      final currentLife = particle.life * (1 - particleProgress);

      particlePaint.color = particle.color.withValues(alpha: currentLife);

      canvas.drawCircle(
        Offset(currentX, currentY),
        particle.size * currentLife,
        particlePaint,
      );
    }
  }

  void _drawCenterIcon(Canvas canvas, Offset center) {
    final iconPaint = Paint()
      ..color = _getSkillColor().withValues(alpha: mainProgress)
      ..style = PaintingStyle.fill;

    final iconSize = 40.0 * mainProgress;

    switch (skillType) {
      case SkillType.offensive:
        _drawLightningIcon(canvas, center, iconSize, iconPaint);
        break;
      case SkillType.defensive:
        _drawShieldIcon(canvas, center, iconSize, iconPaint);
        break;
      case SkillType.disruptive:
        _drawSwirlIcon(canvas, center, iconSize, iconPaint);
        break;
      case SkillType.timeControl:
        _drawClockIcon(canvas, center, iconSize, iconPaint);
        break;
    }
  }

  Color _getSkillColor() {
    switch (skillType) {
      case SkillType.offensive:
        return Colors.red;
      case SkillType.defensive:
        return Colors.blue;
      case SkillType.disruptive:
        return Colors.purple;
      case SkillType.timeControl:
        return Colors.orange;
    }
  }

  void _drawLightningIcon(
    Canvas canvas,
    Offset center,
    double size,
    Paint paint,
  ) {
    final path = Path();
    path.moveTo(center.dx - size * 0.2, center.dy - size * 0.4);
    path.lineTo(center.dx + size * 0.1, center.dy - size * 0.1);
    path.lineTo(center.dx - size * 0.1, center.dy);
    path.lineTo(center.dx + size * 0.2, center.dy + size * 0.4);
    path.lineTo(center.dx - size * 0.1, center.dy + size * 0.1);
    path.lineTo(center.dx + size * 0.1, center.dy);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawShieldIcon(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size * 0.4);
    path.lineTo(center.dx + size * 0.3, center.dy - size * 0.2);
    path.lineTo(center.dx + size * 0.3, center.dy + size * 0.2);
    path.lineTo(center.dx, center.dy + size * 0.4);
    path.lineTo(center.dx - size * 0.3, center.dy + size * 0.2);
    path.lineTo(center.dx - size * 0.3, center.dy - size * 0.2);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawSwirlIcon(Canvas canvas, Offset center, double size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4.0;

    final path = Path();
    for (double i = 0; i < 4 * math.pi; i += 0.1) {
      final radius = size * 0.3 * (i / (4 * math.pi));
      final x = center.dx + radius * math.cos(i);
      final y = center.dy + radius * math.sin(i);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawClockIcon(Canvas canvas, Offset center, double size, Paint paint) {
    // 시계 외곽
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3.0;
    canvas.drawCircle(center, size * 0.3, paint);

    // 시계 바늘
    paint.style = PaintingStyle.fill;
    final handLength = size * 0.2;
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - handLength),
      paint..strokeWidth = 2.0,
    );
    canvas.drawLine(
      center,
      Offset(center.dx + handLength * 0.7, center.dy),
      paint..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
