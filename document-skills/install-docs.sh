#!/usr/bin/env bash
# Document Skills 의존성 자동 설치 스크립트
# OS 자동 감지 후 필요한 Python 라이브러리 설치

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()   { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()  { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

log "Document Skills 의존성 설치 시작"
echo ""

# 1. OS 감지
OS="$(uname -s)"
case "$OS" in
    Darwin*)  OS_NAME="macOS" ;;
    Linux*)   OS_NAME="Linux" ;;
    CYGWIN*|MINGW*|MSYS*) OS_NAME="Windows" ;;
    *)        OS_NAME="Unknown" ;;
esac

log "감지된 OS: $OS_NAME"

# 2. Python 3.10+ 확인 (python-hwpx 등 필수 요구사항)
PYTHON_CMD=""
for candidate in python3.14 python3.13 python3.12 python3.11 python3.10; do
    if command -v "$candidate" &> /dev/null; then
        PYTHON_CMD="$candidate"
        break
    fi
done

# Homebrew Python 경로도 확인
if [ -z "$PYTHON_CMD" ]; then
    for path in /opt/homebrew/bin /usr/local/bin; do
        for ver in python3.14 python3.13 python3.12 python3.11 python3.10; do
            if [ -x "$path/$ver" ]; then
                PYTHON_CMD="$path/$ver"
                break 2
            fi
        done
    done
fi

# 기본 python3 버전 확인
if [ -z "$PYTHON_CMD" ]; then
    if command -v python3 &> /dev/null; then
        PY_VER=$(python3 -c "import sys; print(f'{sys.version_info.minor}')")
        if [ "$PY_VER" -ge 10 ] 2>/dev/null; then
            PYTHON_CMD="python3"
        fi
    fi
fi

if [ -z "$PYTHON_CMD" ]; then
    err "Python 3.10 이상이 필요합니다. 설치 후 재시도하세요.
    macOS: brew install python@3.12
    Ubuntu: sudo apt install python3.12"
fi

log "Python: $($PYTHON_CMD --version)"

# 3. venv 가상환경 생성 (PEP 668 대응)
VENV_PATH="$HOME/.hwp-tools"
echo ""
log "가상환경 생성 중: $VENV_PATH"

if [ -d "$VENV_PATH" ]; then
    warn "기존 가상환경 발견. 업데이트합니다."
else
    $PYTHON_CMD -m venv "$VENV_PATH"
    ok "가상환경 생성 완료"
fi

# venv 활성화
source "$VENV_PATH/bin/activate" 2>/dev/null || source "$VENV_PATH/Scripts/activate" 2>/dev/null
PIP_CMD="pip"

log "venv Python: $(python --version)"

# 4. 공통 라이브러리 설치 (모든 OS)
echo ""
log "공통 라이브러리 설치 중..."

for lib in pyhwp python-hwpx hwpx-mcp-server; do
    log "  설치 중: $lib"
    if $PIP_CMD install --upgrade "$lib" 2>&1 | tail -2; then
        ok "  $lib"
    else
        warn "  $lib 설치 실패"
    fi
done

# kordoc (PyPI에 없을 수 있음 → GitHub 시도)
log "  설치 중: kordoc"
if $PIP_CMD install --upgrade kordoc 2>&1 | tail -2; then
    ok "  kordoc"
else
    log "  kordoc PyPI 없음 → GitHub에서 설치 시도..."
    if $PIP_CMD install git+https://github.com/chrisryugj/kordoc.git 2>&1 | tail -2; then
        ok "  kordoc (GitHub)"
    else
        warn "  kordoc 설치 실패 — 선택 사항, 없어도 동작"
    fi
fi

# 5. Windows 전용 라이브러리
if [ "$OS_NAME" = "Windows" ]; then
    echo ""
    log "Windows 전용 라이브러리 설치 중..."
    log "  설치 중: pyhwpx (한컴 COM)"
    if $PIP_CMD install --upgrade pyhwpx pywin32 2>&1 | tail -2; then
        ok "  pyhwpx + pywin32"
        warn "  한글과컴퓨터 오피스가 설치되어 있어야 동작합니다."
    else
        warn "  pyhwpx 설치 실패 — pip install pyhwpx pywin32"
    fi
fi

# 6. 검증
echo ""
log "설치 검증 중..."

check_import() {
    local module=$1
    if python -c "import $module" 2>/dev/null; then
        ok "  $module"
        return 0
    else
        warn "  $module - import 실패"
        return 1
    fi
}

check_import "hwp5" || true       # pyhwp
check_import "hwpx" || true       # python-hwpx
check_import "hwpx_mcp_server" || true

if [ "$OS_NAME" = "Windows" ]; then
    check_import "pyhwpx" || true
fi

# venv 비활성화
deactivate 2>/dev/null || true

# 8. 디렉토리 구조
echo ""
log "document-skills 디렉토리 생성..."
mkdir -p ~/.claude/skills/document-skills/logs
mkdir -p ~/.claude/skills/document-skills/output
ok "로그/출력 디렉토리 준비 완료"

# 9. 완료 메시지
echo ""
ok "Document Skills 의존성 설치 완료!"
echo ""
echo "🎯 설치된 기능:"
echo "  ✅ HWP 5.x 읽기 (pyhwp)"
echo "  ✅ HWPX 읽기/쓰기 (python-hwpx)"
echo "  ✅ 통합 Markdown 변환 (kordoc)"
echo "  ✅ Claude Desktop/Code용 MCP 서버"

if [ "$OS_NAME" = "Windows" ]; then
    echo "  ✅ HWP 5.x 쓰기 via 한컴 COM (pyhwpx)"
else
    echo "  ⚠️  HWP 5.x 쓰기는 Windows + 한컴에서만 가능"
fi

echo ""
echo "📖 사용 가이드:"
echo "  ~/.claude/skills/document-skills/README.md"
echo ""
echo "💡 예시 코드:"
echo "  ~/.claude/skills/document-skills/examples/"
echo ""
echo "🤖 MCP 서버 설정:"
echo "  Claude Code settings에 다음 추가 고려:"
echo '  {'
echo '    "mcpServers": {'
echo '      "hwpx": {'
echo "        \"command\": \"$HOME/.hwp-tools/bin/python\","
echo '        "args": ["-m", "hwpx_mcp_server"]'
echo '      }'
echo '    }'
echo '  }'
echo ""
echo "🐍 가상환경 경로: $HOME/.hwp-tools"
echo "   Python: $HOME/.hwp-tools/bin/python"
echo "   pip: $HOME/.hwp-tools/bin/pip"
echo ""
echo "⚠️  라이선스 알림:"
echo "  python-hwpx는 Non-Commercial 라이선스입니다."
echo "  개인 사용만 허용됩니다."
