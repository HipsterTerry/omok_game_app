import 'package:flutter/material.dart';

enum ItemType {
  defensive, // 방어형
  offensive, // 공격형
  disruptive, // 교란형
  timeControl, // 시간제어형
}

enum ItemRarity {
  common, // 일반
  rare, // 희귀
  epic, // 영웅
  legendary, // 전설
}

class GameItem {
  final String id;
  final String name;
  final String koreanName;
  final String description;
  final ItemType type;
  final ItemRarity rarity;
  final int maxUsesPerGame; // 게임당 최대 사용 횟수
  final int cooldown; // 쿨다운 (턴 수)
  final Map<String, dynamic> effects;
  final String imagePath;
  final bool isPremium; // 유료 아이템 여부
  final int cost; // 구매 비용 (코인)

  const GameItem({
    required this.id,
    required this.name,
    required this.koreanName,
    required this.description,
    required this.type,
    required this.rarity,
    required this.maxUsesPerGame,
    required this.cooldown,
    required this.effects,
    required this.imagePath,
    this.isPremium = false,
    this.cost = 0,
  });

  String get rarityName {
    switch (rarity) {
      case ItemRarity.common:
        return '일반';
      case ItemRarity.rare:
        return '희귀';
      case ItemRarity.epic:
        return '영웅';
      case ItemRarity.legendary:
        return '전설';
    }
  }

  String get typeName {
    switch (type) {
      case ItemType.defensive:
        return '방어형';
      case ItemType.offensive:
        return '공격형';
      case ItemType.disruptive:
        return '교란형';
      case ItemType.timeControl:
        return '시간제어형';
    }
  }

  Color get rarityColor {
    switch (rarity) {
      case ItemRarity.common:
        return const Color(0xFF9E9E9E); // 회색
      case ItemRarity.rare:
        return const Color(0xFF4CAF50); // 초록
      case ItemRarity.epic:
        return const Color(0xFF9C27B0); // 보라
      case ItemRarity.legendary:
        return const Color(0xFFFF9800); // 주황
    }
  }
}

// 게임 내 아이템 사용 상태를 관리하는 클래스
class GameItemState {
  final GameItem item;
  final int usedCount;
  final int lastUsedTurn;

  const GameItemState({
    required this.item,
    this.usedCount = 0,
    this.lastUsedTurn = -1,
  });

  bool get canUse => usedCount < item.maxUsesPerGame;

  bool canUseOnTurn(int currentTurn) {
    if (!canUse) return false;
    if (lastUsedTurn == -1) return true;
    return currentTurn - lastUsedTurn >= item.cooldown;
  }

  GameItemState copyWith({GameItem? item, int? usedCount, int? lastUsedTurn}) {
    return GameItemState(
      item: item ?? this.item,
      usedCount: usedCount ?? this.usedCount,
      lastUsedTurn: lastUsedTurn ?? this.lastUsedTurn,
    );
  }
}
