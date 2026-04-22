#!/usr/bin/env python3
"""Extrai arquivos-chave do shell legado a partir do ZIP do Mini DayZ."""

from __future__ import annotations

import argparse
import pathlib
import zipfile

DEFAULT_FILES = (
    "Mini DayZ rpg/index.html",
    "Mini DayZ rpg/net-client.js",
    "Mini DayZ rpg/zoom.js",
)


def extract_files(zip_path: pathlib.Path, output_dir: pathlib.Path) -> list[pathlib.Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    extracted: list[pathlib.Path] = []

    with zipfile.ZipFile(zip_path) as zf:
        for item in DEFAULT_FILES:
            target = output_dir / pathlib.Path(item).name
            with zf.open(item) as src, target.open("wb") as dst:
                dst.write(src.read())
            extracted.append(target)

    return extracted


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Extrai index/net-client/zoom do pacote legado."
    )
    parser.add_argument(
        "zip_path",
        nargs="?",
        default="Mini DayZ rpg.zip",
        help="Caminho do arquivo ZIP de origem.",
    )
    parser.add_argument(
        "--output-dir",
        default="legacy-shell",
        help="Diretório de saída para os arquivos extraídos.",
    )
    args = parser.parse_args()

    zip_path = pathlib.Path(args.zip_path)
    output_dir = pathlib.Path(args.output_dir)

    files = extract_files(zip_path, output_dir)
    print(f"Extraídos {len(files)} arquivos para: {output_dir}")
    for f in files:
        print(f"- {f}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
