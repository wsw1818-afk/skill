#!/usr/bin/env bash
# Council-Code 제거 스크립트

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()   { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"

log "Council-Code 제거"
warn "다음 파일들을 제거합니다:"
echo "  - $CLAUDE_HOME/skills/council-code/"
echo "  - $CLAUDE_HOME/agents/perspective-*.md"
echo ""
read -p "계속하시겠습니까? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log "제거 취소"
    exit 0
fi

# 제거 전 자동 백업
BACKUP_DIR="$CLAUDE_HOME/.council-code-uninstall-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR/agents" "$BACKUP_DIR/skills"

# 스킬 제거
if [ -d "$CLAUDE_HOME/skills/council-code" ]; then
    cp -r "$CLAUDE_HOME/skills/council-code" "$BACKUP_DIR/skills/" 2>/dev/null || true
    rm -rf "$CLAUDE_HOME/skills/council-code"
    ok "스킬 디렉토리 제거"
fi

# 페르소나 제거
COUNT=0
for agent in "$CLAUDE_HOME/agents/perspective-"*.md; do
    if [ -f "$agent" ]; then
        cp "$agent" "$BACKUP_DIR/agents/" 2>/dev/null || true
        rm -f "$agent"
        COUNT=$((COUNT + 1))
    fi
done
ok "페르소나 $COUNT개 제거"

echo ""
ok "제거 완료"
echo ""
echo "♻️  안전 백업 위치: $BACKUP_DIR"
echo "   완전 삭제를 원하시면: rm -rf $BACKUP_DIR"
