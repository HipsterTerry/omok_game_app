import 'package:flutter/material.dart';
import 'dart:math' as math;

enum RankTier {
  beginner, // 초급 (30급~10급)
  intermediate, // 중급 (9급~1급)
  advanced, // 고급 (초단~9단)
  master, // 마스터 (최상위)
}

enum TitleType {
  none,
  starCaller, // 별을 부르는 자
  stoneAlchemist, // 검은 돌의 연금술사
  boardMaster, // 바둑판의 지배자
  timeLord, // 시간의 지배자
  strategyGenius, // 전략의 천재
  zodiacChampion, // 십이지신 챔피언
  legendaryPlayer, // 전설의 플레이어
}

class GameRank {
  final int level; // 1~48 (30급부터 마스터까지)
  final RankTier tier;
  final String
  displayName; // "30급", "1급", "초단", "9단", "마스터" 등
  final String description;
  final int requiredWins; // 승급에 필요한 승수
  final int requiredPoints; // 승급에 필요한 포인트
  final Color tierColor;
  final IconData tierIcon;
  final bool hasTitle; // 칭호 퀘스트 여부 (짝수 단)

  const GameRank({
    required this.level,
    required this.tier,
    required this.displayName,
    required this.description,
    required this.requiredWins,
    required this.requiredPoints,
    required this.tierColor,
    required this.tierIcon,
    this.hasTitle = false,
  });
}

class PlayerRankData {
  final GameRank currentRank;
  final int totalWins;
  final int totalLosses;
  final int currentPoints;
  final int winStreak; // 연승
  final int lossStreak; // 연패
  final List<TitleType> earnedTitles;
  final TitleType activeTitle;
  final Map<String, int> characterWins; // 캐릭터별 승수
  final DateTime? lastRankUpTime;

  PlayerRankData({
    required this.currentRank,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.currentPoints = 0,
    this.winStreak = 0,
    this.lossStreak = 0,
    List<TitleType>? earnedTitles,
    this.activeTitle = TitleType.none,
    Map<String, int>? characterWins,
    this.lastRankUpTime,
  }) : earnedTitles = earnedTitles ?? [],
       characterWins = characterWins ?? {};

  // 승률 계산
  double get winRate {
    final total = totalWins + totalLosses;
    return total > 0 ? totalWins / total : 0.0;
  }

  // 승급 가능 여부
  bool get canRankUp {
    return currentPoints >=
            currentRank.requiredPoints &&
        totalWins >= currentRank.requiredWins;
  }

  // 다음 랭크 획득
  PlayerRankData rankUp() {
    if (!canRankUp) return this;

    final nextRank = RankService.getNextRank(
      currentRank.level,
    );
    if (nextRank == null) return this; // 최고 랭크

    return PlayerRankData(
      currentRank: nextRank,
      totalWins: totalWins,
      totalLosses: totalLosses,
      currentPoints: 0, // 승급 후 포인트 초기화
      winStreak: winStreak,
      lossStreak: lossStreak,
      earnedTitles: earnedTitles,
      activeTitle: activeTitle,
      characterWins: characterWins,
      lastRankUpTime: DateTime.now(),
    );
  }

  // 게임 결과 적용
  PlayerRankData applyGameResult({
    required bool isWin,
    required String characterId,
    int? bonusPoints,
  }) {
    final newCharacterWins =
        Map<String, int>.from(characterWins);

    if (isWin) {
      // 승리시
      newCharacterWins[characterId] =
          (newCharacterWins[characterId] ?? 0) +
          1;

      return PlayerRankData(
        currentRank: currentRank,
        totalWins: totalWins + 1,
        totalLosses: totalLosses,
        currentPoints:
            currentPoints + (bonusPoints ?? 10),
        winStreak: winStreak + 1,
        lossStreak: 0,
        earnedTitles: earnedTitles,
        activeTitle: activeTitle,
        characterWins: newCharacterWins,
        lastRankUpTime: lastRankUpTime,
      );
    } else {
      // 패배시
      return PlayerRankData(
        currentRank: currentRank,
        totalWins: totalWins,
        totalLosses: totalLosses + 1,
        currentPoints: math.max(
          0,
          currentPoints - 5,
        ), // 포인트 감소 (0 미만 불가)
        winStreak: 0,
        lossStreak: lossStreak + 1,
        earnedTitles: earnedTitles,
        activeTitle: activeTitle,
        characterWins: characterWins,
        lastRankUpTime: lastRankUpTime,
      );
    }
  }

