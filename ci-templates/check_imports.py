#!/usr/bin/env python3
"""Valida que todo @import en ficheros de gobierno apunta a un fichero existente.

Uso: python ci-templates/check_imports.py <ficheros...>
Sale con código != 0 si algún import está roto (apto para pre-commit).
"""
import os
import sys

USAGE = """Uso:
  python ci-templates/check_imports.py <ficheros...>
  python ci-templates/check_imports.py --help

Verifica que cada línea `@import <ruta>` apunta a un fichero que existe.
"""


def check(path: str) -> list[str]:
    problems: list[str] = []
    try:
        with open(path, encoding="utf-8") as f:
            lines = f.readlines()
    except OSError:
        return problems
    base = os.path.dirname(os.path.abspath(path))
    in_fence = False
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("```") or stripped.startswith("~~~"):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        if stripped.startswith("@import "):
            target = stripped[len("@import "):].strip()
            if not os.path.exists(os.path.join(base, target)):
                problems.append(f"{path}: import roto -> {target}")
    return problems


def main(argv: list[str]) -> int:
    if "--help" in argv or "-h" in argv:
        print(USAGE.strip())
        return 0
    if len(argv) == 1:
        print(USAGE.strip(), file=sys.stderr)
        return 2
    found: list[str] = []
    for path in argv[1:]:
        found.extend(check(path))
    for p in found:
        print(p, file=sys.stderr)
    return 1 if found else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
