import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/player_profile.dart';
import '../services/character_service.dart';
import '../widgets/character_card_widget.dart';
import '../logic/ai_player.dart';
import 'enhanced_game_screen.dart';
import '../models/game_state.dart';

class CharacterSelectionScreen extends StatefulWidget {
  final BoardSize boardSize;
  final bool isAIGame;
  final AIDifficulty? aiDifficulty;

  const CharacterSelectionScreen({
    super.key,
    required this.boardSize,
    this.isAIGame = false,
    this.aiDifficulty,
  });

  @override
  State<CharacterSelectionScreen> createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen>
    with TickerProviderStateMixin {
  Character? _selectedBlackCharacter;
  Character? _selectedWhiteCharacter;
  bool _useBasicStones = true; // 기본 돌 사용 여부

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              _buildHeader(),

              // 돌 타입 선택 (기본 vs 캐릭터)
              _buildStoneTypeSelector(),

              // 캐릭터 선택 영역 (캐릭터돌 선택 시에만 표시)
              if (!_useBasicStones) ...[
                Expanded(child: _buildCharacterSelection()),
              ] else ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.circle, size: 120, color: Colors.grey[600]),
                        const SizedBox(height: 20),
                        Text(
                          '기본 흑/백돌로 게임합니다',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // 하단 버튼
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '캐릭터돌 선택',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [Colors.orange, Colors.yellow],
                ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'FPS 무기처럼 캐릭터돌을 선택하세요',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStoneTypeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _useBasicStones = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: _useBasicStones
                      ? Colors.orange.withOpacity(0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.circle,
                      color: _useBasicStones ? Colors.orange : Colors.grey,
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '기본 돌',
                      style: TextStyle(
                        color: _useBasicStones ? Colors.orange : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '일반 흑/백돌',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _useBasicStones = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: !_useBasicStones
                      ? Colors.orange.withOpacity(0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: !_useBasicStones ? Colors.orange : Colors.grey,
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '캐릭터돌',
                      style: TextStyle(
                        color: !_useBasicStones ? Colors.orange : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '12지신 특수효과',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterSelection() {
    return Column(
      children: [
        // 흑돌 캐릭터 선택
        _buildPlayerSection(
          '흑돌 캐릭터',
          _selectedBlackCharacter,
          (character) => setState(() => _selectedBlackCharacter = character),
          Colors.grey[800]!,
        ),

        const SizedBox(height: 20),

        // 백돌 캐릭터 선택 (AI 게임이 아닐 때만)
        if (!widget.isAIGame)
          _buildPlayerSection(
            '백돌 캐릭터',
            _selectedWhiteCharacter,
            (character) => setState(() => _selectedWhiteCharacter = character),
            Colors.grey[300]!,
          ),
      ],
    );
  }

  Widget _buildPlayerSection(
    String title,
    Character? selectedCharacter,
    Function(Character?) onSelect,
    Color themeColor,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: themeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (selectedCharacter != null)
                  TextButton(
                    onPressed: () => onSelect(null),
                    child: const Text('기본돌로 변경'),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          if (selectedCharacter != null) ...[
            // 선택된 캐릭터 표시
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: selectedCharacter.tierColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedCharacter.tierColor,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _getCharacterEmoji(selectedCharacter.type),
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedCharacter.koreanName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          selectedCharacter.skill.name,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: selectedCharacter.tierColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      selectedCharacter.tierName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // 캐릭터 선택 그리드
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: CharacterService.getAllCharacters().length,
                itemBuilder: (context, index) {
                  final character = CharacterService.getAllCharacters()[index];
                  return GestureDetector(
                    onTap: () => onSelect(character),
                    child: CharacterCardWidget(
                      character: character,
                      isUnlocked: true,
                      isSelected: false,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '뒤로',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '게임 시작',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedGameScreen(
          boardSize: widget.boardSize,
          playerCharacter: _useBasicStones ? null : _selectedBlackCharacter,
          isAIGame: widget.isAIGame,
          aiDifficulty: widget.aiDifficulty,
        ),
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
