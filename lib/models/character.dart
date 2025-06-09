import 'package:flutter/material.dart';

enum CharacterTier { heaven, earth, human }

enum CharacterType {
  rat, // 쥐
  ox, // 소
  tiger, // 호랑이
  rabbit, // 토끼
  dragon, // 용
  snake, // 뱀
  horse, // 말
  goat, // 양
  monkey, // 원숭이
  rooster, // 닭
  dog, // 개
  pig, // 돼지
}

enum SkillType {
  defensive, // 방어형
  offensive, // 공격형
  disruptive, // 교란형
  timeControl, // 시간제어형
}

class CharacterSkill {
  final String name;
  final String description;
  final SkillType type;
  final int cooldown;
  final Map<String, dynamic> effects;

  const CharacterSkill({
    required this.name,
    required this.description,
    required this.type,
    required this.cooldown,
    required this.effects,
  });
}

class Character {
  final CharacterType type;
  final String name;
  final String koreanName;
  final CharacterTier tier;
  final CharacterSkill skill;
  final double winRateBonus; // 승률 보너스 (%)
  final String imagePath;
  final String description;
  final bool isUnlocked;

  const Character({
    required this.type,
    required this.name,
    required this.koreanName,
    required this.tier,
    required this.skill,
    required this.winRateBonus,
    required this.imagePath,
    required this.description,
    this.isUnlocked = false,
  });

  Character copyWith({
    CharacterType? type,
    String? name,
    String? koreanName,
    CharacterTier? tier,
    CharacterSkill? skill,
    double? winRateBonus,
    String? imagePath,
    String? description,
    bool? isUnlocked,
  }) {
    return Character(
      type: type ?? this.type,
      name: name ?? this.name,
      koreanName: koreanName ?? this.koreanName,
      tier: tier ?? this.tier,
      skill: skill ?? this.skill,
      winRateBonus:
          winRateBonus ?? this.winRateBonus,
      imagePath: imagePath ?? this.imagePath,
      description:
          description ?? this.description,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  String get tierName {
    switch (tier) {
      case CharacterTier.heaven:
        return '천급';
      case CharacterTier.earth:
        return '지급';
      case CharacterTier.human:
        return '인급';
    }
  }

  String get typeKoreanName {
    switch (type) {
      case CharacterType.rat:
        return '쥐';
      case CharacterType.ox:
        return '소';
      case CharacterType.tiger:
        return '호랑이';
      case CharacterType.rabbit:
        return '토끼';
      case CharacterType.dragon:
        return '용';
      case CharacterType.snake:
        return '뱀';
      case CharacterType.horse:
        return '말';
      case CharacterType.goat:
        return '양';
      case CharacterType.monkey:
        return '원숭이';
      case CharacterType.rooster:
        return '닭';
      case CharacterType.dog:
        return '개';
      case CharacterType.pig:
        return '돼지';
    }
  }

  // 등급별 색상
  Color get tierColor {
    switch (tier) {
      case CharacterTier.heaven:
        return const Color(0xFFFFD700); // 금색
      case CharacterTier.earth:
        return const Color(0xFFC0C0C0); // 은색
      case CharacterTier.human:
        return const Color(0xFF8B4513); // 갈색
    }
  }

  // 스킬 타입 편의 접근자
  SkillType get skillType => skill.type;

  // 스킬 이름 편의 접근자
  String get skillName => skill.name;
}
