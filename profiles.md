# Council-Code 프로젝트 프로파일 카탈로그

> 프로젝트 특성에 맞춰 페르소나를 자동 선택하는 규칙 집합.
> SKILL.md의 "페르소나 자동 선택" 섹션이 이 카탈로그를 참조한다.

---

## 🎯 프로파일 결정 흐름

```
1. .council-code.yml (프로젝트 루트) 존재?
   YES → 해당 파일의 personas 필드 사용 (최우선)

2. CLAUDE.md에 "## Council-Code Profile" 섹션 존재?
   YES → 해당 섹션의 페르소나 목록 사용

3. 파일 시그니처로 자동 감지
   → 매칭되는 프로파일 적용

4. 모두 실패
   → 디폴트 (engineer + user + security + qa)
```

---

## 📁 `.council-code.yml` 포맷

프로젝트 루트에 생성 가능:

```yaml
# .council-code.yml
name: "프로젝트 이름"
type: "flutter-app"  # 프로파일 타입 (아래 참조)

# 기본 페르소나 (항상 참여)
base_personas:
  - engineer
  - user
  - designer
  - qa

# 이 프로젝트에서 강제 추가 (민감 특성)
forced_personas:
  - security  # 예: 사용자 데이터 저장

# 이 프로젝트에서 기본 제외
excluded_personas:
  - devils-advocate  # 예: MVP 단계라 추가 비판 불필요

# 프로젝트별 추가 컨텍스트 (각 페르소나에게 주입)
context: |
  이 프로젝트는 개인 사용자를 위한 메모 앱이며, 오프라인 우선 설계.
  데이터는 모두 로컬 SQLite에 저장됨.
```

---

## 🎭 프로파일 타입별 표준 매핑

### `flutter-app` — Flutter 모바일/데스크톱 앱
```yaml
signatures: [pubspec.yaml]
base: [engineer, user, designer, qa]
rationale: "UI 중심, 사용자 직접 접점, 시각적 일관성 중요"
```

### `expo-app` — React Native/Expo 앱
```yaml
signatures: [app.json, eas.json]
base: [engineer, user, designer, qa]
rationale: "Flutter와 동일: 모바일 UI"
```

### `web-frontend` — 웹 프론트엔드
```yaml
signatures: [package.json + (react|vue|svelte|next)]
base: [engineer, user, designer, performance]
rationale: "렌더링 성능 + 접근성 + UX"
```

### `python-pipeline` — Python 배치/ML 파이프라인
```yaml
signatures: [requirements.txt, *.py with batch_/flow_/etl_ prefix]
base: [engineer, devops, performance, qa]
rationale: "운영 자동화 + 리소스 최적화 + 재현성"
```

### `python-web` — Python 백엔드 (Django/FastAPI/Flask)
```yaml
signatures: [requirements.txt + (manage.py|fastapi|flask)]
base: [engineer, devops, security, qa]
rationale: "인증 + 배포 + API 계약"
```

### `automation-system` — 자동화 시스템 (에이전트/크론/플로우)
```yaml
signatures: [agents/, flows/, cron/, launchd 스크립트]
base: [engineer, devops, security, devils-advocate]
rationale: "권한 누출 위험 + 자동 실행 위험 + 과도 설계 경계"
```

### `dotnet-app` — .NET 애플리케이션
```yaml
signatures: [*.csproj, *.sln]
base: [engineer, user, qa, security]
rationale: "Windows 생태계, 사용자 권한 중요"
```

### `blockchain` — 스마트 컨트랙트
```yaml
signatures: [*.sol, hardhat.config.*, foundry.toml]
base: [engineer, security, devils-advocate, qa]
forced: [security]  # 타협 불가
rationale: "불변성 + 금전 손실 위험 + 재진입 등 고유 취약점"
```

### `cli-tool` — 명령줄 도구
```yaml
signatures: [bin/, setup.py + console_scripts, cargo.toml + bin/]
base: [engineer, user, qa, devils-advocate]
rationale: "CLI UX + 스크립트 조합 가능성 + 오버엔지니어링 위험"
```

### `docker-service` — 컨테이너화 서비스
```yaml
signatures: [Dockerfile, docker-compose.yml]
base: [engineer, devops, security, qa]
rationale: "배포 + 네트워크 격리 + 이미지 취약점"
```

### `library` — 재사용 라이브러리/SDK
```yaml
signatures: [package.json with "main" field, pyproject.toml, Cargo.toml lib]
base: [engineer, qa, devils-advocate, security]
rationale: "API 안정성 + 하위호환성 + 공격면 최소화"
```

