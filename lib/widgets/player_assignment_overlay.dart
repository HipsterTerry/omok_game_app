import 'package:flutter/material.dart';
import '../models/game_state.dart';

class PlayerAssignmentOverlay
    extends StatefulWidget {
  final PlayerType firstPlayer;
  final bool isPlayerBlack; // 플레이어가 흑돌인지 여부
  final bool isAIGame;
  final VoidCallback onComplete;

  const PlayerAssignmentOverlay({
    super.key,
    required this.firstPlayer,
    required this.isPlayerBlack,
    required this.isAIGame,
    required this.onComplete,
  });

  @override
  State<PlayerAssignmentOverlay> createState() =>
      _PlayerAssignmentOverlayState();
}

class _PlayerAssignmentOverlayState
    extends State<PlayerAssignmentOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(
        milliseconds: 2000,
      ),
      vsync: this,
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
            parent: _animationController,
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
    await _animationController.forward();
    widget.onComplete();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getPlayerText() {
    if (widget.isAIGame) {
      return widget.isPlayerBlack
          ? '플레이어가 흑돌로 시작!'
          : 'AI가 흑돌로 시작!';
    } else {
      return widget.isPlayerBlack
          ? '플레이어 1이 흑돌로 시작!'
          : '플레이어 2가 흑돌로 시작!';
    }
  }

  Color _getPlayerColor() {
    // 항상 흑돌 색상 (흑돌이 먼저 시작하므로)
    return Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.8),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: 1.0 - _fadeAnimation.value,
            child: Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    // 돌 아이콘
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getPlayerColor(),
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                _getPlayerColor()
                                    .withOpacity(
                                      0.5,
                                    ),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.circle,
                        size: 60,
                        color: _getPlayerColor(),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 텍스트
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                              25,
                            ),
                        border: Border.all(
                          color:
                              _getPlayerColor(),
                          width: 3,
                        ),
                      ),
                      child: Text(
                        _getPlayerText(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              _getPlayerColor(),
                        ),
                        textAlign:
                            TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 부제목
                    Text(
                      '🎲 랜덤 플레이어 배정',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white
                            .withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
