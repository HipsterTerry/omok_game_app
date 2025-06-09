import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'character.dart';
import 'game_item_enhanced.dart';

enum LotteryType {
  bronze, // 동 복권
  silver, // 은 복권
  gold, // 금 복권
}

enum RewardType {
  character, // 캐릭터 조각
  item, // 아이템
  coins, // 코인
  experience, // 경험치
}

class LotteryReward {
  final String id;
  final String name;
  final String description;
  final RewardType type;
  final int quantity;
  final String? itemId; // 아이템인 경우
  final CharacterType?
  characterType; // 캐릭터 조각인 경우
  final ItemRarity? itemRarity;
  final Color color;
  final IconData icon;

  const LotteryReward({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.quantity,
    this.itemId,
    this.characterType,
    this.itemRarity,
    required this.color,
    required this.icon,
  });
}

class LotteryTicket {
  final String id;
  final LotteryType type;
  final String name;
  final String description;
  final int cost;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final List<LotteryReward> possibleRewards;
  final Map<String, double>
  rewardProbabilities; // 보상 ID -> 확률

  const LotteryTicket({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.cost,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    required this.possibleRewards,
    required this.rewardProbabilities,
  });

  // 복권 긁기 결과 계산
  LotteryReward drawReward() {
    final random = math.Random();
    double totalProbability = 0.0;
    final randomValue = random.nextDouble();

    for (final reward in possibleRewards) {
      totalProbability +=
          rewardProbabilities[reward.id] ?? 0.0;
      if (randomValue <= totalProbability) {
        return reward;
      }
    }

    // 기본값 (마지막 보상)
    return possibleRewards.last;
  }
}

class LotteryService {
  // 동 복권 보상
  static const List<LotteryReward> bronzeRewards =
      [
        LotteryReward(
          id: 'bronze_coins_50',
          name: '50 코인',
          description: '소량의 코인을 획득합니다',
          type: RewardType.coins,
          quantity: 50,
          color: Colors.amber,
          icon: Icons.monetization_on,
        ),
        LotteryReward(
          id: 'bronze_coins_100',
          name: '100 코인',
          description: '코인을 획득합니다',
          type: RewardType.coins,
          quantity: 100,
          color: Colors.amber,
          icon: Icons.monetization_on,
        ),
        LotteryReward(
          id: 'bronze_time_extend',
          name: '시간 연장',
          description: '시간 연장 아이템을 획득합니다',
          type: RewardType.item,
          quantity: 1,
          itemId: 'time_extend',
          itemRarity: ItemRarity.common,
          color: Colors.blue,
          icon: Icons.access_time,
        ),
        LotteryReward(
          id: 'bronze_rat_fragment',
          name: '쥐 조각',
          description: '쥐 캐릭터 조각을 획득합니다',
          type: RewardType.character,
          quantity: 1,
          characterType: CharacterType.rat,
          color: Colors.grey,
          icon: Icons.pets,
        ),
      ];

  // 은 복권 보상
  static const List<LotteryReward> silverRewards =
      [
        LotteryReward(
          id: 'silver_coins_200',
          name: '200 코인',
          description: '코인을 획득합니다',
          type: RewardType.coins,
          quantity: 200,
          color: Colors.amber,
          icon: Icons.monetization_on,
        ),
        LotteryReward(
          id: 'silver_coins_500',
          name: '500 코인',
          description: '많은 코인을 획득합니다',
          type: RewardType.coins,
          quantity: 500,
          color: Colors.amber,
          icon: Icons.monetization_on,
        ),
        LotteryReward(
          id: 'silver_skill_block',
          name: '스킬 차단',
          description: '스킬 차단 아이템을 획득합니다',
          type: RewardType.item,
          quantity: 1,
          itemId: 'skill_block',
          itemRarity: ItemRarity.rare,
          color: Colors.red,
          icon: Icons.block,
        ),
        LotteryReward(
          id: 'silver_tiger_fragment',
          name: '호랑이 조각',
          description: '호랑이 캐릭터 조각을 획득합니다',
          type: RewardType.character,
          quantity: 2,
          characterType: CharacterType.tiger,
          color: Colors.orange,
          icon: Icons.pets,
        ),
        LotteryReward(
          id: 'silver_rabbit_fragment',
          name: '토끼 조각',
          description: '토끼 캐릭터 조각을 획득합니다',
          type: RewardType.character,
          quantity: 2,
          characterType: CharacterType.rabbit,
          color: Colors.pink,
          icon: Icons.pets,
        ),
      ];