  // 칭호 획득
  PlayerRankData earnTitle(TitleType title) {
    if (earnedTitles.contains(title)) return this;

    final newEarnedTitles = List<TitleType>.from(
      earnedTitles,
    );
    newEarnedTitles.add(title);

    return PlayerRankData(
      currentRank: currentRank,
      totalWins: totalWins,
      totalLosses: totalLosses,
      currentPoints: currentPoints,
      winStreak: winStreak,
      lossStreak: lossStreak,
      earnedTitles: newEarnedTitles,
      activeTitle: activeTitle,
      characterWins: characterWins,
      lastRankUpTime: lastRankUpTime,
    );
  }

  // 활성 칭호 변경
  PlayerRankData setActiveTitle(TitleType title) {
    if (!earnedTitles.contains(title) &&
        title != TitleType.none) {
      return this;
    }

    return PlayerRankData(
      currentRank: currentRank,
      totalWins: totalWins,
      totalLosses: totalLosses,
      currentPoints: currentPoints,
      winStreak: winStreak,
      lossStreak: lossStreak,
      earnedTitles: earnedTitles,
      activeTitle: title,
      characterWins: characterWins,
      lastRankUpTime: lastRankUpTime,
    );
  }

  PlayerRankData copyWith({
    GameRank? currentRank,
    int? totalWins,
    int? totalLosses,
    int? currentPoints,
    int? winStreak,
    int? lossStreak,
    List<TitleType>? earnedTitles,
    TitleType? activeTitle,
    Map<String, int>? characterWins,
    DateTime? lastRankUpTime,
  }) {
    return PlayerRankData(
      currentRank:
          currentRank ?? this.currentRank,
      totalWins: totalWins ?? this.totalWins,
      totalLosses:
          totalLosses ?? this.totalLosses,
      currentPoints:
          currentPoints ?? this.currentPoints,
      winStreak: winStreak ?? this.winStreak,
      lossStreak: lossStreak ?? this.lossStreak,
      earnedTitles:
          earnedTitles ?? this.earnedTitles,
      activeTitle:
          activeTitle ?? this.activeTitle,
      characterWins:
          characterWins ?? this.characterWins,
      lastRankUpTime:
          lastRankUpTime ?? this.lastRankUpTime,
    );
  }
}

