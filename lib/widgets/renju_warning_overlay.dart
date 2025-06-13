import 'package:flutter/material.dart';
import '../logic/advanced_renju_rule_evaluator.dart';

/// 렌주룰 위반 경고 메시지를 표시하는 오버레이
/// 금지 수 클릭 시 0.8초간 자동으로 사라짐
class RenjuWarningOverlay extends StatefulWidget {
  final String message;
  final VoidCallback? onComplete;

  const RenjuWarningOverlay({
    super.key,
    required this.message,
    this.onComplete,
  });

  @override
  State<RenjuWarningOverlay> createState() =>
      _RenjuWarningOverlayState();
}

class _RenjuWarningOverlayState
    extends State<RenjuWarningOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(
              0.0,
              0.3,
              curve: Curves.easeOut,
            ),
          ),
        );

    _scaleAnimation =
        Tween<double>(
          begin: 0.5,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(
              0.0,
              0.4,
              curve: Curves.elasticOut,
            ),
          ),
        );

    // 애니메이션 시작
    _animationController.forward();

    // 0.8초 후 자동으로 사라짐
    Future.delayed(
      const Duration(milliseconds: 800),
      () {
        if (mounted) {
          _animationController.reverse().then((
            _,
          ) {
            if (mounted) {
              widget.onComplete?.call();
            }
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.shade300,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 경고 메시지를 표시하는 헬퍼 클래스
class RenjuWarningHelper {
  static OverlayEntry? _currentOverlay;

  /// 경고 메시지 표시
  static void showWarning(
    BuildContext context,
    ForbiddenType forbiddenType,
  ) {
    // 이전 경고가 있으면 제거
    hideWarning();

    final message =
        AdvancedRenjuRuleEvaluator.getForbiddenMessage(
          forbiddenType,
        );
    if (message.isEmpty) return;

    _currentOverlay = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: RenjuWarningOverlay(
          message: message,
          onComplete: hideWarning,
        ),
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  /// 경고 메시지 숨기기
  static void hideWarning() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}