  // 금 복권 보상
  static const List<LotteryReward> goldRewards = [
    LotteryReward(
      id: 'gold_coins_1000',
      name: '1000 코인',
      description: '대량의 코인을 획득합니다',
      type: RewardType.coins,
      quantity: 1000,
      color: Colors.amber,
      icon: Icons.monetization_on,
    ),
    LotteryReward(
      id: 'gold_stone_swap',
      name: '돌 교환',
      description: '돌 교환 아이템을 획득합니다',
      type: RewardType.item,
      quantity: 1,
      itemId: 'stone_swap',
      itemRarity: ItemRarity.epic,
      color: Colors.purple,
      icon: Icons.swap_horiz,
    ),
    LotteryReward(
      id: 'gold_undo_move',
      name: '무르기',
      description: '무르기 아이템을 획득합니다',
      type: RewardType.item,
      quantity: 1,
      itemId: 'undo_move',
      itemRarity: ItemRarity.legendary,
      color: Colors.orange,
      icon: Icons.undo,
    ),
    LotteryReward(
      id: 'gold_dragon_fragment',
      name: '용 조각',
      description: '용 캐릭터 조각을 대량 획득합니다',
      type: RewardType.character,
      quantity: 5,
      characterType: CharacterType.dragon,
      color: Colors.red,
      icon: Icons.pets,
    ),
  ];

  // 복권 티켓 정의
  static const List<LotteryTicket> tickets = [
    // 동 복권
    LotteryTicket(
      id: 'bronze_ticket',
      type: LotteryType.bronze,
      name: '동 복권',
      description: '기본 보상을 획득할 수 있습니다',
      cost: 100,
      primaryColor: Color(0xFFCD7F32), // 청동색
      secondaryColor: Color(0xFFD2691E),
      icon: Icons.confirmation_number,
      possibleRewards: bronzeRewards,
      rewardProbabilities: {
        'bronze_coins_50': 0.5, // 50%
        'bronze_coins_100': 0.3, // 30%
        'bronze_time_extend': 0.15, // 15%
        'bronze_rat_fragment': 0.05, // 5%
      },
    ),

    // 은 복권
    LotteryTicket(
      id: 'silver_ticket',
      type: LotteryType.silver,
      name: '은 복권',
      description: '좋은 보상을 획득할 수 있습니다',
      cost: 300,
      primaryColor: Color(0xFFC0C0C0), // 은색
      secondaryColor: Color(0xFFD3D3D3),
      icon: Icons.confirmation_number,
      possibleRewards: silverRewards,
      rewardProbabilities: {
        'silver_coins_200': 0.4, // 40%
        'silver_coins_500': 0.25, // 25%
        'silver_skill_block': 0.2, // 20%
        'silver_tiger_fragment': 0.1, // 10%
        'silver_rabbit_fragment': 0.05, // 5%
      },
    ),

    // 금 복권
    LotteryTicket(
      id: 'gold_ticket',
      type: LotteryType.gold,
      name: '금 복권',
      description: '최고급 보상을 획득할 수 있습니다',
      cost: 800,
      primaryColor: Color(0xFFFFD700), // 금색
      secondaryColor: Color(0xFFFFA500),
      icon: Icons.confirmation_number,
      possibleRewards: goldRewards,
      rewardProbabilities: {
        'gold_coins_1000': 0.45, // 45%
        'gold_stone_swap': 0.25, // 25%
        'gold_undo_move': 0.15, // 15%
        'gold_dragon_fragment': 0.15, // 15%
      },
    ),
  ];

