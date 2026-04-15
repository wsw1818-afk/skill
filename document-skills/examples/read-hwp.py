#!/usr/bin/env python3
"""
HWP 읽기 예시 — 크로스플랫폼, 한컴 불필요.

사용법:
    python read-hwp.py <input.hwp 또는 input.hwpx>

지원 형식: HWP 5.x, HWPX
"""

import sys
from pathlib import Path


def read_hwp_file(file_path: str) -> str:
    """HWP 또는 HWPX 파일을 읽어 텍스트 반환."""
    path = Path(file_path)

    if not path.exists():
        raise FileNotFoundError(f"파일이 존재하지 않음: {file_path}")

    suffix = path.suffix.lower()

    if suffix == ".hwp":
        # HWP 5.x 바이너리 → pyhwp 사용
        return read_hwp_binary(file_path)
    elif suffix == ".hwpx":
        # HWPX → python-hwpx 사용
        return read_hwpx(file_path)
    else:
        raise ValueError(f"지원하지 않는 형식: {suffix}")


def read_hwp_binary(file_path: str) -> str:
    """pyhwp로 HWP 5.x 텍스트 추출."""
    try:
        import pyhwp
    except ImportError:
        raise ImportError(
            "pyhwp가 설치되지 않음. 설치: pip install pyhwp"
        )

    # pyhwp CLI 도구 hwp5txt 호출 (가장 안정적)
    import subprocess

    result = subprocess.run(
        ["hwp5txt", file_path],
        capture_output=True,
        text=True,
        encoding="utf-8",
    )

    if result.returncode != 0:
        raise RuntimeError(f"hwp5txt 실행 실패: {result.stderr}")

    return result.stdout


def read_hwpx(file_path: str) -> str:
    """python-hwpx로 HWPX 내용 추출."""
    try:
        from hwpx import HwpxDocument
    except ImportError:
        raise ImportError(
            "python-hwpx가 설치되지 않음. 설치: pip install python-hwpx"
        )

    doc = HwpxDocument.open(file_path)

    # 모든 섹션의 텍스트 결합
    text_parts = []
    for section in doc.sections:
        for paragraph in section.paragraphs:
            text_parts.append(paragraph.text)

    return "\n".join(text_parts)


def main():
    if len(sys.argv) < 2:
        print("사용법: python read-hwp.py <file.hwp 또는 file.hwpx>")
        sys.exit(1)

    file_path = sys.argv[1]

    try:
        content = read_hwp_file(file_path)
        print("=" * 60)
        print(f"파일: {file_path}")
        print("=" * 60)
        print(content)
        print("=" * 60)
        print(f"총 {len(content)} 문자")
    except Exception as e:
        print(f"❌ 오류: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
