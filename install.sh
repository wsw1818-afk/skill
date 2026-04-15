#!/usr/bin/env bash
# Council-Code 자동 설치 스크립트
# 다른 PC에서 실행: bash install.sh

set -e

# 색상
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()   { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()  { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# 스크립트 위치
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"

log "Council-Code 설치 시작"
log "소스: $SCRIPT_DIR"
log "대상: $CLAUDE_HOME"
echo ""

# 1. Claude Code 디렉토리 존재 확인
if [ ! -d "$CLAUDE_HOME" ]; then
    warn "$CLAUDE_HOME 디렉토리가 없습니다. 생성합니다."
    mkdir -p "$CLAUDE_HOME/agents" "$CLAUDE_HOME/skills"
fi

# 2. 필수 디렉토리 생성
mkdir -p "$CLAUDE_HOME/agents"
mkdir -p "$CLAUDE_HOME/skills/council-code"

# 3. 기존 파일 백업
BACKUP_DIR="$CLAUDE_HOME/.council-code-backup-$(date +%Y%m%d-%H%M%S)"
HAS_EXISTING=false

for f in "$CLAUDE_HOME/agents/perspective-"*.md "$CLAUDE_HOME/skills/council-code/"*.md; do
    if [ -f "$f" ]; then
        HAS_EXISTING=true
        break
    fi
done

if [ "$HAS_EXISTING" = true ]; then
    warn "기존 Council-Code 파일 발견. 백업합니다: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR/agents" "$BACKUP_DIR/skills"
    cp -r "$CLAUDE_HOME/agents/perspective-"*.md "$BACKUP_DIR/agents/" 2>/dev/null || true
    cp -r "$CLAUDE_HOME/skills/council-code/" "$BACKUP_DIR/skills/" 2>/dev/null || true
    ok "백업 완료: $BACKUP_DIR"
fi

# 4. 스킬 파일 설치
log "스킬 파일 설치 중..."
if [ -f "$SCRIPT_DIR/SKILL.md" ]; then
    cp "$SCRIPT_DIR/SKILL.md" "$CLAUDE_HOME/skills/council-code/"
    ok "  SKILL.md"
fi
if [ -f "$SCRIPT_DIR/personas.md" ]; then
    cp "$SCRIPT_DIR/personas.md" "$CLAUDE_HOME/skills/council-code/"
    ok "  personas.md"
fi

# 5. 페르소나 에이전트 설치
log "페르소나 에이전트 설치 중..."
PERSONA_COUNT=0
for agent_file in "$SCRIPT_DIR/agents/perspective-"*.md; do
    if [ -f "$agent_file" ]; then
        cp "$agent_file" "$CLAUDE_HOME/agents/"
        basename_file=$(basename "$agent_file")
        ok "  $basename_file"
        PERSONA_COUNT=$((PERSONA_COUNT + 1))
    fi
done

if [ "$PERSONA_COUNT" -eq 0 ]; then
    err "페르소나 에이전트를 찾을 수 없습니다. agents/ 디렉토리 확인 필요."
fi

# 6. 샘플 프로젝트 설정 (선택)
if [ -d "$SCRIPT_DIR/samples" ]; then
    log "샘플 프로젝트 설정이 samples/ 디렉토리에 있습니다."
    log "원하는 프로젝트에 수동 복사하세요:"
    for sample in "$SCRIPT_DIR/samples/"*.yml; do
        [ -f "$sample" ] && echo "  - $(basename "$sample")"
    done
fi

# 7. 완료 메시지
echo ""
ok "설치 완료!"
echo ""
echo "📦 설치된 항목:"
echo "  - 스킬: $CLAUDE_HOME/skills/council-code/"
echo "  - 페르소나 $PERSONA_COUNT개: $CLAUDE_HOME/agents/perspective-*.md"
echo ""
echo "🎬 사용법:"
echo "  /council-code \"주제\"              # 기본"
echo "  /council-code --quick \"주제\"       # 3명 미니"
echo "  /council-code --personas all \"주제\" # 풀 원탁"
echo ""
echo "📁 프로젝트별 프로파일 설정:"
echo "  프로젝트 루트에 .council-code.yml 생성 (samples/ 참고)"
echo ""
if [ "$HAS_EXISTING" = true ]; then
    echo "♻️  기존 백업: $BACKUP_DIR"
fi
