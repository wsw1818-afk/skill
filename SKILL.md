---
name: council-code
description: |
  Multi-perspective code design council. Use when designing new features, making
  architectural decisions, reviewing UX-sensitive changes, or any situation where
  multiple viewpoints (developer, user, security, QA, PM, designer, devops,
  devil's advocate) should debate before coding begins.
  Trigger: /council-code "주제" or phrases like "다각도로 검토", "여러 관점",
  "논의해서 결정", "원탁회의".
---

# Council-Code: 다관점 코드 설계 원탁회의

> 한 문제를 8명의 페르소나 에이전트가 **병렬 의견 → 교차 비판 → 합의 →
> 구현 → 재검증**의 4라운드로 수렴하는 통합 워크플로우.

---

## 🎯 언제 사용하는가

**반드시 사용:**
- 새 기능 설계 (3+ 파일 수정 예상)
- 아키텍처 결정 (DB 변경, 프레임워크 교체, API 재설계)
- UX 민감 변경 (인증 플로우, 온보딩, 오류 메시지)
- 보안 민감 코드 (auth, 결제, 개인정보)
- "어떻게 할지 결정 못하겠다" 상태

**사용 금지:**
- 오타 수정, 단순 버그 패치
- 단일 파일 1-2줄 변경
- 명확한 기계적 작업 (포맷팅, 리네임)

---

## 🎭 참여 가능한 8개 페르소나

| 페르소나 | 에이전트 파일 | 관점 |
|---------|-------------|------|
| 🧑‍💻 **개발자** | `perspective-engineer` | 유지보수성, 기술부채, 성능 |
| 👤 **사용자** | `perspective-user` | UX, 학습곡선, 직관성 |
| 🔒 **보안 전문가** | `perspective-security` | 취약점, 프라이버시, 공격면 |
| 🧪 **QA** | `perspective-qa` | 엣지 케이스, 회귀, 테스트 가능성 |
| 💼 **PM** | `perspective-pm` | ROI, 스코프, 일정, MVP |
| 🎨 **디자이너** | `perspective-designer` | 일관성, 접근성, 시각 계층 |
| ⚙️ **DevOps** | `perspective-devops` | 배포, 모니터링, 장애 복구 |
| 😤 **비판자** | `perspective-devils-advocate` | "왜 하지 말아야 하는가" |

자세한 역할 정의는 [personas.md](personas.md) 참조.

---

## 📋 사용법

### 기본 호출

```
/council-code "새 다크모드 기능 추가"
```

### 페르소나 지정 (선택)

```
/council-code --personas engineer,user,security,qa "인증 플로우 재설계"
```

### 빠른 모드 (3명 미니 원탁)

```
/council-code --quick "함수 네이밍 결정"
```

---

## 🔄 4-라운드 프로토콜

### Round 1: 독립 의견 제시 (병렬, ~1분)

메인 Claude가 **한 메시지에 지정된 페르소나 에이전트들을 병렬 호출**한다.

**중요**: 에이전트들은 서로의 의견을 보지 못한 상태에서 독립적으로 답변한다.

각 페르소나는 다음 형식으로 응답:

```markdown
## 🎭 [페르소나명]의 초기 의견

### 핵심 우려사항 3가지
1. ...
2. ...
3. ...

### 권장 접근
...

### 반드시 피해야 할 것
...

### 필요한 추가 정보
...
```

### Round 2: 교차 비판 (병렬, ~1분)

메인 Claude가 **Round 1의 모든 의견을 종합한 문서를 만들고**, 각 페르소나
에이전트에게 다시 보내 다음 질문을 한다:

1. 다른 페르소나들의 의견 중 **동의하는 것**은?
2. **반대하는 것**과 그 이유는?
3. **놓친 관점**이 있는가?
4. 당신의 초기 의견을 **수정하고 싶은가**?

각 페르소나는 다음 형식으로 응답:

```markdown
## 🎭 [페르소나명]의 교차 비판

### ✅ 동의
- [다른 페르소나 X의 의견] — 이유: ...

### ❌ 반대
- [다른 페르소나 Y의 의견] — 이유: ...

### 🔍 보완
- 아무도 언급하지 않은 관점: ...

### 🔄 의견 수정
- Round 1에서 제가 놓친 것: ...
```

### Round 3: 합의 도출 (메인, ~1분)

메인 Claude가 Round 1+2 결과를 종합하여 **합의안 작성**:

```markdown
## 📜 원탁회의 합의안

### 결정 사항
✅ ...
✅ ...

### 보류/후순위 (별도 마일스톤)
⏭️ ...

### 명시적 포기
❌ ... (이유: ...)

### 남은 이견 (사용자 판단 필요)
⚠️ [A안 vs B안] - 각 페르소나 찬반: ...

### 구현 계획
1. ...
2. ...
```

**사용자 승인 대기.**

### Round 4: 구현 + 재검증 (~시간 가변)

1. **메인 Claude가 합의안에 따라 직접 구현** (병렬 구현은 금지 — 파일 충돌)
2. 구현 완료 후, **Round 1과 동일한 페르소나들을 병렬 재호출**하여 검증
3. 각 페르소나가 "합의안이 제대로 반영되었는가?" 확인
4. 불합격 시 Round 3-4 반복 (최대 3회)

---

## 🧭 오케스트레이션 의사코드

메인 Claude는 아래 로직을 따른다:

```
function councilCode(topic, personas = defaultFour, mode = "full"):

  # 1단계: 페르소나 선택
  if personas not specified:
    personas = selectPersonasByTopic(topic)
    # 예: 보안 키워드 감지 → security 포함
    # 예: UI 키워드 감지 → designer 포함

  # 2단계: Round 1 병렬 실행
  round1Results = parallel([
    for p in personas:
      Agent(perspective-{p}, prompt="초기 의견 제시: {topic}")
  ])

  # 3단계: Round 2 교차 비판 (병렬)
  round2Results = parallel([
    for p in personas:
      Agent(perspective-{p}, prompt="다른 의견들 비판: {round1Results}")
  ])

  # 4단계: 메인이 합의안 작성
  consensus = synthesize(round1Results, round2Results)
  showToUser(consensus)
  awaitApproval()

  # 5단계: 구현
  implementation = mainClaude.implement(consensus)

  # 6단계: 재검증 (병렬)
  validation = parallel([
    for p in personas:
      Agent(perspective-{p}, prompt="합의안 반영 확인: {implementation}")
  ])

  if allPass(validation):
    return done
  else:
    goto step 4 (max 3 retries)
```

---

## 🎬 페르소나 자동 선택 (2단계 감지)

**최종 팀 = 프로젝트 프로파일(베이스) ∪ 주제 키워드(추가) ∪ 사용자 오버라이드**

### 1단계: 프로젝트 프로파일 감지 (우선순위 순)

```
감지 순서:
1. 현재 디렉토리에 `.council-code.yml` 존재 → 최우선 적용
2. 프로젝트 CLAUDE.md에 `## Council-Code Profile` 섹션 존재 → 적용
3. 파일 시그니처 자동 감지 (아래 규칙) → 적용
4. 위 모두 실패 → 디폴트 4인 (engineer, user, security, qa)
```

자세한 매핑은 [profiles.md](profiles.md) 참조.

#### 파일 시그니처 → 프로젝트 타입 자동 감지

| 발견된 파일 | 추정 프로젝트 타입 | 기본 페르소나 |
|-----------|-----------------|-------------|
| `pubspec.yaml` | **Flutter 앱** | engineer + user + **designer** + qa |
| `app.json` + `eas.json` | **Expo 앱** | engineer + user + **designer** + qa |
| `requirements.txt` + `*.py` 배치 스크립트 | **Python 파이프라인** | engineer + **devops** + **performance** + qa |
| `package.json` + React/Vue/Svelte | **웹 프론트엔드** | engineer + user + designer + performance |
| `Dockerfile` + `docker-compose.yml` | **컨테이너화 서비스** | engineer + **devops** + security + qa |
| `*.csproj` | **.NET 앱** | engineer + user + qa + security |
| `*.sol` (Solidity) | **블록체인** | engineer + **security**(필수) + devils-advocate + qa |
| `agents/` + `flows/` + `cron/` | **자동화 시스템** | engineer + **devops** + **security** + devils-advocate |
| `credentials/` 또는 `secrets/` | **시크릿 보유** | 보안 에이전트 **강제 추가** |

### 2단계: 주제 키워드로 페르소나 추가

프로젝트 프로파일 위에 주제 키워드로 **추가** 페르소나 합류:

| 키워드 패턴 | 추가되는 페르소나 |
|------------|-----------------|
| "인증", "로그인", "결제", "개인정보", "OAuth", "토큰" | +**security** |
| "UI", "화면", "버튼", "레이아웃", "다크모드", "색상" | +**designer** |
| "배포", "CI/CD", "모니터링", "로그", "알람" | +**devops** |
| "MVP", "기능 추가", "일정", "출시", "출시일" | +**pm** |
| "리팩터링", "기술부채", "마이그레이션", "이전" | +**devils-advocate** |
| "성능", "최적화", "메모리", "속도", "병목" | +**performance** |
| "테스트", "버그", "엣지", "회귀" | +**qa** |
| "접근성", "WCAG", "A11y", "스크린리더" | +**designer** |
| "아키텍처", "프레임워크 교체", "전면 개편" | **8명 전원** |

### 3단계: 사용자 오버라이드

```
/council-code --personas engineer,security,qa "주제"  # 명시 지정
/council-code --add performance "주제"                # 추가
/council-code --exclude devils-advocate "주제"        # 제외
/council-code --quick "주제"                          # 3명 미니
/council-code --personas all "주제"                   # 풀 원탁 (8명)
```

### 예시: 자동 감지 시나리오

**시나리오 1**: winote에서 다크모드 요청
```
CWD: /Volumes/SSD/claude/Claude/winote
→ pubspec.yaml 감지 → Flutter 앱
→ 프로젝트 프로파일: engineer + user + designer + qa
→ 키워드 "다크모드" 감지 → +designer (이미 포함됨)
→ 최종: engineer + user + designer + qa (4명)
```

**시나리오 2**: 이미지생성에서 병렬 처리 추가
```
CWD: /Volumes/SSD/claude/이미지생성
→ *.py 배치 스크립트 감지 → Python 파이프라인
→ 프로젝트 프로파일: engineer + devops + performance + qa
→ 키워드 "병렬" 감지 → +performance (이미 포함)
→ 최종: engineer + devops + performance + qa (4명)
```

**시나리오 3**: 오픈클로에 새 에이전트 추가
```
CWD: /Volumes/SSD/claude/Claude/오픈클로
→ agents/ + flows/ + cron/ 감지 → 자동화 시스템
→ credentials/ 감지 → security 강제 추가
→ 프로젝트 프로파일: engineer + devops + security + devils-advocate
→ 키워드 "새 에이전트" → (추가 없음)
→ 최종: engineer + devops + security + devils-advocate (4명)
```

---

## 📖 미니 예시: winote "빠른 메모" 기능

```
사용자: /council-code "winote에 플로팅 버튼으로 빠른 메모 작성 기능 추가"

메인 Claude:
  [키워드 감지: UI + 새 기능]
  → 선택된 페르소나: engineer, user, designer, qa
  
  Round 1 (병렬):
    4개 Agent 동시 호출 → 독립 의견 수집
  
  Round 2 (병렬):
    4개 Agent 동시 호출 → 교차 비판
  
  Round 3: 합의안 제시
    ✅ 플로팅 버튼 (우측 하단, safeArea 적용)
    ✅ 자동저장 + 토스트 피드백
    ✅ 빈 메모 필터링 (QA 요청)
    ❌ 핫키는 후속 마일스톤 (PM 결정)
    ⚠️ 암호화 기본값 → 사용자 결정 필요
  
  [사용자 승인 대기]
  
  Round 4:
    메인이 구현 → 4개 Agent 재검증 → 모두 통과 → 완료
```

---

## 🔗 관련 도구 (사용자 환경)

이 스킬은 아래 기존 도구와 공존/보완:

- **`/council`** (기존): 일반 의사결정용 4-voice council. `council-code`는 코드 특화.
- **`gan-generator` + `gan-evaluator`** (기존): 대립적 생성-평가 루프. 단일 관점 vs 본 스킬의 다관점.
- **`/santa-loop`** (기존): 이중 리뷰어 수렴. 2명 vs 본 스킬의 4-8명.
- **`/plan`** (기존): 사전 기획용. Plan → council-code → 구현 흐름 권장.

---

## ⚠️ 주의사항

- **컨텍스트 윈도우**: 8명 풀 원탁은 토큰 소모 큼. 일반적으로 4명 권장.
- **순차 강제**: Round 4 구현은 반드시 메인이 단독 수행 (병렬 구현 시 파일 충돌).
- **무한 루프 방지**: Round 3-4 재시도는 최대 3회. 초과 시 사용자에게 수동 개입 요청.
- **관점 오염 방지**: Round 1은 에이전트들이 서로의 답변을 보지 못하게 격리해야 함.

---

## 📊 측정 지표

세션 종료 시 메인 Claude가 다음을 보고:

```markdown
## 📊 Council 성과

- 참여 페르소나: 4명 (engineer, user, designer, qa)
- 총 라운드: 4
- Round 1 독립 의견 수: 4
- Round 2 수정 의견: 2건
- 합의 도달 여부: ✅
- Round 4 재시도: 0회
- 예상 대비 발견한 추가 이슈: 3개 (엣지케이스 2, UX 1)
- 토큰 사용량: 약 X
```

---

## 🎓 언제 이 스킬을 호출하지 말아야 하는가

- 이미 `/plan`으로 합의된 작업을 단순 실행하는 경우
- 사용자가 명시적으로 "그냥 빨리 해줘"라고 한 경우
- 1-2줄 수정 같은 자명한 작업
- 단순 질문/조사 (Agent 도구 직접 사용이 더 효율적)

---

## 📚 이론적 근거

- **Anthropic**: "Multi-perspective Analysis" (split role sub-agents)
- **Microsoft AutoGen**: GroupChat, Society of Mind patterns
- **Constitutional AI**: Self-critique loop (Round 2 = peer critique)
- **CAMEL 논문**: Role-playing agent collaboration
- **사용자 환경**: `rules/agents-v2.md`의 "Multi-Perspective Analysis" 섹션과 연계
