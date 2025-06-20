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
  testWidgets('Omok App should show home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OmokArenaApp());

    // Verify that we have the home screen elements
    expect(find.text('Omok Arena'), findsOneWidget);
    expect(find.text('🎮 플레이 모드 선택'), findsOneWidget);
    expect(find.text('👥 2인 플레이 (로컬)'), findsOneWidget);
    expect(find.text('🤖 1인 플레이 (AI 대전)'), findsOneWidget);
  });

  testWidgets('Game mode buttons should be tappable', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OmokArenaApp());

    // Find 2-player button
    final twoPlayerButton = find.text('👥 2인 플레이 (로컬)');
    expect(twoPlayerButton, findsOneWidget);

    // Find AI button
    final aiButton = find.text('🤖 1인 플레이 (AI 대전)');
    expect(aiButton, findsOneWidget);

    // Verify buttons exist and are widgets
    expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
  });
}
