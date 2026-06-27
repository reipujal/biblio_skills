#!/usr/bin/env python3
"""build_memory_index.py — genera/valida el índice MEMORY.md de un repo.

  python build_memory_index.py <repo>/docs/memory           # regenera MEMORY.md
  python build_memory_index.py <repo>/docs/memory --check    # falla si está desactualizado
                                                             # o hay ficheros mal formados

Escanea docs/memory/*.md (saltando MEMORY.md), lee su frontmatter, y emite MEMORY.md como
índice de punteros. No mantiene MEMORY.md a mano. Mismo patrón que scripts/build_index.py.
"""
import sys
from pathlib import Path

USAGE = """Uso:
  python build_memory_index.py <dir docs/memory>
  python build_memory_index.py <dir docs/memory> --check
  python build_memory_index.py --help

Genera o valida MEMORY.md escaneando memorias markdown con frontmatter.
"""

VALID_TYPES = {"user", "feedback", "project", "reference"}


def parse_frontmatter(md: Path) -> dict:
    text = md.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return {}
    end = text.find("\n---", 3)
    if end == -1:
        return {}
    data, key, in_metadata = {}, None, False
    for line in text[3:end].splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        if stripped == "metadata:":
            in_metadata = True
            key = None
            continue
        if line[:1].isspace() and key:
            data[key] += " " + line.strip()
            continue
        if line[:1].isspace() and in_metadata and ":" in stripped:
            k, _, v = stripped.partition(":")
            if k.strip() == "type":
                data["type"] = v.strip().strip('"').strip("'")
            continue
        in_metadata = False
        if ":" in line:
            k, _, v = line.partition(":")
            k, v = k.strip(), v.strip().strip('"').strip("'")
            if k in ("name", "description", "type"):
                data[k] = v
                key = k
            else:
                key = None
    return data


def collect(mem_dir: Path):
    entries, problems, seen = [], [], set()
    for md in sorted(mem_dir.glob("*.md")):
        if md.name == "MEMORY.md":
            continue
        fm = parse_frontmatter(md)
        name = fm.get("name", "")
        desc = fm.get("description", "")
        typ = fm.get("type", "")
        if not name:
            problems.append(f"{md.name}: falta 'name' en frontmatter")
            name = md.stem
        if not desc:
            problems.append(f"{md.name}: falta 'description'")
        if typ and typ not in VALID_TYPES:
            problems.append(f"{md.name}: type '{typ}' no válido {sorted(VALID_TYPES)}")
        if name in seen:
            problems.append(f"slug duplicado: {name}")
        seen.add(name)
        entries.append((name, desc, md.name))
    return entries, problems


def render(entries) -> str:
    lines = ["# Memory Index", "",
             "> Índice autogenerado por build_memory_index.py — no editar a mano.", ""]
    if not entries:
        lines.append("_(sin memorias todavía)_")
    for name, desc, fname in entries:
        lines.append(f"- [{name}]({fname}) — {desc}")
    return "\n".join(lines) + "\n"


def main(argv) -> int:
    if "--help" in argv or "-h" in argv:
        print(USAGE.strip())
        return 0
    unknown = [a for a in argv if a.startswith("-") and a != "--check"]
    if unknown:
        print(f"Argumento no reconocido: {unknown[0]}", file=sys.stderr)
        print(USAGE.strip(), file=sys.stderr)
        return 2
    args = [a for a in argv if not a.startswith("--")]
    check = "--check" in argv
    if not args:
        print(USAGE.strip(), file=sys.stderr)
        return 2
    mem_dir = Path(args[0])
    if not mem_dir.is_dir():
        print(f"No existe el directorio {mem_dir}", file=sys.stderr)
        return 1
    entries, problems = collect(mem_dir)
    new = render(entries)
    out = mem_dir / "MEMORY.md"

    if check:
        if problems:
            print("PROBLEMAS:", file=sys.stderr)
            for p in problems:
                print(f"  - {p}", file=sys.stderr)
        drift = not out.exists() or out.read_text(encoding="utf-8") != new
        if drift:
            print("MEMORY.md desactualizado: ejecuta build_memory_index.py.", file=sys.stderr)
        if problems or drift:
            return 1
        print(f"--check OK: {len(entries)} memorias, MEMORY.md al día.")
        return 0

    if problems:
        print("Aviso (se genera igualmente):", file=sys.stderr)
        for p in problems:
            print(f"  - {p}", file=sys.stderr)
    out.write_text(new, encoding="utf-8")
    print(f"MEMORY.md escrito con {len(entries)} memorias.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
