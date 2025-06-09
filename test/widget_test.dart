// This is a basic Flutter widget test for Omok Game App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:omok_game_app/main.dart';

void main() {
  testWidgets('Omok App should show home screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OmokGameApp());

    // Verify that we have the home screen elements
    expect(
      find.text('Omok Arena'),
      findsOneWidget,
    );
    expect(
      find.text('13x13 보드에서 5목을 완성하세요!'),
      findsOneWidget,
    );
    expect(find.text('게임 시작'), findsOneWidget);
    expect(find.text('게임 규칙'), findsOneWidget);

    // Verify the play button exists
    expect(
      find.byIcon(Icons.play_arrow),
      findsOneWidget,
    );
    expect(
      find.byIcon(Icons.help_outline),
      findsOneWidget,
    );
  });

  testWidgets(
    'Game rules dialog should open and close',
    (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        const OmokGameApp(),
      );

      // Tap the game rules button
      await tester.tap(find.text('게임 규칙'));
      await tester.pumpAndSettle();

      // Verify that the rules dialog is shown
      expect(find.text('게임 규칙'), findsWidgets);
      expect(find.text('🎯 목표'), findsOneWidget);
      expect(
        find.text('🎮 게임 방법'),
        findsOneWidget,
      );
      expect(
        find.text('🏆 승리 조건'),
        findsOneWidget,
      );

      // Close the dialog
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();

      // Verify the dialog is closed
      expect(find.text('🎯 목표'), findsNothing);
    },
  );
}
