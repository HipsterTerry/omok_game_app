import '../models/character.dart';

class CharacterService {
  static final Map<CharacterType, Character>
  _characters = {
    // 천급 캐릭터 (15% 승률 우위)
    CharacterType.dragon: Character(
      type: CharacterType.dragon,
      name: 'Azure Dragon',
      koreanName: '청룡',
      tier: CharacterTier.heaven,
      skill: CharacterSkill(
        name: '천둥번개',
        description: '상대방의 다음 수를 무효화합니다',
        type: SkillType.disruptive,
        cooldown: 0,
        effects: {'disable_next_move': true},
      ),
      winRateBonus: 15.0,
      imagePath: 'assets/characters/dragon.png',
      description: '하늘을 지배하는 용의 힘으로 상대를 압도합니다',
    ),

    CharacterType.tiger: Character(
      type: CharacterType.tiger,
      name: 'White Tiger',
      koreanName: '백호',
      tier: CharacterTier.heaven,
      skill: CharacterSkill(
        name: '맹호의 일격',
        description: '상대방의 돌 하나를 제거합니다',
        type: SkillType.offensive,
        cooldown: 0,
        effects: {'remove_stone': true},
      ),
      winRateBonus: 15.0,
      imagePath: 'assets/characters/tiger.png',
      description: '서방의 백호, 강력한 공격력을 가집니다',
    ),

    CharacterType.snake: Character(
      type: CharacterType.snake,
      name: 'Mystic Snake',
      koreanName: '현무뱀',
      tier: CharacterTier.heaven,
      skill: CharacterSkill(
        name: '독사의 독',
        description: '상대방의 시간을 30초 감소시킵니다',
        type: SkillType.timeControl,
        cooldown: 0,
        effects: {'reduce_time': 30},
      ),
      winRateBonus: 15.0,
      imagePath: 'assets/characters/snake.png',
      description: '신비로운 뱀의 독으로 상대를 혼란에 빠뜨립니다',
    ),

    // 지급 캐릭터 (8-10% 승률 우위)
    CharacterType.horse: Character(
      type: CharacterType.horse,
      name: 'Swift Horse',
      koreanName: '천리마',
      tier: CharacterTier.earth,
      skill: CharacterSkill(
        name: '질주',
        description: '연속으로 두 번 둘 수 있습니다',
        type: SkillType.offensive,
        cooldown: 0,
        effects: {'extra_turn': true},
      ),
      winRateBonus: 10.0,
      imagePath: 'assets/characters/horse.png',
      description: '빠른 속도로 상대를 앞서나갑니다',
    ),

    CharacterType.monkey: Character(
      type: CharacterType.monkey,
      name: 'Clever Monkey',
      koreanName: '영리원숭이',
      tier: CharacterTier.earth,
      skill: CharacterSkill(
        name: '속임수',
        description: '이미 놓인 돌의 위치를 한 칸 이동시킵니다',
        type: SkillType.disruptive,
        cooldown: 0,
        effects: {'move_stone': true},
      ),
      winRateBonus: 9.0,
      imagePath: 'assets/characters/monkey.png',
      description: '영리한 꾀로 상황을 역전시킵니다',
    ),

    CharacterType.rooster: Character(
      type: CharacterType.rooster,
      name: 'Golden Rooster',
      koreanName: '금계',
      tier: CharacterTier.earth,
      skill: CharacterSkill(
        name: '새벽울음',
        description: '시간을 30초 추가로 얻습니다',
        type: SkillType.timeControl,
        cooldown: 0,
        effects: {'add_time': 30},
      ),
      winRateBonus: 8.0,
      imagePath: 'assets/characters/rooster.png',
      description: '새벽을 알리는 닭의 울음으로 시간을 조절합니다',
    ),

    CharacterType.dog: Character(
      type: CharacterType.dog,
      name: 'Loyal Dog',
      koreanName: '충견',
      tier: CharacterTier.earth,
      skill: CharacterSkill(
        name: '수호',
        description: '다음 상대방의 공격 스킬을 무효화합니다',
        type: SkillType.defensive,
        cooldown: 0,
        effects: {'block_skill': true},
      ),
      winRateBonus: 8.0,
      imagePath: 'assets/characters/dog.png',
      description: '충실한 개의 수호로 위험을 막아냅니다',
    ),

    // 인급 캐릭터 (2-4% 승률 우위)
    CharacterType.rat: Character(
      type: CharacterType.rat,
      name: 'Quick Rat',
      koreanName: '쥐돌이',
      tier: CharacterTier.human,
      skill: CharacterSkill(
        name: '재빠른 움직임',
        description: '상대방의 마지막 수를 확인할 수 있습니다',
        type: SkillType.disruptive,
        cooldown: 0,
        effects: {'reveal_last_move': true},
      ),
      winRateBonus: 2.0,
      imagePath: 'assets/characters/rat.png',
      description: '작지만 재빠른 쥐의 민첩함을 활용합니다',
    ),

    CharacterType.ox: Character(
      type: CharacterType.ox,
      name: 'Strong Ox',
      koreanName: '황소',
      tier: CharacterTier.human,
      skill: CharacterSkill(
        name: '완고함',
        description: '다음 턴에 받는 모든 효과를 무시합니다',
        type: SkillType.defensive,
        cooldown: 0,
        effects: {'immunity': true},
      ),
      winRateBonus: 3.0,
      imagePath: 'assets/characters/ox.png',
      description: '황소의 완고함으로 모든 방해를 이겨냅니다',
    ),

    CharacterType.rabbit: Character(
      type: CharacterType.rabbit,
      name: 'Lucky Rabbit',
      koreanName: '행운토끼',
      tier: CharacterTier.human,
      skill: CharacterSkill(
        name: '행운',
        description: '랜덤한 좋은 효과를 받습니다',
        type: SkillType.defensive,
        cooldown: 0,
        effects: {'random_bonus': true},
      ),
      winRateBonus: 4.0,
      imagePath: 'assets/characters/rabbit.png',
      description: '토끼의 행운으로 예상치 못한 기회를 얻습니다',
    ),

    CharacterType.goat: Character(
      type: CharacterType.goat,
      name: 'Peaceful Goat',
      koreanName: '평화양',
      tier: CharacterTier.human,
      skill: CharacterSkill(
        name: '평화',
        description: '양 플레이어의 시간이 30초씩 추가됩니다',
        type: SkillType.timeControl,
        cooldown: 0,
        effects: {'add_time_both': 30},
      ),
      winRateBonus: 2.0,
      imagePath: 'assets/characters/goat.png',
      description: '양의 평화로운 성격으로 게임에 여유를 가져다줍니다',
    ),

    CharacterType.pig: Character(
      type: CharacterType.pig,
      name: 'Fortune Pig',
      koreanName: '복돼지',
      tier: CharacterTier.human,
      skill: CharacterSkill(
        name: '황금돼지',
        description: '게임 종료 후 코인을 2배로 받습니다',
        type: SkillType.defensive,
        cooldown: 0,
        effects: {'double_coins': true},
      ),
      winRateBonus: 3.0,
      imagePath: 'assets/characters/pig.png',
      description: '복을 가져다주는 돼지로 더 많은 보상을 얻습니다',
    ),
  };

