import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/character.dart';
import '../models/enhanced_game_state.dart';

class SkillActivationWidget
    extends StatefulWidget {
  final Character? character;
  final bool canUseSkill;
  final VoidCallback onSkillActivated;
  final bool isCurrentTurn;

  const SkillActivationWidget({
    Key? key,
    required this.character,
    required this.canUseSkill,
    required this.onSkillActivated,
    required this.isCurrentTurn,
  }) : super(key: key);

  @override
  State<SkillActivationWidget> createState() =>
      _SkillActivationWidgetState();
}

class _SkillActivationWidgetState
    extends State<SkillActivationWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(
        milliseconds: 1200,
      ),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(
        milliseconds: 3000,
      ),
      vsync: this,
    )..repeat();

    _pulseAnimation =
        Tween<double>(
          begin: 0.8,
          end: 1.2,
        ).animate(
          CurvedAnimation(
            parent: _pulseController,
            curve: Curves.easeInOut,
          ),
        );

    _rotationAnimation =
        Tween<double>(
          begin: 0.0,
          end: 2 * math.pi,
        ).animate(
          CurvedAnimation(
            parent: _rotationController,
            curve: Curves.linear,
          ),
        );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _activateSkill() {
    if (!widget.canUseSkill ||
        !widget.isCurrentTurn)
      return;

    // 햅틱 피드백
    HapticFeedback.mediumImpact();

    // 스킬 발동 효과
    _showSkillEffect();

    // 콜백 호출
    widget.onSkillActivated();
  }

  void _showSkillEffect() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SkillEffectDialog(
          character: widget.character!,
          onComplete: () =>
              Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.character == null) {
      return const SizedBox.shrink();
    }

    final character = widget.character!;
    final canActivate =
        widget.canUseSkill &&
        widget.isCurrentTurn;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _pulseAnimation,
        _rotationAnimation,
      ]),
      builder: (context, child) {
        return Container(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 배경 원형 효과 (사용 가능할 때만)
              if (canActivate)
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          character.tierColor
                              .withOpacity(0.3),
                          character.tierColor
                              .withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

              // 회전하는 테두리 (천급, 지급만)
              if (canActivate &&
                  character.tier !=
                      CharacterTier.human)
                Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            character.tier ==
                                CharacterTier
                                    .heaven
                            ? const Color(
                                0xFFFFD700,
                              )
                            : const Color(
                                0xFFC0C0C0,
                              ),
                        width: 2,
                      ),
                    ),
                  ),
                ),

              // 메인 스킬 버튼
              GestureDetector(
                onTap: _activateSkill,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: canActivate
                          ? [
                              character.tierColor
                                  .withOpacity(
                                    0.9,
                                  ),
                              character.tierColor,
                            ]
                          : [
                              Colors.grey[400]!,
                              Colors.grey[600]!,
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: canActivate
                            ? character.tierColor
                                  .withOpacity(
                                    0.4,
                                  )
                            : Colors.black26,
                        blurRadius: canActivate
                            ? 12
                            : 4,
                        offset: const Offset(
                          0,
                          4,
                        ),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getSkillIcon(
                      character.skillType,
                    ),
                    size: 28,
                    color: canActivate
                        ? Colors.white
                        : Colors.grey[300],
                  ),
                ),
              ),

              // 비활성화 오버레이
              if (!canActivate)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),

              // 쿨다운 표시 (사용 후)
              if (!widget.canUseSkill &&
                  widget.character != null)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(
                      0.7,
                    ),
                  ),
                  child: const Icon(
                    Icons.block,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  IconData _getSkillIcon(SkillType skillType) {
    switch (skillType) {
      case SkillType.offensive:
        return Icons.flash_on;
      case SkillType.defensive:
        return Icons.shield;
      case SkillType.disruptive:
        return Icons.psychology;
      case SkillType.timeControl:
        return Icons.access_time;
    }
  }
}

// 스킬 발동 효과 다이얼로그
class SkillEffectDialog extends StatefulWidget {
  final Character character;
  final VoidCallback onComplete;

  const SkillEffectDialog({
    Key? key,
    required this.character,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<SkillEffectDialog> createState() =>
      _SkillEffectDialogState();
}

class _SkillEffectDialogState
    extends State<SkillEffectDialog>
    with TickerProviderStateMixin {
  late AnimationController _effectController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _effectController = AnimationController(
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
            parent: _effectController,
            curve: const Interval(
              0.0,
              0.6,
              curve: Curves.elasticOut,
            ),
          ),
        );

    _fadeAnimation =
        Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: _effectController,
            curve: const Interval(
              0.7,
              1.0,
              curve: Curves.easeOut,
            ),
          ),
        );

    _effectController.forward().then((_) {
      Future.delayed(
        const Duration(milliseconds: 500),
        () {
          widget.onComplete();
        },
      );
    });
  }

  @override
  void dispose() {
    _effectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _fadeAnimation,
      ]),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black
              .withOpacity(
                0.8 * _fadeAnimation.value,
              ),
          body: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.character.tierColor
                            .withOpacity(0.8),
                        widget.character.tierColor
                            .withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child:
                      TweenAnimationBuilder<
                        double
                      >(
                        duration: const Duration(
                          milliseconds: 800,
                        ),
                        tween: Tween(
                          begin: 0.0,
                          end: 1.0,
                        ),
                        builder: (context, value, _) {
                          return Transform.scale(
                            scale:
                                0.5 +
                                (value * 1.5),
                            child: Opacity(
                              opacity:
                                  1.0 -
                                  (value * 0.3),
                              child: Icon(
                                _getSkillIcon(
                                  widget
                                      .character
                                      .skillType,
                                ),
                                size: 80,
                                color:
                                    Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getSkillIcon(SkillType skillType) {
    switch (skillType) {
      case SkillType.offensive:
        return Icons.flash_on;
      case SkillType.defensive:
        return Icons.shield;
      case SkillType.disruptive:
        return Icons.psychology;
      case SkillType.timeControl:
        return Icons.access_time;
    }
  }
}
