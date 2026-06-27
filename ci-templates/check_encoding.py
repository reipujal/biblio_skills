#!/usr/bin/env python3
"""Detecta ficheros de texto no-UTF-8 o con mojibake típico (ej. 'Ã±' por 'ñ').

Uso: python scripts/check_encoding.py <ficheros...>
Sale con codigo != 0 si encuentra problemas (apto para pre-commit).
Derivado de la regla de encoding del protocolo de colaboracion.
"""
import sys

USAGE = """Uso:
  python scripts/check_encoding.py <ficheros...>
  python scripts/check_encoding.py --help

Detecta ficheros no UTF-8 o con mojibake frecuente.
"""

# Secuencias de mojibake frecuentes al re-decodificar UTF-8 como latin-1.
MOJIBAKE = ("Ã±", "Ã³", "Ã©", "Ã­", "Ãº", "Ã¡", "Â¿", "Â¡", "â€")


def check(path: str) -> list[str]:
    problems: list[str] = []
    try:
        with open(path, "rb") as f:
            raw = f.read()
    except OSError:
        return problems
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError:
        problems.append(f"{path}: no es UTF-8 valido")
        return problems
    for token in MOJIBAKE:
        if token in text:
            problems.append(f"{path}: posible mojibake '{token}' (re-guardar como UTF-8)")
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