  // 모든 캐릭터 목록 가져오기
  static List<Character> getAllCharacters() {
    return _characters.values.toList();
  }

  // 특정 캐릭터 가져오기
  static Character? getCharacter(
    CharacterType type,
  ) {
    return _characters[type];
  }

  // 등급별 캐릭터 가져오기
  static List<Character> getCharactersByTier(
    CharacterTier tier,
  ) {
    return _characters.values
        .where((char) => char.tier == tier)
        .toList();
  }

  // 천급 캐릭터들
  static List<Character>
  getHeavenTierCharacters() {
    return getCharactersByTier(
      CharacterTier.heaven,
    );
  }

  // 지급 캐릭터들
  static List<Character>
  getEarthTierCharacters() {
    return getCharactersByTier(
      CharacterTier.earth,
    );
  }

  // 인급 캐릭터들
  static List<Character>
  getHumanTierCharacters() {
    return getCharactersByTier(
      CharacterTier.human,
    );
  }

  // 기본 제공 캐릭터 (게임 시작 시)
  static List<Character> getStarterCharacters() {
    return [
      _characters[CharacterType.rat]!,
      _characters[CharacterType.ox]!,
      _characters[CharacterType.rabbit]!,
    ];
  }

  // 캐릭터 잠금 해제 조건 확인
  static bool canUnlockCharacter(
    CharacterType type,
    int playerLevel,
    int coins,
  ) {
    final character = _characters[type];
    if (character == null) return false;

    switch (character.tier) {
      case CharacterTier.heaven:
        return playerLevel >= 20 && coins >= 5000;
      case CharacterTier.earth:
        return playerLevel >= 10 && coins >= 2000;
      case CharacterTier.human:
        return playerLevel >= 5 && coins >= 500;
    }
  }

  // 캐릭터 잠금 해제 비용
  static int getUnlockCost(CharacterType type) {
    final character = _characters[type];
    if (character == null) return 0;

    switch (character.tier) {
      case CharacterTier.heaven:
        return 5000;
      case CharacterTier.earth:
        return 2000;
      case CharacterTier.human:
        return 500;
    }
  }

  // 스킬 효과 적용
  static Map<String, dynamic> applySkillEffect(
    CharacterSkill skill,
    Map<String, dynamic> gameState,
  ) {
    final effects = Map<String, dynamic>.from(
      gameState,
    );

    skill.effects.forEach((effectType, value) {
      switch (effectType) {
        case 'disable_next_move':
          effects['opponentMoveDisabled'] = true;
          break;
        case 'remove_stone':
          effects['canRemoveStone'] = true;
          break;
        case 'reduce_time':
          effects['opponentTimeReduction'] =
              value;
          break;
        case 'extra_turn':
          effects['hasExtraTurn'] = true;
          break;
        case 'move_stone':
          effects['canMoveStone'] = true;
          break;
        case 'add_time':
          effects['timeBonus'] = value;
          break;
        case 'block_skill':
          effects['skillBlocked'] = true;
          break;
        case 'reveal_last_move':
          effects['lastMoveRevealed'] = true;
          break;
        case 'immunity':
          effects['immuneToEffects'] = true;
          break;
        case 'random_bonus':
          effects['randomBonus'] =
              _getRandomBonus();
          break;
        case 'add_time_both':
          effects['timeBonusBoth'] = value;
          break;
        case 'double_coins':
          effects['doubleCoinReward'] = true;
          break;
      }
    });

    return effects;
  }

  static Map<String, dynamic> _getRandomBonus() {
    final bonuses = [
      {'type': 'time', 'value': 20},
      {'type': 'extra_move', 'value': true},
      {'type': 'reveal_hint', 'value': true},
      {'type': 'immunity', 'value': true},
    ];

    bonuses.shuffle();
    return bonuses.first;
  }
}
