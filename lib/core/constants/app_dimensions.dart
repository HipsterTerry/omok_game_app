/// 앱 전체에서 사용하는 크기와 여백 상수
///
/// 사용법:
/// SizedBox(height: AppDimensions.spacingMedium)
/// BorderRadius.circular(AppDimensions.radiusSmall)
class AppDimensions {
  AppDimensions._(); // 인스턴스 생성 방지

  // 🎯 여백 (Spacing)
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

  // 🎯 패딩 (Padding)
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // 🎯 둥근 모서리 (Border Radius)
  static const double radiusXSmall = 4.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusXXLarge = 24.0;

  // 🎯 아이콘 크기 (Icon Size)
  static const double iconXSmall = 16.0;
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // 🎯 버튼 크기 (Button Size)
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonHeightLarge = 56.0;
  static const double buttonWidthSmall = 80.0;
  static const double buttonWidthMedium = 120.0;
  static const double buttonWidthLarge = 200.0;

  // 🎯 게임 관련 크기
  static const double gameStoneSize = 30.0;
  static const double gameBoardPadding = 20.0;
  static const double gameTimerSize = 60.0;
  static const double characterCardWidth = 120.0;
  static const double characterCardHeight = 160.0;

  // 🎯 화면 여백
  static const double screenPaddingHorizontal = 20.0;
  static const double screenPaddingVertical = 16.0;
  static const double screenPaddingTop = 40.0;
  static const double screenPaddingBottom = 20.0;

  // 🎯 카드/컨테이너 크기
  static const double cardElevation = 4.0;
  static const double cardPadding = 16.0;
  static const double containerMinHeight = 100.0;
  static const double containerMaxWidth = 400.0;

  // 🎯 애니메이션 관련
  static const double animationOffset = 50.0;
  static const double animationScale = 1.2;

  // 🎯 그림자 (Shadow)
  static const double shadowBlurRadius = 8.0;
  static const double shadowSpreadRadius = 2.0;
  static const double shadowOffsetX = 0.0;
  static const double shadowOffsetY = 4.0;
}
