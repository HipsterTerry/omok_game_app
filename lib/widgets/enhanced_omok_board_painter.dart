import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/enhanced_game_state.dart';
import '../models/character.dart';
import '../models/game_state.dart';
import '../models/player_profile.dart';

class EnhancedOmokBoardPainter
    extends CustomPainter {
  final EnhancedGameState gameState;
  late final double stoneRadius;
  final bool showCoordinates;
  final BoardSize boardSizeType;
  final Position? hoverPosition;
  final bool isPressed;

  EnhancedOmokBoardPainter({
    required this.gameState,
    required this.boardSizeType,
    this.showCoordinates = false,
    this.hoverPosition,
    this.isPressed = false,
  }) {
    // 동적으로 돌 크기 계산 (보드 크기에 비례)
    final boardSize = gameState.boardSize;
    stoneRadius =
        (400.0 / (boardSize + 1)) *
        0.4; // 보드 크기에 맞는 돌 크기
  }

  @override
  void paint(Canvas canvas, Size size) {
    final boardSize = gameState.boardSize;

    // 정확한 좌표 계산
    final cellSize = size.width / (boardSize + 1);
    final boardRect = Rect.fromLTWH(
      cellSize,
      cellSize,
      cellSize * (boardSize - 1),
      cellSize * (boardSize - 1),
    );

    // 1. 테마별 나무 질감 배경 그리기
    _drawThemedWoodenBackground(canvas, size);

    // 2. 바둑판 선 그리기
    _drawBoardLines(
      canvas,
      boardRect,
      cellSize,
      boardSize,
    );

    // 3. 화점(별점) 그리기
    _drawStarPoints(canvas, cellSize, boardSize);

    // 4. 좌표 표시 (옵션)
    if (showCoordinates) {
      _drawCoordinates(
        canvas,
        boardRect,
        cellSize,
        boardSize,
      );
    }

    // 5. 바둑돌과 캐릭터 그리기 - PNG 이미지로 대체됨
    // _drawStones(canvas, cellSize, boardSize);

    // 6. 마지막 수 표시
    _drawLastMoveIndicator(canvas, cellSize);

    // 7. 호버 효과 표시 (돌 놓기 미리보기)
    if (hoverPosition != null) {
      _drawHoverEffect(canvas, cellSize);
    }

    // 8. 승리 라인 표시 (게임 종료 시)
    if (gameState.status != GameStatus.playing) {
      _drawWinningLine(canvas, cellSize);
    }
  }

  void _drawThemedWoodenBackground(
    Canvas canvas,
    Size size,
  ) {
    List<Color> woodColors;
    double grainOpacity;

    // 보드 크기별 테마 적용
    switch (boardSizeType) {
      case BoardSize.small: // 초급 (13x13) - 밝은 나무
        woodColors = [
          const Color(0xFFF5DEB3), // Wheat
          const Color(0xFFDEB887), // BurlyWood
          const Color(0xFFD2B48C), // Tan
          const Color(0xFFDEB887),
        ];
        grainOpacity = 0.08;
        break;
      case BoardSize
          .medium: // 중급 (16x16) - 클래식 중간 톤
        woodColors = [
          const Color(0xFFDEB887), // BurlyWood
          const Color(0xFFD2B48C), // Tan
          const Color(0xFFCD853F), // Peru
          const Color(0xFFD2B48C),
        ];
        grainOpacity = 0.12;
        break;
      case BoardSize
          .large: // 고급 (19x19) - 어두운 고급 목재
        woodColors = [
          const Color(0xFFCD853F), // Peru
          const Color(0xFFA0522D), // Sienna
          const Color(0xFF8B4513), // SaddleBrown
          const Color(0xFFA0522D),
        ];
        grainOpacity = 0.15;
        break;
    }

    final woodGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: woodColors,
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    final backgroundPaint = Paint()
      ..shader = woodGradient.createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
      backgroundPaint,
    );

    // 테마별 나무 결 패턴
    _drawThemedWoodGrain(
      canvas,
      size,
      grainOpacity,
    );

    // 고급 보드에는 전통 문양 추가
    if (boardSizeType == BoardSize.large) {
      _drawTraditionalPattern(canvas, size);
    }
  }

  void _drawThemedWoodGrain(
    Canvas canvas,
    Size size,
    double opacity,
  ) {
    final grainPaint = Paint()
      ..color = const Color(
        0xFFDEB887,
      ).withValues(alpha: opacity)
      ..strokeWidth = 0.5;

    final random = math.Random(
      42,
    ); // 시드 고정으로 일관된 패턴

    for (int i = 0; i < 20; i++) {
      final y = size.height * i / 20;
      final path = Path();
      path.moveTo(0, y);

      for (
        double x = 0;
        x <= size.width;
        x += 10
      ) {
        final yOffset =
            math.sin(x * 0.02) * 3 +
            random.nextDouble() * 2;
        path.lineTo(x, y + yOffset);
      }

      canvas.drawPath(path, grainPaint);
    }
  }

  void _drawTraditionalPattern(
    Canvas canvas,
    Size size,
  ) {
    final patternPaint = Paint()
      ..color = const Color(
        0xFF8B4513,
      ).withValues(alpha: 0.08)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius =
        math.min(size.width, size.height) * 0.4;

    // 전통 한국 문양 (간단한 원형 패턴)
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius * i / 3,
        patternPaint,
      );
    }

    // 대각선 패턴
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final startX =
          centerX +
          math.cos(angle) * radius * 0.3;
      final startY =
          centerY +
          math.sin(angle) * radius * 0.3;
      final endX =
          centerX +
          math.cos(angle) * radius * 0.7;
      final endY =
          centerY +
          math.sin(angle) * radius * 0.7;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        patternPaint,
      );
    }
  }

  void _drawBoardLines(
    Canvas canvas,
    Rect boardRect,
    double cellSize,
    int boardSize,
  ) {
    // 기본 격자선 (더 부드럽고 우아한 색상)
    final linePaint = Paint()
      ..color =
          const Color(0xFF4A4A4A) // 부드러운 진회색
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // 외곽선용 페인트 (더 진하게)
    final borderPaint = Paint()
      ..color =
          const Color(0xFF2A2A2A) // 진한 회색
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // 중앙선 강조용 페인트 (미묘하게)
    final centerLinePaint = Paint()
      ..color =
          const Color(0xFF3A3A3A) // 중간 진회색
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final center = (boardSize - 1) ~/ 2;

    // 세로선 그리기
    for (int i = 0; i < boardSize; i++) {
      final x = cellSize * (i + 1);
      Paint currentPaint;

      if (i == 0 || i == boardSize - 1) {
        currentPaint = borderPaint; // 외곽선
      } else if (i == center) {
        currentPaint = centerLinePaint; // 중앙선
      } else {
        currentPaint = linePaint; // 일반선
      }

      canvas.drawLine(
        Offset(x, cellSize),
        Offset(x, cellSize * boardSize),
        currentPaint,
      );
    }

    // 가로선 그리기
    for (int i = 0; i < boardSize; i++) {
      final y = cellSize * (i + 1);
      Paint currentPaint;

      if (i == 0 || i == boardSize - 1) {
        currentPaint = borderPaint; // 외곽선
      } else if (i == center) {
        currentPaint = centerLinePaint; // 중앙선
      } else {
        currentPaint = linePaint; // 일반선
      }

      canvas.drawLine(
        Offset(cellSize, y),
        Offset(cellSize * boardSize, y),
        currentPaint,
      );
    }

    // 격자선에 미묘한 그림자 효과 추가
    _drawGridShadow(canvas, cellSize, boardSize);
  }

  void _drawGridShadow(
    Canvas canvas,
    double cellSize,
    int boardSize,
  ) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // 그림자는 1픽셀 오프셋으로 그리기
    for (int i = 0; i < boardSize; i++) {
      // 세로선 그림자
      final x = cellSize * (i + 1);
      canvas.drawLine(
        Offset(x + 0.5, cellSize + 0.5),
        Offset(
          x + 0.5,
          cellSize * boardSize + 0.5,
        ),
        shadowPaint,
      );

      // 가로선 그림자
      final y = cellSize * (i + 1);
      canvas.drawLine(
        Offset(cellSize + 0.5, y + 0.5),
        Offset(
          cellSize * boardSize + 0.5,
          y + 0.5,
        ),
        shadowPaint,
      );
    }
  }

  void _drawStarPoints(
    Canvas canvas,
    double cellSize,
    int boardSize,
  ) {
    final starPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    List<List<int>> starPoints = [];

    // 보드 크기별 화점 설정 (0-based 인덱스, 정확한 중앙 위치)
    if (boardSize == 13) {
      // 13x13: 정확한 중심점 (6,6) - 0부터 12까지 중에서 6이 중앙
      final center = 6;
      starPoints = [
        [3, 3], [3, 9], [9, 3], [9, 9], // 모서리 4개
        [center, 3], [center, 9], // 상하 중앙
        [3, center], [9, center], // 좌우 중앙
        [center, center], // 정중앙 화점 ⭐
      ];
    } else if (boardSize == 17) {
      // 17x17: 정확한 중심점 (8,8) - 0부터 16까지 중에서 8이 중앙
      final center = 8;
      starPoints = [
        [3, 3],
        [3, 13],
        [13, 3],
        [13, 13], // 모서리 4개
        [center, 3], [center, 13], // 상하 중앙
        [3, center], [13, center], // 좌우 중앙
        [center, center], // 정중앙 화점 ⭐
      ];
    } else if (boardSize == 21) {
      // 21x21: 정확한 중심점 (10,10) - 0부터 20까지 중에서 10이 중앙
      final center = 10;
      starPoints = [
        [3, 3],
        [3, 17],
        [17, 3],
        [17, 17], // 모서리 4개
        [center, 3], [center, 17], // 상하 중앙
        [3, center], [17, center], // 좌우 중앙
        [center, center], // 정중앙 화점 ⭐
      ];
    }

    // 화점 크기를 보드 크기에 따라 조정 (더 큰 크기)
    final starRadius = (cellSize * 0.15).clamp(
      4.0,
      8.0,
    );

    for (final point in starPoints) {
      // 정확한 격자점 위치 계산
      final x = cellSize * (point[0] + 1);
      final y = cellSize * (point[1] + 1);

      // 중앙 화점은 더 크게 표시
      final isCenterPoint =
          (boardSize == 13 &&
              point[0] == 6 &&
              point[1] == 6) ||
          (boardSize == 17 &&
              point[0] == 8 &&
              point[1] == 8) ||
          (boardSize == 21 &&
              point[0] == 10 &&
              point[1] == 10);

      final currentRadius = isCenterPoint
          ? starRadius * 1.5
          : starRadius;

      // 화점 그림자 그리기 (입체감)
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x + 0.5, y + 0.5), // 그림자 오프셋
        currentRadius,
        shadowPaint,
      );

      // 메인 화점 그리기 (그라데이션 효과)
      final starGradient = RadialGradient(
        colors: [
          const Color(0xFF2A2A2A), // 중심: 진한 색
          const Color(0xFF4A4A4A), // 가장자리: 연한 색
        ],
        stops: const [0.3, 1.0],
      );

      final gradientPaint = Paint()
        ..shader = starGradient.createShader(
          Rect.fromCircle(
            center: Offset(x, y),
            radius: currentRadius,
          ),
        );

      canvas.drawCircle(
        Offset(x, y),
        currentRadius,
        gradientPaint,
      );

      // 중앙 화점에 특별한 강조 효과
      if (isCenterPoint) {
        // 내부 하이라이트
        final highlightPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(x - 0.5, y - 0.5), // 하이라이트 오프셋
          currentRadius * 0.3,
          highlightPaint,
        );

        // 외부 링 (천원점 표시)
        final centerRingPaint = Paint()
          ..color = const Color(0xFF2A2A2A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

        canvas.drawCircle(
          Offset(x, y),
          currentRadius + 3,
          centerRingPaint,
        );

        // 보조 링 (더 미묘하게)
        final secondaryRingPaint = Paint()
          ..color = Colors.black.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

        canvas.drawCircle(
          Offset(x, y),
          currentRadius + 5,
          secondaryRingPaint,
        );
      }

      // 일반 화점에도 미묘한 외곽선
      if (!isCenterPoint) {
        final outlinePaint = Paint()
          ..color = Colors.black.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

        canvas.drawCircle(
          Offset(x, y),
          currentRadius + 1,
          outlinePaint,
        );
      }
    }
  }

  void _drawCoordinates(
    Canvas canvas,
    Rect boardRect,
    double cellSize,
    int boardSize,
  ) {
    final textStyle = TextStyle(
      color: Colors.black54,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    // 숫자 좌표 (왼쪽)
    for (int i = 0; i < boardSize; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${boardSize - i}',
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final y =
          boardRect.top +
          i * cellSize -
          textPainter.height / 2;
      textPainter.paint(
        canvas,
        Offset(boardRect.left - 25, y),
      );
    }

    // 알파벳 좌표 (하단)
    const letters = 'ABCDEFGHIJKLMNOPQRS';
    for (int i = 0; i < boardSize; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: letters[i],
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final x =
          boardRect.left +
          i * cellSize -
          textPainter.width / 2;
      textPainter.paint(
        canvas,
        Offset(x, boardRect.bottom + 10),
      );
    }
  }

  void _drawStones(
    Canvas canvas,
    double cellSize,
    int boardSize,
  ) {
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        final stone = gameState.board[row][col];
        if (stone != null) {
          _drawStone(
            canvas,
            cellSize * (col + 1),
            cellSize * (row + 1),
            stone,
            cellSize,
            row,
            col,
          );
        }
      }
    }
  }

  void _drawStone(
    Canvas canvas,
    double x,
    double y,
    PlayerType player,
    double cellSize,
    int row,
    int col,
  ) {
    // 🎯 오목돌 크기 적절히 조정
    final stoneRadius = cellSize * 0.42;

    // 마지막에 놓인 돌인지 확인
    final isLastMove =
        gameState.lastMove != null &&
        gameState.lastMove!.row == row &&
        gameState.lastMove!.col == col;

    // 🎯 간소화된 그림자 시스템 (2단계만)
    // 1단계: 주 그림자 (더 작고 자연스럽게)
    final mainShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        6,
      );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x + 3, y + 4),
        width: stoneRadius * 1.8,
        height: stoneRadius * 1.4,
      ),
      mainShadowPaint,
    );

    // 2단계: 접촉 그림자 (돌이 바둑판에 닿는 부분)
    final contactShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        2,
      );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x + 1, y + 1),
        width: stoneRadius * 1.6,
        height: stoneRadius * 1.2,
      ),
      contactShadowPaint,
    );

    if (player == PlayerType.black) {
      // 🖤 흑돌 - 대폭 강화된 진한 검정색과 명확한 대비

      // 베이스 돌 (완전한 검정색)
      final basePaint = Paint()
        ..color = const Color(0xFF000000);
      canvas.drawCircle(
        Offset(x, y),
        stoneRadius,
        basePaint,
      );

      // 🌟 검은돌 전용 그라데이션 (더 진하고 명확하게)
      final blackGradient = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 1.0,
        colors: [
          Colors.grey[500]!, // 하이라이트 (검은돌에 맞게 조정)
          Colors.grey[700]!, // 중간 하이라이트
          Colors.grey[900]!, // 어두운 중간 톤
          const Color(0xFF0A0A0A), // 매우 어두운 부분
          const Color(0xFF000000), // 완전한 검정 테두리
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      );

      final blackPaint = Paint()
        ..shader = blackGradient.createShader(
          Rect.fromCircle(
            center: Offset(x, y),
            radius: stoneRadius,
          ),
        );

      canvas.drawCircle(
        Offset(x, y),
        stoneRadius,
        blackPaint,
      );

      // 🔥 검은돌 하이라이트 (절제된 밝기)
      final blackHighlightPaint = Paint()
        ..color = Colors.grey[400]!.withValues(alpha: 
          0.6,
        )
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          2,
        );

      canvas.drawCircle(
        Offset(
          x - stoneRadius * 0.4,
          y - stoneRadius * 0.4,
        ),
        stoneRadius * 0.3,
        blackHighlightPaint,
      );

      // ✨ 검은돌 핀포인트 하이라이트
      final blackPinpointPaint = Paint()
        ..color = Colors.grey[300]!.withValues(alpha: 
          0.8,
        );

      canvas.drawCircle(
        Offset(
          x - stoneRadius * 0.5,
          y - stoneRadius * 0.5,
        ),
        stoneRadius * 0.1,
        blackPinpointPaint,
      );
    } else {
      // 🤍 백돌 - 대폭 강화된 순수 흰색과 명확한 대비

      // 베이스 돌 (완전한 흰색)
      final basePaint = Paint()
        ..color = const Color(0xFFFFFFFF);
      canvas.drawCircle(
        Offset(x, y),
        stoneRadius,
        basePaint,
      );

      // 🌟 흰돌 전용 그라데이션 (더 밝고 명확하게)
      final whiteGradient = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 1.0,
        colors: [
          const Color(0xFFFFFFFF), // 완전한 흰색 하이라이트
          const Color(0xFFFAFAFA), // 거의 흰색
          const Color(0xFFF0F0F0), // 연한 회색
          const Color(0xFFE0E0E0), // 중간 회색
          const Color(0xFFD0D0D0), // 테두리 회색
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      );

      final whitePaint = Paint()
        ..shader = whiteGradient.createShader(
          Rect.fromCircle(
            center: Offset(x, y),
            radius: stoneRadius,
          ),
        );

      canvas.drawCircle(
        Offset(x, y),
        stoneRadius,
        whitePaint,
      );

      // 🔥 흰돌 하이라이트 (강한 밝기)
      final whiteHighlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          2,
        );

      canvas.drawCircle(
        Offset(
          x - stoneRadius * 0.4,
          y - stoneRadius * 0.4,
        ),
        stoneRadius * 0.3,
        whiteHighlightPaint,
      );

      // ✨ 흰돌 핀포인트 하이라이트
      final whitePinpointPaint = Paint()
        ..color = Colors.white;

      canvas.drawCircle(
        Offset(
          x - stoneRadius * 0.5,
          y - stoneRadius * 0.5,
        ),
        stoneRadius * 0.1,
        whitePinpointPaint,
      );

      // 🔲 흰돌 테두리 강화 (검은돌과 구분을 위해)
      final whiteBorderPaint = Paint()
        ..color = Colors.grey[400]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawCircle(
        Offset(x, y),
        stoneRadius,
        whiteBorderPaint,
      );
    }

    // 마지막 수 표시 - 강화된 효과
    if (isLastMove) {
      // 외곽 링 애니메이션 효과
      final outerRingPaint = Paint()
        ..color =
            (player == PlayerType.black
                    ? Colors.white
                    : Colors.red)
                .withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          1,
        );

      canvas.drawCircle(
        Offset(x, y),
        stoneRadius + 6,
        outerRingPaint,
      );

      // 내부 점 표시
      final dotPaint = Paint()
        ..color = player == PlayerType.black
            ? Colors.white
            : Colors.red
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        3.0,
        dotPaint,
      );
    }

    // 캐릭터 효과 표시
    _drawCharacterEffect(
      canvas,
      x,
      y,
      player,
      stoneRadius,
      row,
      col,
    );
  }

  void _drawCharacterEffect(
    Canvas canvas,
    double x,
    double y,
    PlayerType player,
    double stoneRadius,
    int row,
    int col,
  ) {
    // 플레이어별 캐릭터 확인
    final character = player == PlayerType.black
        ? gameState.blackPlayerState.character
        : gameState.whitePlayerState.character;

    if (character != null) {
      // 캐릭터 오라 효과
      final auraPaint = Paint()
        ..color = character.tierColor.withValues(alpha: 
          0.3,
        )
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          8,
        );

      canvas.drawCircle(
        Offset(x, y),
        stoneRadius + 8,
        auraPaint,
      );

      // 등급별 특수 효과
      switch (character.tier) {
        case CharacterTier.heaven:
          // 천급 - 금색 별빛 효과
          _drawStarEffect(
            canvas,
            x,
            y,
            stoneRadius,
            const Color(0xFFFFD700),
          );
          break;
        case CharacterTier.earth:
          // 지급 - 은색 원형 효과
          _drawRingEffect(
            canvas,
            x,
            y,
            stoneRadius,
            const Color(0xFFC0C0C0),
          );
          break;
        case CharacterTier.human:
          // 인급 - 갈색 점선 효과
          _drawDottedEffect(
            canvas,
            x,
            y,
            stoneRadius,
            Colors.brown,
          );
          break;
      }
    }
  }

  void _drawStarEffect(
    Canvas canvas,
    double x,
    double y,
    double radius,
    Color color,
  ) {
    final starPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // 6각별 그리기
    final path = Path();
    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi / 6);
      final r = (i % 2 == 0)
          ? radius + 6
          : radius + 3;
      final px = x + r * math.cos(angle);
      final py = y + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, starPaint);
  }

  void _drawRingEffect(
    Canvas canvas,
    double x,
    double y,
    double radius,
    Color color,
  ) {
    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(
      Offset(x, y),
      radius + 6,
      ringPaint,
    );
    canvas.drawCircle(
      Offset(x, y),
      radius + 10,
      ringPaint,
    );
  }

  void _drawDottedEffect(
    Canvas canvas,
    double x,
    double y,
    double radius,
    Color color,
  ) {
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // 8방향으로 점 배치
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final px =
          x + (radius + 8) * math.cos(angle);
      final py =
          y + (radius + 8) * math.sin(angle);
      canvas.drawCircle(
        Offset(px, py),
        2.0,
        dotPaint,
      );
    }
  }

  void _drawHoverEffect(
    Canvas canvas,
    double cellSize,
  ) {
    if (hoverPosition == null) return;

    final x = cellSize * (hoverPosition!.col + 1);
    final y = cellSize * (hoverPosition!.row + 1);
    final center = Offset(x, y);

    // 현재 플레이어에 따라 미리보기 돌 색상 결정
    final isBlackTurn =
        gameState.currentPlayer ==
        PlayerType.black;

    // 미리보기 돌 (반투명)
    final previewPaint = Paint()
      ..color =
          (isBlackTurn
                  ? Colors.black
                  : Colors.white)
              .withValues(alpha: isPressed ? 0.7 : 0.4)
      ..style = PaintingStyle.fill;

    // 미리보기 돌 그림자
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx + 1, center.dy + 1),
      stoneRadius * (isPressed ? 0.95 : 0.9),
      shadowPaint,
    );

    // 메인 미리보기 돌
    canvas.drawCircle(
      center,
      stoneRadius * (isPressed ? 0.95 : 0.9),
      previewPaint,
    );

    // 흰 돌인 경우 외곽선 추가
    if (!isBlackTurn) {
      final outlinePaint = Paint()
        ..color = Colors.black.withValues(alpha: 
          isPressed ? 0.5 : 0.3,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(
        center,
        stoneRadius * (isPressed ? 0.95 : 0.9),
        outlinePaint,
      );
    }

    // 호버 링 효과
    final hoverRingPaint = Paint()
      ..color =
          (isBlackTurn
                  ? Colors.white
                  : Colors.black)
              .withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(
      center,
      stoneRadius + 4,
      hoverRingPaint,
    );

    // 펄스 효과 (더 큰 원)
    final pulsePaint = Paint()
      ..color =
          (isBlackTurn
                  ? Colors.white
                  : Colors.black)
              .withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(
      center,
      stoneRadius + 8,
      pulsePaint,
    );
  }

  void _drawLastMoveIndicator(
    Canvas canvas,
    double cellSize,
  ) {
    final lastMove = gameState.lastMove;
    if (lastMove == null) return;

    // 정확한 좌표 계산
    final x = cellSize * (lastMove.col + 1);
    final y = cellSize * (lastMove.row + 1);
    final center = Offset(x, y);

    // 돌의 색상에 따라 표시 색상 결정
    final stoneColor = gameState
        .board[lastMove.row][lastMove.col];
    final indicatorColor =
        stoneColor == PlayerType.black
        ? Colors.white.withValues(alpha: 
            0.9,
          ) // 검은 돌에는 흰색 표시
        : Colors.red.withValues(alpha: 
            0.9,
          ); // 흰 돌에는 빨간색 표시

    // 외곽 그림자 효과
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(
      Offset(
        center.dx + 1,
        center.dy + 1,
      ), // 그림자 오프셋
      stoneRadius + 6,
      shadowPaint,
    );

    // 메인 표시 링
    final mainIndicatorPaint = Paint()
      ..color = indicatorColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    canvas.drawCircle(
      center,
      stoneRadius + 5,
      mainIndicatorPaint,
    );

    // 내부 보조 링 (더 가는 선)
    final innerRingPaint = Paint()
      ..color = indicatorColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(
      center,
      stoneRadius + 2,
      innerRingPaint,
    );

    // 펄스 효과를 위한 외부 링
    final pulseColor =
        stoneColor == PlayerType.black
        ? Colors.yellow.withValues(alpha: 0.4)
        : Colors.orange.withValues(alpha: 0.4);

    final pulsePaint = Paint()
      ..color = pulseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(
      center,
      stoneRadius + 9,
      pulsePaint,
    );

    // 더 큰 외부 펄스
    final outerPulsePaint = Paint()
      ..color = pulseColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(
      center,
      stoneRadius + 12,
      outerPulsePaint,
    );

    // 중앙에 작은 하이라이트 점
    final centerDotPaint = Paint()
      ..color = indicatorColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      2.0,
      centerDotPaint,
    );

    // 4방향 강조 선 (십자가 형태)
    final crossPaint = Paint()
      ..color = indicatorColor.withValues(alpha: 0.7)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final crossLength = stoneRadius * 0.6;

    // 수직선
    canvas.drawLine(
      Offset(center.dx, center.dy - crossLength),
      Offset(center.dx, center.dy + crossLength),
      crossPaint,
    );

    // 수평선
    canvas.drawLine(
      Offset(center.dx - crossLength, center.dy),
      Offset(center.dx + crossLength, center.dy),
      crossPaint,
    );
  }

  void _drawWinningLine(
    Canvas canvas,
    double cellSize,
  ) {
    // TODO: 승리 라인 그리기 구현
    // 현재는 단순히 게임 종료 상태만 확인
    if (gameState.status == GameStatus.playing)
      return;

    final winnerColor =
        gameState.status == GameStatus.blackWin
        ? Colors.yellow
        : Colors.blue;

    final linePaint = Paint()
      ..color = winnerColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    // 임시로 마지막 수 주변에 승리 효과 표시
    final lastMove = gameState.lastMove;
    if (lastMove != null) {
      final x = cellSize * (lastMove.col + 1);
      final y = cellSize * (lastMove.row + 1);
      final center = Offset(x, y);

      // 승리 이펙트 (별 모양)
      _drawWinStar(canvas, center, winnerColor);
    }
  }

  void _drawWinStar(
    Canvas canvas,
    Offset center,
    Color color,
  ) {
    final starPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    const radius = 20.0;
    const innerRadius = 10.0;

    for (int i = 0; i < 10; i++) {
      final angle = (i * math.pi) / 5;
      final r = i % 2 == 0 ? radius : innerRadius;
      final x =
          center.dx +
          r * math.cos(angle - math.pi / 2);
      final y =
          center.dy +
          r * math.sin(angle - math.pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, starPaint);
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    if (oldDelegate is! EnhancedOmokBoardPainter)
      return true;

    return oldDelegate.gameState != gameState ||
        oldDelegate.hoverPosition !=
            hoverPosition ||
        oldDelegate.isPressed != isPressed;
  }
}
