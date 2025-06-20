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

  // 홈 화면 스타일의 Figma 버튼
  Widget _buildFigmaButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
    double width = 120,
    double fontSize = 16,
    bool isEnabled = true,
    String? emoji,
  }) {
    return Container(
      width: width,
      height: 45,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: width,
              height: 45,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 2,
                    strokeAlign: BorderSide
                        .strokeAlignOutside,
                    color: Color(0x590A0A0A),
                  ),
                  borderRadius:
                      BorderRadius.circular(22),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Container(
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.00, -1.00),
                    end: Alignment(0, 1),
                    colors: [
                      isEnabled
                          ? color
                          : Colors.grey,
                      isEnabled
                          ? color.withOpacity(0.7)
                          : Colors.grey
                                .withOpacity(0.7),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 4,
                      color: Colors.white,
                    ),
                    borderRadius:
                        BorderRadius.circular(22),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 8,
            top: 5,
            right: 8,
            child: Container(
              height: 35,
              child: GestureDetector(
                onTap: isEnabled
                    ? onPressed
                    : null,
                child: Center(
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      if (emoji != null) ...[
                        Text(
                          emoji,
                          style: TextStyle(
                            fontSize: fontSize,
                          ),
                        ),
                        SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          text,
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                            fontFamily:
                                'Cafe24Ohsquare',
                            height: 0,
                            letterSpacing: -0.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black, // 홈 화면과 동일한 검은색 배경
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () =>
              Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.00, -1.00),
                  end: Alignment(0, 1),
                  colors: [
                    const Color(0xFFFFC107),
                    const Color(
                      0xFFFFC107,
                    ).withOpacity(0.7),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🎭',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '캐릭터 선택',
                    style: TextStyle(
                      fontFamily:
                          'Cafe24Ohsquare',
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 홈 스타일 헤더
            _buildFigmaHeader(),

            // 보드 크기 정보
            _buildBoardSizeInfo(),

            // 돌 타입 선택 토글
            _buildFigmaStoneToggle(),

            // 캐릭터 선택 영역
            Expanded(
              child: _useCharacterStone
                  ? _buildFigmaCharacterSelection()
                  : _buildFigmaStonePreview(),
            ),

            // 시작 버튼
            _buildFigmaStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFigmaHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 캐릭터 아이콘들
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              _buildFigmaCharacterIcon(
                '🐯',
                const Color(0xFFFF9800),
              ),
              const SizedBox(width: 12),
              _buildFigmaCharacterIcon(
                '🐰',
                const Color(0xFFE91E63),
              ),
              const SizedBox(width: 12),
              _buildFigmaCharacterIcon(
                '🐲',
                const Color(0xFF9C27B0),
              ),
              const SizedBox(width: 12),
              _buildFigmaCharacterIcon(
                '🐭',
                const Color(0xFF2196F3),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _useCharacterStone
                ? '두 플레이어 모두 캐릭터를 선택하세요!'
                : '기본 흑백돌로 클래식하게 플레이하세요!',
            style: TextStyle(
              color: Colors.white.withOpacity(
                0.9,
              ),
              fontSize: 16,
              fontFamily: 'Cafe24Ohsquare',
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFigmaCharacterIcon(
    String emoji,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.00, -1.00),
          end: Alignment(0, 1),
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Text(
        emoji,
        style: TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildBoardSizeInfo() {
    String boardText = '';
    Color boardColor = const Color(0xFF2196F3);

    switch (widget.boardSize) {
      case BoardSize.small:
        boardText = '13x13 (초급자용)';
        boardColor = const Color(0xFF4CAF50);
        break;
      case BoardSize.medium:
        boardText = '17x17 (중급자용)';
        boardColor = const Color(0xFFF44336);
        break;
      case BoardSize.large:
        boardText = '21x21 (고급자용)';
        boardColor = const Color(0xFF9C27B0);
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.00, -1.00),
          end: Alignment(0, 1),
          colors: [
            boardColor,
            boardColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.grid_view,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            '바둑판 크기: $boardText',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Cafe24Ohsquare',
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFigmaStoneToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
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
                  gradient: !_useCharacterStone
                      ? LinearGradient(
                          begin: Alignment(
                            0.00,
                            -1.00,
                          ),
                          end: Alignment(0, 1),
                          colors: [
                            const Color(
                              0xFF2196F3,
                            ),
                            const Color(
                              0xFF2196F3,
                            ).withOpacity(0.7),
                          ],
                        )
                      : null,
                  borderRadius:
                      BorderRadius.circular(12),
                  border: !_useCharacterStone
                      ? Border.all(
                          color: Colors.white,
                          width: 2,
                        )
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '기본 돌',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily:
                            'Cafe24Ohsquare',
                        letterSpacing: -0.2,
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
                  gradient: _useCharacterStone
                      ? LinearGradient(
                          begin: Alignment(
                            0.00,
                            -1.00,
                          ),
                          end: Alignment(0, 1),
                          colors: [
                            const Color(
                              0xFFFF9800,
                            ),
                            const Color(
                              0xFFFF9800,
                            ).withOpacity(0.7),
                          ],
                        )
                      : null,
                  borderRadius:
                      BorderRadius.circular(12),
                  border: _useCharacterStone
                      ? Border.all(
                          color: Colors.white,
                          width: 2,
                        )
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      '🎭',
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '캐릭터 돌',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily:
                            'Cafe24Ohsquare',
                        letterSpacing: -0.2,
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

  Widget _buildFigmaStonePreview() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.00, -1.00),
                end: Alignment(0, 1),
                colors: [
                  const Color(0xFF2196F3),
                  const Color(
                    0xFF2196F3,
                  ).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(
                15,
              ),
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.games,
              color: Colors.white,
              size: 64,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '클래식 오목',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'Cafe24Ohsquare',
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '전통적인 흑백돌로 진행되는\n정통 오목 게임을 즐기세요',
            style: TextStyle(
              color: Colors.white.withOpacity(
                0.8,
              ),
              fontSize: 16,
              fontFamily: 'Cafe24Ohsquare',
              letterSpacing: -0.3,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'VS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Cafe24Ohsquare',
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFigmaCharacterSelection() {
    final characters =
        CharacterService.getAllCharacters();

    return Column(
      children: [
        // 플레이어 1 (흑돌)
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(
              15,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(
                0.3,
              ),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                '플레이어 1 (흑돌)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Cafe24Ohsquare',
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              if (_blackPlayerCharacter != null)
                Container(
                  padding: const EdgeInsets.all(
                    12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(
                        0.00,
                        -1.00,
                      ),
                      end: Alignment(0, 1),
                      colors: [
                        const Color(0xFF424242),
                        const Color(
                          0xFF424242,
                        ).withOpacity(0.7),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '🐯',
                    style: TextStyle(
                      fontSize: 32,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              _buildFigmaButton(
                text:
                    _blackPlayerCharacter?.name ??
                    '캐릭터 선택',
                color: const Color(0xFF424242),
                onPressed: () =>
                    _selectCharacter(true),
                width: 150,
                fontSize: 14,
              ),
            ],
          ),
        ),

        // 플레이어 2 (백돌)
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(
              15,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(
                0.3,
              ),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                widget.isAIGame
                    ? 'AI 플레이어 (백돌)'
                    : '플레이어 2 (백돌)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Cafe24Ohsquare',
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              if (_whitePlayerCharacter != null)
                Container(
                  padding: const EdgeInsets.all(
                    12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(
                        0.00,
                        -1.00,
                      ),
                      end: Alignment(0, 1),
                      colors: [
                        const Color(0xFFE0E0E0),
                        const Color(
                          0xFFE0E0E0,
                        ).withOpacity(0.7),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '🐰',
                    style: TextStyle(
                      fontSize: 32,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              _buildFigmaButton(
                text:
                    _whitePlayerCharacter?.name ??
                    '캐릭터 선택',
                color: const Color(0xFFE0E0E0),
                onPressed: () =>
                    _selectCharacter(false),
                width: 150,
                fontSize: 14,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFigmaStartButton() {
    bool canStart =
        !_useCharacterStone ||
        (_blackPlayerCharacter != null &&
            _whitePlayerCharacter != null);

    return Container(
      margin: const EdgeInsets.all(16),
      child: _buildFigmaButton(
        text: '게임 시작하기',
        color: const Color(0xFF4CAF50),
        onPressed: canStart ? _startGame : () {},
        width: double.infinity,
        fontSize: 18,
        isEnabled: canStart,
        emoji: '🚀',
      ),
    );
  }

  void _selectCharacter(bool isBlackPlayer) {
    // 캐릭터 선택 로직
    final characters =
        CharacterService.getAllCharacters();
    if (characters.isNotEmpty) {
      setState(() {
        if (isBlackPlayer) {
          _blackPlayerCharacter =
              characters.first;
        } else {
          _whitePlayerCharacter = characters.last;
        }
      });
    }
  }

  void _startGame() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder:
            (
              context,
              animation,
              secondaryAnimation,
            ) => EnhancedGameScreen(
              boardSize: widget.boardSize,
              blackCharacter: _useCharacterStone
                  ? _blackPlayerCharacter
                  : null,
              whiteCharacter: _useCharacterStone
                  ? _whitePlayerCharacter
                  : null,
              isAIGame: widget.isAIGame,
            ),
        transitionDuration: const Duration(
          milliseconds: 600,
        ),
        transitionsBuilder:
            (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
      ),
    );
  }
}