class RankService {
  static const List<GameRank> allRanks = [
    // 초급 (30급~10급)
    GameRank(
      level: 1,
      tier: RankTier.beginner,
      displayName: '30급',
      description: '오목을 시작한 초보자',
      requiredWins: 3,
      requiredPoints: 30,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),
    GameRank(
      level: 2,
      tier: RankTier.beginner,
      displayName: '29급',
      description: '기본 규칙을 익혀가는 단계',
      requiredWins: 5,
      requiredPoints: 50,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),
    GameRank(
      level: 3,
      tier: RankTier.beginner,
      displayName: '28급',
      description: '돌을 놓는 것이 익숙해짐',
      requiredWins: 7,
      requiredPoints: 70,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),
    GameRank(
      level: 4,
      tier: RankTier.beginner,
      displayName: '27급',
      description: '간단한 공격과 방어를 배움',
      requiredWins: 10,
      requiredPoints: 100,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),
    GameRank(
      level: 5,
      tier: RankTier.beginner,
      displayName: '26급',
      description: '연결의 중요성을 알아감',
      requiredWins: 12,
      requiredPoints: 120,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),
    GameRank(
      level: 6,
      tier: RankTier.beginner,
      displayName: '25급',
      description: '기본적인 패턴을 인식',
      requiredWins: 15,
      requiredPoints: 150,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),
    GameRank(
      level: 7,
      tier: RankTier.beginner,
      displayName: '24급',
      description: '상대방의 수를 예측하기 시작',
      requiredWins: 18,
      requiredPoints: 180,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),
    GameRank(
      level: 8,
      tier: RankTier.beginner,
      displayName: '23급',
      description: '방어의 기초를 이해',
      requiredWins: 21,
      requiredPoints: 210,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),
    GameRank(
      level: 9,
      tier: RankTier.beginner,
      displayName: '22급',
      description: '다양한 공격 방법을 배움',
      requiredWins: 24,
      requiredPoints: 240,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),
    GameRank(
      level: 10,
      tier: RankTier.beginner,
      displayName: '21급',
      description: '게임의 흐름을 파악',
      requiredWins: 27,
      requiredPoints: 270,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),
    GameRank(
      level: 11,
      tier: RankTier.beginner,
      displayName: '20급',
      description: '중급으로 가는 길목',
      requiredWins: 30,
      requiredPoints: 300,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),
    GameRank(
      level: 12,
      tier: RankTier.beginner,
      displayName: '19급',
      description: '안정적인 실력을 쌓아감',
      requiredWins: 33,
      requiredPoints: 330,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),
    GameRank(
      level: 13,
      tier: RankTier.beginner,
      displayName: '18급',
      description: '전략적 사고가 늘어남',
      requiredWins: 36,
      requiredPoints: 360,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),
    GameRank(
      level: 14,
      tier: RankTier.beginner,
      displayName: '17급',
      description: '복잡한 상황도 판단 가능',
      requiredWins: 39,
      requiredPoints: 390,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),
    GameRank(
      level: 15,
      tier: RankTier.beginner,
      displayName: '16급',
      description: '고급 기술을 조금씩 습득',
      requiredWins: 42,
      requiredPoints: 420,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),
    GameRank(
      level: 16,
      tier: RankTier.beginner,
      displayName: '15급',
      description: '실전 경험이 풍부해짐',
      requiredWins: 45,
      requiredPoints: 450,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),
    GameRank(
      level: 17,
      tier: RankTier.beginner,
      displayName: '14급',
      description: '중급 진입을 앞둠',
      requiredWins: 48,
      requiredPoints: 480,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),
    GameRank(
      level: 18,
      tier: RankTier.beginner,
      displayName: '13급',
      description: '초급의 마지막 단계',
      requiredWins: 51,
      requiredPoints: 510,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),
    GameRank(
      level: 19,
      tier: RankTier.beginner,
      displayName: '12급',
      description: '중급으로의 도약 준비',
      requiredWins: 54,
      requiredPoints: 540,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),
    GameRank(
      level: 20,
      tier: RankTier.beginner,
      displayName: '11급',
      description: '초급 마스터에 근접',
      requiredWins: 57,
      requiredPoints: 570,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),
    GameRank(
      level: 21,
      tier: RankTier.beginner,
      displayName: '10급',
      description: '초급 과정 완주',
      requiredWins: 60,
      requiredPoints: 600,
      tierColor: Colors.brown,
      tierIcon: Icons.eco,
    ),

    // 중급 (9급~1급)
    GameRank(
      level: 22,
      tier: RankTier.intermediate,
      displayName: '9급',
      description: '중급 진입, 실전 감각 향상',
      requiredWins: 65,
      requiredPoints: 650,
      tierColor: Colors.blue,
      tierIcon: Icons.stars,
    ),
    GameRank(
      level: 23,
      tier: RankTier.intermediate,
      displayName: '8급',
      description: '고급 기법을 익혀감',
      requiredWins: 70,
      requiredPoints: 700,
      tierColor: Colors.blue,
      tierIcon: Icons.stars,
    ),
    GameRank(
      level: 24,
      tier: RankTier.intermediate,
      displayName: '7급',
      description: '전략적 깊이가 생김',
      requiredWins: 75,
      requiredPoints: 750,
      tierColor: Colors.blue,
      tierIcon: Icons.stars,
    ),
    GameRank(
      level: 25,
      tier: RankTier.intermediate,
      displayName: '6급',
      description: '중급자의 실력을 갖춤',
      requiredWins: 80,
      requiredPoints: 800,
      tierColor: Colors.blue,
      tierIcon: Icons.stars,
    ),
    GameRank(
      level: 26,
      tier: RankTier.intermediate,
      displayName: '5급',
      description: '고급 진입을 노림',
      requiredWins: 85,
      requiredPoints: 850,
      tierColor: Colors.blue,
      tierIcon: Icons.stars,
    ),
    GameRank(
      level: 27,
      tier: RankTier.intermediate,
      displayName: '4급',
      description: '숙련된 중급자',
      requiredWins: 90,
      requiredPoints: 900,
      tierColor: Colors.blue,
      tierIcon: Icons.stars,
    ),
    GameRank(
      level: 28,
      tier: RankTier.intermediate,
      displayName: '3급',
      description: '고급으로의 문턱',
      requiredWins: 95,
      requiredPoints: 950,
      tierColor: Colors.blue,
      tierIcon: Icons.stars,
    ),
    GameRank(
      level: 29,
      tier: RankTier.intermediate,
      displayName: '2급',
      description: '중급 마스터급 실력',
      requiredWins: 100,
      requiredPoints: 1000,
      tierColor: Colors.blue,
      tierIcon: Icons.stars,
    ),
    GameRank(
      level: 30,
      tier: RankTier.intermediate,
      displayName: '1급',
      description: '고급 진입 직전',
      requiredWins: 110,
      requiredPoints: 1100,
      tierColor: Colors.blue,
      tierIcon: Icons.stars,
    ),

    // 고급 (초단~9단)
    GameRank(
      level: 31,
      tier: RankTier.advanced,
      displayName: '초단',
      description: '고급자의 시작',
      requiredWins: 120,
      requiredPoints: 1200,
      tierColor: Colors.purple,
      tierIcon: Icons.military_tech,
    ),
    GameRank(
      level: 32,
      tier: RankTier.advanced,
      displayName: '2단',
      description: '안정적인 고급 실력',
      requiredWins: 130,
      requiredPoints: 1300,
      tierColor: Colors.purple,
      tierIcon: Icons.military_tech,
      hasTitle: true,
    ),
    GameRank(
      level: 33,
      tier: RankTier.advanced,
      displayName: '3단',
      description: '뛰어난 전략적 사고',
      requiredWins: 140,
      requiredPoints: 1400,
      tierColor: Colors.purple,
      tierIcon: Icons.military_tech,
    ),
    GameRank(
      level: 34,
      tier: RankTier.advanced,
      displayName: '4단',
      description: '고급자 중에서도 상위권',
      requiredWins: 150,
      requiredPoints: 1500,
      tierColor: Colors.purple,
      tierIcon: Icons.military_tech,
      hasTitle: true,
    ),
    GameRank(
      level: 35,
      tier: RankTier.advanced,
      displayName: '5단',
      description: '마스터를 노리는 실력',
      requiredWins: 160,
      requiredPoints: 1600,
      tierColor: Colors.purple,
      tierIcon: Icons.military_tech,
    ),
    GameRank(
      level: 36,
      tier: RankTier.advanced,
      displayName: '6단',
      description: '최고급 플레이어',
      requiredWins: 170,
      requiredPoints: 1700,
      tierColor: Colors.purple,
      tierIcon: Icons.military_tech,
      hasTitle: true,
    ),
    GameRank(
      level: 37,
      tier: RankTier.advanced,
      displayName: '7단',
      description: '전문가 수준',
      requiredWins: 180,
      requiredPoints: 1800,
      tierColor: Colors.purple,
      tierIcon: Icons.military_tech,
    ),
    GameRank(
      level: 38,
      tier: RankTier.advanced,
      displayName: '8단',
      description: '마스터 직전',
      requiredWins: 190,
      requiredPoints: 1900,
      tierColor: Colors.purple,
      tierIcon: Icons.military_tech,
      hasTitle: true,
    ),
    GameRank(
      level: 39,
      tier: RankTier.advanced,
      displayName: '9단',
      description: '최고급 고수',
      requiredWins: 200,
      requiredPoints: 2000,
      tierColor: Colors.purple,
      tierIcon: Icons.military_tech,
    ),

    // 마스터
    GameRank(
      level: 40,
      tier: RankTier.master,
      displayName: '마스터',
      description: '오목의 달인',
      requiredWins: 250,
      requiredPoints: 2500,
      tierColor: Colors.red,
      tierIcon: Icons.emoji_events,
    ),
    GameRank(
      level: 41,
      tier: RankTier.master,
      displayName: '그랜드 마스터',
      description: '전설적인 플레이어',
      requiredWins: 300,
      requiredPoints: 3000,
      tierColor: Colors.red,
      tierIcon: Icons.emoji_events,
    ),
  ];

