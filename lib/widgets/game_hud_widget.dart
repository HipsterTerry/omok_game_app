import 'package:flutter/material.dart';
import '../models/enhanced_game_state.dart';
import '../models/player_profile.dart';
import '../models/game_state.dart';

class GameHudWidget extends StatefulWidget {
  final EnhancedGameState gameState;
  final int blackTimeRemaining;
  final int whiteTimeRemaining;
  final int turnNumber;

  const GameHudWidget({
    super.key,
    required this.gameState,
    required this.blackTimeRemaining,
    required this.whiteTimeRemaining,
    required this.turnNumber,
  });

  @override
  State<GameHudWidget> createState() => _GameHudWidgetState();
}

class _GameHudWidgetState extends State<GameHudWidget> {
  @override
  Widget build(BuildContext context) {
    final currentPlayer = widget.gameState.currentPlayer;
    final isBlackTurn = currentPlayer == PlayerType.black;

    return Container(
      height: 50, // 높이를 50으로 더 줄임
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[800]!.withOpacity(0.95),
            Colors.grey[700]!.withOpacity(0.85),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 흑돌 정보
          _buildSimplePlayerInfo('흑돌', widget.blackTimeRemaining, isBlackTurn),

          // 중앙 정보
          Text(
            '${widget.turnNumber}수',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          // 백돌 정보
          _buildSimplePlayerInfo('백돌', widget.whiteTimeRemaining, !isBlackTurn),
        ],
      ),
    );
  }

  Widget _buildSimplePlayerInfo(
    String playerName,
    int timeRemaining,
    bool isCurrentTurn,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isCurrentTurn
            ? Colors.orange.withOpacity(0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: isCurrentTurn
            ? Border.all(color: Colors.orange, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            playerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${timeRemaining}s',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
