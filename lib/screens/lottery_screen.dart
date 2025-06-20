import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/lottery_system.dart';
import '../widgets/scratch_card_widget.dart';
import '../widgets/reward_popup_widget.dart';
import '../widgets/enhanced_visual_effects.dart';
import '../core/constants/index.dart';

class LotteryScreen extends StatefulWidget {
  const LotteryScreen({Key? key})
    : super(key: key);

  @override
  State<LotteryScreen> createState() =>
      _LotteryScreenState();
}

class _LotteryScreenState
    extends State<LotteryScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  PlayerLotteryData playerData =
      PlayerLotteryData(
        totalCoins: 1500,
        ownedTickets: {
          'bronze_ticket': 3,
          'silver_ticket': 1,
          'gold_ticket': 0,
        },
      );

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _backgroundAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _backgroundController,
            curve: Curves.linear,
          ),
        );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
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

  void _useLotteryTicket(LotteryTicket ticket) {
    if (!playerData.canUseTicket(ticket.id)) {
      _showMessage('복권이 부족합니다! 🎫');
      return;
    }

    // 복권 긁기 화면으로 이동
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (
              context,
              animation,
              secondaryAnimation,
            ) => ScratchCardScreen(
              ticket: ticket,
              onComplete: (reward) {
                setState(() {
                  playerData = playerData
                      .useTicket(
                        ticket.id,
                        reward,
                      );
                });
                _showRewardPopup(reward);
              },
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
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
      ),
    );
  }

  void _buyLotteryTicket(LotteryTicket ticket) {
    if (playerData.totalCoins < ticket.cost) {
      _showMessage('코인이 부족합니다! 💰');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20,
            ),
            side: const BorderSide(
              color: Colors.white,
              width: 2,
            ),
          ),
          title: Text(
            '${ticket.name} 구매',
            style: TextStyle(
              fontFamily: 'Cafe24Ohsquare',
              fontSize: 20,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            '${ticket.cost} 코인으로 ${ticket.name}을 구매하시겠습니까?',
            style: TextStyle(
              fontFamily: 'Cafe24Ohsquare',
              fontSize: 16,
              color: Colors.white.withOpacity(
                0.9,
              ),
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
              children: [
                _buildFigmaButton(
                  text: '취소',
                  color: const Color(0xFF757575),
                  onPressed: () =>
                      Navigator.of(context).pop(),
                  width: 80,
                  fontSize: 14,
                ),
                _buildFigmaButton(
                  text: '구매',
                  color: const Color(0xFF4CAF50),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      playerData = playerData
                          .buyTicket(
                            ticket.id,
                            ticket.cost,
                          );
                    });
                    _showMessage(
                      '${ticket.name}을 구매했습니다! 🎉',
                    );
                  },
                  width: 80,
                  fontSize: 14,
                ),
              ],
            ),
          ],
          actionsPadding: const EdgeInsets.all(
            16,
          ),
        );
      },
    );
  }

  void _getFreeTicket() {
    if (!playerData.canGetFreeTicket()) {
      _showMessage('24시간마다 무료 복권을 받을 수 있습니다! ⏰');
      return;
    }

    setState(() {
      playerData = playerData.getFreeTicket();
    });
    _showMessage('무료 동 복권을 받았습니다! 🎁');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            color: Colors.white,
            letterSpacing: -0.2,
          ),
        ),
        backgroundColor: const Color(0xFFFFC107),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showRewardPopup(LotteryReward reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RewardPopupWidget(reward: reward);
      },
    );
  }

  Widget _buildTicketCard(LotteryTicket ticket) {
    final owned =
        playerData.ownedTickets[ticket.id] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // 헤더 섹션
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(
                    16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(
                        0.00,
                        -1.00,
                      ),
                      end: Alignment(0, 1),
                      colors: [
                        ticket.primaryColor,
                        ticket.primaryColor
                            .withOpacity(0.7),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    ticket.icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily:
                              'Cafe24Ohsquare',
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticket.description,
                        style: TextStyle(
                          color: Colors.white
                              .withOpacity(0.8),
                          fontSize: 14,
                          fontFamily:
                              'Cafe24Ohsquare',
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // 보유 개수 표시
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(
                        0.00,
                        -1.00,
                      ),
                      end: Alignment(0, 1),
                      colors: [
                        const Color(0xFFFFC107),
                        const Color(
                          0xFFFFC107,
                        ).withOpacity(0.7),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '보유: $owned개',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily:
                          'Cafe24Ohsquare',
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 정보 섹션
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(
                  0.1,
                ),
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(
                    0.2,
                  ),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      Text(
                        '💰 가격',
                        style: TextStyle(
                          color: Colors.white
                              .withOpacity(0.9),
                          fontSize: 14,
                          fontFamily:
                              'Cafe24Ohsquare',
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        '${ticket.cost} 코인',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily:
                              'Cafe24Ohsquare',
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      Text(
                        '🎯 당첨 확률',
                        style: TextStyle(
                          color: Colors.white
                              .withOpacity(0.9),
                          fontSize: 14,
                          fontFamily:
                              'Cafe24Ohsquare',
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        '높은 확률',
                        style: TextStyle(
                          color: const Color(
                            0xFF4CAF50,
                          ),
                          fontSize: 14,
                          fontFamily:
                              'Cafe24Ohsquare',
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 버튼 섹션
            Row(
              children: [
                Expanded(
                  child: _buildFigmaButton(
                    text: '복권 긁기',
                    color: ticket.primaryColor,
                    onPressed: () =>
                        _useLotteryTicket(ticket),
                    isEnabled: owned > 0,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFigmaButton(
                    text: '구매하기',
                    color: const Color(
                      0xFF4CAF50,
                    ),
                    onPressed: () =>
                        _buyLotteryTicket(ticket),
                    isEnabled:
                        playerData.totalCoins >=
                        ticket.cost,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tickets = [
      // 임시 복권 데이터
    ];

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
                    '🎫',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '복권 상점',
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
      body: Column(
        children: [
          // 코인 및 상태 표시
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
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
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.3,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
              children: [
                // 보유 코인
                Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.all(
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
                            const Color(
                              0xFFFFC107,
                            ),
                            const Color(
                              0xFFFFC107,
                            ).withOpacity(0.7),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.monetization_on,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${playerData.totalCoins}',
                      style: TextStyle(
                        fontFamily:
                            'Cafe24Ohsquare',
                        fontSize: 18,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      '코인',
                      style: TextStyle(
                        fontFamily:
                            'Cafe24Ohsquare',
                        fontSize: 12,
                        color: Colors.white
                            .withOpacity(0.8),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),

                // 무료 복권 버튼
                Column(
                  children: [
                    _buildFigmaButton(
                      text: '무료 복권',
                      color: const Color(
                        0xFF4CAF50,
                      ),
                      onPressed: _getFreeTicket,
                      width: 100,
                      fontSize: 14,
                      isEnabled: playerData
                          .canGetFreeTicket(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      playerData
                              .canGetFreeTicket()
                          ? '사용 가능'
                          : '24시간 대기',
                      style: TextStyle(
                        fontFamily:
                            'Cafe24Ohsquare',
                        fontSize: 10,
                        color:
                            playerData
                                .canGetFreeTicket()
                            ? const Color(
                                0xFF4CAF50,
                              )
                            : Colors.white
                                  .withOpacity(
                                    0.6,
                                  ),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),

                // 총 복권 수
                Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.all(
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
                            const Color(
                              0xFF2196F3,
                            ),
                            const Color(
                              0xFF2196F3,
                            ).withOpacity(0.7),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.confirmation_number,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${playerData.ownedTickets.values.fold(0, (sum, count) => sum + count)}',
                      style: TextStyle(
                        fontFamily:
                            'Cafe24Ohsquare',
                        fontSize: 18,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      '총 복권',
                      style: TextStyle(
                        fontFamily:
                            'Cafe24Ohsquare',
                        fontSize: 12,
                        color: Colors.white
                            .withOpacity(0.8),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 복권 리스트
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(
                bottom: 20,
              ),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                return _buildTicketCard(
                  tickets[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
