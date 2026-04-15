#!/usr/bin/env python3
"""
크로스플랫폼 HWPX 쓰기 예시 (python-hwpx).

Mac/Linux/Windows 모두 동작. 한글과컴퓨터 설치 불필요.
HWPX(XML 기반)만 지원. HWP 5.x 바이너리는 Windows + 한컴 필요.

⚠️ python-hwpx는 Non-Commercial 라이선스. 개인 사용만 허용.

사용법:
    python write-hwpx-cross.py [template.hwpx] [output.hwpx]
"""

import sys
from pathlib import Path


def create_new_hwpx(output_path: str):
    """빈 HWPX 문서를 새로 생성하고 텍스트 삽입."""
    try:
        from hwpx import HwpxDocument
    except ImportError:
        raise ImportError(
            "python-hwpx 설치 필요: pip install python-hwpx"
        )

    # 빈 문서 생성
    doc = HwpxDocument.new()

    # 제목 추가
    doc.add_paragraph("자동 생성된 HWPX 보고서")

    # 본문 추가
    doc.add_paragraph("")
    doc.add_paragraph("1. 개요")
    doc.add_paragraph("  본 문서는 python-hwpx로 자동 생성되었습니다.")
    doc.add_paragraph("")
    doc.add_paragraph("2. 상세 내용")
    doc.add_paragraph("  HWPX 포맷은 XML + ZIP 구조로 크로스플랫폼 처리 가능.")

    # 표 추가 (간단 예시)
    # 실제 API는 python-hwpx 버전에 따라 다를 수 있음
    # doc.add_table(rows=3, cols=4)

    doc.save(output_path)
    print(f"✅ 새 HWPX 파일 생성: {output_path}")


def fill_template(template_path: str, output_path: str, replacements: dict):
    """템플릿 HWPX 파일에서 {{변수}} 치환."""
    try:
        from hwpx import HwpxDocument
    except ImportError:
        raise ImportError(
            "python-hwpx 설치 필요: pip install python-hwpx"
        )

    doc = HwpxDocument.open(template_path)

    # 각 변수 치환
    for key, value in replacements.items():
        placeholder = "{{" + key + "}}"
        doc.replace_all(placeholder, str(value))

    doc.save(output_path)
    print(f"✅ 템플릿 채움 완료: {output_path}")


def main():
    args = sys.argv[1:]

    if len(args) == 0:
        # 기본 동작: 새 파일 생성
        output = "output.hwpx"
        create_new_hwpx(output)
    elif len(args) == 2:
        # 템플릿 모드
        template, output = args

        if not Path(template).exists():
            print(f"❌ 템플릿 파일 없음: {template}", file=sys.stderr)
            sys.exit(1)

        # 예시 치환 데이터
        replacements = {
            "NAME": "홍길동",
            "DATE": "2026-04-15",
            "TITLE": "월간 보고서",
            "AUTHOR": "자동 생성",
        }

        fill_template(template, output, replacements)
    else:
        print("사용법:")
        print("  새 문서: python write-hwpx-cross.py")
        print("  템플릿: python write-hwpx-cross.py <template.hwpx> <output.hwpx>")
        sys.exit(1)


if __name__ == "__main__":
    main()