### `mobile-game` — 모바일 게임
```yaml
signatures: [Unity.app, Godot project, unreal]
base: [engineer, user, designer, performance]
rationale: "FPS + 메모리 + 시각 품질"
```

### `data-pipeline` — 데이터 파이프라인
```yaml
signatures: [airflow/, dbt_project.yml, luigi]
base: [engineer, devops, qa, performance]
rationale: "데이터 신뢰성 + 스케줄링 + 비용"
```

### `ml-training` — ML 학습 코드
```yaml
signatures: [*.ipynb, train.py, pytorch_lightning, transformers]
base: [engineer, performance, qa, devils-advocate]
rationale: "재현성 + GPU 비용 + 실험 가설"
```

---

## 🚨 강제 페르소나 규칙

특정 파일/디렉토리 감지 시 **반드시 추가**:

| 감지 | 강제 추가 페르소나 | 이유 |
|-----|-----------------|------|
| `credentials/`, `secrets/`, `.env*` | **security** | 시크릿 유출 방지 |
| `migrations/`, `alembic/` | **devops** | 데이터 마이그레이션 위험 |
| `payment`, `billing`, `stripe` 관련 | **security** + **pm** | 금전 거래 |
| `auth`, `oauth`, `jwt` 파일 | **security** | 인증 공격면 |
| `analytics`, `tracking` | **pm** + **user** | 프라이버시/측정 |
| `accessibility/`, `a11y/` | **designer** | WCAG 전담 |
| `terraform/`, `kubernetes/`, `helm/` | **devops** + **security** | 인프라 |
| `*.test.*`, `tests/`, `spec/` | (테스트 주제면) **qa** | |

---

## 🧩 복합 프로파일

여러 시그니처가 동시에 감지되는 경우:

### Flutter + Firebase
```yaml
signatures: [pubspec.yaml + firebase_options.dart]
base: [engineer, user, designer, qa]
forced: [security, devops]  # 백엔드 연동
```

### Python + Docker
```yaml
signatures: [requirements.txt + Dockerfile]
base: python-pipeline 또는 python-web 기반
forced: [devops]
```

### Next.js + API Routes
```yaml
signatures: [next.config.*, pages/api/ 또는 app/api/]
base: [engineer, user, designer, security]  # 풀스택
forced: [devops] (배포 시)
```

---

## 🎚️ 우선순위 충돌 해결

프로파일 간 충돌 시 규칙:

1. **명시적 > 암시적**: `.council-code.yml` > 자동 감지
2. **강제 > 권장**: `forced` > `base`
3. **보안 > 편의**: 보안 강제 추가는 제외 불가
4. **중복 제거**: 같은 페르소나 2번 추가 시 1번만
5. **상한 8명**: `--personas all` 외에는 최대 6명 권장

---

## 📊 사용자 환경 프로젝트별 실제 적용

### winote (`/Volumes/SSD/claude/Claude/winote`)
```yaml
감지: pubspec.yaml + app.json + eas.json → Flutter+Expo 하이브리드
→ base: [engineer, user, designer, qa]
→ CLAUDE.md에 "오프라인 우선, 로컬 SQLite" 감지 가능
→ 권장: 위 4명 + 필요 시 security (백업/동기화 시)
```

### 오픈클로 (`/Volumes/SSD/claude/Claude/오픈클로`)
```yaml
감지: agents/ + flows/ + cron/ + credentials/ → 자동화 시스템
→ base: [engineer, devops, security, devils-advocate]
→ credentials/ 감지 → security 강제 포함
→ 권장: 위 4명 고정
```

### 이미지생성 (`/Volumes/SSD/claude/이미지생성`)
```yaml
감지: batch_generate.py, flow_*.py, gpt_*.py → Python 파이프라인
→ base: [engineer, devops, performance, qa]
→ 권장: 위 4명 + ROI 논의 시 pm 추가
```

---

## 🔧 새 프로파일 추가 방법

본 카탈로그에 없는 프로젝트 타입 발견 시:

1. `type` 이름 결정 (kebab-case)
2. `signatures`: 감지에 쓸 파일/디렉토리 목록
3. `base`: 표준 페르소나 4명 (필요 시 5-6명)
4. `forced`: 강제 추가 (있다면)
5. `rationale`: 선택 근거 1-2줄

아래 양식으로 본 문서에 추가:

```yaml
### `프로젝트-타입-이름` — 한 줄 설명
signatures: [파일1, 파일2]
base: [페르소나1, 페르소나2, 페르소나3, 페르소나4]
forced: [강제페르소나]  # optional
rationale: "선택 근거"
```
