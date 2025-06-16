import 'package:flutter/material.dart';

enum ItemType {
  extraTurn, // 추가 턴
  skillBlock, // 스킬 차단
  stoneSwap, // 돌 교환
  timeExtend, // 시간 연장
  positionHint, // 위치 힌트
  undoMove, // 무르기
}

enum ItemRarity {
  common, // 일반 (흰색)
  rare, // 희귀 (파란색)
  epic, // 영웅 (보라색)
  legendary, // 전설 (주황색)
}

class GameItemEnhanced {
  final String id;
  final String name;
  final String description;
  final ItemType type;
  final ItemRarity rarity;
  final int cost;
  final bool isPremium;
  final IconData icon;
  final Color color;
  final String effectDescription;
  final int cooldownTurns;

  const GameItemEnhanced({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
    required this.cost,
    required this.isPremium,
    required this.icon,
    required this.color,
    required this.effectDescription,
    this.cooldownTurns = 0,
  });

  // 아이템 사용 가능 여부 체크
  bool canUse(int turnCount) {
    // 쿨다운 체크는 게임 상태에서 관리
    return true;
  }

  // 아이템별 색상
  Color get rarityColor {
    switch (rarity) {
      case ItemRarity.common:
        return Colors.grey[400]!;
      case ItemRarity.rare:
        return Colors.blue[400]!;
      case ItemRarity.epic:
        return Colors.purple[400]!;
      case ItemRarity.legendary:
        return Colors.orange[400]!;
    }
  }

  // 아이템별 배경 그라데이션
  LinearGradient get rarityGradient {
    switch (rarity) {
      case ItemRarity.common:
        return LinearGradient(colors: [Colors.grey[300]!, Colors.grey[500]!]);
      case ItemRarity.rare:
        return LinearGradient(colors: [Colors.blue[300]!, Colors.blue[600]!]);
      case ItemRarity.epic:
        return LinearGradient(
          colors: [Colors.purple[300]!, Colors.purple[600]!],
        );
      case ItemRarity.legendary:
        return LinearGradient(
          colors: [Colors.orange[300]!, Colors.orange[600]!],
        );
    }
  }
}

class ItemService {
  static const List<GameItemEnhanced> allItems = [
    // 일반 아이템
    GameItemEnhanced(
      id: 'extra_turn',
      name: '추가 턴',
      description: '한 번 더 둘 수 있는 기회를 얻습니다',
      type: ItemType.extraTurn,
      rarity: ItemRarity.common,
      cost: 100,
      isPremium: false,
      icon: Icons.refresh,
      color: Colors.green,
      effectDescription: '다음 턴을 추가로 진행할 수 있습니다.',
    ),

    GameItemEnhanced(
      id: 'time_extend',
      name: '시간 연장',
      description: '턴 시간을 15초 추가합니다',
      type: ItemType.timeExtend,
      rarity: ItemRarity.common,
      cost: 80,
      isPremium: false,
      icon: Icons.access_time,
      color: Colors.blue,
      effectDescription: '현재 턴 시간을 15초 연장합니다.',
    ),

    // 희귀 아이템
    GameItemEnhanced(
      id: 'skill_block',
      name: '스킬 차단',
      description: '상대방의 스킬 사용을 1턴 차단합니다',
      type: ItemType.skillBlock,
      rarity: ItemRarity.rare,
      cost: 200,
      isPremium: false,
      icon: Icons.block,
      color: Colors.red,
      effectDescription: '상대방의 스킬을 3턴간 사용할 수 없게 합니다.',
    ),

    GameItemEnhanced(
      id: 'position_hint',
      name: '위치 힌트',
      description: '최적의 수를 3개까지 표시해줍니다',
      type: ItemType.positionHint,
      rarity: ItemRarity.rare,
      cost: 150,
      isPremium: false,
      icon: Icons.lightbulb,
      color: Colors.yellow,
      effectDescription: '가장 좋은 수 후보 3곳을 표시합니다.',
    ),

    // 영웅 아이템
    GameItemEnhanced(
      id: 'stone_swap',
      name: '돌 교환',
      description: '보드 위의 돌 2개의 위치를 바꿉니다',
      type: ItemType.stoneSwap,
      rarity: ItemRarity.epic,
      cost: 300,
      isPremium: true,
      icon: Icons.swap_horiz,
      color: Colors.purple,
      effectDescription: '원하는 두 돌의 위치를 서로 바꿉니다.',
    ),

    // 전설 아이템
    GameItemEnhanced(
      id: 'undo_move',
      name: '무르기',
      description: '마지막 3수까지 되돌릴 수 있습니다',
      type: ItemType.undoMove,
      rarity: ItemRarity.legendary,
      cost: 500,
      isPremium: true,
      icon: Icons.undo,
      color: Colors.orange,
      effectDescription: '최대 3수까지 되돌릴 수 있습니다.',
    ),
  ];

