---
name: document-skills
description: |
  통합 문서 처리 스킬 — HWP(한글), HWPX, DOCX, PDF, XLSX 읽기/쓰기/변환.
  OS 자동 감지(Mac/Linux/Windows)로 최적 도구 선택. 한글과컴퓨터 설치
  감지. 개인 사용 특화 (Non-Commercial 라이선스 포함).
  Use when user wants to read/write/convert HWP, HWPX, or cross-format
  document automation in Korean workflows.
---

# Document-Skills: 통합 문서 처리

> 한국어 문서(HWP/HWPX)를 중심으로 MS Office(DOCX/XLSX/PPTX)와 PDF까지
> 통합 처리하는 스킬. OS별 최적 도구를 자동 선택한다.

---

## 🎯 언제 사용하는가

**반드시 사용:**
- HWP/HWPX 파일 읽기/쓰기/변환
- 한국어 문서 자동화 워크플로
- 여러 형식 간 상호 변환 (HWP ↔ Markdown ↔ DOCX)
- 공공기관/법원/교육청 양식 자동화

**사용 금지 (다른 스킬 사용):**
- MS Office만 필요 → `anthropic-skills:docx/pptx/xlsx/pdf` 직접 사용
- 이미지/비디오 처리 → 해당 전용 도구
- 단순 텍스트 편집 → Read/Write 직접

---

## 🛠️ 도구 매트릭스 (OS/작업별)

### 읽기 (크로스플랫폼)

| 작업 | 도구 | 이유 |
|-----|------|------|
| HWP 5.x 텍스트 추출 | `pyhwp` | 16년 검증된 표준 |
| HWPX 텍스트/구조 | `python-hwpx` | Pure Python, 월 27K 다운로드 |
| 통합 → Markdown | `kordoc` | HWP/HWPX/PDF/DOCX/XLSX 모두 처리 |
| DOCX/PDF/XLSX | `anthropic-skills:*` | 공식 스킬 활용 |

### 쓰기 (OS별 분기)

| 환경 | 도구 | 특징 |
|-----|------|------|
| **Windows + 한컴** | `pyhwpx` | 한컴 공식 포럼 언급, HWP 쓰기 가능 |
| **Mac/Linux (HWPX만)** | `python-hwpx` | Pure Python 편집 |
| **HWP 5.x 쓰기 (크로스)** | ❌ 현실적 부재 | Windows pyhwpx 권장 |

### 변환

| 변환 | 최선 경로 |
|-----|---------|
| HWP → Markdown | `kordoc parse` |
| HWP → DOCX | `kordoc` → Markdown → `pandoc` |
| HWP → PDF (Windows) | `pyhwpx` → SaveAs PDF |
| HWP → PDF (Mac/Linux) | LibreOffice headless (`soffice --convert-to pdf`) |
| Markdown → HWP | `md2hml` 또는 kordoc 역변환 |
| HWPX → PDF | LibreOffice 또는 python-hwpx + pandoc |

---

## 🔍 OS 자동 감지 로직

```python
import platform
import shutil
import subprocess

def detect_environment():
    os_type = platform.system()  # Darwin / Linux / Windows
    has_hancom = False

    if os_type == "Windows":
        # 한컴오피스 설치 확인
        import winreg
        try:
            winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE,
                          r"SOFTWARE\HNC\Hwp")
            has_hancom = True
        except FileNotFoundError:
            pass

    has_libreoffice = shutil.which("soffice") is not None

    return {
        "os": os_type,
        "has_hancom": has_hancom,
        "has_libreoffice": has_libreoffice,
    }
```

→ 감지 결과에 따라 도구 라우팅

---

## 📋 사용 시나리오별 플로우

### 시나리오 1: "이 HWP 파일 내용 요약해줘"

```
1. OS 감지 (모든 OS에서 동일)
2. kordoc parse {file}.hwp → Markdown
3. Markdown을 Claude에게 전달
4. Claude 요약
```

### 시나리오 2: "이 HWP 파일을 편집하고 저장"

```
1. OS 감지
2-A. Windows + 한컴:
     pyhwpx로 열기 → 편집 → SaveAs(.hwp)
2-B. Mac/Linux:
     HWP → HWPX로 변환 (kordoc)
     python-hwpx로 편집 → HWPX 저장
     (원본 HWP 5.x로 저장은 불가)
```

### 시나리오 3: "여러 HWP 파일 텍스트 일괄 추출"

```
for file in *.hwp:
  kordoc parse {file} → Markdown
  저장 → output/{file}.md
```

### 시나리오 4: "HWP로 보고서 자동 생성"

