import 'package:flutter/material.dart';
import '../models/character.dart';

class CharacterCardWidget
    extends StatelessWidget {
  final Character character;
  final bool isUnlocked;
  final bool isSelected;
  final VoidCallback? onTap;

  const CharacterCardWidget({
    super.key,
    required this.character,
    required this.isUnlocked,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? _getTierColor(character.tier)
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 
                0.1,
              ),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            if (isSelected)
              BoxShadow(
                color: _getTierColor(
                  character.tier,
                ).withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              16,
            ),
          ),
          child: Stack(
            children: [
              // 배경 그라데이션
              Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isUnlocked
                        ? [
                            _getTierColor(
                              character.tier,
                            ).withValues(alpha: 0.1),
                            _getTierColor(
                              character.tier,
                            ).withValues(alpha: 0.05),
                          ]
                        : [
                            Colors.grey
                                .withValues(alpha: 0.1),
                            Colors.grey
                                .withValues(alpha: 
                                  0.05,
                                ),
                          ],
                  ),
                ),
              ),

              // 잠금 상태 오버레이
              if (!isUnlocked)
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(16),
                    color: Colors.black
                        .withValues(alpha: 0.6),
                  ),
                ),

              // 카드 내용
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    // 상단: 캐릭터 이미지와 등급
                    Column(
                      children: [
                        // 등급 배지
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                          decoration: BoxDecoration(
                            color: _getTierColor(
                              character.tier,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                                  12,
                                ),
                          ),
                          child: Text(
                            character.tierName,
                            style:
                                const TextStyle(
                                  color: Colors
                                      .white,
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // 캐릭터 이미지 (임시로 아이콘 사용)
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isUnlocked
                                ? _getTierColor(
                                    character
                                        .tier,
                                  ).withValues(alpha: 
                                    0.2,
                                  )
                                : Colors.grey
                                      .withValues(alpha: 
                                        0.3,
                                      ),
                            shape:
                                BoxShape.circle,
                          ),
                          child: Icon(
                            _getCharacterIcon(
                              character.type,
                            ),
                            size: 30,
                            color: isUnlocked
                                ? _getTierColor(
                                    character
                                        .tier,
                                  )
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    // 하단: 캐릭터 정보
                    Column(
                      children: [
                        Text(
                          character.koreanName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                            color: isUnlocked
                                ? Colors.black87
                                : Colors.grey,
                          ),
                          textAlign:
                              TextAlign.center,
                        ),

                        const SizedBox(height: 4),

                        Text(
                          '+${character.winRateBonus.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: isUnlocked
                                ? _getTierColor(
                                    character
                                        .tier,
                                  )
                                : Colors.grey,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // 스킬 타입 표시
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                          decoration: BoxDecoration(
                            color:
                                _getSkillTypeColor(
                                  character
                                      .skill
                                      .type,
                                ).withValues(alpha: 
                                  0.2,
                                ),
                            borderRadius:
                                BorderRadius.circular(
                                  8,
                                ),
                          ),
                          child: Text(
                            _getSkillTypeName(
                              character
                                  .skill
                                  .type,
                            ),
                            style: TextStyle(
                              fontSize: 10,
                              color: isUnlocked
                                  ? _getSkillTypeColor(
                                      character
                                          .skill
                                          .type,
                                    )
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 잠금 아이콘
              if (!isUnlocked)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 20,
                  ),
                ),

              // 선택 체크마크
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getTierColor(
                        character.tier,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTierColor(CharacterTier tier) {
    switch (tier) {
      case CharacterTier.heaven:
        return const Color(0xFFFFD700); // 금색
      case CharacterTier.earth:
        return const Color(0xFF8B4513); // 갈색
      case CharacterTier.human:
        return const Color(0xFF708090); // 회색
    }
  }

  Color _getSkillTypeColor(SkillType type) {
    switch (type) {
      case SkillType.offensive:
        return Colors.red;
      case SkillType.defensive:
        return Colors.blue;
      case SkillType.disruptive:
        return Colors.purple;
      case SkillType.timeControl:
        return Colors.orange;
    }
  }

  String _getSkillTypeName(SkillType type) {
    switch (type) {
      case SkillType.offensive:
        return '공격';
      case SkillType.defensive:
        return '방어';
      case SkillType.disruptive:
        return '교란';
      case SkillType.timeControl:
        return '시간';
    }
  }

  IconData _getCharacterIcon(CharacterType type) {
    switch (type) {
      case CharacterType.rat:
        return Icons.mouse;
      case CharacterType.ox:
        return Icons.emoji_nature;
      case CharacterType.tiger:
        return Icons.pets;
      case CharacterType.rabbit:
        return Icons.cruelty_free;
      case CharacterType.dragon:
        return Icons.whatshot;
      case CharacterType.snake:
        return Icons.timeline;
      case CharacterType.horse:
        return Icons.directions_run;
      case CharacterType.goat:
        return Icons.agriculture;
      case CharacterType.monkey:
        return Icons.face;
      case CharacterType.rooster:
        return Icons.alarm;
      case CharacterType.dog:
        return Icons.pets_outlined;
      case CharacterType.pig:
        return Icons.savings;
    }
  }
}