  static List<GameItemEnhanced> getItemsByRarity(ItemRarity rarity) {
    return allItems.where((item) => item.rarity == rarity).toList();
  }

  static List<GameItemEnhanced> getFreeItems() {
    return allItems.where((item) => !item.isPremium).toList();
  }

  static List<GameItemEnhanced> getPremiumItems() {
    return allItems.where((item) => item.isPremium).toList();
  }

  static GameItemEnhanced? getItemById(String id) {
    try {
      return allItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
}

// 플레이어가 보유한 아이템 정보
class PlayerItemInventory {
  final Map<String, int> items; // 아이템 ID -> 개수
  final Map<String, int> usedInGame; // 현재 게임에서 사용한 아이템 ID -> 사용 횟수
  final Map<String, int> cooldowns; // 아이템 ID -> 남은 쿨다운 턴

  PlayerItemInventory({
    Map<String, int>? items,
    Map<String, int>? usedInGame,
    Map<String, int>? cooldowns,
  }) : items = items ?? {},
       usedInGame = usedInGame ?? {},
       cooldowns = cooldowns ?? {};

  // 아이템 사용 가능 여부
  bool canUseItem(String itemId) {
    final item = ItemService.getItemById(itemId);
    if (item == null) return false;

    // 보유 여부 체크
    if ((items[itemId] ?? 0) <= 0) return false;

    // 게임 내 사용 횟수 체크 (최대 2회)
    if ((usedInGame[itemId] ?? 0) >= 2) return false;

    // 쿨다운 체크
    if ((cooldowns[itemId] ?? 0) > 0) return false;

    return true;
  }

  // 아이템 사용
  PlayerItemInventory useItem(String itemId) {
    if (!canUseItem(itemId)) return this;

    final newItems = Map<String, int>.from(items);
    final newUsedInGame = Map<String, int>.from(usedInGame);
    final newCooldowns = Map<String, int>.from(cooldowns);

    // 아이템 개수 감소
    newItems[itemId] = (newItems[itemId] ?? 0) - 1;
    if (newItems[itemId]! <= 0) {
      newItems.remove(itemId);
    }

    // 게임 내 사용 횟수 증가
    newUsedInGame[itemId] = (newUsedInGame[itemId] ?? 0) + 1;

    // 쿨다운 설정 (아이템별로 다름)
    final item = ItemService.getItemById(itemId);
    if (item != null && item.cooldownTurns > 0) {
      newCooldowns[itemId] = item.cooldownTurns;
    }

    return PlayerItemInventory(
      items: newItems,
      usedInGame: newUsedInGame,
      cooldowns: newCooldowns,
    );
  }

  // 쿨다운 감소 (턴 종료시 호출)
  PlayerItemInventory reduceCooldowns() {
    final newCooldowns = Map<String, int>.from(cooldowns);

    newCooldowns.forEach((key, value) {
      if (value > 0) {
        newCooldowns[key] = value - 1;
      }
    });

    // 쿨다운이 0인 항목 제거
    newCooldowns.removeWhere((key, value) => value <= 0);

    return PlayerItemInventory(
      items: items,
      usedInGame: usedInGame,
      cooldowns: newCooldowns,
    );
  }

  // 아이템 추가
  PlayerItemInventory addItem(String itemId, int count) {
    final newItems = Map<String, int>.from(items);
    newItems[itemId] = (newItems[itemId] ?? 0) + count;

    return PlayerItemInventory(
      items: newItems,
      usedInGame: usedInGame,
      cooldowns: cooldowns,
    );
  }

  // 게임 종료시 사용 기록 초기화
  PlayerItemInventory resetGameUsage() {
    return PlayerItemInventory(items: items, usedInGame: {}, cooldowns: {});
  }

  PlayerItemInventory copyWith({
    Map<String, int>? items,
    Map<String, int>? usedInGame,
    Map<String, int>? cooldowns,
  }) {
    return PlayerItemInventory(
      items: items ?? this.items,
      usedInGame: usedInGame ?? this.usedInGame,
      cooldowns: cooldowns ?? this.cooldowns,
    );
  }
}
