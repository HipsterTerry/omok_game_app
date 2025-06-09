import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/character.dart';
import '../models/game_state.dart';

class AnimatedStoneWidget extends StatefulWidget {
  final PlayerType stoneType;
  final Character? character;
  final double stoneRadius;
  final bool isLastMove;
  final VoidCallback? onAnimationComplete;

  const AnimatedStoneWidget({
    Key? key,
    required this.stoneType,
    this.character,
    this.stoneRadius = 15.0,
    this.isLastMove = false,
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<AnimatedStoneWidget> createState() =>
      _AnimatedStoneWidgetState();
}

class _AnimatedStoneWidgetState
    extends State<AnimatedStoneWidget>
    with TickerProviderStateMixin {
  late AnimationController _dropController;
  late AnimationController _bounceController;
  late AnimationController _scaleController;

  late Animation<double> _dropAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 떨어지는 애니메이션
    _dropController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // 바운스 애니메이션
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // 스케일 애니메이션 (마지막 수 강조)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _dropAnimation =
        Tween<double>(
          begin: -50.0, // 위에서 시작
          end: 0.0, // 제자리로
        ).animate(
          CurvedAnimation(
            parent: _dropController,
            curve: Curves.easeInQuart,
          ),
        );

    _bounceAnimation =
        Tween<double>(
          begin: 0.0,
          end: -8.0, // 살짝 튕김
        ).animate(
          CurvedAnimation(
            parent: _bounceController,
            curve: Curves.elasticOut,
          ),
        );

    _scaleAnimation =
        Tween<double>(
          begin: 1.0,
          end: 1.3,
        ).animate(
          CurvedAnimation(
            parent: _scaleController,
            curve: Curves.elasticInOut,
          ),
        );

    // 애니메이션 시퀀스 시작
    _startAnimation();
  }

  void _startAnimation() async {
    // 1. 떨어지는 애니메이션
    await _dropController.forward();

    // 2. 바운스 애니메이션
    await _bounceController.forward();
    await _bounceController.reverse();

    // 3. 마지막 수라면 스케일 애니메이션
    if (widget.isLastMove) {
      _scaleController.repeat(reverse: true);
    }

    // 애니메이션 완료 콜백
    widget.onAnimationComplete?.call();
  }

  @override
  void dispose() {
    _dropController.dispose();
    _bounceController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBlack =
        widget.stoneType == PlayerType.black;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _dropAnimation,
        _bounceAnimation,
        _scaleAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            _dropAnimation.value +
                _bounceAnimation.value,
          ),
          child: Transform.scale(
            scale: widget.isLastMove
                ? _scaleAnimation.value
                : 1.0,
            child: _buildStone(isBlack),
          ),
        );
      },
    );
  }

  Widget _buildStone(bool isBlack) {
    final tier =
        widget.character?.tier ??
        CharacterTier.human;

    return Container(
      width: widget.stoneRadius * 2,
      height: widget.stoneRadius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 그림자
          Positioned(
            bottom: -2,
            right: 2,
            child: Container(
              width: widget.stoneRadius * 2,
              height: widget.stoneRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(
                  0.3,
                ),
              ),
            ),
          ),

          // 메인 돌
          Container(
            width: widget.stoneRadius * 2,
            height: widget.stoneRadius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: _getStoneColors(
                  isBlack,
                  tier,
                ),
                stops: tier == CharacterTier.human
                    ? [0.3, 1.0]
                    : [0.0, 0.7, 1.0],
              ),
              border: Border.all(
                color: _getBorderColor(tier),
                width: _getBorderWidth(tier),
              ),
              boxShadow: [
                BoxShadow(
                  color: _getTierColor(
                    tier,
                  ).withOpacity(0.5),
                  blurRadius:
                      tier == CharacterTier.heaven
                      ? 8
                      : 4,
                  spreadRadius:
                      tier == CharacterTier.heaven
                      ? 2
                      : 0,
                ),
              ],
            ),
            child: Center(
              child: _buildCharacterIcon(),
            ),
          ),

          // 하이라이트
          Positioned(
            top: widget.stoneRadius * 0.3,
            left: widget.stoneRadius * 0.3,
            child: Container(
              width: widget.stoneRadius * 0.8,
              height: widget.stoneRadius * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(
                  isBlack ? 0.3 : 0.7,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getStoneColors(
    bool isBlack,
    CharacterTier tier,
  ) {
    if (isBlack) {
      switch (tier) {
        case CharacterTier.heaven:
          return [
            const Color(0xFF4A4A4A),
            const Color(0xFF1C1C1C),
            const Color(
              0xFFFFD700,
            ).withOpacity(0.3),
          ];
        case CharacterTier.earth:
          return [
            const Color(0xFF3A3A3A),
            const Color(0xFF101010),
            const Color(
              0xFFC0C0C0,
            ).withOpacity(0.2),
          ];
        case CharacterTier.human:
          return [
            const Color(0xFF2C2C2C),
            const Color(0xFF000000),
          ];
      }
    } else {
      switch (tier) {
        case CharacterTier.heaven:
          return [
            const Color(0xFFFFFFF0),
            const Color(0xFFE0E0E0),
            const Color(
              0xFFFFD700,
            ).withOpacity(0.4),
          ];
        case CharacterTier.earth:
          return [
            const Color(0xFFFFFFFF),
            const Color(0xFFE0E0E0),
            const Color(
              0xFFC0C0C0,
            ).withOpacity(0.3),
          ];
        case CharacterTier.human:
          return [
            const Color(0xFFFFFFFF),
            const Color(0xFFE0E0E0),
          ];
      }
    }
  }

  Color _getBorderColor(CharacterTier tier) {
    switch (tier) {
      case CharacterTier.heaven:
        return const Color(0xFFFFD700);
      case CharacterTier.earth:
        return const Color(0xFFC0C0C0);
      case CharacterTier.human:
        return Colors.grey[600]!;
    }
  }

  double _getBorderWidth(CharacterTier tier) {
    switch (tier) {
      case CharacterTier.heaven:
        return 2.5;
      case CharacterTier.earth:
        return 2.0;
      case CharacterTier.human:
        return 1.0;
    }
  }

  Color _getTierColor(CharacterTier tier) {
    switch (tier) {
      case CharacterTier.heaven:
        return const Color(0xFFFFD700);
      case CharacterTier.earth:
        return const Color(0xFFC0C0C0);
      case CharacterTier.human:
        return const Color(0xFF8B4513);
    }
  }

  Widget _buildCharacterIcon() {
    if (widget.character == null)
      return const SizedBox.shrink();

    final emoji = _getCharacterEmoji(
      widget.character!.type,
    );

    return Text(
      emoji,
      style: TextStyle(
        fontSize: widget.stoneRadius * 0.8,
      ),
    );
  }

  String _getCharacterEmoji(CharacterType type) {
    switch (type) {
      case CharacterType.rat:
        return '🐭';
      case CharacterType.ox:
        return '🐂';
      case CharacterType.tiger:
        return '🐅';
      case CharacterType.rabbit:
        return '🐰';
      case CharacterType.dragon:
        return '🐲';
      case CharacterType.snake:
        return '🐍';
      case CharacterType.horse:
        return '🐴';
      case CharacterType.goat:
        return '🐐';
      case CharacterType.monkey:
        return '🐵';
      case CharacterType.rooster:
        return '🐓';
      case CharacterType.dog:
        return '🐶';
      case CharacterType.pig:
        return '🐷';
    }
  }
}

class PulseAnimationWidget
    extends StatefulWidget {
  final Widget child;
  final Color color;
  final double radius;

  const PulseAnimationWidget({
    super.key,
    required this.child,
    required this.color,
    this.radius = 20.0,
  });

  @override
  State<PulseAnimationWidget> createState() =>
      _PulseAnimationWidgetState();
}

class _PulseAnimationWidgetState
    extends State<PulseAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 1000,
      ),
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

    _controller.repeat();
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
        return Stack(
          alignment: Alignment.center,
          children: [
            // 펄스 효과
            Container(
              width:
                  widget.radius *
                  2 *
                  (1 + _animation.value),
              height:
                  widget.radius *
                  2 *
                  (1 + _animation.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.color.withOpacity(
                    1 - _animation.value,
                  ),
                  width: 2,
                ),
              ),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}

class WinningLineAnimationWidget
    extends StatefulWidget {
  final List<Offset> positions;
  final Color color;
  final double strokeWidth;

  const WinningLineAnimationWidget({
    super.key,
    required this.positions,
    required this.color,
    this.strokeWidth = 4.0,
  });

  @override
  State<WinningLineAnimationWidget>
  createState() =>
      _WinningLineAnimationWidgetState();
}

class _WinningLineAnimationWidgetState
    extends State<WinningLineAnimationWidget>
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
            curve: Curves.easeInOut,
          ),
        );

    _controller.forward();
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
        return CustomPaint(
          painter: WinningLinePainter(
            positions: widget.positions,
            color: widget.color,
            strokeWidth: widget.strokeWidth,
            progress: _animation.value,
          ),
        );
      },
    );
  }
}

