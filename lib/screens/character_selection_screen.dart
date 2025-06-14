import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/character.dart';
import '../models/player_profile.dart';
import '../services/character_service.dart';
import '../logic/ai_player.dart';
import 'enhanced_game_screen.dart';
import '../models/game_state.dart';
import '../widgets/enhanced_visual_effects.dart';
import '../core/constants/index.dart';

class CharacterSelectionScreen
    extends StatefulWidget {
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

class _CharacterSelectionScreenState
    extends State<CharacterSelectionScreen>
    with TickerProviderStateMixin {
  Character? _blackPlayerCharacter;
  Character? _whitePlayerCharacter;
  bool _useCharacterStone = false;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '🎭 캐릭터 선택',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cafe24Ohsquare',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🎮 키치한 헤더
            _buildCuteHeader(),

            // 🔥 돌 타입 선택 토글
            _buildStoneToggle(),

            // ✨ 캐릭터 선택 영역
            Expanded(
              child: _useCharacterStone
                  ? _buildDualPlayerCharacterSelection()
                  : _buildBasicStonePreview(),
            ),

            // 🚀 시작 버튼
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCuteHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 🎨 v2.0.0: 귀여운 캐릭터 이미지들 (PNG 이미지로 교체)
          // 쥐, 양, 용, 토끼 순서로 Bounce 애니메이션 적용 (호랑이 → 양 교체)
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              _buildBounceIcon(
                'assets/image/rat.png',
                0,
              ),
              _buildBounceIcon(
                'assets/image/goat.png', // v2.0.0: tiger → goat 교체
                200,
              ),
              _buildBounceIcon(
                'assets/image/dragon.png',
                400,
              ),
              _buildBounceIcon(
                'assets/image/rabbit.png',
                600,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _useCharacterStone
                ? '두 플레이어 모두 12지신 캐릭터를 선택하세요!'
                : '기본 흑백돌로 클래식하게 플레이하세요!',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontFamily: 'Pretendard',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBounceIcon(
    String imagePath,
    int delay,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(
        milliseconds: 1000 + delay,
      ),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.4),
          child: Image.asset(
            imagePath,
            width: 48,
            height: 48,
            fit: BoxFit.contain,
            errorBuilder:
                (context, error, stackTrace) {
                  // 이미지 로딩 실패시 이모지로 대체
                  String emoji =
                      imagePath.contains('rat')
                      ? '🐭'
                      : imagePath.contains('goat')
                      ? '🐐'
                      : imagePath.contains(
                          'dragon',
                        )
                      ? '🐲'
                      : '🐰';
                  return Text(
                    emoji,
                    style: const TextStyle(
                      fontSize: 32,
                    ),
                  );
                },
          ),
        );
      },
    );
  }

  Widget _buildStoneToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.tertiary.withOpacity(
          0.3,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.tertiary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF51D4EB,
            ).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _useCharacterStone = false;
                  _blackPlayerCharacter = null;
                  _whitePlayerCharacter = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 300,
                ),
                padding:
                    const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                decoration: BoxDecoration(
                  color: !_useCharacterStone
                      ? const Color(
                          0xFFFFD966,
                        ) // 새로운 버튼 색상
                      : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.circle,
                      color: !_useCharacterStone
                          ? const Color(
                              0xFF2D2D2D,
                            ) // 메인 텍스트 색상
                          : const Color(
                              0xFF2D2D2D,
                            ).withOpacity(0.5),
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '기본돌',
                      style: TextStyle(
                        color: !_useCharacterStone
                            ? Colors.white
                            : Colors.grey,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _useCharacterStone = true;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 300,
                ),
                padding:
                    const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                decoration: BoxDecoration(
                  color: _useCharacterStone
                      ? Colors.orange
                      : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: _useCharacterStone
                          ? Colors.white
                          : Colors.grey,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '캐릭터돌',
                      style: TextStyle(
                        color: _useCharacterStone
                            ? Colors.white
                            : Colors.grey,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                      ),
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

  Widget _buildBasicStonePreview() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.brown[800],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF5C47CE,
                  ).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(
                        color: Color(0xFF5C47CE),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(
                        color: Color(0xFF5C47CE),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            '🎯 클래식 오목',
            style: TextStyle(
              color: Color(0xFF5C47CE),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'SUIT',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '전통적인 흑백돌로\n순수한 실력 대결!',
            style: TextStyle(
              color: const Color(
                0xFF5C47CE,
              ).withOpacity(0.7),
              fontSize: 16,
              fontFamily: 'Pretendard',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDualPlayerCharacterSelection() {
    return Column(
      children: [
        // 플레이어 상태 표시
        _buildPlayerStatus(),

        const SizedBox(height: 16),

        // 캐릭터 그리드
        Expanded(child: _buildCharacterGrid()),
      ],
    );
  }

  Widget _buildPlayerStatus() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FEFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF51D4EB),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 흑돌 플레이어
          Expanded(
            child: _buildPlayerCard(
              PlayerType.black,
              _blackPlayerCharacter,
              '흑돌 플레이어',
              Colors.black,
            ),
          ),

          const SizedBox(width: 16),

          // VS 구분자
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF51D4EB),
              shape: BoxShape.circle,
            ),
            child: const Text(
              'VS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                fontFamily: 'SUIT',
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 백돌 플레이어
          Expanded(
            child: _buildPlayerCard(
              PlayerType.white,
              _whitePlayerCharacter,
              '백돌 플레이어',
              Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(
    PlayerType playerType,
    Character? character,
    String playerName,
    Color stoneColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: character != null
            ? character.tierColor.withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              character?.tierColor ?? Colors.grey,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 플레이어 이름
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.circle,
                color: stoneColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                playerName,
                style: const TextStyle(
                  color: Color(0xFF5C47CE),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SUIT',
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 캐릭터 정보
          if (character != null) ...[
            Container(
              width: 32,
              height: 32,
              child: Image.asset(
                _getCharacterImagePath(
                  character.type,
                ),
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) {
                      // 이미지 로딩 실패시 기존 아이콘으로 대체
                      return Icon(
                        _getCharacterIcon(
                          character.type,
                        ),
                        color:
                            character.tierColor,
                        size: 24,
                      );
                    },
              ),
            ),
            const SizedBox(height: 4),
            Text(
              character.koreanName,
              style: TextStyle(
                color: character.tierColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              character.skill.name,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ] else ...[
            Icon(
              Icons.person_outline,
              color: Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            const Text(
              '캐릭터 선택',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCharacterGrid() {
    final characters =
        CharacterService.getAllCharacters();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
        itemCount: characters.length,
        itemBuilder: (context, index) {
          final character = characters[index];
          final isBlackSelected =
              _blackPlayerCharacter?.type ==
              character.type;
          final isWhiteSelected =
              _whitePlayerCharacter?.type ==
              character.type;
          final isSelected =
              isBlackSelected || isWhiteSelected;

          return GestureDetector(
            onTap: () =>
                _selectCharacter(character),
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 200,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? [
                          character.tierColor
                              .withOpacity(0.8),
                          character.tierColor
                              .withOpacity(0.6),
                        ]
                      : [
                          const Color(0xFF16213E),
                          const Color(0xFF1A1A2E),
                        ],
                ),
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? character.tierColor
                      : Colors.grey.withOpacity(
                          0.3,
                        ),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: character
                              .tierColor
                              .withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  // 선택된 플레이어 표시
                  if (isSelected) ...[
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.9),
                        borderRadius:
                            BorderRadius.circular(
                              8,
                            ),
                      ),
                      child: Text(
                        isBlackSelected
                            ? '흑돌'
                            : '백돌',
                        style: TextStyle(
                          color: isBlackSelected
                              ? Colors.black
                              : Colors.black,
                          fontSize: 8,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],

                  // 캐릭터 이미지
                  Container(
                    width: 32,
                    height: 32,
                    child: Image.asset(
                      _getCharacterImagePath(
                        character.type,
                      ),
                      fit: BoxFit.contain,
                      color: isSelected
                          ? Colors.white
                                .withOpacity(0.9)
                          : null,
                      colorBlendMode: isSelected
                          ? BlendMode.modulate
                          : null,
                      errorBuilder:
                          (
                            context,
                            error,
                            stackTrace,
                          ) {
                            // 이미지 로딩 실패시 기존 아이콘으로 대체
                            return Icon(
                              _getCharacterIcon(
                                character.type,
                              ),
                              color: isSelected
                                  ? Colors.white
                                  : character
                                        .tierColor,
                              size: 24,
                            );
                          },
                    ),
                  ),

                  const SizedBox(height: 4),

                  // 캐릭터 이름
                  Text(
                    character.koreanName,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 2),

                  // 티어 표시
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                    decoration: BoxDecoration(
                      color: character.tierColor
                          .withOpacity(0.3),
                      borderRadius:
                          BorderRadius.circular(
                            4,
                          ),
                    ),
                    child: Text(
                      _getTierName(
                        character.tier,
                      ),
                      style: TextStyle(
                        color:
                            character.tierColor,
                        fontSize: 8,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _selectCharacter(Character character) {
    HapticFeedback.lightImpact();

    setState(() {
      // 이미 선택된 캐릭터면 해제
      if (_blackPlayerCharacter?.type ==
          character.type) {
        _blackPlayerCharacter = null;
      } else if (_whitePlayerCharacter?.type ==
          character.type) {
        _whitePlayerCharacter = null;
      } else {
        // 새로운 캐릭터 선택
        if (_blackPlayerCharacter == null) {
          _blackPlayerCharacter = character;
        } else if (_whitePlayerCharacter ==
            null) {
          _whitePlayerCharacter = character;
        } else {
          // 둘 다 선택되어 있으면 흑돌 플레이어를 새로 선택된 캐릭터로 교체
          _blackPlayerCharacter = character;
        }
      }
    });
  }

  String _getTierName(CharacterTier tier) {
    switch (tier) {
      case CharacterTier.heaven:
        return '천급';
      case CharacterTier.earth:
        return '지급';
      case CharacterTier.human:
        return '인급';
    }
  }

  Widget _buildStartButton() {
    final canStart =
        !_useCharacterStone ||
        (_blackPlayerCharacter != null &&
            _whitePlayerCharacter != null);

    return Container(
      padding: const EdgeInsets.all(20),
      child: VolumetricPlayButton(
        text: _useCharacterStone
            ? (_blackPlayerCharacter != null &&
                      _whitePlayerCharacter !=
                          null
                  ? '🚀 게임 시작!'
                  : '두 플레이어 모두 캐릭터를 선택하세요')
            : '🚀 게임 시작!',
        onPressed: canStart ? _startGame : () {},
        backgroundColor: canStart
            ? const Color(0xFF89E0F7)
            : const Color(
                0xFF8BBEDC,
              ).withOpacity(0.5),
        width: double.infinity,
        height: 56,
      ),
    );
  }

  void _startGame() {
    HapticFeedback.mediumImpact();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedGameScreen(
          boardSize: widget.boardSize,
          blackCharacter: _useCharacterStone
              ? _blackPlayerCharacter
              : null,
          whiteCharacter: _useCharacterStone
              ? _whitePlayerCharacter
              : null,
          isAIGame: widget.isAIGame,
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
        return '🐯';
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
        return '🐕';
      case CharacterType.pig:
        return '🐷';
    }
  }

  String _getCharacterImagePath(
    CharacterType type,
  ) {
    switch (type) {
      case CharacterType.rat:
        return 'assets/image/rat.png';
      case CharacterType.ox:
        return 'assets/image/ox.png';
      case CharacterType.tiger:
        return 'assets/image/tiger.png';
      case CharacterType.rabbit:
        return 'assets/image/rabbit.png';
      case CharacterType.dragon:
        return 'assets/image/dragon.png';
      case CharacterType.snake:
        return 'assets/image/snake.png';
      case CharacterType.horse:
        return 'assets/image/horse.png';
      case CharacterType.goat:
        return 'assets/image/goat.png';
      case CharacterType.monkey:
        return 'assets/image/monkey.png';
      case CharacterType.rooster:
        return 'assets/image/rooster.png';
      case CharacterType.dog:
        return 'assets/image/dog.png';
      case CharacterType.pig:
        return 'assets/image/pig.png';
    }
  }

  IconData _getCharacterIcon(CharacterType type) {
    switch (type) {
      case CharacterType.rat:
        return Icons.pets;
      case CharacterType.ox:
        return Icons.grass;
      case CharacterType.tiger:
        return Icons.flash_on;
      case CharacterType.rabbit:
        return Icons.eco;
      case CharacterType.dragon:
        return Icons.flare;
      case CharacterType.snake:
        return Icons.waves;
      case CharacterType.horse:
        return Icons.directions_run;
      case CharacterType.goat:
        return Icons.cloud;
      case CharacterType.monkey:
        return Icons.psychology;
      case CharacterType.rooster:
        return Icons.access_time;
      case CharacterType.dog:
        return Icons.shield;
      case CharacterType.pig:
        return Icons.savings;
    }
  }
}
