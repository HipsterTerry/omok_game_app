import 'package:flutter/material.dart';

class AnimatedCountdown extends StatefulWidget {
  final int remainingTime; // 외부에서 받아올 남은 시간
  final double size;
  final VoidCallback? onTimeUp; // 시간 종료 시 콜백

  const AnimatedCountdown({
    super.key,
    required this.remainingTime,
    required this.size,
    this.onTimeUp,
  });

  @override
  State<AnimatedCountdown> createState() =>
      _AnimatedCountdownState();
}

class _AnimatedCountdownState
    extends State<AnimatedCountdown> {
  @override
  Widget build(BuildContext context) {
    // 디버그: 현재 남은 시간 출력
    print(
      '🕐 AnimatedCountdown: ${widget.remainingTime}초',
    );

    // 10초 이하일 때 빨간색, 그 외에는 주황색 (기존 로직 유지)
    final isLowTime = widget.remainingTime <= 10;

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: isLowTime
            ? Colors.red[400]
            : Colors.amber[300],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(
          milliseconds: 400,
        ),
        transitionBuilder: (child, animation) =>
            ScaleTransition(
              scale: animation,
              child: child,
            ),
        child: Text(
          '${widget.remainingTime}',
          key: ValueKey<int>(
            widget.remainingTime,
          ),
          style: TextStyle(
            fontSize: widget.size / 2.5,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