class WinningLinePainter extends CustomPainter {
  final List<Offset> positions;
  final Color color;
  final double strokeWidth;
  final double progress;

  WinningLinePainter({
    required this.positions,
    required this.color,
    required this.strokeWidth,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = strokeWidth * 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        4,
      );

    final path = Path();
    path.moveTo(
      positions.first.dx,
      positions.first.dy,
    );

    for (int i = 1; i < positions.length; i++) {
      path.lineTo(
        positions[i].dx,
        positions[i].dy,
      );
    }

    // 진행률에 따른 PathMetric 계산
    final pathMetric = path
        .computeMetrics()
        .first;
    final extractPath = pathMetric.extractPath(
      0.0,
      pathMetric.length * progress,
    );

    // 글로우 효과
    canvas.drawPath(extractPath, glowPaint);
    // 메인 라인
    canvas.drawPath(extractPath, paint);

    // 끝점에 별 효과
    if (progress > 0.8) {
      final endPosition = positions.last;
      _drawWinStar(
        canvas,
        endPosition,
        color,
        (progress - 0.8) / 0.2,
      );
    }
  }

  void _drawWinStar(
    Canvas canvas,
    Offset center,
    Color color,
    double alpha,
  ) {
    final starPaint = Paint()
      ..color = color.withOpacity(alpha)
      ..style = PaintingStyle.fill;

    final path = Path();
    const radius = 15.0;
    const innerRadius = 7.0;

    for (int i = 0; i < 10; i++) {
      final angle = (i * math.pi) / 5;
      final r = i % 2 == 0 ? radius : innerRadius;
      final x =
          center.dx +
          r * math.cos(angle - math.pi / 2);
      final y =
          center.dy +
          r * math.sin(angle - math.pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, starPaint);
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return oldDelegate is! WinningLinePainter ||
        oldDelegate.progress != progress;
  }
}
