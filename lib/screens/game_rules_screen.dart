import 'package:flutter/material.dart';

import '../widgets/enhanced_visual_effects.dart';

class GameRulesScreen extends StatefulWidget {
  const GameRulesScreen({super.key});

  @override
  State<GameRulesScreen> createState() =>
      _GameRulesScreenState();
}

class _GameRulesScreenState
    extends State<GameRulesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 홈 화면 스타일의 Figma 버튼
  Widget _buildFigmaButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
    double width = 120,
    double fontSize = 16,
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
                      color,
                      color.withOpacity(0.7),
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
                onTap: onPressed,
                child: Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
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
                    '🎮',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '오목 게임 방법',
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(
                0.1,
              ),
              borderRadius: BorderRadius.circular(
                15,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(
                  0.3,
                ),
                width: 1,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white
                  .withOpacity(0.6),
              indicator: BoxDecoration(
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
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              indicatorPadding:
                  const EdgeInsets.all(4),
              labelStyle: const TextStyle(
                fontFamily: 'Cafe24Ohsquare',
                fontSize: 12,
                letterSpacing: -0.2,
              ),
              unselectedLabelStyle:
                  const TextStyle(
                    fontFamily: 'Cafe24Ohsquare',
                    fontSize: 12,
                    letterSpacing: -0.2,
                  ),
              tabs: const [
                Tab(
                  icon: Icon(
                    Icons.sports_esports,
                    size: 18,
                  ),
                  text: '기본 룰',
                ),
                Tab(
                  icon: Icon(
                    Icons.rule,
                    size: 18,
                  ),
                  text: '렌주 룰',
                ),
                Tab(
                  icon: Icon(
                    Icons.people,
                    size: 18,
                  ),
                  text: '캐릭터',
                ),
                Tab(
                  icon: Icon(
                    Icons.schedule,
                    size: 18,
                  ),
                  text: '타이머',
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicRules(),
          _buildRenjuRules(),
          _buildCharacterRules(),
          _buildTimerRules(),
        ],
      ),
    );
  }

  // 홈 화면 스타일의 규칙 카드
  Widget _buildRuleCard(
    String title,
    String content,
    Color accentColor, {
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // 타이틀 섹션
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.00, -1.00),
                end: Alignment(0, 1),
                colors: [
                  accentColor,
                  accentColor.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(
                10,
              ),
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cafe24Ohsquare',
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 내용 섹션
          Text(
            content,
            style: TextStyle(
              fontFamily: 'Cafe24Ohsquare',
              fontSize: 14,
              color: Colors.white.withOpacity(
                0.9,
              ),
              letterSpacing: -0.2,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 렌주 규칙 전용 카드
  Widget _buildRenjuCard(
    String title,
    String content,
    Color dangerColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: dangerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: dangerColor.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: dangerColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.00, -1.00),
                end: Alignment(0, 1),
                colors: [
                  dangerColor,
                  dangerColor.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(
                10,
              ),
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cafe24Ohsquare',
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'Cafe24Ohsquare',
              fontSize: 14,
              color: Colors.white.withOpacity(
                0.9,
              ),
              letterSpacing: -0.2,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicRules() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildRuleCard(
            '🎯 기본 목표',
            '가로, 세로, 대각선 중 하나의 방향으로 자신의 돌을 5개 연속으로 배치하면 승리합니다.',
            const Color(0xFF2196F3),
            icon: Icons.my_location,
          ),
          _buildRuleCard(
            '🏁 게임 진행',
            '''• 흑돌이 먼저 시작합니다
• 번갈아가며 한 수씩 돌을 놓습니다
• 한 번 놓인 돌은 옮길 수 없습니다
• 빈 교차점에만 돌을 놓을 수 있습니다''',
            const Color(0xFF4CAF50),
            icon: Icons.play_circle_outline,
          ),
          _buildRuleCard(
            '📏 바둑판 크기',
            '''• 13x13 (초급자용)
• 17x17 (중급자용)  
• 21x21 (고급자용)
홀수 보드로 명확한 중앙점과 대칭성을 제공합니다.''',
            const Color(0xFF9C27B0),
            icon: Icons.grid_view,
          ),
          _buildRuleCard(
            '⭐ 화점 (별점)',
            '''바둑판의 중요한 지점들을 표시하는 점입니다.
• 13x13: 중앙(6,6)과 8방향
• 17x17: 중앙(8,8)과 8방향
• 21x21: 중앙(10,10)과 8방향
홀수 보드로 완벽한 중앙 대칭을 이룹니다.''',
            const Color(0xFFFF9800),
            icon: Icons.star_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildRenjuRules() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // 렌주 룰 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(
              bottom: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.00, -1.00),
                end: Alignment(0, 1),
                colors: [
                  const Color(0xFFF44336),
                  const Color(
                    0xFFF44336,
                  ).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(
                15,
              ),
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFFF44336,
                  ).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 45,
                ),
                SizedBox(height: 12),
                Text(
                  '렌주 룰 (Renju Rule)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'Cafe24Ohsquare',
                    letterSpacing: -0.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  '흑돌에게만 적용되는 특별한 제한 규칙',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontFamily: 'Cafe24Ohsquare',
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          _buildRenjuCard(
            '❌ 3-3 금지',
            '''동시에 두 개의 열린 3을 만드는 것이 금지됩니다.
• 열린 3: 양쪽 끝이 모두 비어있는 3연속
• 예: _●●●_ 형태
• 3-3을 만들면 즉시 패배합니다''',
            const Color(0xFFF44336),
          ),
          _buildRenjuCard(
            '❌ 4-4 금지',
            '''동시에 두 개의 4를 만드는 것이 금지됩니다.
• 4: 막히지 않은 4연속
• 예: _●●●●_ 또는 ●●●●_ 형태
• 4-4를 만들면 즉시 패배합니다''',
            const Color(0xFFF44336),
          ),
          _buildRenjuCard(
            '❌ 장목 (6목 이상) 금지',
            '''6개 이상 연속으로 놓는 것이 금지됩니다.
• 6목, 7목, 8목 등은 모두 패배
• 정확히 5목만 승리 조건
• 장목을 만들면 즉시 패배합니다''',
            const Color(0xFFF44336),
          ),

          // 백돌 안내
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(
                0.1,
              ),
              borderRadius: BorderRadius.circular(
                12,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(
                  0.3,
                ),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '백돌은 렌주 룰 제약이 없어 자유롭게 플레이할 수 있습니다.',
                    style: TextStyle(
                      fontFamily:
                          'Cafe24Ohsquare',
                      fontSize: 14,
                      color: Colors.white
                          .withOpacity(0.9),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterRules() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildRuleCard(
            '🐯 호랑이',
            '''공격적이고 대담한 플레이 스타일을 상징합니다.
• 빠른 공격 패턴 선호
• 적극적인 수 읽기
• 강력한 마무리 능력''',
            const Color(0xFFFF9800),
            icon: Icons.flash_on,
          ),
          _buildRuleCard(
            '🐰 토끼',
            '''신중하고 전략적인 플레이 스타일을 상징합니다.
• 안정적인 방어 우선
• 치밀한 계산과 분석
• 끈기 있는 게임 운영''',
            const Color(0xFFE91E63),
            icon: Icons.shield_outlined,
          ),
          _buildRuleCard(
            '⚡ 스킬 시스템',
            '''각 캐릭터는 고유한 스킬을 보유합니다.
• 게임 중 1회 사용 가능
• 상황에 따른 전략적 활용
• 승부의 중요한 변수''',
            const Color(0xFF9C27B0),
            icon: Icons.auto_awesome,
          ),
        ],
      ),
    );
  }

  Widget _buildTimerRules() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildRuleCard(
            '⏱️ 총 지속시간',
            '''각 플레이어는 총 5분(300초)의 시간을 가집니다.
• 자신의 턴에서만 시간이 소모됩니다
• 총 시간이 모두 소진되면 패배
• 상대방 턴에는 시간이 정지됩니다''',
            const Color(0xFF2196F3),
            icon: Icons.timer,
          ),
          _buildRuleCard(
            '⚡ 턴별 제한',
            '''각 수마다 30초의 제한 시간이 있습니다.
• 30초 안에 수를 놓아야 합니다
• 시간 초과시 자동으로 패배
• 빠른 판단력이 필요합니다''',
            const Color(0xFFFF5722),
            icon: Icons.speed,
          ),
          _buildRuleCard(
            '🎯 시간 전략',
            '''시간 관리가 승부의 핵심입니다.
• 초반에는 빠르게, 종반에는 신중하게
• 상대방의 시간도 고려한 플레이
• 심리전의 중요한 요소''',
            const Color(0xFF4CAF50),
            icon: Icons.psychology,
          ),

          // 하단 버튼
          const SizedBox(height: 20),
          Center(
            child: _buildFigmaButton(
              text: '게임 시작하기',
              color: const Color(0xFF4CAF50),
              onPressed: () =>
                  Navigator.of(context).pop(),
              width: 200,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
