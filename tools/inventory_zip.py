#!/usr/bin/env python3
"""Gera inventário resumido de um arquivo ZIP para auditoria técnica inicial."""

from __future__ import annotations

import collections
import json
import os
import sys
import zipfile
from dataclasses import asdict, dataclass


@dataclass
class Inventory:
    archive: str
    total_files: int
    by_extension: dict[str, int]
    top_level_entries: list[str]


def build_inventory(zip_path: str) -> Inventory:
    with zipfile.ZipFile(zip_path) as zf:
        files = [name for name in zf.namelist() if not name.endswith("/")]

    ext_counter = collections.Counter(
        (os.path.splitext(name)[1].lower() or "<sem_ext>") for name in files
    )

    top_level = sorted({
        name.split("/")[1]
        for name in files
        if "/" in name and len(name.split("/")) > 1
    })

    return Inventory(
        archive=zip_path,
        total_files=len(files),
        by_extension=dict(ext_counter.most_common()),
        top_level_entries=top_level,
    )


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("Uso: tools/inventory_zip.py <arquivo.zip>", file=sys.stderr)
        return 1

    zip_path = argv[1]
    inventory = build_inventory(zip_path)
    print(json.dumps(asdict(inventory), ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
