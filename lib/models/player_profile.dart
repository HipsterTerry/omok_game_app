import 'character.dart';

enum PlayerRank {
  // 급수 시스템 (30급부터 시작)
  kyu30,
  kyu29,
  kyu28,
  kyu27,
  kyu26,
  kyu25,
  kyu24,
  kyu23,
  kyu22,
  kyu21,
  kyu20,
  kyu19,
  kyu18,
  kyu17,
  kyu16,
  kyu15,
  kyu14,
  kyu13,
  kyu12,
  kyu11,
  kyu10,
  kyu9,
  kyu8,
  kyu7,
  kyu6,
  kyu5,
  kyu4,
  kyu3,
  kyu2,
  kyu1,

  // 단 시스템
  dan1,
  dan2,
  dan3,
  dan4,
  dan5,
  dan6,
  dan7,
  dan8,
  dan9,

  // 고급 단계
  master,
  grandMaster,
}

enum BoardSize {
  small(13), // 초급
  medium(17), // 중급
  large(21); // 고급

  const BoardSize(this.size);
  final int size;

  String get description {
    switch (this) {
      case BoardSize.small:
        return '초급 (13x13)';
      case BoardSize.medium:
        return '중급 (17x17)';
      case BoardSize.large:
        return '고급 (21x21)';
    }
  }
}

class PlayerStats {
  final int totalGames;
  final int wins;
  final int losses;
  final int draws;
  final int winStreak;
  final int maxWinStreak;
  final int experience;
  final int level;

  const PlayerStats({
    this.totalGames = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.winStreak = 0,
    this.maxWinStreak = 0,
    this.experience = 0,
    this.level = 1,
  });

  double get winRate {
    if (totalGames == 0) return 0.0;
    return (wins / totalGames) * 100;
  }

  PlayerStats copyWith({
    int? totalGames,
    int? wins,
    int? losses,
    int? draws,
    int? winStreak,
    int? maxWinStreak,
    int? experience,
    int? level,
  }) {
    return PlayerStats(
      totalGames: totalGames ?? this.totalGames,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      winStreak: winStreak ?? this.winStreak,
      maxWinStreak:
          maxWinStreak ?? this.maxWinStreak,
      experience: experience ?? this.experience,
      level: level ?? this.level,
    );
  }
}

class PlayerProfile {
  final String playerId;
  final String nickname;
  final String avatarPath;
  final PlayerRank rank;
  final PlayerStats stats;
  final Character? selectedCharacter;
  final List<Character> unlockedCharacters;
  final int coins;
  final int gems; // 프리미엄 화폐
  final DateTime createdAt;
  final DateTime lastPlayedAt;
  final BoardSize preferredBoardSize;

  const PlayerProfile({
    required this.playerId,
    required this.nickname,
    required this.avatarPath,
    required this.rank,
    required this.stats,
    this.selectedCharacter,
    required this.unlockedCharacters,
    this.coins = 0,
    this.gems = 0,
    required this.createdAt,
    required this.lastPlayedAt,
    this.preferredBoardSize = BoardSize.small,
  });

  String get rankDisplayName {
    switch (rank) {
      case PlayerRank.kyu30:
        return '30급';
      case PlayerRank.kyu29:
        return '29급';
      case PlayerRank.kyu28:
        return '28급';
      case PlayerRank.kyu27:
        return '27급';
      case PlayerRank.kyu26:
        return '26급';
      case PlayerRank.kyu25:
        return '25급';
      case PlayerRank.kyu24:
        return '24급';
      case PlayerRank.kyu23:
        return '23급';
      case PlayerRank.kyu22:
        return '22급';
      case PlayerRank.kyu21:
        return '21급';
      case PlayerRank.kyu20:
        return '20급';
      case PlayerRank.kyu19:
        return '19급';
      case PlayerRank.kyu18:
        return '18급';
      case PlayerRank.kyu17:
        return '17급';
      case PlayerRank.kyu16:
        return '16급';
      case PlayerRank.kyu15:
        return '15급';
      case PlayerRank.kyu14:
        return '14급';
      case PlayerRank.kyu13:
        return '13급';
      case PlayerRank.kyu12:
        return '12급';
      case PlayerRank.kyu11:
        return '11급';
      case PlayerRank.kyu10:
        return '10급';
      case PlayerRank.kyu9:
        return '9급';
      case PlayerRank.kyu8:
        return '8급';
      case PlayerRank.kyu7:
        return '7급';
      case PlayerRank.kyu6:
        return '6급';
      case PlayerRank.kyu5:
        return '5급';
      case PlayerRank.kyu4:
        return '4급';
      case PlayerRank.kyu3:
        return '3급';
      case PlayerRank.kyu2:
        return '2급';
      case PlayerRank.kyu1:
        return '1급';
      case PlayerRank.dan1:
        return '1단';
      case PlayerRank.dan2:
        return '2단';
      case PlayerRank.dan3:
        return '3단';
      case PlayerRank.dan4:
        return '4단';
      case PlayerRank.dan5:
        return '5단';
      case PlayerRank.dan6:
        return '6단';
      case PlayerRank.dan7:
        return '7단';
      case PlayerRank.dan8:
        return '8단';
      case PlayerRank.dan9:
        return '9단';
      case PlayerRank.master:
        return 'Master';
      case PlayerRank.grandMaster:
        return 'Grand Master';
    }
  }

  bool get canPromote {
    // 승급 조건: 승률 60% 이상, 최소 10게임 이상
    return stats.totalGames >= 10 &&
        stats.winRate >= 60.0;
  }

  PlayerProfile copyWith({
    String? playerId,
    String? nickname,
    String? avatarPath,
    PlayerRank? rank,
    PlayerStats? stats,
    Character? selectedCharacter,
    List<Character>? unlockedCharacters,
    int? coins,
    int? gems,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
    BoardSize? preferredBoardSize,
  }) {
    return PlayerProfile(
      playerId: playerId ?? this.playerId,
      nickname: nickname ?? this.nickname,
      avatarPath: avatarPath ?? this.avatarPath,
      rank: rank ?? this.rank,
      stats: stats ?? this.stats,
      selectedCharacter:
          selectedCharacter ??
          this.selectedCharacter,
      unlockedCharacters:
          unlockedCharacters ??
          this.unlockedCharacters,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt:
          lastPlayedAt ?? this.lastPlayedAt,
      preferredBoardSize:
          preferredBoardSize ??
          this.preferredBoardSize,
    );
  }
}
