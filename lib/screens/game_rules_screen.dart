import 'package:flutter/material.dart';
import '../theme/omok_arena_theme.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFFBFF),
      appBar: AppBar(
        title: const Text(
          '🎮 오목 게임 방법',
          style: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C47CE),
          ),
        ),
        backgroundColor: const Color(0xFF89E0F7),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF5C47CE),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF5C47CE),
          unselectedLabelColor: const Color(
            0xFF5C47CE,
          ).withOpacity(0.6),
          indicatorColor: const Color(0xFF51D4EB),
          labelStyle: const TextStyle(
            fontFamily: 'SUIT',
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.sports_esports),
              text: '기본 룰',
            ),
            Tab(
              icon: Icon(Icons.rule),
              text: '렌주 룰',
            ),
            Tab(
              icon: Icon(Icons.people),
              text: '캐릭터',
            ),
            Tab(
              icon: Icon(Icons.schedule),
              text: '타이머',
            ),
          ],
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
            Colors.blue,
          ),
          _buildRuleCard(
            '🏁 게임 진행',
            '''• 흑돌이 먼저 시작합니다
• 번갈아가며 한 수씩 돌을 놓습니다
• 한 번 놓인 돌은 옮길 수 없습니다
• 빈 교차점에만 돌을 놓을 수 있습니다''',
            Colors.green,
          ),
          _buildRuleCard(
            '📏 바둑판 크기',
            '''• 13x13 (초급자용)
• 17x17 (중급자용)  
• 21x21 (고급자용)
홀수 보드로 명확한 중앙점과 대칭성을 제공합니다.''',
            Colors.purple,
          ),
          _buildRuleCard(
            '⭐ 화점 (별점)',
            '''바둑판의 중요한 지점들을 표시하는 점입니다.
• 13x13: 중앙(6,6)과 8방향
• 17x17: 중앙(8,8)과 8방향
• 21x21: 중앙(10,10)과 8방향
홀수 보드로 완벽한 중앙 대칭을 이룹니다.''',
            Colors.orange,
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red[400]!,
                  Colors.red[600]!,
                ],
              ),
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(height: 8),
                Text(
                  '렌주 룰 (Renju Rule)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '흑돌에게만 적용되는 특별한 제한 규칙',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildRenjuCard(
            '❌ 3-3 금지',
            '''동시에 두 개의 열린 3을 만드는 것이 금지됩니다.
• 열린 3: 양쪽 끝이 모두 비어있는 3연속
• 예: _●●●_ 형태
• 3-3을 만들면 즉시 패배합니다''',
            Colors.red[600]!,
          ),
          _buildRenjuCard(
            '❌ 4-4 금지',
            '''동시에 두 개의 4를 만드는 것이 금지됩니다.
• 4: 막히지 않은 4연속
• 예: _●●●●_ 또는 ●●●●_ 형태
• 4-4를 만들면 즉시 패배합니다''',
            Colors.red[600]!,
          ),
          _buildRenjuCard(
            '❌ 장목 금지',
            '''6개 이상 연속으로 배치하는 것이 금지됩니다.
• 6목, 7목, 8목 등 모두 패배
• 정확히 5목만 승리 조건입니다
• 장목을 만들면 즉시 패배합니다''',
            Colors.red[600]!,
          ),
          _buildRenjuCard(
            '✅ 백돌 자유',
            '''백돌은 렌주룰의 제한을 받지 않습니다.
• 3-3, 4-4, 장목 모두 가능
• 6목 이상도 승리로 인정
• 흑돌보다 유리한 조건''',
            Colors.green[600]!,
          ),

          Container(
            margin: const EdgeInsets.only(
              top: 16,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(
                8,
              ),
              border: Border.all(
                color: Colors.yellow[600]!,
              ),
            ),
            child: const Text(
              '💡 렌주룰의 목적: 선공의 이점을 가진 흑돌에게 제한을 두어 게임의 균형을 맞추는 것입니다.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
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
            '🐲 12간지 캐릭터',
            '''쥐, 소, 호랑이, 토끼, 용, 뱀, 말, 양, 원숭이, 닭, 개, 돼지
각 캐릭터마다 고유한 스킬과 특성을 가지고 있습니다.''',
            Colors.purple,
          ),
          _buildTierCard(
            '천급 (天級)',
            '15% 승률 보너스',
            '용, 호랑이, 원숭이',
            Colors.amber[700]!,
            Icons.star,
          ),
          _buildTierCard(
            '지급 (地級)',
            '8-10% 승률 보너스',
            '말, 뱀, 개, 닭',
            Colors.grey[600]!,
            Icons.circle,
          ),
          _buildTierCard(
            '인급 (人級)',
            '2-4% 승률 보너스',
            '쥐, 소, 토끼, 양, 돼지',
            Colors.brown[600]!,
            Icons.person,
          ),
          _buildRuleCard(
            '⚡ 스킬 시스템',
            '''• 공격형: 공격력 증가 스킬
• 방어형: 방어력 증가 스킬  
• 방해형: 상대방을 방해하는 스킬
• 시간형: 시간 관련 스킬
각 게임당 1회만 사용 가능합니다.''',
            Colors.red,
          ),
          _buildRuleCard(
            '🎰 뽑기 시스템',
            '''• 브론즈 티켓: 인급 캐릭터 위주
• 실버 티켓: 지급 캐릭터 포함
• 골드 티켓: 천급 캐릭터 확률 증가
매일 무료 뽑기 기회가 주어집니다.''',
            Colors.blue,
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
            '⏰ 이중 타이머 시스템',
            '''게임에는 두 가지 시간 제한이 있습니다:
• 전체 게임 시간: 5분
• 1수 제한 시간: 30초''',
            Colors.blue,
          ),
          _buildRuleCard(
            '🎯 전체 게임 시간',
            '''• 각 플레이어마다 총 5분의 시간이 주어집니다
• 자신의 차례일 때만 시간이 차감됩니다
• 전체 시간이 0이 되면 시간 초과로 패배합니다
• 상단 프로그레스 바로 남은 시간을 확인할 수 있습니다''',
            Colors.green,
          ),
          _buildRuleCard(
            '⚡ 1수 제한 시간',
            '''• 매 턴마다 30초의 시간이 주어집니다
• 30초 안에 돌을 놓지 않으면 시간 초과로 패배합니다
• 턴이 바뀔 때마다 30초로 초기화됩니다
• 원형 프로그레스로 남은 시간을 확인할 수 있습니다''',
            Colors.orange,
          ),
          _buildRuleCard(
            '⚠️ 경고 시스템',
            '''• 1수 시간이 10초 이하일 때 빨간색으로 변합니다
• 전체 시간이 30초 이하일 때 경고 애니메이션이 작동합니다
• 타이머가 깜빡이며 긴급 상황을 알려줍니다''',
            Colors.red,
          ),
          Container(
            margin: const EdgeInsets.only(
              top: 16,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(
                8,
              ),
              border: Border.all(
                color: Colors.blue[600]!,
              ),
            ),
            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 타이머 전략 팁',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• 초반에는 신중하게, 후반에는 빠르게\n• 중요한 수일 때는 시간을 충분히 활용\n• 상대방의 시간도 주시하세요\n• 시간 압박을 이용한 심리전도 가능',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(
    String title,
    String content,
    Color color,
  ) {
    return CloudContainer(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              borderRadius:
                  const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'SUIT',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF5C47CE),
                fontFamily: 'Pretendard',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRenjuCard(
    String title,
    String content,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'SUIT',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF5C47CE),
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard(
    String tier,
    String bonus,
    String characters,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  tier,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  bonus,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  characters,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
