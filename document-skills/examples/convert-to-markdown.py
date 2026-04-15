#!/usr/bin/env python3
"""
통합 문서 → Markdown 변환 예시 (kordoc 활용).

지원 형식: HWP, HWPX, PDF, DOCX, XLSX, PPTX

사용법:
    python convert-to-markdown.py <input-file> [output.md]
    python convert-to-markdown.py --batch <input-dir> [output-dir]
"""

import sys
from pathlib import Path


def convert_to_markdown(input_path: str, output_path: str = None) -> str:
    """
    문서를 Markdown으로 변환.

    kordoc는 HWP/HWPX/PDF/DOCX/XLSX/PPTX를 통합 지원.
    """
    try:
        from kordoc import parse_document
    except ImportError:
        raise ImportError(
            "kordoc가 설치되지 않음. 설치: pip install kordoc"
        )

    markdown = parse_document(input_path)

    if output_path:
        Path(output_path).write_text(markdown, encoding="utf-8")
        print(f"✅ 저장됨: {output_path}")
    else:
        print(markdown)

    return markdown


def batch_convert(input_dir: str, output_dir: str = None):
    """디렉토리 내 모든 문서를 일괄 변환."""
    input_path = Path(input_dir)

    if not input_path.is_dir():
        raise ValueError(f"디렉토리가 아님: {input_dir}")

    output_path = Path(output_dir) if output_dir else input_path / "markdown"
    output_path.mkdir(parents=True, exist_ok=True)

    supported_ext = {".hwp", ".hwpx", ".pdf", ".docx", ".xlsx", ".pptx"}
    converted = 0
    failed = 0

    for file in input_path.iterdir():
        if file.suffix.lower() not in supported_ext:
            continue

        output_file = output_path / f"{file.stem}.md"

        try:
            convert_to_markdown(str(file), str(output_file))
            converted += 1
        except Exception as e:
            print(f"❌ 실패: {file.name} — {e}", file=sys.stderr)
            failed += 1

    print()
    print(f"📊 변환 완료: {converted}개 성공, {failed}개 실패")
    print(f"📁 출력 위치: {output_path}")


def main():
    args = sys.argv[1:]

    if not args:
        print("사용법:")
        print("  단일: python convert-to-markdown.py <file> [output.md]")
        print("  배치: python convert-to-markdown.py --batch <dir> [output-dir]")
        sys.exit(1)

    if args[0] == "--batch":
        if len(args) < 2:
            print("배치 모드는 디렉토리 경로 필요")
            sys.exit(1)
        input_dir = args[1]
        output_dir = args[2] if len(args) > 2 else None
        batch_convert(input_dir, output_dir)
    else:
        input_file = args[0]
        output_file = args[1] if len(args) > 1 else None
        convert_to_markdown(input_file, output_file)


if __name__ == "__main__":
    main()
