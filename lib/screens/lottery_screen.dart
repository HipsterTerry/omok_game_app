import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/lottery_system.dart';
import '../widgets/scratch_card_widget.dart';
import '../widgets/reward_popup_widget.dart';
import '../widgets/enhanced_visual_effects.dart';

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

  void _useLotteryTicket(LotteryTicket ticket) {
    if (!playerData.canUseTicket(ticket.id)) {
      _showMessage('복권이 부족합니다!');
      return;
    }

    // 복권 긁기 화면으로 이동
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScratchCardScreen(
          ticket: ticket,
          onComplete: (reward) {
            setState(() {
              playerData = playerData.useTicket(
                ticket.id,
                reward,
              );
            });
            _showRewardPopup(reward);
          },
        ),
      ),
    );
  }

  void _buyLotteryTicket(LotteryTicket ticket) {
    if (playerData.totalCoins < ticket.cost) {
      _showMessage('코인이 부족합니다!');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${ticket.name} 구매'),
          content: Text(
            '${ticket.cost} 코인으로 ${ticket.name}을 구매하시겠습니까?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () =>
                  Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('구매'),
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
                  '${ticket.name}을 구매했습니다!',
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _getFreeTicket() {
    if (!playerData.canGetFreeTicket()) {
      _showMessage('24시간마다 무료 복권을 받을 수 있습니다!');
      return;
    }

    setState(() {
      playerData = playerData.getFreeTicket();
    });
    _showMessage('무료 동 복권을 받았습니다!');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
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
        vertical: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            ticket.primaryColor,
            ticket.secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: ticket.primaryColor
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(
                    12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.2),
                    borderRadius:
                        BorderRadius.circular(12),
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
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      Text(
                        ticket.description,
                        style: TextStyle(
                          color: Colors.white
                              .withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.2),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    '보유: $owned개',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: owned > 0
                        ? () => _useLotteryTicket(
                            ticket,
                          )
                        : null,
                    icon: const Icon(
                      Icons.card_giftcard,
                    ),
                    label: Text(
                      owned > 0
                          ? '복권 긁기'
                          : '복권 없음',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.white,
                      foregroundColor:
                          ticket.primaryColor,
                      padding:
                          const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () =>
                      _buyLotteryTicket(ticket),
                  icon: const Icon(
                    Icons.monetization_on,
                  ),
                  label: Text('${ticket.cost}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white
                        .withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                            12,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardHistory() {
    if (playerData.rewardHistory.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                '아직 복권을 긁어본 기록이 없습니다',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            '최근 보상 기록',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...playerData.rewardHistory.take(5).map(
            (reward) {
              return Container(
                margin: const EdgeInsets.only(
                  bottom: 8,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: reward.color.withOpacity(
                    0.1,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color: reward.color
                        .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      reward.icon,
                      color: reward.color,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            reward.name,
                            style:
                                const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                          ),
                          Text(
                            reward.description,
                            style: TextStyle(
                              color: Colors
                                  .grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'x${reward.quantity}',
                      style: TextStyle(
                        color: reward.color,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFFBFF),
      appBar: AppBar(
        title: const Text(
          '🎁 캐릭터 뽑기',
          style: TextStyle(
            fontFamily: 'Cafe24Ohsquare',
            color: Color(0xFF5C47CE),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF89E0F7),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF5C47CE),
        ),
        centerTitle: true,
      ),
      body: SoftBlurBackground(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFDFFBFF),
                Color(0xFFF4FEFF),
                Color(0xFFFAF9FB),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 헤더
                Container(
                  padding: const EdgeInsets.all(
                    20,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            Navigator.of(
                              context,
                            ).pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Colors.white,
                          padding:
                              const EdgeInsets.all(
                                12,
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          '🎰 복권 센터',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius:
                              BorderRadius.circular(
                                20,
                              ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber
                                  .withOpacity(
                                    0.3,
                                  ),
                              blurRadius: 8,
                              offset:
                                  const Offset(
                                    0,
                                    4,
                                  ),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons
                                  .monetization_on,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              '${playerData.totalCoins}',
                              style:
                                  const TextStyle(
                                    color: Colors
                                        .white,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    fontSize: 16,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 무료 복권 버튼
                Container(
                  margin:
                      const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                  child: ElevatedButton.icon(
                    onPressed:
                        playerData
                            .canGetFreeTicket()
                        ? _getFreeTicket
                        : null,
                    icon: const Icon(
                      Icons.card_giftcard,
                    ),
                    label: Text(
                      playerData
                              .canGetFreeTicket()
                          ? '무료 복권 받기!'
                          : '24시간 후 사용 가능',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          playerData
                              .canGetFreeTicket()
                          ? Colors.green
                          : Colors.grey,
                      foregroundColor:
                          Colors.white,
                      padding:
                          const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                      minimumSize: const Size(
                        double.infinity,
                        0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 복권 목록
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...LotteryService.getAvailableTickets()
                            .map(
                              (ticket) =>
                                  _buildTicketCard(
                                    ticket,
                                  ),
                            )
                            .toList(),

                        const SizedBox(
                          height: 20,
                        ),

                        // 보상 기록
                        _buildRewardHistory(),

                        const SizedBox(
                          height: 100,
                        ), // 하단 여백
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