  static GameRank getRankByLevel(int level) {
    try {
      return allRanks.firstWhere(
        (rank) => rank.level == level,
      );
    } catch (e) {
      return allRanks.first; // 기본값
    }
  }

  static GameRank? getNextRank(int currentLevel) {
    if (currentLevel >= allRanks.length)
      return null;
    try {
      return allRanks.firstWhere(
        (rank) => rank.level == currentLevel + 1,
      );
    } catch (e) {
      return null;
    }
  }

  static List<GameRank> getRanksByTier(
    RankTier tier,
  ) {
    return allRanks
        .where((rank) => rank.tier == tier)
        .toList();
  }

  static GameRank getStartingRank() {
    return allRanks.first; // 30급부터 시작
  }
}

class TitleService {
  static const Map<TitleType, TitleInfo>
  titleInfos = {
    TitleType.none: TitleInfo(
      name: '칭호 없음',
      description: '',
      color: Colors.grey,
      icon: Icons.person,
    ),
    TitleType.starCaller: TitleInfo(
      name: '별을 부르는 자',
      description: '연승 10회 달성시 획득',
      color: Colors.yellow,
      icon: Icons.star,
    ),
    TitleType.stoneAlchemist: TitleInfo(
      name: '검은 돌의 연금술사',
      description: '흑돌로 50승 달성시 획득',
      color: Colors.black,
      icon: Icons.science,
    ),
    TitleType.boardMaster: TitleInfo(
      name: '바둑판의 지배자',
      description: '19x19 보드에서 20승 달성시 획득',
      color: Colors.brown,
      icon: Icons.grid_4x4,
    ),
    TitleType.timeLord: TitleInfo(
      name: '시간의 지배자',
      description: '남은 시간 5초 이내로 승리 10회 달성시 획득',
      color: Colors.blue,
      icon: Icons.access_time,
    ),
    TitleType.strategyGenius: TitleInfo(
      name: '전략의 천재',
      description: '스킬 사용 없이 승리 30회 달성시 획득',
      color: Colors.purple,
      icon: Icons.psychology,
    ),
    TitleType.zodiacChampion: TitleInfo(
      name: '십이지신 챔피언',
      description: '모든 12지신 캐릭터로 승리 달성시 획득',
      color: Colors.orange,
      icon: Icons.pets,
    ),
    TitleType.legendaryPlayer: TitleInfo(
      name: '전설의 플레이어',
      description: '그랜드 마스터 달성시 획득',
      color: Colors.red,
      icon: Icons.emoji_events,
    ),
  };

  static TitleInfo getTitleInfo(TitleType type) {
    return titleInfos[type] ??
        titleInfos[TitleType.none]!;
  }

  static List<TitleType> getAvailableTitles() {
    return TitleType.values
        .where((title) => title != TitleType.none)
        .toList();
  }
}

class TitleInfo {
  final String name;
  final String description;
  final Color color;
  final IconData icon;

  const TitleInfo({
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
  });
}
