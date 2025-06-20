import 'package:flutter/material.dart';
import 'dart:ui';

/// 키치 테마 시각적 효과 강화 위젯들

/// Cloud BG 효과가 적용된 컨테이너
class CloudContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const CloudContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding:
          padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(
          0xFFF4FEFF,
        ).withValues(alpha: 0.9),
        borderRadius:
            borderRadius ??
            BorderRadius.circular(24),
        boxShadow: [
          // Soft white shadow for cloud effect
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 20,
            offset: const Offset(0, -2),
            spreadRadius: 2,
          ),
          // Subtle bottom shadow
          BoxShadow(
            color: const Color(
              0xFFC5F6F9,
            ).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: const Color(
            0xFFC5F6F9,
          ).withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: child,
    );
  }
}

/// 입체적 효과가 적용된 PLAY 버튼
class VolumetricPlayButton
    extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final double? width;
  final double? height;
  final Color? backgroundColor;

  const VolumetricPlayButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height,
    this.backgroundColor,
  });

  @override
  State<VolumetricPlayButton> createState() =>
      _VolumetricPlayButtonState();
}

class _VolumetricPlayButtonState
    extends State<VolumetricPlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation =
        Tween<double>(
          begin: 1.0,
          end: 0.95,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width ?? 200,
              height: widget.height ?? 60,
              decoration: BoxDecoration(
                // Gradient for volumetric effect
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    widget.backgroundColor ??
                        const Color(
                          0xFF89E0F7,
                        ), // 사용자 정의 또는 기본 색상
                    (widget.backgroundColor ??
                            const Color(
                              0xFF89E0F7,
                            ))
                        .withValues(alpha: 
                          0.8,
                        ), // 진한 버전
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 
                    0.3,
                  ),
                  width: 2,
                ),
                boxShadow: [
                  // Top inner highlight effect (강화)
                  BoxShadow(
                    color: Colors.white
                        .withValues(alpha: 0.8),
                    blurRadius: 6,
                    offset: const Offset(0, -4),
                    spreadRadius: 1,
                  ),
                  // Main depth shadow (강화)
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                  // Side shadow for depth
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(2, 4),
                    spreadRadius: 0,
                  ),
                  // Pressed state glow
                  if (_isPressed)
                    BoxShadow(
                      color:
                          (widget.backgroundColor ??
                                  const Color(
                                    0xFF89E0F7,
                                  ))
                              .withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 0),
                      spreadRadius: 8,
                    ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    fontFamily: 'SUIT',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors
                        .white, // 텍스트 하얀색으로 변경
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 오목판 배경 효과
class BoardBackground extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const BoardBackground({
    super.key,
    required this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(
          0xFFFFFDFB,
        ), // Board 배경
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(
            0xFFC5F6F9,
          ), // Board Border
          width: 2,
        ),
        boxShadow: [
          // Soft inner shadow for depth
          BoxShadow(
            color: const Color(
              0xFFC5F6F9,
            ).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: 0.3,
            sigmaY: 0.3,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 강조 텍스트 (Selection Border 색상 사용)
class AccentText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool isSelected;

  const AccentText({
    super.key,
    required this.text,
    this.style,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        style ??
        Theme.of(context).textTheme.bodyMedium!;

    return Text(
      text,
      style: baseStyle.copyWith(
        color: isSelected
            ? const Color(
                0xFF51D4EB,
              ) // Selection Border 색상
            : const Color(
                0xFF5C47CE,
              ).withValues(alpha: 0.8), // 기본 텍스트 반투명
        shadows: isSelected
            ? [
                Shadow(
                  color: const Color(
                    0xFF51D4EB,
                  ).withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
    );
  }
}

/// 캐릭터 선택 배경 효과
class CharacterBackground
    extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final EdgeInsetsGeometry? padding;

  const CharacterBackground({
    super.key,
    required this.child,
    this.isSelected = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(
          0xFFFAF9FB,
        ), // Character BG
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(
                  0xFF51D4EB,
                ) // Selection Border
              : const Color(
                  0xFFC5F6F9,
                ).withValues(alpha: 0.5),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: const Color(
                0xFF51D4EB,
              ).withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.7),
            blurRadius: 6,
            offset: const Offset(0, -1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 부드러운 배경 블러 효과
class SoftBlurBackground extends StatelessWidget {
  final Widget child;
  final double blurAmount;

  const SoftBlurBackground({
    super.key,
    required this.child,
    this.blurAmount = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred background
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: blurAmount,
              sigmaY: blurAmount,
            ),
            child: Container(
              color: const Color(
                0xFFDFFBFF,
              ).withValues(alpha: 0.3),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
