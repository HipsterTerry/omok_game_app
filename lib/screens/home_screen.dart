import 'package:flutter/material.dart';
import 'character_selection_screen.dart';
import 'lottery_screen.dart';
import 'game_rules_screen.dart';
import 'enhanced_game_screen.dart';

import '../models/player_profile.dart';
import '../logic/ai_player.dart';
import '../models/game_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(
                    context,
                  ).size.height -
                  MediaQuery.of(
                    context,
                  ).padding.top -
                  MediaQuery.of(
                    context,
                  ).padding.bottom,
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                SizedBox(height: 10), // 상단 여백 줄임
                // 캐릭터 로고 + 타이틀 (Stack으로 겹치게 배치)
                Container(
                  width: 305,
                  height:
                      265, // 높이를 늘려서 로고가 잘리지 않게
                  child: Stack(
                    children: [
                      // 캐릭터 이미지 (위쪽 잘림 방지)
                      Positioned(
                        top: 0, // 위쪽 여백 확보
                        left: 0,
                        child: Container(
                          width: 305,
                          height:
                              210, // 이미지 높이 조정
                          child: Image.asset(
                            'assets/image/home_logo.png',
                            fit: BoxFit.cover,
                            errorBuilder:
                                (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  // 이미지 로드 실패시 이모지 캐릭터 표시
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Container(
                                        width:
                                            100,
                                        height:
                                            100,
                                        decoration: BoxDecoration(
                                          color: Colors
                                              .orange
                                              .shade300,
                                          borderRadius:
                                              BorderRadius.circular(
                                                50,
                                              ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '🐯',
                                            style: TextStyle(
                                              fontSize:
                                                  50,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 30,
                                      ),
                                      Container(
                                        width:
                                            100,
                                        height:
                                            100,
                                        decoration: BoxDecoration(
                                          color: Colors
                                              .pink
                                              .shade100,
                                          borderRadius:
                                              BorderRadius.circular(
                                                50,
                                              ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '🐰',
                                            style: TextStyle(
                                              fontSize:
                                                  50,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                          ),
                        ),
                      ),

                      // 타이틀 텍스트 (위치 그대로 유지)
                      Positioned(
                        bottom: 0, // 컨테이너 하단에서
                        left: 0,
                        right: 0,
                        child: Text(
                          'Omok Arena',
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 44,
                            fontFamily:
                                'Cafe24Ohsquare',
                            height:
                                0, // Figma 스타일 - 텍스트를 이미지와 더 가깝게
                            letterSpacing: -0.66,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                // AI 연습게임 버튼
                _buildFigmaButton(
                  context,
                  text: 'AI 연습게임',
                  color: Color(0xFF2196F3),
                  onPressed: () =>
                      _showBoardSizeDialog(
                        context,
                        isAI: true,
                      ),
                ),

                SizedBox(height: 18), // 간격 줄임
                // 2인 플레이 버튼
                _buildFigmaButton(
                  context,
                  text: '2인 플레이',
                  color: Color(0xFFFF9800),
                  onPressed: () =>
                      _showBoardSizeDialog(
                        context,
                        isAI: false,
                      ),
                ),

                SizedBox(height: 18), // 간격 줄임
                // 온라인 플레이 버튼
                _buildFigmaButton(
                  context,
                  text: '온라인 플레이',
                  color: Color(0xFFF44336),
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '온라인 플레이 기능 개발 중입니다!',
                        ),
                        duration: Duration(
                          seconds: 2,
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 20), // 간격 줄임
                // 하단 작은 버튼들 (메인 버튼과 너비 맞춤)
                Container(
                  width: 250, // 메인 버튼과 동일한 너비
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween, // 양쪽 끝에 배치
                    children: [
                      _buildFigmaSmallButton(
                        context,
                        text: '규칙설명',
                        color: Color(0xFFFFC107),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const GameRulesScreen(),
                            ),
                          );
                        },
                      ),

                      _buildFigmaSmallButton(
                        context,
                        text: '복권/상점',
                        color: Color(0xFFFFC107),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const LotteryScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20), // 간격 줄임
                // 버전 정보
                SizedBox(
                  width: 175,
                  height: 30,
                  child: Text(
                    'Omok Arena v 1.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily:
                          'Cafe24Ohsquare',
                      height: 0,
                      letterSpacing: -0.23,
                    ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Figma 스타일의 메인 버튼 (정확한 복사)
  Widget _buildFigmaButton(
    BuildContext context, {
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 250,
      height: 48,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 250,
              height: 48,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 3,
                    strokeAlign: BorderSide
                        .strokeAlignOutside,
                    color: Color(0x590A0A0A),
                  ),
                  borderRadius:
                      BorderRadius.circular(24),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 5,
                    offset: Offset(0, 1),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Color(0x1E000000),
                    blurRadius: 4,
                    offset: Offset(0, 3),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Color(0x23000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 250,
                      height: 48,
                      decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(
                            0.00,
                            -1.00,
                          ),
                          end: Alignment(0, 1),
                          colors: [
                            color,
                            color.withOpacity(
                              0.7,
                            ),
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 6,
                            color: Colors.white,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                                24,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 10, // 텍스트 영역을 더 넓게
            top: 5,
            right: 10, // 오른쪽 여백도 확보
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(
                vertical: 3,
              ),
              child: GestureDetector(
                onTap: onPressed,
                child: Center(
                  // Row 대신 Center 사용
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    maxLines: 1, // 한 줄로 제한
                    overflow: TextOverflow
                        .ellipsis, // 넘치면 ... 표시
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          22, // 크기를 25에서 22로 줄임
                      fontFamily:
                          'Cafe24Ohsquare',
                      height: 0,
                      letterSpacing:
                          -0.30, // 글자 간격 조정
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Figma 스타일의 작은 버튼 (메인 버튼과 규격 맞춤)
  Widget _buildFigmaSmallButton(
    BuildContext context, {
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width:
          105, // 크기를 110에서 105로 조정 (250px 컨테이너에 양쪽 배치)
      height: 48,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 105, // 크기를 110에서 105로 조정
              height: 48,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 3,
                    strokeAlign: BorderSide
                        .strokeAlignOutside,
                    color: Color(0x590A0A0A),
                  ),
                  borderRadius:
                      BorderRadius.circular(24),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 5,
                    offset: Offset(0, 1),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Color(0x1E000000),
                    blurRadius: 4,
                    offset: Offset(0, 3),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Color(0x23000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width:
                          105, // 크기를 110에서 105로 조정
                      height: 48,
                      decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(
                            0.00,
                            -1.00,
                          ),
                          end: Alignment(0, 1),
                          colors: [
                            color,
                            color.withOpacity(
                              0.7,
                            ),
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 6,
                            color: Colors.white,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                                24,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 5, // 텍스트 영역 조정
            top: 5,
            right: 5, // 텍스트 영역 조정
            child: Container(
              height: 38,
              padding: const EdgeInsets.only(
                top: 7,
                bottom: 6,
              ),
              child: GestureDetector(
                onTap: onPressed,
                child: Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow:
                        TextOverflow.visible,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          16, // 크기를 17에서 16으로 조정 (105px에 맞춤)
                      fontFamily:
                          'Cafe24Ohsquare',
                      height: 0,
                      letterSpacing:
                          -0.25, // 글자 간격 조정
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBoardSizeDialog(
    BuildContext context, {
    bool isAI = false,
    AIDifficulty? aiDifficulty,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 2,
          ),
        ),
        title: Text(
          '🎯 보드 크기 선택',
          style: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '게임할 보드 크기를 선택하세요:',
              style: TextStyle(
                fontFamily: 'SUIT',
                color: Colors.white.withOpacity(
                  0.8,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...BoardSize.values.map(
              (size) => Card(
                color: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                  side: BorderSide(
                    color: Colors.white
                        .withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    _getBoardSizeIcon(size),
                    color: _getBoardSizeColor(
                      size,
                    ),
                  ),
                  title: Text(
                    size.description,
                    style: TextStyle(
                      fontFamily: 'SUIT',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${size.size}x${size.size} 보드',
                    style: TextStyle(
                      fontFamily: 'SUIT',
                      color: Colors.white
                          .withOpacity(0.7),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _startGame(
                      context,
                      size,
                      isAI: isAI,
                      aiDifficulty: aiDifficulty,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
            onPressed: () =>
                Navigator.of(context).pop(),
            child: const Text(
              '취소',
              style: TextStyle(
                fontFamily: 'SUIT',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getBoardSizeIcon(BoardSize size) {
    switch (size) {
      case BoardSize.small:
        return Icons.grid_3x3;
      case BoardSize.medium:
        return Icons.grid_4x4;
      case BoardSize.large:
        return Icons.apps;
    }
  }

  Color _getBoardSizeColor(BoardSize size) {
    switch (size) {
      case BoardSize.small:
        return Colors.green;
      case BoardSize.medium:
        return Colors.orange;
      case BoardSize.large:
        return Colors.red;
    }
  }

  void _startGame(
    BuildContext context,
    BoardSize boardSize, {
    bool isAI = false,
    AIDifficulty? aiDifficulty,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedGameScreen(
          boardSize: boardSize,
          isAIGame: isAI,
          aiDifficulty:
              aiDifficulty ?? AIDifficulty.normal,
        ),
      ),
    );
  }
}
