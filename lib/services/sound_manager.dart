import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../models/character.dart';

class SoundManager {
  static final SoundManager _instance =
      SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _effectPlayer = AudioPlayer();
  final AudioPlayer _backgroundPlayer =
      AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _effectVolume = 0.7;
  double _musicVolume = 0.5;

  // 사운드 설정
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  double get effectVolume => _effectVolume;
  double get musicVolume => _musicVolume;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      _backgroundPlayer.stop();
    }
  }

  void setEffectVolume(double volume) {
    _effectVolume = volume;
    _effectPlayer.setVolume(volume);
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume;
    _backgroundPlayer.setVolume(volume);
  }

  // 효과음 재생
  Future<void> playStonePlace(
    bool isBlack,
  ) async {
    if (!_soundEnabled) return;

    try {
      // 햅틱 피드백 + 시스템 사운드
      await _playSystemSound(
        isBlack ? 'stone_black' : 'stone_white',
      );

      // 햅틱 피드백 추가
      await _playHapticFeedback();
    } catch (e) {
      print('사운드 재생 오류: $e');
    }
  }

  Future<void> playSkillActivation(
    SkillType skillType,
  ) async {
    if (!_soundEnabled) return;

    try {
      String soundKey;
      switch (skillType) {
        case SkillType.offensive:
          soundKey = 'skill_fire';
          break;
        case SkillType.defensive:
          soundKey = 'skill_shield';
          break;
        case SkillType.disruptive:
          soundKey = 'skill_magic';
          break;
        case SkillType.timeControl:
          soundKey = 'skill_time';
          break;
      }
      await _playSystemSound(soundKey);
    } catch (e) {
      print('스킬 사운드 재생 오류: $e');
    }
  }

  Future<void> playVictory() async {
    if (!_soundEnabled) return;

    try {
      await _playSystemSound('victory');
    } catch (e) {
      print('승리 사운드 재생 오류: $e');
    }
  }

  Future<void> playDefeat() async {
    if (!_soundEnabled) return;

    try {
      await _playSystemSound('defeat');
    } catch (e) {
      print('패배 사운드 재생 오류: $e');
    }
  }

  Future<void> playButtonClick() async {
    if (!_soundEnabled) return;

    try {
      await _playSystemSound('button_click');
    } catch (e) {
      print('버튼 클릭 사운드 재생 오류: $e');
    }
  }

  Future<void> playGameStart() async {
    if (!_soundEnabled) return;

    try {
      await _playSystemSound('game_start');
    } catch (e) {
      print('게임 시작 사운드 재생 오류: $e');
    }
  }

  Future<void> playTimeWarning() async {
    if (!_soundEnabled) return;

    try {
      await _playSystemSound('time_warning');
    } catch (e) {
      print('시간 경고 사운드 재생 오류: $e');
    }
  }

  // 배경음악 재생
  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;

    try {
      await _backgroundPlayer.setVolume(
        _musicVolume,
      );
      // 실제 배경음악 파일이 있다면:
      // await _backgroundPlayer.play(AssetSource('audio/background_music.mp3'));
      // await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print('배경음악 재생 오류: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundPlayer.stop();
    } catch (e) {
      print('배경음악 정지 오류: $e');
    }
  }

  // 시스템 사운드 시뮬레이션 (실제 파일 없이 테스트용)
  Future<void> _playSystemSound(
    String soundKey,
  ) async {
    try {
      // 현재는 콘솔 로그로 대체
      print(
        '🔊 사운드 재생: $soundKey (볼륨: $_effectVolume)',
      );

      // 시스템 사운드 + 햅틱 피드백으로 사운드 효과 시뮬레이션
      await _playAlternativeSound(soundKey);
    } catch (e) {
      print('사운드 재생 오류: $e');
    }
  }

  // 대안 사운드 효과 (실제 파일 없이)
  Future<void> _playAlternativeSound(
    String soundKey,
  ) async {
    try {
      switch (soundKey) {
        case 'stone_black':
        case 'stone_white':
          // 돌 놓는 소리 - 시스템 클릭음 + 햅틱
          await SystemSound.play(
            SystemSoundType.click,
          );
          await HapticFeedback.selectionClick();
          print('🎯 돌 놓기: 시스템 클릭음 + 햅틱');
          break;
        case 'victory':
          // 승리 소리 - 강한 햅틱 + 시스템 알림음
          await HapticFeedback.heavyImpact();
          await SystemSound.play(
            SystemSoundType.alert,
          );
          // 추가 승리 효과음 - 여러 번 재생
          await Future.delayed(
            Duration(milliseconds: 100),
          );
          await SystemSound.play(
            SystemSoundType.click,
          );
          await Future.delayed(
            Duration(milliseconds: 100),
          );
          await SystemSound.play(
            SystemSoundType.click,
          );
          print('🏆 승리: 시스템 알림음 + 강한 햅틱 + 연속음');
          break;
        case 'button_click':
          // 버튼 클릭 - 시스템 클릭음 + 가벼운 햅틱
          await SystemSound.play(
            SystemSoundType.click,
          );
          await HapticFeedback.lightImpact();
          print('👆 버튼 클릭: 시스템 클릭음 + 햅틱');
          break;
        case 'game_start':
          // 게임 시작 - 시스템 클릭음 연속
          await SystemSound.play(
            SystemSoundType.click,
          );
          await Future.delayed(
            Duration(milliseconds: 150),
          );
          await SystemSound.play(
            SystemSoundType.click,
          );
          await HapticFeedback.mediumImpact();
          print('🎮 게임 시작: 시스템 연속음 + 햅틱');
          break;
        case 'skill_fire':
        case 'skill_shield':
        case 'skill_magic':
        case 'skill_time':
          // 스킬 효과 - 특별한 패턴
          await HapticFeedback.heavyImpact();
          await SystemSound.play(
            SystemSoundType.alert,
          );
          await Future.delayed(
            Duration(milliseconds: 50),
          );
          await HapticFeedback.mediumImpact();
          print('⚡ 스킬 사용: 강화된 사운드 패턴');
          break;
        case 'time_warning':
          // 시간 경고 - 강한 알림
          await HapticFeedback.vibrate();
          await SystemSound.play(
            SystemSoundType.alert,
          );
          await Future.delayed(
            Duration(milliseconds: 200),
          );
          await HapticFeedback.vibrate();
          print('⏰ 시간 경고: 강화된 알림');
          break;
        default:
          await SystemSound.play(
            SystemSoundType.click,
          );
          await HapticFeedback.selectionClick();
      }
    } catch (e) {
      print('대안 사운드 재생 오류: $e');
    }
  }

  // 햅틱 피드백 재생
  Future<void> _playHapticFeedback() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      print('햅틱 피드백 오류: $e');
    }
  }

  // 리소스 정리
  void dispose() {
    _effectPlayer.dispose();
    _backgroundPlayer.dispose();
  }
}

// 사운드 설정을 위한 enum
enum SoundType {
  stonePlace,
  skillActivation,
  victory,
  defeat,
  buttonClick,
  gameStart,
  timeWarning,
}

// 사운드 설정 모델
class SoundSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final double effectVolume;
  final double musicVolume;

  const SoundSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.effectVolume = 0.7,
    this.musicVolume = 0.5,
  });

  SoundSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    double? effectVolume,
    double? musicVolume,
  }) {
    return SoundSettings(
      soundEnabled:
          soundEnabled ?? this.soundEnabled,
      musicEnabled:
          musicEnabled ?? this.musicEnabled,
      effectVolume:
          effectVolume ?? this.effectVolume,
      musicVolume:
          musicVolume ?? this.musicVolume,
    );
  }
}
