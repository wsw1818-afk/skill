# 🎭 Council-Code

> 다관점 에이전트 원탁회의로 코드 설계를 수렴시키는 Claude Code 스킬.
>
> 개발자, 사용자, 보안, QA, PM, 디자이너, DevOps, 비판자, 성능 전문가 —
> 최대 9명의 페르소나가 **병렬 → 교차비판 → 합의 → 재검증** 4단계로
> 논의합니다. 프로젝트 타입을 자동 감지해 팀을 구성합니다.

---

## ✨ 특징

- 🎭 **9개 페르소나 에이전트**: 서로 다른 시각에서 코드 검토
- 🔄 **4-라운드 합의 프로토콜**: Anthropic + AutoGen 패턴 기반
- 🎯 **프로젝트 자동 감지**: 14개 프로파일 타입 (Flutter/Python/자동화 등)
- ⚡ **병렬 실행**: 한 메시지에 4-8명 동시 호출 → 3배 속도
- 📦 **포터블**: tar.gz 패키지로 PC 간 이식
- 🔒 **프로젝트별 커스터마이징**: `.council-code.yml` 파일로 제어

---

## 🚀 빠른 시작

```bash
# 설치
bash install.sh

# 사용 (Claude 세션 내)
/council-code "새 다크모드 기능 추가"
/council-code --quick "함수 네이밍 결정"
/council-code --personas all "아키텍처 결정"
```

---

## 📂 구조

```
council-code/
├── SKILL.md              # 메인 오케스트레이션 로직
├── personas.md           # 9개 페르소나 카탈로그
├── profiles.md           # 14개 프로젝트 프로파일 매핑
├── install.sh            # 설치 스크립트
├── uninstall.sh          # 제거 스크립트
├── package.sh            # 다른 PC 전송용 패키징
├── INSTALL.md            # 상세 설치 가이드
├── README.md             # 이 파일
├── agents/               # 페르소나 에이전트 (9개)
│   ├── perspective-engineer.md
│   ├── perspective-user.md
│   ├── perspective-security.md
│   ├── perspective-qa.md
│   ├── perspective-pm.md
│   ├── perspective-designer.md
│   ├── perspective-devops.md
│   ├── perspective-devils-advocate.md
│   └── perspective-performance.md
└── samples/              # 프로젝트별 .council-code.yml 예시
    ├── flutter-app.yml
    ├── python-pipeline.yml
    └── automation-system.yml
```

---

## 🎭 페르소나 9명

| 페르소나 | 관점 | 모델 |
|---------|-----|------|
| 🧑‍💻 engineer | 유지보수성, 기술부채 | Sonnet |
| 👤 user | UX, 직관성 | Sonnet |
| 🔒 security | OWASP, 공격면 | Opus |
| 🧪 qa | 엣지 케이스, 회귀 | Sonnet |
| 💼 pm | ROI, MVP 스코프 | Sonnet |
| 🎨 designer | WCAG, 시각 일관성 | Sonnet |
| ⚙️ devops | 배포, 관찰성 | Sonnet |
| 😤 devils-advocate | "왜 하지 말아야" | Opus |
| ⚡ performance | 병목, 벤치마크 | Sonnet |

---

## 🔄 4-라운드 프로토콜

```
Round 1: 병렬 독립 의견 (~1분)
    ↓
Round 2: 병렬 교차 비판 (~1분)
    ↓
Round 3: 메인이 합의안 도출 → 사용자 승인
    ↓
Round 4: 구현 + 같은 팀이 재검증 (병렬)
```

---

## 🎯 프로젝트 자동 감지

```
[Step 1] .council-code.yml 있음? → YES: 사용
[Step 2] CLAUDE.md에 Profile 섹션? → YES: 사용
[Step 3] 파일 시그니처 감지
    pubspec.yaml       → flutter-app
    requirements.txt   → python-pipeline
    agents/+flows/     → automation-system
    Dockerfile         → docker-service
    ...14개 타입
[Step 4] 주제 키워드로 페르소나 추가
    "보안" → +security
    "성능" → +performance
```

---

## 📦 다른 PC로 이식

```bash
# 현재 PC
bash package.sh
# → ~/Desktop/council-code-v20260415-xxxx.tar.gz 생성

# 새 PC
tar xzf council-code-v*.tar.gz
cd council-code-v*
bash install.sh
```

자세한 가이드: [INSTALL.md](INSTALL.md)

---

## 🧪 사용 예시

### 예시 1: Flutter 앱에 다크모드 추가

```
cd winote/
/council-code "다크모드 추가"

→ 자동 감지: flutter-app
→ 팀: engineer + user + designer + qa
→ Round 1: 4명 병렬 의견
→ Round 2: 교차 비판
→ Round 3: 합의
  ✅ Material 3 ThemeMode.system 기본
  ✅ 수동 오버라이드 토글 제공
  ⚠️ 사용자 선호 저장 방식 결정 필요
→ Round 4: 구현 + 재검증
```

### 예시 2: Python 파이프라인 최적화

```
cd image-pipeline/
/council-code "배치 생성 병렬화"

→ 자동 감지: python-pipeline
→ 팀: engineer + devops + performance + qa
→ 병렬 처리량, GPU 활용률, 실패 복구 중심 논의
```

---

## 📖 이론적 근거

- **Anthropic**: "Multi-perspective Analysis" (split role sub-agents)
- **Microsoft AutoGen**: GroupChat, Society of Mind patterns
- **Constitutional AI**: Self-critique loop
- **CAMEL 논문**: Role-playing agent collaboration

---

## 🔧 커스터마이징

### 새 페르소나 추가

```bash
# 1. 에이전트 파일 생성
cp agents/perspective-engineer.md agents/perspective-ml.md
# 내용 편집

# 2. personas.md에 등록

# 3. profiles.md의 프로파일에 추가
```

### 새 프로파일 타입 추가

`profiles.md` 참조. 파일 시그니처와 기본 팀만 정의하면 됨.

---

## 📄 라이선스

MIT License. 자유롭게 사용/수정/배포하세요.

---

## 🙏 크레딧

- 설계: 사용자 맞춤 다관점 시스템
- 기반: Claude Code 서브에이전트 시스템 (Anthropic)
- 패턴 참조: wshobson/agents, VoltAgent/awesome-claude-code-subagents
