# 📄 Document Skills

> 통합 문서 처리 스킬 — HWP(한글), HWPX, DOCX, PDF, XLSX 자동화.
> 한국어 환경에 특화된 크로스플랫폼 문서 워크플로.

---

## ✨ 특징

- 🇰🇷 **한국어 문서 특화**: HWP/HWPX 완벽 지원
- 🖥️ **OS 자동 감지**: Mac/Linux/Windows에 맞는 도구 선택
- 🏢 **한컴 선택적**: 한컴 없어도 HWPX 작업 가능
- 🤖 **Claude 자동 라우팅**: 사용자 요청에 최적 도구 자동 선택
- 📊 **통합 변환**: HWP ↔ Markdown ↔ DOCX ↔ PDF

---

## 🚀 빠른 시작

### 설치

```bash
bash install-docs.sh
```

→ OS 자동 감지 + 필요한 라이브러리 설치

### 사용

Claude Code 세션에서 자연어로:

```
"이 HWP 파일 요약해줘"
"이 보고서 내용으로 HWP 문서 생성해줘"
"HWP 파일들을 모두 Markdown으로 변환"
"PDF로 변환해서 공유해줘"
```

→ `document-skills` 스킬이 자동 활성화되어 적절한 도구 호출

---

## 📚 사용 시나리오

### 1. HWP 읽기

```python
# examples/read-hwp.py 참조
from kordoc import parse_document

content = parse_document("report.hwp")  # → Markdown
print(content)
```

### 2. 여러 형식 통합 변환

```python
# examples/convert-to-markdown.py 참조
# HWP, HWPX, DOCX, PDF, XLSX 모두 Markdown으로
```

### 3. HWPX 편집 (크로스플랫폼)

```python
# examples/write-hwpx-cross.py 참조
from hwpx import HwpxDocument

doc = HwpxDocument.open("template.hwpx")
doc.replace_all("{{NAME}}", "홍길동")
doc.save("output.hwpx")
```

### 4. HWP 쓰기 (Windows + 한컴)

```python
# examples/write-hwp-windows.py 참조
from pyhwpx import Hwp

hwp = Hwp()
hwp.insert_text("새 보고서")
hwp.create_table(3, 4)
hwp.save_as("report.hwp")
```

---

## 🔧 포함된 도구

| 도구 | 역할 | OS | 라이선스 |
|-----|-----|-----|--------|
| **pyhwp** | HWP 5.x 읽기 | 모든 OS | AGPL-3.0 |
| **python-hwpx** | HWPX 편집 | 모든 OS | ⚠️ **Non-Commercial** |
| **kordoc** | 통합 Markdown 변환 | 모든 OS | MIT |
| **pyhwpx** | HWP 쓰기 (한컴 COM) | Windows | MIT |
| **hwpx-mcp-server** | Claude MCP 서버 | 모든 OS | MIT |

---

## ⚠️ 라이선스 주의

### python-hwpx (Non-Commercial)
- 개인 사용 **OK**
- 상업 사용 **금지**
- 배포 제품에 포함 시 라이선스 위반

**본 스킬은 개인 사용 전제**로 설계됨. 상업 사용 시 대안:
- `neolord0/hwplib` (Java, Apache-2.0)
- 한컴 공식 SDK (유료)

### pyhwp (AGPL-3.0)
- 개인 사용 **OK**
- 배포 시 소스 공개 의무

---

## 🎯 OS별 기능 매트릭스

| 작업 | Mac | Linux | Windows (한컴 X) | Windows (한컴 O) |
|------|:-:|:-:|:-:|:-:|
| HWP 읽기 | ✅ | ✅ | ✅ | ✅ |
| HWPX 읽기 | ✅ | ✅ | ✅ | ✅ |
| HWPX 쓰기 | ✅ | ✅ | ✅ | ✅ |
| HWP 5.x 쓰기 | ❌ | ❌ | ❌ | ✅ |
| HWP → PDF | ⚠️ LibreOffice | ⚠️ LibreOffice | ⚠️ | ✅ |
| HWP 편집 (고급) | ❌ | ❌ | ❌ | ✅ |
| Markdown 변환 | ✅ | ✅ | ✅ | ✅ |

→ **Windows + 한컴** 환경이 가장 강력

---

## 🤖 MCP 서버 설정 (선택)

Claude Desktop 또는 Claude Code에서 HWPX를 MCP로 자동화:

### Claude Code

`~/.claude/settings.json`:
```json
{
  "mcpServers": {
    "hwpx": {
      "command": "python3",
      "args": ["-m", "hwpx_mcp_server"]
    }
  }
}
```

### Claude Desktop

`~/Library/Application Support/Claude/claude_desktop_config.json`:
```json
{
  "mcpServers": {
    "hwpx": {
      "command": "python3",
      "args": ["-m", "hwpx_mcp_server"]
    }
  }
}
```

설정 후 재시작.

---

## 🔧 문제 해결

### "import hwpx failed"
```bash
pip install --upgrade python-hwpx
```

### "pyhwpx: No module named 'win32com'" (Windows)
```bash
pip install pywin32
python -m pip install --upgrade pywin32
# 관리자 권한 PowerShell:
python Scripts/pywin32_postinstall.py -install
```

### "HWP 파일 인코딩 오류"
- HWP 5.x 버전 확인
- `kordoc` 시도 (더 관대한 파서)

### "한컴 자동화 실패" (Windows)
- 한컴오피스가 설치되어 있는지 확인
- 한글 프로그램이 이미 열려 있지 않은지 확인
- 관리자 권한으로 스크립트 실행

### "Mac에서 HWP 쓰기가 안 됨"
- Mac에서는 **HWP 5.x 쓰기 불가**
- 대안: HWPX로 저장 → Windows PC에서 한컴으로 변환

---

## 📖 더 배우기

- [pyhwp 공식 문서](https://github.com/mete0r/pyhwp)
- [python-hwpx 문서](https://github.com/airmang/python-hwpx)
- [kordoc README](https://github.com/chrisryugj/kordoc)
- [한컴 공식 pyhwpx 포럼](https://forum.developer.hancom.com/t/pyhwpx/1111)
- [HWPX OOXML 공식 규격](https://www.hancom.com/etc/hwpDownload.do)

---

## 🙏 크레딧

- mete0r — pyhwp (16년 유지)
- airmang (Kyuhyun Ko, 광교고 정보교사) — python-hwpx 생태계
- martiniifun — pyhwpx (한컴 COM)
- chrisryugj — kordoc (HWP→Markdown 통합)

---

## 📄 라이선스

본 스킬 자체: MIT (스킬 문서/스크립트).
단, 내부에서 사용하는 라이브러리들은 각자의 라이선스를 따름.
**개인 사용 전제**.
