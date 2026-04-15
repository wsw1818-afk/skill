#!/usr/bin/env bash
# Council-Code 포터블 패키지 생성 스크립트
# 현재 PC의 설정을 tar.gz로 묶어 다른 PC로 전송 가능하게 만듦

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()  { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/Desktop}"
VERSION=$(date +%Y%m%d-%H%M)
PKG_NAME="council-code-v${VERSION}"
TMP_DIR=$(mktemp -d)
PKG_DIR="$TMP_DIR/$PKG_NAME"

log "Council-Code 포터블 패키지 생성"
log "소스: $CLAUDE_HOME"
log "임시 작업 디렉토리: $PKG_DIR"
echo ""

# 1. 임시 구조 생성
mkdir -p "$PKG_DIR/agents" "$PKG_DIR/samples"

# 2. 스킬 파일 복사
log "스킬 파일 수집..."
if [ -d "$CLAUDE_HOME/skills/council-code" ]; then
    cp "$CLAUDE_HOME/skills/council-code/SKILL.md" "$PKG_DIR/" 2>/dev/null && ok "  SKILL.md"
    cp "$CLAUDE_HOME/skills/council-code/personas.md" "$PKG_DIR/" 2>/dev/null && ok "  personas.md"
    cp "$CLAUDE_HOME/skills/council-code/install.sh" "$PKG_DIR/" 2>/dev/null && ok "  install.sh"
    cp "$CLAUDE_HOME/skills/council-code/uninstall.sh" "$PKG_DIR/" 2>/dev/null && ok "  uninstall.sh"
    cp "$CLAUDE_HOME/skills/council-code/INSTALL.md" "$PKG_DIR/" 2>/dev/null && ok "  INSTALL.md"
    cp "$CLAUDE_HOME/skills/council-code/README.md" "$PKG_DIR/" 2>/dev/null && ok "  README.md"
fi

# 3. 페르소나 에이전트 수집
log "페르소나 에이전트 수집..."
COUNT=0
for agent in "$CLAUDE_HOME/agents/perspective-"*.md; do
    if [ -f "$agent" ]; then
        cp "$agent" "$PKG_DIR/agents/"
        ok "  $(basename "$agent")"
        COUNT=$((COUNT + 1))
    fi
done
log "총 $COUNT개 페르소나 수집됨"

# 4. 샘플 프로젝트 설정 수집 (있으면)
log "샘플 프로젝트 설정 수집..."
SAMPLE_COUNT=0

# 사용자 환경의 3개 프로젝트 경로
SAMPLE_PATHS=(
    "/Volumes/SSD/claude/Claude/winote/.council-code.yml"
    "/Volumes/SSD/claude/Claude/오픈클로/.council-code.yml"
    "/Volumes/SSD/claude/이미지생성/.council-code.yml"
)

for path in "${SAMPLE_PATHS[@]}"; do
    if [ -f "$path" ]; then
        # 프로젝트명 추출
        proj_name=$(basename "$(dirname "$path")")
        cp "$path" "$PKG_DIR/samples/${proj_name}.council-code.yml"
        ok "  samples/${proj_name}.council-code.yml"
        SAMPLE_COUNT=$((SAMPLE_COUNT + 1))
    fi
done

# 5. 실행 권한 부여
chmod +x "$PKG_DIR/install.sh" "$PKG_DIR/uninstall.sh" 2>/dev/null || true

# 6. 버전 정보 생성
cat > "$PKG_DIR/VERSION" <<EOF
Council-Code Portable Package
Version: $VERSION
Packaged: $(date)
Source Host: $(hostname)
Source User: $USER
Personas: $COUNT
Samples: $SAMPLE_COUNT
EOF
ok "VERSION 정보 생성"

# 7. tar.gz 압축
OUTPUT_FILE="$OUTPUT_DIR/${PKG_NAME}.tar.gz"
log "압축 중: $OUTPUT_FILE"
cd "$TMP_DIR"
tar czf "$OUTPUT_FILE" "$PKG_NAME"

# 8. 크기 확인 및 정리
SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
rm -rf "$TMP_DIR"

echo ""
ok "패키지 생성 완료!"
echo ""
echo "📦 파일: $OUTPUT_FILE"
echo "📏 크기: $SIZE"
echo "🎯 포함: 스킬 파일 + 페르소나 $COUNT개 + 샘플 $SAMPLE_COUNT개"
echo ""
echo "🚀 다른 PC에서 사용하는 방법:"
echo "  1. $OUTPUT_FILE 을 다른 PC로 전송"
echo "     (AirDrop / USB / Google Drive / scp 등)"
echo "  2. tar xzf ${PKG_NAME}.tar.gz"
echo "  3. cd $PKG_NAME"
echo "  4. bash install.sh"
echo ""
echo "💡 Claude Code 사용자명이 다른 PC의 경우에도 자동 감지됩니다."