  static LotteryTicket? getTicketById(String id) {
    try {
      return tickets.firstWhere(
        (ticket) => ticket.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  static List<LotteryTicket>
  getAvailableTickets() {
    return tickets;
  }

  static LotteryTicket? getTicketByType(
    LotteryType type,
  ) {
    try {
      return tickets.firstWhere(
        (ticket) => ticket.type == type,
      );
    } catch (e) {
      return null;
    }
  }
}

// 플레이어의 복권 관련 정보
class PlayerLotteryData {
  final Map<String, int>
  ownedTickets; // 보유 복권 ID -> 개수
  final List<LotteryReward>
  rewardHistory; // 획득한 보상 기록
  final Map<String, int>
  characterFragments; // 캐릭터 조각 ID -> 개수
  final int totalCoins;
  final DateTime?
  lastFreeTicketTime; // 마지막 무료 복권 시간

  PlayerLotteryData({
    Map<String, int>? ownedTickets,
    List<LotteryReward>? rewardHistory,
    Map<String, int>? characterFragments,
    this.totalCoins = 0,
    this.lastFreeTicketTime,
  }) : ownedTickets = ownedTickets ?? {},
       rewardHistory = rewardHistory ?? [],
       characterFragments =
           characterFragments ?? {};

  // 복권 사용 가능 여부
  bool canUseTicket(String ticketId) {
    return (ownedTickets[ticketId] ?? 0) > 0;
  }

  // 무료 복권 사용 가능 여부 (24시간마다 1개)
  bool canGetFreeTicket() {
    if (lastFreeTicketTime == null) return true;

    final now = DateTime.now();
    final difference = now.difference(
      lastFreeTicketTime!,
    );
    return difference.inHours >= 24;
  }

  // 복권 사용
  PlayerLotteryData useTicket(
    String ticketId,
    LotteryReward reward,
  ) {
    final newOwnedTickets = Map<String, int>.from(
      ownedTickets,
    );
    final newRewardHistory =
        List<LotteryReward>.from(rewardHistory);
    final newCharacterFragments =
        Map<String, int>.from(characterFragments);
    int newTotalCoins = totalCoins;

    // 복권 개수 감소
    if (newOwnedTickets[ticketId] != null &&
        newOwnedTickets[ticketId]! > 0) {
      newOwnedTickets[ticketId] =
          newOwnedTickets[ticketId]! - 1;
      if (newOwnedTickets[ticketId]! <= 0) {
        newOwnedTickets.remove(ticketId);
      }
    }

    // 보상 처리
    newRewardHistory.add(reward);

    switch (reward.type) {
      case RewardType.coins:
        newTotalCoins += reward.quantity;
        break;
      case RewardType.character:
        if (reward.characterType != null) {
          final fragmentId =
              reward.characterType!.name;
          newCharacterFragments[fragmentId] =
              (newCharacterFragments[fragmentId] ??
                  0) +
              reward.quantity;
        }
        break;
      case RewardType.item:
        // 아이템은 별도 인벤토리에서 관리
        break;
      case RewardType.experience:
        // 경험치는 별도 시스템에서 관리
        break;
    }

    return PlayerLotteryData(
      ownedTickets: newOwnedTickets,
      rewardHistory: newRewardHistory,
      characterFragments: newCharacterFragments,
      totalCoins: newTotalCoins,
      lastFreeTicketTime: lastFreeTicketTime,
    );
  }

  // 복권 추가
  PlayerLotteryData addTicket(
    String ticketId,
    int count,
  ) {
    final newOwnedTickets = Map<String, int>.from(
      ownedTickets,
    );
    newOwnedTickets[ticketId] =
        (newOwnedTickets[ticketId] ?? 0) + count;

    return PlayerLotteryData(
      ownedTickets: newOwnedTickets,
      rewardHistory: rewardHistory,
      characterFragments: characterFragments,
      totalCoins: totalCoins,
      lastFreeTicketTime: lastFreeTicketTime,
    );
  }

  // 무료 복권 획득
  PlayerLotteryData getFreeTicket() {
    if (!canGetFreeTicket()) return this;

    return PlayerLotteryData(
      ownedTickets: ownedTickets,
      rewardHistory: rewardHistory,
      characterFragments: characterFragments,
      totalCoins: totalCoins,
      lastFreeTicketTime: DateTime.now(),
    ).addTicket('bronze_ticket', 1);
  }

  // 코인으로 복권 구매
  PlayerLotteryData buyTicket(
    String ticketId,
    int cost,
  ) {
    if (totalCoins < cost) return this; // 코인 부족

    return PlayerLotteryData(
      ownedTickets: ownedTickets,
      rewardHistory: rewardHistory,
      characterFragments: characterFragments,
      totalCoins: totalCoins - cost,
      lastFreeTicketTime: lastFreeTicketTime,
    ).addTicket(ticketId, 1);
  }

  PlayerLotteryData copyWith({
    Map<String, int>? ownedTickets,
    List<LotteryReward>? rewardHistory,
    Map<String, int>? characterFragments,
    int? totalCoins,
    DateTime? lastFreeTicketTime,
  }) {
    return PlayerLotteryData(
      ownedTickets:
          ownedTickets ?? this.ownedTickets,
      rewardHistory:
          rewardHistory ?? this.rewardHistory,
      characterFragments:
          characterFragments ??
          this.characterFragments,
      totalCoins: totalCoins ?? this.totalCoins,
      lastFreeTicketTime:
          lastFreeTicketTime ??
          this.lastFreeTicketTime,
    );
  }
}
