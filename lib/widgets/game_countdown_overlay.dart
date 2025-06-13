import 'package:flutter/material.dart';
import 'dart:async';

class GameCountdownOverlay
    extends StatefulWidget {
  final VoidCallback onCountdownComplete;
  final bool showCountdown;

  const GameCountdownOverlay({
    super.key,
    required this.onCountdownComplete,
    required this.showCountdown,
  });

  @override
  State<GameCountdownOverlay> createState() =>
      _GameCountdownOverlayState();
}

class _GameCountdownOverlayState
    extends State<GameCountdownOverlay> {
  int _currentCount = 3;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    if (widget.showCountdown) {
      _startCountdown();
    }
  }

  @override
  void didUpdateWidget(
    GameCountdownOverlay oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (widget.showCountdown &&
        !oldWidget.showCountdown) {
      _startCountdown();
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();

    setState(() {
      _currentCount = 3;
    });

    print('🔥 카운트다운 시작: $_currentCount');

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        print(
          '⏰ 카운트다운: $_currentCount -> ${_currentCount - 1}',
        );

        setState(() {
          _currentCount--;
        });

        if (_currentCount < 0) {
          print('🎮 게임 시작!');
          timer.cancel();

          // 1초 후 완료
          Future.delayed(
            const Duration(seconds: 1),
            () {
              widget.onCountdownComplete();
            },
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showCountdown) {
      return const SizedBox.shrink();
    }

    print('🎨 카운트다운 UI 빌드: $_currentCount');

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: _currentCount > 0
            ? Text(
                '$_currentCount',
                style: const TextStyle(
                  fontSize: 200,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Cafe24Ohsquare',
                  shadows: [
                    Shadow(
                      offset: Offset(3, 3),
                      blurRadius: 8,
                      color: Colors.black54,
                    ),
                    Shadow(
                      offset: Offset(-1, -1),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
              )
            : const Text(
                'Start!',
                style: TextStyle(
                  fontSize: 100,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Cafe24Ohsquare',
                  shadows: [
                    Shadow(
                      offset: Offset(3, 3),
                      blurRadius: 8,
                      color: Colors.black54,
                    ),
                    Shadow(
                      offset: Offset(-1, -1),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
