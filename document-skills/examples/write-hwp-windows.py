#!/usr/bin/env python3
"""
Windows + 한컴오피스에서 HWP 5.x 바이너리 쓰기 예시 (pyhwpx).

⚠️ 이 스크립트는 Windows에서만 동작합니다.
⚠️ 한글과컴퓨터 오피스가 설치되어 있어야 합니다.
⚠️ pyhwpx는 한컴 공식 포럼에서 언급된 신뢰할 수 있는 라이브러리입니다.

사용법:
    python write-hwp-windows.py [output.hwp]
"""

import sys
import platform


def check_environment():
    """Windows + 한컴 환경 확인."""
    if platform.system() != "Windows":
        print("❌ 이 스크립트는 Windows 전용입니다.", file=sys.stderr)
        print(
            "Mac/Linux에서는 write-hwpx-cross.py를 사용하세요.",
            file=sys.stderr,
        )
        sys.exit(1)

    try:
        import win32com.client  # noqa
    except ImportError:
        print("❌ pywin32가 설치되지 않음", file=sys.stderr)
        print("설치: pip install pywin32", file=sys.stderr)
        sys.exit(1)

    try:
        import pyhwpx  # noqa
    except ImportError:
        print("❌ pyhwpx가 설치되지 않음", file=sys.stderr)
        print("설치: pip install pyhwpx", file=sys.stderr)
        sys.exit(1)


def create_hwp_report(output_path: str):
    """새 HWP 파일 생성 + 제목, 본문, 표 삽입 + 저장."""
    from pyhwpx import Hwp

    # 한컴 오피스 인스턴스 생성
    hwp = Hwp(new=True, visible=False)  # visible=True면 한컴이 눈에 보임

    try:
        # 1. 제목 삽입
        hwp.insert_text("자동 생성된 HWP 보고서")
        hwp.HAction.Run("BreakPara")  # 줄바꿈

        # 2. 본문 삽입
        hwp.insert_text("")
        hwp.HAction.Run("BreakPara")

        hwp.insert_text("1. 개요")
        hwp.HAction.Run("BreakPara")
        hwp.insert_text("  본 문서는 pyhwpx로 자동 생성되었습니다.")
        hwp.HAction.Run("BreakPara")

        hwp.insert_text("")
        hwp.HAction.Run("BreakPara")

        hwp.insert_text("2. 상세 내용")
        hwp.HAction.Run("BreakPara")
        hwp.insert_text("  한컴 COM 자동화로 HWP 5.x 바이너리를 직접 조작.")
        hwp.HAction.Run("BreakPara")

        # 3. 표 삽입 (3행 4열)
        hwp.insert_text("")
        hwp.HAction.Run("BreakPara")
        hwp.insert_text("3. 실적 표")
        hwp.HAction.Run("BreakPara")

        hwp.create_table(rows=3, cols=4)

        # 표 데이터 채우기 (예시)
        headers = ["항목", "1분기", "2분기", "3분기"]
        for col, header in enumerate(headers):
            hwp.put_field_text(f"cell_{0}_{col}", header)

        # 4. 저장
        hwp.save_as(output_path)
        print(f"✅ HWP 파일 생성 완료: {output_path}")

    finally:
        # 한컴 인스턴스 종료 (중요)
        hwp.quit()


def convert_hwp_to_pdf(hwp_path: str, pdf_path: str):
    """HWP → PDF 변환 (한컴 내장 기능 활용)."""
    from pyhwpx import Hwp

    hwp = Hwp(visible=False)
    try:
        hwp.open(hwp_path)
        hwp.save_as(pdf_path, format="PDF")
        print(f"✅ PDF 변환 완료: {pdf_path}")
    finally:
        hwp.quit()


def main():
    check_environment()

    args = sys.argv[1:]
    output = args[0] if args else "output.hwp"

    create_hwp_report(output)

    # 선택: PDF 변환도 시연
    if "--pdf" in args:
        pdf_output = output.replace(".hwp", ".pdf")
        convert_hwp_to_pdf(output, pdf_output)


if __name__ == "__main__":
    main()
