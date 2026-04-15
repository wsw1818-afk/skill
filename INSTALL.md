# Council-Code 설치 가이드 (다른 PC용)

## 📦 설치 방법 3가지

사용 환경에 맞는 방법을 선택하세요.

---

## 🥇 방법 1: 포터블 tar.gz 패키지 (가장 간단)

### 기존 PC에서 (패키징)

```bash
# 1. 패키지 생성
bash ~/.claude/skills/council-code/package.sh

# 결과: ~/Desktop/council-code-v20260415-xxxx.tar.gz 생성됨
```

### 새 PC로 전송

다음 중 하나:
- AirDrop (macOS ↔ macOS)
- USB 드라이브
- Google Drive / Dropbox / iCloud
- `scp` 명령: `scp council-code-v*.tar.gz user@newpc:~/Desktop/`

### 새 PC에서 (설치)

```bash
# 1. 압축 해제
cd ~/Desktop
tar xzf council-code-v*.tar.gz
cd council-code-v*

# 2. 설치 스크립트 실행
bash install.sh

# 3. 확인
ls ~/.claude/agents/perspective-*.md
ls ~/.claude/skills/council-code/
```

**소요 시간**: 약 1분

---

## 🥈 방법 2: GitHub 리포지터리 (재사용/공유 최적)

### 기존 PC에서 (GitHub 업로드)

```bash
cd ~/.claude/skills/council-code

# 1. Git 초기화
git init
git add .
git commit -m "feat: council-code multi-perspective agent system"

# 2. GitHub 리포 생성 (gh CLI 필요)
gh repo create council-code --private --source=. --push

# 또는 수동으로:
# - github.com에서 새 리포 생성
# - git remote add origin <URL>
# - git push -u origin main

# 3. 페르소나 파일도 포함 (에이전트는 별도 위치이므로 복사)
mkdir -p agents
cp ~/.claude/agents/perspective-*.md agents/
git add agents/
git commit -m "feat: add 9 perspective personas"
git push
```

### 새 PC에서 (설치)

```bash
# 1. 리포 클론
cd ~/Downloads  # 임시 위치
git clone https://github.com/YOUR_USERNAME/council-code.git
cd council-code

# 2. 설치
bash install.sh
```

**장점**:
- 버전 관리 가능
- 여러 PC에서 `git pull`로 동기화
- 팀/커뮤니티와 공유 용이

---

## 🥉 방법 3: 수동 복사 (최후의 수단)

Claude Code가 설치된 PC라면 직접 파일 복사:

```bash
# 기존 PC에서 → 새 PC로

# 1. 스킬 파일
scp -r ~/.claude/skills/council-code/ \
    user@newpc:~/.claude/skills/

# 2. 페르소나 에이전트 (와일드카드는 개별 복사)
scp ~/.claude/agents/perspective-*.md \
    user@newpc:~/.claude/agents/
```

---

## 🔍 설치 확인

새 PC에서 설치 후 확인:

```bash
# 1. 파일 존재 확인
ls ~/.claude/skills/council-code/SKILL.md
ls ~/.claude/agents/perspective-*.md | wc -l  # 9개여야 함

# 2. Claude Code 재시작 (필요 시)
# 새 스킬/에이전트가 즉시 인식됨

# 3. 테스트
# Claude에서:
# /council-code "테스트 주제"
```

---

## 🎯 프로젝트별 설정 이식

프로젝트별 `.council-code.yml` 파일은 프로젝트 단위로 관리:

### Option A: 프로젝트 자체가 Git으로 관리되는 경우

```bash
# .council-code.yml을 프로젝트 git에 커밋
cd /path/to/project
git add .council-code.yml
git commit -m "chore: add council-code profile"

# 다른 PC에서 프로젝트 clone 시 자동 포함됨
```

### Option B: 샘플에서 복사

포터블 패키지에 포함된 `samples/` 디렉토리에서:

```bash
cd council-code-v*/samples/
# 필요한 샘플을 프로젝트에 복사
cp winote.council-code.yml /path/to/new-winote-project/.council-code.yml
```

### Option C: 새로 작성

프로젝트 루트에서:

```bash
cat > .council-code.yml <<'EOF'
name: "내 프로젝트"
type: "flutter-app"  # 또는 python-pipeline / web-frontend 등
base_personas: [engineer, user, designer, qa]
EOF
```

---

## ⚠️ 주의사항

### 경로 의존성

스킬 자체는 **절대 경로를 참조하지 않음**. 어떤 사용자명/PC에서든 동작.

단, 예시 문서(SKILL.md)의 경로는 사용자 환경 예시일 뿐 실제 로직과 무관.

### Claude Code 버전 호환성

- Claude Code 1.x 이상 필요
- 서브에이전트 기능이 있어야 함 (`~/.claude/agents/` 지원)

### 기존 설치 덮어쓰기

`install.sh`는 기존 파일을 **자동 백업** 후 덮어씁니다:
- 백업 위치: `~/.claude/.council-code-backup-YYYYMMDD-HHMMSS/`
- 복원하려면 백업 디렉토리에서 파일 복사

---

## 🔄 업데이트 흐름

### 한 PC에서 수정 → 다른 PC로 동기화

**tar.gz 방식**:
```bash
# PC A (수정 후)
bash ~/.claude/skills/council-code/package.sh

# PC B (업데이트)
tar xzf council-code-v*.tar.gz
cd council-code-v*
bash install.sh  # 기존 자동 백업
```

**Git 방식**:
```bash
# PC A
cd ~/.claude/skills/council-code
git commit -am "feat: add new persona"
git push

# PC B
cd ~/Downloads/council-code
git pull
bash install.sh
```

---

## 🧪 이식성 테스트 (선택)

새 PC에서 설치 직후 동작 확인:

```bash
# 1. 디렉토리 구조 검증
test -f ~/.claude/skills/council-code/SKILL.md && echo "✅ SKILL.md"
test -f ~/.claude/skills/council-code/personas.md && echo "✅ personas.md"
test -f ~/.claude/skills/council-code/profiles.md && echo "✅ profiles.md"

# 2. 페르소나 개수 확인 (9개 기본)
count=$(ls ~/.claude/agents/perspective-*.md 2>/dev/null | wc -l)
echo "페르소나: $count / 9"

# 3. 권한 확인
test -x ~/.claude/skills/council-code/install.sh && echo "✅ install.sh 실행 가능"
```

---

## ❓ 문제 해결

### "권한 없음" 오류
```bash
chmod +x install.sh uninstall.sh package.sh
```

### Claude Code가 스킬을 인식 못함
- Claude Code 재시작
- `ls ~/.claude/skills/council-code/SKILL.md` 파일 존재 확인
- SKILL.md의 프론트매터(`---`) 손상 여부 확인

### 페르소나가 호출되지 않음
- `~/.claude/agents/` 디렉토리 권한 확인: `chmod 755 ~/.claude/agents`
- 파일 권한: `chmod 644 ~/.claude/agents/perspective-*.md`

### 프로젝트 자동 감지 실패
- `.council-code.yml` 파일이 **프로젝트 루트**에 있는지 확인
- Claude 세션을 해당 디렉토리에서 시작했는지 확인
