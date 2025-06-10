# 📋 Omok Arena - 향후 작업 이슈 리스트

> GitHub Issues에 등록할 작업들을 우선순위별로 정리

## 🚨 긴급 (Critical)

### Issue #1: iOS 시뮬레이터 디버그 연결 문제 해결
**Labels**: `bug`, `iOS`, `critical`
**Description**: 
- iOS 시뮬레이터에서 가끔 "debug connection failed" 에러 발생
- 앱은 빌드되지만 디버그 연결이 끊어짐
- 시뮬레이터 재시작으로 임시 해결 가능

**Acceptance Criteria**:
- [ ] iOS 시뮬레이터에서 안정적인 디버그 연결
- [ ] 에러 발생 시 자동 재연결 메커니즘
- [ ] 에러 로그 개선

---

## 🔥 높음 (High Priority)

### Issue #2: 승리 연결선 애니메이션 구현
**Labels**: `enhancement`, `UI/UX`, `high priority`
**Description**:
- 5목이 완성되었을 때 연결선을 동적으로 그리는 애니메이션
- 현재는 단순한 별 효과만 있음
- 승리한 5개 돌을 연결하는 선을 부드럽게 그리기

**Acceptance Criteria**:
- [ ] 5목 완성 시 연결선 자동 감지
- [ ] 부드러운 선 그리기 애니메이션 (0.5초)
- [ ] 연결선 색상: 흑돌=금색, 백돌=은색
- [ ] 애니메이션 완료 후 승리 효과

### Issue #3: Android 실기기 테스트 및 최적화
**Labels**: `testing`, `Android`, `high priority`
**Description**:
- Android 실제 디바이스에서 성능 테스트
- 다양한 화면 크기 대응
- 메모리 사용량 최적화

**Acceptance Criteria**:
- [ ] 3개 이상 Android 기기에서 테스트
- [ ] 60 FPS 안정적 유지
- [ ] 메모리 사용량 200MB 이하
- [ ] 배터리 효율성 검증

### Issue #4: 웹 버전 반응형 UI 개선
**Labels**: `enhancement`, `Web`, `responsive`
**Description**:
- 데스크톱 브라우저에서 UI 최적화
- 터치 vs 마우스 인터페이스 차이점 해결
- 다양한 화면 비율 대응

**Acceptance Criteria**:
- [ ] 1920x1080, 1366x768 해상도 최적화
- [ ] 마우스 호버 효과 개선
- [ ] 키보드 단축키 지원
- [ ] 브라우저별 호환성 테스트

---

## 🎨 중간 (Medium Priority)

### Issue #5: 캐릭터별 승리 애니메이션
**Labels**: `enhancement`, `characters`, `animation`
**Description**:
- 각 십이지 캐릭터별 고유 승리 포즈
- 캐릭터 등급(천/지/인)에 따른 차별화된 효과
- 승리 시 캐릭터 모델 확대 표시

**Acceptance Criteria**:
- [ ] 12개 캐릭터별 고유 승리 애니메이션
- [ ] 천급 캐릭터: 3초간 화려한 효과
- [ ] 지급 캐릭터: 2초간 중간 효과  
- [ ] 인급 캐릭터: 1초간 간단한 효과

### Issue #6: 게임 통계 및 전적 시스템
**Labels**: `feature`, `statistics`, `database`
**Description**:
- 플레이어별 승률 기록
- AI 난이도별 전적 추적
- 사용한 캐릭터별 통계
- 게임 기록 저장 (SQLite)

**Acceptance Criteria**:
- [ ] 로컬 데이터베이스 구축 (SQLite)
- [ ] 승률 계산 및 표시
- [ ] 캐릭터별 승률 통계
- [ ] 게임 히스토리 뷰어

### Issue #7: 사운드 시스템 확장
**Labels**: `enhancement`, `audio`, `medium priority`
**Description**:
- 배경음악 추가 (BGM)
- 캐릭터별 고유 사운드
- 승리 테마 음악
- 볼륨 조절 설정

**Acceptance Criteria**:
- [ ] 3개 이상 배경음악 트랙
- [ ] 캐릭터별 스킬 사운드 차별화
- [ ] 설정에서 사운드 on/off 가능
- [ ] 볼륨 슬라이더 (0-100%)

---

## 💡 낮음 (Low Priority)

### Issue #8: 리플레이 시스템
**Labels**: `feature`, `replay`, `nice-to-have`
**Description**:
- 게임 진행 과정을 기보로 저장
- 저장된 게임을 다시 재생하는 기능
- 기보 파일 내보내기/가져오기

**Acceptance Criteria**:
- [ ] 게임 진행을 JSON 형태로 저장
- [ ] 재생 컨트롤 (재생/일시정지/빨리감기)
- [ ] 기보 파일 공유 기능
- [ ] 유명한 오목 기보 샘플 제공

### Issue #9: 온라인 멀티플레이어 (미래)
**Labels**: `feature`, `multiplayer`, `future`
**Description**:
- Firebase 실시간 데이터베이스 연동
- 친구 초대 시스템
- 전 세계 랭킹 시스템
- 매치메이킹 시스템

**Acceptance Criteria**:
- [ ] Firebase 프로젝트 설정
- [ ] 실시간 게임 동기화
- [ ] 사용자 인증 시스템
- [ ] 글로벌 리더보드

### Issue #10: AI 난이도 고도화
**Labels**: `enhancement`, `AI`, `algorithm`
**Description**:
- 현재 3단계를 5단계로 확장
- 머신러닝 기반 AI 구현
- 플레이어 스타일 학습 AI
- 프로 수준 AI 추가

**Acceptance Criteria**:
- [ ] 5단계 난이도 (초보/쉬움/보통/어려움/프로)
- [ ] TensorFlow Lite 모델 통합
- [ ] 사용자 패턴 학습 기능
- [ ] 실시간 AI 성능 모니터링

---

## 🐛 버그 수정

### Issue #11: withOpacity Deprecated 경고 해결
**Labels**: `bug`, `dart`, `deprecation`
**Description**:
- Flutter 최신 버전에서 withOpacity() deprecated
- .withValues() 메서드로 교체 필요
- 195개 경고 메시지 해결

**Acceptance Criteria**:
- [ ] 모든 withOpacity() → withValues() 변경
- [ ] flutter analyze 경고 0개
- [ ] 기존 기능 정상 동작 확인

---

## 📱 플랫폼별 최적화

### Issue #12: iOS App Store 출시 준비
**Labels**: `deployment`, `iOS`, `app-store`
**Description**:
- iOS 앱스토어 심사 기준 준수
- 아이콘 및 스크린샷 준비
- 개인정보 처리방침 작성

### Issue #13: Android Play Store 출시 준비  
**Labels**: `deployment`, `Android`, `play-store`
**Description**:
- Google Play 정책 준수
- AAB 파일 빌드
- 앱 설명 및 키워드 최적화

---

**📝 이슈 생성 시 참고사항**:
- 각 이슈는 GitHub Issues에 개별 등록
- 적절한 라벨 태깅 필수
- Milestone 설정으로 버전별 그룹화
- Assignee는 개발 시작 시 지정 