```
1. OS 감지
2-A. Windows + 한컴 (권장):
     pyhwpx로 새 문서 생성 → 텍스트/표 삽입 → .hwp 저장
2-B. Mac/Linux:
     python-hwpx로 HWPX 템플릿 생성 → HWPX 저장
     (Windows PC에서 나중에 .hwp로 변환)
```

### 시나리오 5: "HWP → PDF 변환"

```
1. OS 감지
2-A. Windows + 한컴:
     pyhwpx로 열기 → SaveAs(PDF)
2-B. Mac/Linux + LibreOffice:
     soffice --headless --convert-to pdf {file}.hwp
     (일부 서식 손실 가능)
2-C. LibreOffice 없음:
     사용자에게 설치 안내 또는 한국 온라인 변환 서비스 안내
```

---

## 🎬 Claude 행동 지침

사용자가 HWP/HWPX 관련 요청 시 **자동으로 다음 순서로 판단**:

```
1. 파일 존재/경로 확인
2. detect_environment() 실행 → OS/한컴/LibreOffice 상태 파악
3. 작업 유형 분류:
   - 읽기? → kordoc 또는 pyhwp/python-hwpx
   - 쓰기? → OS별 분기 (위 시나리오 참조)
   - 변환? → 변환 매트릭스 참조
4. 적절한 examples/*.py 스크립트 참조
5. 실행 + 결과 보고
```

**중요 알림**:
- Mac/Linux에서 HWP 5.x 쓰기 요청 시 → "이 환경에서는 HWPX 저장만 가능합니다. Windows 전환 또는 HWPX 수락?"
- 한컴 없는 Windows에서 HWP 쓰기 요청 시 → "한컴 설치가 필요합니다. HWPX로 저장할까요?"

---

## 📚 라이브러리 라이선스 (사용자 인지 필수)

| 라이브러리 | 라이선스 | 사용 제한 |
|----------|---------|---------|
| pyhwp | AGPL-3.0 | 개인 OK, 배포 시 동일 라이선스 |
| python-hwpx | **NOASSERTION (Non-Commercial)** | **개인 OK, 상업 금지** |
| kordoc | MIT | 제약 없음 |
| pyhwpx | MIT | 제약 없음 |
| hwpx-mcp-server | MIT | 제약 없음 |

→ **이 스킬은 개인 사용을 전제**로 함. 상업/배포 시 python-hwpx 교체 필요.

---

## 🔗 관련 스킬/도구

- **`doc-hub`** (기존): 여러 문서 형식 라우팅 허브
- **`anthropic-skills:docx/pptx/xlsx/pdf`**: MS Office 공식 스킬
- **`docx`** (기존): Word 한국어 특화
- **`council-code`**: 문서 자동화 아키텍처 결정 필요 시 원탁회의

---

## ⚠️ 제한사항

### HWP 5.x 바이너리 쓰기
- Windows + 한컴 필수 (pyhwpx)
- Mac/Linux에서는 현실적으로 불가능
- 대안: HWPX(XML 기반)로 작업 후 Windows에서 HWP 변환

### 한컴 자동화 (pyhwpx) 제한
- pywin32 의존 (Windows 전용)
- 한컴오피스가 백그라운드에서 실행됨 (리소스 사용)
- 동시 다중 파일 처리 시 주의

### HWP → PDF 크로스플랫폼 변환
- LibreOffice headless는 일부 서식 손실 가능
- 정확한 PDF 필요 시 Windows + 한컴 + pyhwpx 권장

---

## 🧪 검증된 사용 사례 (조사 결과)

- **공공기관 공문서**: `sinmb79/GongMun-Doctor-MCP` (HWPX 기반)
- **나라장터 API**: `Kwondongkyun/nara-api` (python-hwpx 의존)
- **HWP CLI**: `reallygood83/hwpx-cli`
- **한컴 공식 언급**: martiniifun/pyhwpx (한컴 개발자 포럼 등재)

---

## 📊 측정 지표

실행 로그: `~/.claude/skills/document-skills/logs/YYYY-MM-DD.jsonl`

```json
{"timestamp": "...", "operation": "read|write|convert",
 "format_in": "hwp", "format_out": "markdown",
 "tool_used": "kordoc", "os": "darwin", "has_hancom": false,
 "duration_ms": 1200, "status": "success"}
```

---

## 🎓 언제 이 스킬을 호출하지 말 것

- 단순 텍스트 파일 읽기/쓰기 (Read/Write 직접)
- MS Office만 처리 (anthropic-skills 직접)
- 이미지/비디오/오디오 (다른 전용 도구)
- 대용량 DB 문서 관리 (별도 도구)
